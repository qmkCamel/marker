package com.edge.marker.app

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material.icons.outlined.Archive
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material.icons.outlined.ChevronRight
import androidx.compose.material.icons.outlined.RadioButtonUnchecked
import androidx.compose.material.icons.outlined.Restore
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.unit.dp
import com.edge.marker.designsystem.MarkerCornerRadius
import com.edge.marker.designsystem.MarkerSpacing
import com.edge.marker.domain.MarkerWeekday
import com.edge.marker.domain.StatisticsWindow
import com.edge.marker.domain.TrackerKind
import java.text.DateFormat
import java.util.Date

@Composable
fun TodayScreen(model: MarkerAppModel) {
    var presentedDraft: TrackerDraft? by remember { mutableStateOf(null) }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(MarkerSpacing.ScreenPadding),
        verticalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 1.5f),
    ) {
        item {
            ScreenHeader(
                title = "Today",
                actionLabel = "新增",
                actionIcon = Icons.Outlined.Add,
                onAction = {
                    presentedDraft = TrackerDraft.empty
                },
            )
        }

        item {
            TodayProgressCard(model = model)
        }

        if (model.todayItems.isEmpty()) {
            item {
                EmptyStateCard(
                    title = "今天很轻松",
                    description = "当前没有待追踪项目，或者你还没有创建追踪项。",
                    actionLabel = "创建第一个追踪项",
                    onAction = {
                        presentedDraft = TrackerDraft.empty
                    },
                )
            }
        } else {
            items(items = model.todayItems, key = { item -> item.id }) { item ->
                TodayTrackerRow(
                    item = item,
                    onToggle = { model.toggleEntry(item.tracker) },
                    onEdit = { presentedDraft = TrackerDraft(item.tracker) },
                )
            }
        }
    }

    presentedDraft?.let { draft ->
        TrackerEditorDialog(
            draft = draft,
            onSave = { updatedDraft ->
                model.saveTracker(updatedDraft)
                presentedDraft = null
            },
            onCancel = {
                presentedDraft = null
            },
        )
    }
}

@Composable
fun HistoryScreen(model: MarkerAppModel) {
    var selectedSection: HistoryDaySection? by remember { mutableStateOf(null) }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(MarkerSpacing.ScreenPadding),
        verticalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 1.5f),
    ) {
        item {
            ScreenHeader(title = "History")
        }

        if (model.historySections.isEmpty()) {
            item {
                EmptyStateCard(
                    title = "还没有历史记录",
                    description = "完成一次记录后，这里会显示每天的明细。",
                )
            }
        } else {
            items(items = model.historySections, key = { section -> section.id }) { section ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { selectedSection = section },
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(MarkerSpacing.ScreenPadding),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(4.dpValue),
                        ) {
                            Text(
                                text = section.dayKey.rawValue,
                                style = MaterialTheme.typography.titleMedium,
                            )
                            Text(
                                text = "完成 ${section.items.size} 项",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }

                        Icon(
                            imageVector = Icons.Outlined.ChevronRight,
                            contentDescription = "查看详情",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }

    selectedSection?.let { section ->
        HistoryDayDetailDialog(
            section = section,
            onDismiss = { selectedSection = null },
        )
    }
}

@Composable
fun StatisticsScreen(model: MarkerAppModel) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(MarkerSpacing.ScreenPadding),
        verticalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 1.5f),
    ) {
        ScreenHeader(title = "Statistics")

        StatisticsSummaryGrid(model = model)

        Text(
            text = "追踪项明细",
            style = MaterialTheme.typography.titleMedium,
        )

        if (model.statisticsSummary.trackerBreakdown.isEmpty()) {
            EmptyStateCard(
                title = "还没有统计数据",
                description = "先创建追踪项并完成几次记录。",
            )
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(12.dpValue)) {
                model.statisticsSummary.trackerBreakdown.forEach { item ->
                    Card(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(MarkerSpacing.ScreenPadding),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(10.dpValue)
                                    .background(
                                        color = MarkerPresentation.color(item.colorToken),
                                        shape = CircleShape,
                                    ),
                            )

                            Text(
                                modifier = Modifier
                                    .weight(1f)
                                    .padding(start = 12.dpValue),
                                text = item.trackerName,
                                style = MaterialTheme.typography.bodyLarge,
                            )

                            Text(
                                text = "${item.totalEntryCount} 次",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun SettingsScreen(model: MarkerAppModel) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(MarkerSpacing.ScreenPadding),
        verticalArrangement = Arrangement.spacedBy(MarkerSpacing.ScreenPadding / 1.5f),
    ) {
        ScreenHeader(title = "Settings")

        SettingsSectionCard(title = "偏好") {
            ChoiceChipGroup(
                title = "周起始日",
                options = MarkerWeekday.entries,
                selected = model.preferences.weekStartsOn,
                labelFor = { weekday -> weekday.shortTitle },
                onSelected = { weekday -> model.updateWeekStartsOn(weekday) },
            )

            ChoiceChipGroup(
                title = "统计窗口",
                options = listOf(
                    StatisticsWindow.SEVEN_DAYS,
                    StatisticsWindow.THIRTY_DAYS,
                    StatisticsWindow.NINETY_DAYS,
                ),
                selected = model.preferences.preferredStatisticsWindow,
                labelFor = { window -> window.title },
                onSelected = { window -> model.updateStatisticsWindow(window) },
            )
        }

        SettingsSectionCard(title = "管理") {
            if (model.archivedTrackers.isEmpty()) {
                Text(
                    text = "没有归档追踪项",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            } else {
                model.archivedTrackers.forEach { tracker ->
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(4.dpValue),
                        ) {
                            Text(
                                text = tracker.name,
                                style = MaterialTheme.typography.bodyLarge,
                            )
                            Text(
                                text = MarkerPresentation.scheduleDescription(tracker.schedule),
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }

                        TextButton(onClick = { model.restoreTracker(tracker) }) {
                            Icon(
                                imageVector = Icons.Outlined.Restore,
                                contentDescription = "恢复",
                            )
                            Text("恢复")
                        }
                    }
                }
            }
        }

        SettingsSectionCard(title = "关于") {
            LabeledLine(label = "应用名", value = "Marker")
            LabeledLine(label = "模式", value = "本地优先")
            LabeledLine(label = "同步", value = "暂未启用")
        }
    }
}

@Composable
private fun ScreenHeader(
    title: String,
    actionLabel: String? = null,
    actionIcon: androidx.compose.ui.graphics.vector.ImageVector? = null,
    onAction: (() -> Unit)? = null,
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            modifier = Modifier.weight(1f),
            text = title,
            style = MaterialTheme.typography.headlineMedium,
        )

        if (actionLabel != null && actionIcon != null && onAction != null) {
            TextButton(onClick = onAction) {
                Icon(imageVector = actionIcon, contentDescription = actionLabel)
                Text(actionLabel)
            }
        }
    }
}

@Composable
private fun TodayProgressCard(model: MarkerAppModel) {
    val completed = model.todayItems.count { item -> item.isCompleted }
    val total = model.todayItems.size
    val progress = if (total == 0) 0f else completed.toFloat() / total.toFloat()

    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(MarkerSpacing.ScreenPadding),
            verticalArrangement = Arrangement.spacedBy(12.dpValue),
        ) {
            Text(
                text = "今日进度",
                style = MaterialTheme.typography.titleMedium,
            )

            androidx.compose.material3.LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier.fillMaxWidth(),
            )

            Text(
                text = if (total == 0) "先创建追踪项，开始第一天记录。" else "已完成 $completed / $total",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun TodayTrackerRow(
    item: TodayTrackerItem,
    onToggle: () -> Unit,
    onEdit: () -> Unit,
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onEdit),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(MarkerSpacing.ScreenPadding),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = Modifier
                    .size(12.dpValue)
                    .background(
                        color = MarkerPresentation.color(item.tracker.colorToken),
                        shape = CircleShape,
                    ),
            )

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 12.dpValue),
                verticalArrangement = Arrangement.spacedBy(4.dpValue),
            ) {
                Text(
                    text = item.tracker.name,
                    style = MaterialTheme.typography.titleMedium,
                )
                Text(
                    text = item.weeklyProgressText?.let { progress ->
                        "频率：${MarkerPresentation.scheduleDescription(item.tracker.schedule)} · 本周 $progress"
                    } ?: "频率：${MarkerPresentation.scheduleDescription(item.tracker.schedule)}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                if (item.tracker.notes.isNotBlank()) {
                    Text(
                        text = item.tracker.notes,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            IconButton(onClick = onToggle) {
                Icon(
                    imageVector = if (item.isCompleted) Icons.Outlined.CheckCircle else Icons.Outlined.RadioButtonUnchecked,
                    contentDescription = if (item.isCompleted) "取消完成" else "标记完成",
                    tint = if (item.isCompleted) MarkerPresentation.color(item.tracker.colorToken) else MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

@Composable
private fun StatisticsSummaryGrid(model: MarkerAppModel) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dpValue)) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dpValue)) {
            SummaryCard(
                modifier = Modifier.weight(1f),
                title = "活跃追踪项",
                value = model.statisticsSummary.activeTrackerCount.toString(),
            )
            SummaryCard(
                modifier = Modifier.weight(1f),
                title = "累计记录",
                value = model.statisticsSummary.totalEntryCount.toString(),
            )
        }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dpValue)) {
            SummaryCard(
                modifier = Modifier.weight(1f),
                title = model.preferences.preferredStatisticsWindow.title + "完成率",
                value = if (model.statisticsSummary.currentWindowDueCount == 0) {
                    "--"
                } else {
                    String.format("%.0f%%", model.statisticsSummary.currentWindowCompletionRate * 100)
                },
            )
            SummaryCard(
                modifier = Modifier.weight(1f),
                title = "当前连胜",
                value = "${model.statisticsSummary.currentStreakDays} 天",
            )
        }
    }
}

@Composable
private fun SummaryCard(
    modifier: Modifier = Modifier,
    title: String,
    value: String,
) {
    Card(modifier = modifier) {
        Column(
            modifier = Modifier.padding(MarkerSpacing.ScreenPadding),
            verticalArrangement = Arrangement.spacedBy(8.dpValue),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = value,
                style = MaterialTheme.typography.headlineSmall,
            )
        }
    }
}

@Composable
private fun SettingsSectionCard(
    title: String,
    content: @Composable () -> Unit,
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(MarkerSpacing.ScreenPadding),
            verticalArrangement = Arrangement.spacedBy(12.dpValue),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
            )
            content()
        }
    }
}

@Composable
private fun <T> ChoiceChipGroup(
    title: String,
    options: List<T>,
    selected: T,
    labelFor: (T) -> String,
    onSelected: (T) -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dpValue)) {
        Text(
            text = title,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        options.chunked(3).forEach { rowItems ->
            Row(horizontalArrangement = Arrangement.spacedBy(8.dpValue)) {
                rowItems.forEach { option ->
                    FilterChip(
                        selected = option == selected,
                        onClick = { onSelected(option) },
                        label = { Text(labelFor(option)) },
                    )
                }
            }
        }
    }
}

@Composable
private fun LabeledLine(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth()) {
        Text(
            modifier = Modifier.weight(1f),
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}

@Composable
private fun EmptyStateCard(
    title: String,
    description: String,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null,
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(MarkerSpacing.ScreenPadding),
            verticalArrangement = Arrangement.spacedBy(12.dpValue),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
            )
            Text(
                text = description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            if (actionLabel != null && onAction != null) {
                Button(onClick = onAction) {
                    Text(actionLabel)
                }
            }
        }
    }
}

@Composable
private fun HistoryDayDetailDialog(
    section: HistoryDaySection,
    onDismiss: () -> Unit,
) {
    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = RoundedCornerShape(MarkerCornerRadius.Card),
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 560.dpValue)
                .padding(20.dpValue),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(MarkerSpacing.ScreenPadding),
                verticalArrangement = Arrangement.spacedBy(12.dpValue),
            ) {
                Text(
                    text = section.dayKey.rawValue,
                    style = MaterialTheme.typography.headlineSmall,
                )
                LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dpValue)) {
                    items(items = section.items, key = { item -> item.id }) { item ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(12.dpValue)
                                    .background(
                                        color = MarkerPresentation.color(item.colorToken),
                                        shape = CircleShape,
                                    ),
                            )
                            Column(
                                modifier = Modifier.padding(start = 12.dpValue),
                                verticalArrangement = Arrangement.spacedBy(4.dpValue),
                            ) {
                                Text(item.trackerName)
                                Text(
                                    text = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(item.recordedAtMillis)),
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                        }
                    }
                }
                TextButton(onClick = onDismiss, modifier = Modifier.align(Alignment.End)) {
                    Text("关闭")
                }
            }
        }
    }
}

@Composable
private fun TrackerEditorDialog(
    draft: TrackerDraft,
    onSave: (TrackerDraft) -> Unit,
    onCancel: () -> Unit,
) {
    var editedDraft: TrackerDraft by remember(draft.id, draft.existingTrackerId) { mutableStateOf(draft) }

    Dialog(onDismissRequest = onCancel) {
        Surface(
            shape = RoundedCornerShape(MarkerCornerRadius.Card),
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 720.dpValue)
                .padding(20.dpValue),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(MarkerSpacing.ScreenPadding),
                verticalArrangement = Arrangement.spacedBy(16.dpValue),
            ) {
                Text(
                    text = if (editedDraft.existingTrackerId == null) "新建追踪项" else "编辑追踪项",
                    style = MaterialTheme.typography.headlineSmall,
                )

                SettingsSectionCard(title = "基础信息") {
                    ChoiceChipGroup(
                        title = "类型",
                        options = TrackerKind.entries,
                        selected = editedDraft.kind,
                        labelFor = { kind -> kind.title },
                        onSelected = { kind -> editedDraft = editedDraft.copy(kind = kind) },
                    )

                    OutlinedTextField(
                        modifier = Modifier.fillMaxWidth(),
                        value = editedDraft.name,
                        onValueChange = { value -> editedDraft = editedDraft.copy(name = value) },
                        label = { Text("追踪项名称") },
                        singleLine = true,
                    )

                    OutlinedTextField(
                        modifier = Modifier.fillMaxWidth(),
                        value = editedDraft.notes,
                        onValueChange = { value -> editedDraft = editedDraft.copy(notes = value) },
                        label = { Text("备注") },
                        minLines = 2,
                    )
                }

                SettingsSectionCard(title = "颜色") {
                    TrackerDraft.availableColorTokens.chunked(4).forEach { rowItems ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dpValue),
                        ) {
                            rowItems.forEach { token ->
                                IconButton(
                                    onClick = { editedDraft = editedDraft.copy(colorToken = token) },
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(28.dpValue)
                                            .background(
                                                color = MarkerPresentation.color(token),
                                                shape = CircleShape,
                                            ),
                                        contentAlignment = Alignment.Center,
                                    ) {
                                        if (editedDraft.colorToken == token) {
                                            Text("✓", color = MaterialTheme.colorScheme.onPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SettingsSectionCard(title = "频率") {
                    ChoiceChipGroup(
                        title = "类型",
                        options = TrackerScheduleKind.entries.toList(),
                        selected = editedDraft.scheduleKind,
                        labelFor = { kind -> kind.title },
                        onSelected = { kind -> editedDraft = editedDraft.copy(scheduleKind = kind) },
                    )

                    when (editedDraft.scheduleKind) {
                        TrackerScheduleKind.DAILY -> {
                            Text(
                                text = "每天都算应完成",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                        TrackerScheduleKind.WEEKLY_ON_DAYS -> {
                            Column(verticalArrangement = Arrangement.spacedBy(8.dpValue)) {
                                Text(
                                    text = "选择星期",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                                MarkerWeekday.entries.chunked(3).forEach { rowItems ->
                                    Row(horizontalArrangement = Arrangement.spacedBy(8.dpValue)) {
                                        rowItems.forEach { weekday ->
                                            FilterChip(
                                                selected = editedDraft.selectedWeekdays.contains(weekday),
                                                onClick = {
                                                    editedDraft = editedDraft.copy(
                                                        selectedWeekdays = if (editedDraft.selectedWeekdays.contains(weekday)) {
                                                            editedDraft.selectedWeekdays - weekday
                                                        } else {
                                                            editedDraft.selectedWeekdays + weekday
                                                        },
                                                    )
                                                },
                                                label = { Text(weekday.shortTitle) },
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        TrackerScheduleKind.WEEKLY_QUOTA -> {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(12.dpValue),
                            ) {
                                OutlinedButton(
                                    onClick = {
                                        editedDraft = editedDraft.copy(
                                            weeklyQuotaTarget = maxOf(1, editedDraft.weeklyQuotaTarget - 1),
                                        )
                                    },
                                ) {
                                    Text("-")
                                }
                                Text("每周 ${editedDraft.weeklyQuotaTarget} 次")
                                OutlinedButton(
                                    onClick = {
                                        editedDraft = editedDraft.copy(
                                            weeklyQuotaTarget = editedDraft.weeklyQuotaTarget + 1,
                                        )
                                    },
                                ) {
                                    Text("+")
                                }
                            }
                        }
                    }
                }

                if (editedDraft.existingTrackerId != null) {
                    SettingsSectionCard(title = "状态") {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text(
                                modifier = Modifier.weight(1f),
                                text = "归档该追踪项",
                                style = MaterialTheme.typography.bodyLarge,
                            )
                            Switch(
                                checked = editedDraft.isArchived,
                                onCheckedChange = { checked ->
                                    editedDraft = editedDraft.copy(isArchived = checked)
                                },
                            )
                        }
                    }
                }

                editedDraft.validationMessage?.let { message ->
                    Text(
                        text = message,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.error,
                    )
                }

                HorizontalDivider()

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End,
                ) {
                    TextButton(onClick = onCancel) {
                        Text("取消")
                    }
                    Button(
                        onClick = { onSave(editedDraft) },
                        enabled = editedDraft.validationMessage == null,
                    ) {
                        Text("保存")
                    }
                }
            }
        }
    }
}

private val Int.dpValue get() = this.dp
private val Float.dpValue get() = this.dp
