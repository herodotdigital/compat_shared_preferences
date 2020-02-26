package com.goldapp.compat_shared_preferences

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.os.AsyncTask
import android.util.Base64
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.*
import java.math.BigInteger
import java.util.HashMap

class CompatSharedPreferencesMethodHandler(context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"
        private const val BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy"
        private const val DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"
    }

    private val preferences: SharedPreferences = context.getSharedPreferences(context.getString(R.string.flutter_shared_preferences_name) ?: "FlutterSharedPreferences", Context.MODE_PRIVATE)


    @SuppressLint("CommitPrefEdits")
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        try {
            when (call.method) {
                "setBool" -> commitAsync(preferences.edit().putBoolean(key, call.argument<Any>("value") as Boolean), result)
                "setDouble" -> {
                    val doubleValue: Double = (call.argument<Any>("value") as Number).toDouble()
                    val doubleValueStr = doubleValue.toString()
                    commitAsync(preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr), result)
                }
                "setInt" -> {
                    val number = call.argument<Number>("value")
                    if (number is BigInteger) {
                        commitAsync(
                                preferences
                                        .edit()
                                        .putString(key, BIG_INTEGER_PREFIX + number.toString(Character.MAX_RADIX)),
                                result)
                    } else {
                        commitAsync(preferences.edit().putLong(key, number!!.toLong()), result)
                    }
                }
                "setString" -> {
                    val value = call.argument<Any>("value") as String
                    if (value.startsWith(LIST_IDENTIFIER) || value.startsWith(BIG_INTEGER_PREFIX)) {
                        result.error(
                                "StorageError",
                                "This string cannot be stored as it clashes with special identifier prefixes.",
                                null)
                        return
                    }
                    commitAsync(preferences.edit().putString(key, value), result)
                }
                "setStringList" -> {
                    val list = call.argument<List<String>>("value")!!
                    commitAsync(
                            preferences.edit().putString(key, LIST_IDENTIFIER + encodeList(list)), result)
                }
                "commit" ->  // We've been committing the whole time.
                    result.success(true)
                "getAll" -> {
                    result.success(getAllPrefs())
                    return
                }
                "remove" -> commitAsync(preferences.edit().remove(key), result)
                "clear" -> {
                    val keySet: Set<String> = getAllPrefs().keys
                    val clearEditor = preferences.edit()
                    for (keyToDelete in keySet) {
                        clearEditor.remove(keyToDelete)
                    }
                    commitAsync(clearEditor, result)
                }
                else -> result.notImplemented()
            }
        } catch (e: IOException) {
            result.error("IOException encountered", call.method, e)
        }
    }

    private fun commitAsync(editor: SharedPreferences.Editor, result: MethodChannel.Result) {
        object : AsyncTask<Void?, Void?, Boolean?>() {
            override fun onPostExecute(value: Boolean?) {
                result.success(value)
            }

            override fun doInBackground(vararg params: Void?): Boolean? {
                return editor.commit()
            }
        }.execute()
    }

    @Throws(IOException::class)
    private fun decodeList(encodedList: String): List<String?> {
        var stream: ObjectInputStream? = null
        return try {
            stream = ObjectInputStream(ByteArrayInputStream(Base64.decode(encodedList, 0)))
            stream.readObject() as List<String?>
        } catch (e: ClassNotFoundException) {
            throw IOException(e)
        } finally {
            stream?.close()
        }
    }

    @Throws(IOException::class)
    private fun encodeList(list: List<String?>): String {
        var stream: ObjectOutputStream? = null
        return try {
            val byteStream = ByteArrayOutputStream()
            stream = ObjectOutputStream(byteStream)
            stream.writeObject(list)
            stream.flush()
            Base64.encodeToString(byteStream.toByteArray(), 0)
        } finally {
            stream?.close()
        }
    }

    @Throws(IOException::class)
    private fun getAllPrefs(): Map<String, Any?> {
        val allPrefs = preferences.all
        val filteredPrefs: MutableMap<String, Any?> = HashMap()
        for (key in allPrefs.keys) {
            var value = allPrefs[key]
            if (value is String) {
                val stringValue = value
                when {
                    stringValue.startsWith(LIST_IDENTIFIER) -> {
                        value = decodeList(stringValue.substring(LIST_IDENTIFIER.length))
                    }
                    stringValue.startsWith(BIG_INTEGER_PREFIX) -> {
                        val encoded: String = stringValue.substring(BIG_INTEGER_PREFIX.length)
                        value = BigInteger(encoded, Character.MAX_RADIX)
                    }
                    stringValue.startsWith(DOUBLE_PREFIX) -> {
                        val doubleStr: String = stringValue.substring(DOUBLE_PREFIX.length)
                        value = java.lang.Double.valueOf(doubleStr)
                    }
                }
            } else if (value is Set<*>) {
                val listValue: List<String?> = ArrayList()
                val success = preferences
                        .edit()
                        .remove(key)
                        .putString(key, LIST_IDENTIFIER + encodeList(listValue))
                        .commit()
                if (!success) {
                    throw IOException("Could not migrate set to list")
                }
                value = listValue
            }
            filteredPrefs[key] = value
        }
        return filteredPrefs
    }
}