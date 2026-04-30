package com.edge.marker.app

import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController

@Composable
fun MarkerApp(dependencies: MarkerAppDependencies) {
    val navController = rememberNavController()
    val currentBackStackEntry = navController.currentBackStackEntryAsState()
    val currentDestination = currentBackStackEntry.value?.destination
    val model = remember(dependencies.store) { MarkerAppModel(store = dependencies.store) }

    MaterialTheme {
        Scaffold(
            bottomBar = {
                NavigationBar {
                    AppDestination.entries.forEach { destination: AppDestination ->
                        val isSelected: Boolean = currentDestination?.hierarchy?.any { navDestination ->
                            navDestination.route == destination.route
                        } == true

                        NavigationBarItem(
                            selected = isSelected,
                            onClick = {
                                navController.navigate(destination.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = {
                                Icon(
                                    imageVector = destination.icon,
                                    contentDescription = destination.title,
                                )
                            },
                            label = { Text(destination.title) },
                        )
                    }
                }
            },
        ) { innerPadding ->
            NavHost(
                navController = navController,
                startDestination = AppDestination.TODAY.route,
            ) {
                composable(route = AppDestination.TODAY.route) {
                    MarkerAppScreenContainer(innerPadding = innerPadding) {
                        TodayScreen(model = model)
                    }
                }
                composable(route = AppDestination.HISTORY.route) {
                    MarkerAppScreenContainer(innerPadding = innerPadding) {
                        HistoryScreen(model = model)
                    }
                }
                composable(route = AppDestination.STATISTICS.route) {
                    MarkerAppScreenContainer(innerPadding = innerPadding) {
                        StatisticsScreen(model = model)
                    }
                }
                composable(route = AppDestination.SETTINGS.route) {
                    MarkerAppScreenContainer(innerPadding = innerPadding) {
                        SettingsScreen(model = model)
                    }
                }
            }
        }

        model.lastErrorMessage?.let { message ->
            AlertDialog(
                onDismissRequest = model::clearError,
                confirmButton = {
                    TextButton(onClick = model::clearError) {
                        Text("确定")
                    }
                },
                title = {
                    Text("发生错误")
                },
                text = {
                    Text(message)
                },
            )
        }
    }
}
