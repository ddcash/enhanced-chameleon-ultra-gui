package com.ddcash.enhanced_chameleon_ultra_gui

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.hardware.usb.UsbManager
import android.hardware.usb.UsbDevice
import android.content.Intent
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.app.PendingIntent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "chameleon_ultra"
    private lateinit var methodChannel: MethodChannel
    private var nfcAdapter: NfcAdapter? = null
    private var usbManager: UsbManager? = null
    
    companion object {
        private const val TAG = "ChameleonUltra"
        private const val USB_PERMISSION = "com.ddcash.enhanced_chameleon_ultra_gui.USB_PERMISSION"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize native platform bridge
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    initializeHardware()
                    result.success(true)
                }
                "connect" -> {
                    val port = call.argument<String>("port") ?: "auto"
                    val baudRate = call.argument<Int>("baudRate") ?: 115200
                    connectToDevice(port, baudRate, result)
                }
                "disconnect" -> {
                    disconnectFromDevice(result)
                }
                "sendCommand" -> {
                    val command = call.argument<String>("command")
                    val timeout = call.argument<Int>("timeout") ?: 5000
                    if (command != null) {
                        sendCommandToDevice(command, timeout, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Command cannot be null", null)
                    }
                }
                "getAvailablePorts" -> {
                    getAvailablePorts(result)
                }
                "autoDetectDevice" -> {
                    autoDetectDevice(result)
                }
                "getDeviceStatus" -> {
                    getDeviceStatus(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Initialize hardware components
        initializeHardware()
    }
    
    private fun initializeHardware() {
        try {
            // Initialize NFC adapter
            nfcAdapter = NfcAdapter.getDefaultAdapter(this)
            
            // Initialize USB manager
            usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
            
            Log.d(TAG, "Hardware initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize hardware: ${e.message}")
        }
    }
    
    private fun connectToDevice(port: String, baudRate: Int, result: MethodChannel.Result) {
        try {
            // Mock connection for development
            Log.d(TAG, "Connecting to device on port: $port at $baudRate baud")
            
            // Simulate connection delay
            Thread.sleep(1000)
            
            // For now, return success for mock implementation
            result.success(true)
            
            // Notify Flutter about successful connection
            methodChannel.invokeMethod("onConnectionEstablished", mapOf(
                "port" to port,
                "baudRate" to baudRate
            ))
            
        } catch (e: Exception) {
            Log.e(TAG, "Connection failed: ${e.message}")
            result.error("CONNECTION_FAILED", e.message, null)
        }
    }
    
    private fun disconnectFromDevice(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Disconnecting from device")
            
            // Mock disconnection
            result.success(null)
            
            // Notify Flutter about disconnection
            methodChannel.invokeMethod("onConnectionLost", null)
            
        } catch (e: Exception) {
            Log.e(TAG, "Disconnection failed: ${e.message}")
            result.error("DISCONNECTION_FAILED", e.message, null)
        }
    }
    
    private fun sendCommandToDevice(command: String, timeout: Int, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Sending command: $command")
            
            // Mock command execution
            val response = when {
                command.startsWith("hw version") -> "Chameleon Ultra firmware 2.0.0"
                command.startsWith("hf search") -> "14a card found! UID: 04689571fa5c64"
                command.startsWith("lf search") -> "EM410x ID: 1234567890"
                else -> "Command executed successfully"
            }
            
            // Simulate processing delay
            Thread.sleep(200)
            
            result.success(response)
            
            // Notify Flutter about received data
            methodChannel.invokeMethod("onDataReceived", mapOf(
                "data" to response
            ))
            
        } catch (e: Exception) {
            Log.e(TAG, "Command execution failed: ${e.message}")
            result.error("COMMAND_FAILED", e.message, null)
        }
    }
    
    private fun getAvailablePorts(result: MethodChannel.Result) {
        try {
            val ports = mutableListOf<String>()
            
            // Check for USB devices
            usbManager?.let { manager ->
                val deviceList = manager.deviceList
                for ((_, device) in deviceList) {
                    ports.add("USB:${device.deviceName}")
                }
            }
            
            // Add common serial ports
            ports.addAll(listOf(
                "/dev/ttyUSB0",
                "/dev/ttyUSB1",
                "/dev/ttyACM0",
                "/dev/ttyACM1"
            ))
            
            result.success(ports)
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get available ports: ${e.message}")
            result.error("PORT_ENUMERATION_FAILED", e.message, null)
        }
    }
    
    private fun autoDetectDevice(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Auto-detecting Chameleon Ultra device")
            
            // Mock auto-detection
            Thread.sleep(2000)
            
            // Return first available port for mock
            result.success("/dev/ttyUSB0")
            
        } catch (e: Exception) {
            Log.e(TAG, "Auto-detection failed: ${e.message}")
            result.error("AUTO_DETECT_FAILED", e.message, null)
        }
    }
    
    private fun getDeviceStatus(result: MethodChannel.Result) {
        try {
            val status = mapOf(
                "firmware_version" to "2.0.0",
                "hardware_version" to "2.0",
                "device_serial" to "CU-123456789ABC",
                "battery_level" to 85,
                "charging" to false,
                "usb_connected" to true,
                "ble_available" to true,
                "ble_connected" to false,
                "active_slot" to 1,
                "slots_used" to 3,
                "total_slots" to 8
            )
            
            result.success(status)
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get device status: ${e.message}")
            result.error("STATUS_FAILED", e.message, null)
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Handle NFC intents
        handleNfcIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNfcIntent(intent)
    }
    
    private fun handleNfcIntent(intent: Intent) {
        if (NfcAdapter.ACTION_TAG_DISCOVERED == intent.action ||
            NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            
            val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
            tag?.let {
                Log.d(TAG, "NFC tag detected: ${it.id.joinToString("") { "%02x".format(it) }}")
                
                // Notify Flutter about NFC tag
                methodChannel.invokeMethod("onNfcTagDetected", mapOf(
                    "uid" to it.id.joinToString("") { "%02x".format(it) },
                    "techList" to it.techList.toList()
                ))
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        
        // Enable NFC foreground dispatch
        nfcAdapter?.let { adapter ->
            val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            val pendingIntent = PendingIntent.getActivity(
                this, 0, intent, PendingIntent.FLAG_MUTABLE
            )
            
            adapter.enableForegroundDispatch(this, pendingIntent, null, null)
        }
    }
    
    override fun onPause() {
        super.onPause()
        
        // Disable NFC foreground dispatch
        nfcAdapter?.disableForegroundDispatch(this)
    }
}