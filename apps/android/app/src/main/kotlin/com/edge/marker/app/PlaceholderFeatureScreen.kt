package com.edge.marker.app

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import com.edge.marker.designsystem.MarkerCornerRadius
import com.edge.marker.designsystem.MarkerSpacing

@Composable
fun PlaceholderFeatureScreen(
    title: String,
    subtitle: String,
    highlights: List<String>,
    icon: ImageVector,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(MarkerSpacing.ScreenPadding),
        verticalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding),
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 2),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = MaterialTheme.colorScheme.primary,
            )
            Text(
                text = title,
                style = MaterialTheme.typography.headlineMedium,
            )
        }

        Text(
            text = subtitle,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(MarkerCornerRadius.Card),
        ) {
            Column(
                modifier = Modifier.padding(MarkerSpacing.ScreenPadding),
                verticalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 2),
            ) {
                highlights.forEach { highlight: String ->
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 2),
                        verticalAlignment = Alignment.Top,
                    ) {
                        Box(
                            modifier = Modifier.padding(top = MarkerSpacing.ScreenPadding / 3),
                        ) {
                            Text(
                                text = "•",
                                style = MaterialTheme.typography.bodyLarge,
                                color = MaterialTheme.colorScheme.primary,
                            )
                        }
                        Text(
                            modifier = Modifier.fillMaxWidth(),
                            text = highlight,
                            style = MaterialTheme.typography.bodyLarge,
                        )
                    }
                }
            }
        }
    }
}
