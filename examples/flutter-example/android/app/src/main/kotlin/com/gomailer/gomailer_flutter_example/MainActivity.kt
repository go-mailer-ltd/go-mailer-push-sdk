package com.gomailer.gomailer_flutter_example

import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		if (Build.VERSION.SDK_INT >= 33) {
			ActivityCompat.requestPermissions(
				this,
				arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
				/* requestCode */ 1001
			)
		}
	}
}
