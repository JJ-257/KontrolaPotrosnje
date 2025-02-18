package com.kontrolapotrosnje.kontrolapotrosnje

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // 1. Aktiviramo (instaliramo) Android 12 Splash Screen
        val splashScreen = installSplashScreen()

        // 2. Tek onda pozivamo super
        super.onCreate(savedInstanceState)
        // Ovdje možete dodati i ostale stvari ako je potrebno...
    }
}

