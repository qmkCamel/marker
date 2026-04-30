package com.edge.marker.app

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.BarChart
import androidx.compose.material.icons.outlined.History
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.ui.graphics.vector.ImageVector

enum class AppDestination(
    val route: String,
    val title: String,
    val icon: ImageVector,
) {
    TODAY(
        route = "today",
        title = "Today",
        icon = Icons.Outlined.Home,
    ),
    HISTORY(
        route = "history",
        title = "History",
        icon = Icons.Outlined.History,
    ),
    STATISTICS(
        route = "statistics",
        title = "Statistics",
        icon = Icons.Outlined.BarChart,
    ),
    SETTINGS(
        route = "settings",
        title = "Settings",
        icon = Icons.Outlined.Settings,
    ),
}
