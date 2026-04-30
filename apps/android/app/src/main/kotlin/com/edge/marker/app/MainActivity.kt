package com.edge.marker.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent

class MainActivity : ComponentActivity() {
    private val dependencies: MarkerAppDependencies by lazy(LazyThreadSafetyMode.NONE) {
        MarkerAppDependencies.live(context = this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MarkerApp(dependencies = dependencies)
        }
    }
}
