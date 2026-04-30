package com.edge.marker.app

import android.content.Context
import com.edge.marker.data.MarkerDataModule
import com.edge.marker.data.MarkerLocalStore

data class MarkerAppDependencies(
    val supportedBoundaryCount: Int,
    val store: MarkerLocalStore,
) {
    companion object {
        fun live(context: Context): MarkerAppDependencies = MarkerAppDependencies(
            supportedBoundaryCount = MarkerDataModule.supportedBoundaries.size,
            store = MarkerLocalStore.live(context = context),
        )
    }
}
