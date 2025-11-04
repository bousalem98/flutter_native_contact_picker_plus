package com.mohamedbousalem.flutter_native_contact_picker_plus

import androidx.annotation.NonNull
import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import java.util.HashMap
import android.net.Uri
import android.util.Log


/** FlutterNativeContactPickerPlusPlugin */
class FlutterNativeContactPickerPlusPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var pendingResult: Result? = null
  private var selectPhoneNumber: Boolean = false
  private val PICK_CONTACT = 2015

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_contact_picker_plus")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "selectContact" -> {
        if (pendingResult != null) {
          pendingResult!!.error("multiple_requests", "Cancelled by a second request.", null)
          pendingResult = null
        }
        pendingResult = result

        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
        activity?.startActivityForResult(intent, PICK_CONTACT)
      }
      "selectPhoneNumber" -> {
        pendingResult = result
        selectPhoneNumber = true
        val intent = Intent(Intent.ACTION_PICK).apply {
            type = ContactsContract.CommonDataKinds.Phone.CONTENT_TYPE
        }
        try {
          activity?.startActivityForResult(intent, PICK_CONTACT)
        } catch (e: Exception) {
          result.error("ERROR", "Failed to start phone picker: ${e.message}", null)
        }
      }
      "selectContacts" ->  result.error("NOT_SUPPORTED", "Multiple contact selection is not supported on Android", null)
      
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
    this.activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    this.activity = null
  }
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode != PICK_CONTACT) return false
    if (resultCode != RESULT_OK) {
        pendingResult?.success(null)
        pendingResult = null
        return true
    }

    data?.data?.let { contactUri ->
        val cursor = activity!!.contentResolver.query(contactUri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val contact = HashMap<String, Any?>()

                // Safe helper
                fun getStringSafe(cursor: android.database.Cursor, column: String): String? {
                    val index = cursor.getColumnIndex(column)
                    return if (index >= 0) cursor.getString(index) else null
                }
                fun getIntSafe(cursor: android.database.Cursor, column: String): Int? {
                    val index = cursor.getColumnIndex(column)
                    return if (index >= 0) cursor.getInt(index) else null
                }

                val contactId = getStringSafe(it, ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
                val lookupKey = getStringSafe(it, ContactsContract.CommonDataKinds.Phone.LOOKUP_KEY)
                val fullName = getStringSafe(it, ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                val number = getStringSafe(it, ContactsContract.CommonDataKinds.Phone.NUMBER)
                val photoUri = getStringSafe(it, ContactsContract.CommonDataKinds.Phone.PHOTO_URI)
                val phoneType = getIntSafe(it, ContactsContract.CommonDataKinds.Phone.TYPE) ?: -1

                contact.apply {
                    put("fullName", fullName)
                    put("selectedPhoneNumber", number)
                    put("phoneNumbers", listOfNotNull(number))
                    put("contactId", contactId)
                    put("lookupKey", lookupKey)
                    put(
                        "phoneType", when (phoneType) {
                            ContactsContract.CommonDataKinds.Phone.TYPE_HOME -> "home"
                            ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE -> "mobile"
                            ContactsContract.CommonDataKinds.Phone.TYPE_WORK -> "work"
                            else -> "other"
                        }
                    )

                    // Default empty fields
                    put("emailAddresses", emptyList<Map<String, String>>())
                    put("postalAddresses", emptyList<Map<String, String>>())
                    put("homePhoneNumber", null)
                    put("mobilePhoneNumber", null)
                    put("workPhoneNumber", null)
                    put("websiteURLs", emptyList<String>())
                    put("organizationInfo", null)
                    put("birthday", null)
                    put("notes", null)
                    put("avatar", null)
                }

                if (photoUri != null) {
                    try {
                        activity?.contentResolver?.openInputStream(Uri.parse(photoUri))?.use { stream ->
                            val bytes = stream.readBytes()
                            contact["avatar"] =
                                android.util.Base64.encodeToString(bytes, android.util.Base64.NO_WRAP)
                        }
                    } catch (e: Exception) {
                        Log.w("ContactPicker", "Failed to read avatar: ${e.message}")
                    }
                }

                // Continue with other processing
                processEmails(contact, contactId)
                processAddresses(contact, contactId)
                processPhoneNumbers(contact, contactId)
                processOrganization(contact, contactId)
                processBirthday(contact, contactId)
                processNotes(contact, contactId)
                processWebsites(contact, contactId)

                pendingResult?.success(contact)
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
            return true
        }
    }


    pendingResult?.success(null)
    pendingResult = null
    return true
}

private fun processEmails(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        val emails = mutableListOf<Map<String, String>>()
        activity?.contentResolver?.query(
            ContactsContract.CommonDataKinds.Email.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.Email.ADDRESS,
                ContactsContract.CommonDataKinds.Email.TYPE
            ),
            "${ContactsContract.CommonDataKinds.Email.CONTACT_ID} = ?",
            arrayOf(contactId),
            null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                emails.add(mapOf(
                    "email" to (cursor.getString(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.Email.ADDRESS)) ?: ""),
                    "label" to when (cursor.getInt(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.Email.TYPE))) {
                        ContactsContract.CommonDataKinds.Email.TYPE_HOME -> "home"
                        ContactsContract.CommonDataKinds.Email.TYPE_WORK -> "work"
                        ContactsContract.CommonDataKinds.Email.TYPE_MOBILE -> "mobile"
                        else -> "other"
                    }
                ))
            }
        }
        contact["emailAddresses"] = emails
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Emails require READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read emails: ${e.message}")
    }
}

private fun processAddresses(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        val addresses = mutableListOf<Map<String, String>>()
        activity?.contentResolver?.query(
            ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.StructuredPostal.STREET,
                ContactsContract.CommonDataKinds.StructuredPostal.CITY,
                ContactsContract.CommonDataKinds.StructuredPostal.REGION,
                ContactsContract.CommonDataKinds.StructuredPostal.POSTCODE,
                ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY,
                ContactsContract.CommonDataKinds.StructuredPostal.TYPE
            ),
            "${ContactsContract.CommonDataKinds.StructuredPostal.CONTACT_ID} = ?",
            arrayOf(contactId),
            null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                addresses.add(mapOf(
                    "street" to (cursor.getString(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.StructuredPostal.STREET)) ?: ""),
                    "city" to (cursor.getString(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.StructuredPostal.CITY)) ?: ""),
                    "state" to (cursor.getString(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.StructuredPostal.REGION)) ?: ""),
                    "postalCode" to (cursor.getString(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.StructuredPostal.POSTCODE)) ?: ""),
                    "country" to (cursor.getString(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY)) ?: ""),
                    "label" to when (cursor.getInt(cursor.getColumnIndexOrThrow(
                        ContactsContract.CommonDataKinds.StructuredPostal.TYPE))) {
                        ContactsContract.CommonDataKinds.StructuredPostal.TYPE_HOME -> "home"
                        ContactsContract.CommonDataKinds.StructuredPostal.TYPE_WORK -> "work"
                        else -> "other"
                    }
                ))
            }
        }
        contact["postalAddresses"] = addresses
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Addresses require READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read addresses: ${e.message}")
    }
}

private fun processOrganization(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        val orgInfo = mutableMapOf<String, String>()
        activity?.contentResolver?.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.Organization.COMPANY,
                ContactsContract.CommonDataKinds.Organization.TITLE
            ),
            "${ContactsContract.Data.CONTACT_ID} = ? AND ${ContactsContract.Data.MIMETYPE} = ?",
            arrayOf(
                contactId,
                ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE
            ),
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                orgInfo["company"] = cursor.getString(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Organization.COMPANY)) ?: ""
                orgInfo["jobTitle"] = cursor.getString(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Organization.TITLE)) ?: ""
            }
        }
        if (orgInfo.isNotEmpty()) {
            contact["organizationInfo"] = orgInfo
        }
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Organization info requires READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read organization info: ${e.message}")
    }
}

private fun processBirthday(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        activity?.contentResolver?.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(ContactsContract.CommonDataKinds.Event.START_DATE),
            "${ContactsContract.Data.CONTACT_ID} = ? AND ${ContactsContract.Data.MIMETYPE} = ?",
            arrayOf(
                contactId,
                ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE
            ),
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                contact["birthday"] = cursor.getString(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Event.START_DATE))
            }
        }
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Birthday requires READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read birthday: ${e.message}")
    }
}

private fun processNotes(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        activity?.contentResolver?.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(ContactsContract.CommonDataKinds.Note.NOTE),
            "${ContactsContract.Data.CONTACT_ID} = ? AND ${ContactsContract.Data.MIMETYPE} = ?",
            arrayOf(
                contactId,
                ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE
            ),
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                contact["notes"] = cursor.getString(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Note.NOTE))
            }
        }
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Notes require READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read notes: ${e.message}")
    }
}

private fun processWebsites(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        val websites = mutableListOf<String>()
        activity?.contentResolver?.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(ContactsContract.CommonDataKinds.Website.URL),
            "${ContactsContract.Data.CONTACT_ID} = ? AND ${ContactsContract.Data.MIMETYPE} = ?",
            arrayOf(
                contactId,
                ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE
            ),
            null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                websites.add(cursor.getString(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Website.URL)) ?: "")
            }
        }
        contact["websiteURLs"] = websites
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Websites require READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read websites: ${e.message}")
    }
}

private fun processPhoneNumbers(contact: HashMap<String, Any?>, contactId: String?) {
    try {
        activity?.contentResolver?.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.Phone.NUMBER,
                ContactsContract.CommonDataKinds.Phone.TYPE
            ),
            "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
            arrayOf(contactId),
            null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val phoneNumber = cursor.getString(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Phone.NUMBER))
                val phoneType = cursor.getInt(cursor.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Phone.TYPE))
                
                when (phoneType) {
                    ContactsContract.CommonDataKinds.Phone.TYPE_HOME -> {
                        if (contact["homePhoneNumber"] == null) contact["homePhoneNumber"] = phoneNumber
                    }
                    ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE -> {
                        if (contact["mobilePhoneNumber"] == null) contact["mobilePhoneNumber"] = phoneNumber
                    }
                    ContactsContract.CommonDataKinds.Phone.TYPE_WORK -> {
                        if (contact["workPhoneNumber"] == null) contact["workPhoneNumber"] = phoneNumber
                    }
                }
            }
        }
    } catch (e: SecurityException) {
        Log.w("ContactPicker", "Phone numbers require READ_CONTACTS permission")
    } catch (e: Exception) {
        Log.w("ContactPicker", "Failed to read phone numbers: ${e.message}")
    }
}


}