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

/** FlutterNativeContactPickerPlusPlugin */
class FlutterNativeContactPickerPlusPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var pendingResult: Result? = null
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
    if (requestCode != PICK_CONTACT) {
      return false
    }
    if (resultCode != RESULT_OK) {
      pendingResult?.success(null)
      pendingResult = null
      return true
    }

    data?.data?.let { contactUri ->
      val cursor = activity!!.contentResolver.query(contactUri, null, null, null, null)
      cursor?.use {
        it.moveToFirst()
        val number = it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))
        val fullName = it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
        val contact = HashMap<String, Any>()
        contact["fullName"] = fullName
        contact["phoneNumbers"] = listOf(number)
        pendingResult?.success(contact)
        pendingResult = null
        return@use true
      }
    }

    pendingResult?.success(null)
    pendingResult = null
    return true
  }
}
