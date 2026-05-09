import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/markdown_editing.dart';
import '../../../core/memoflow_palette.dart';
import '../../../data/models/memo_location.dart';
import '../../../state/memos/memo_composer_state.dart';
import '../../../state/memos/memos_providers.dart';
import '../../../state/tags/tag_color_lookup.dart';
import '../../memos/compose_toolbar_shared.dart';
import '../../memos/tag_autocomplete.dart';
import '../../../i18n/strings.g.dart';

class NoteInputFullscreenCompose extends StatelessWidget {
  const NoteInputFullscreenCompose({
    super.key,
    required this.isDark,
    required this.sheetColor,
    required this.chipBg,
    required this.chipText,
    required this.chipDelete,
    required this.visibilityLabel,
    required this.visibilityIcon,
    required this.visibilityColor,
    required this.tagSuggestions,
    required this.highlightedTagSuggestionIndex,
    required this.tagColorLookup,
    required this.activeTagQuery,
    required this.editorTextStyle,
    required this.toolbarPreferences,
    required this.toolbarActions,
    required this.editorHintText,
    required this.attachmentPreview,
    required this.linkedMemos,
    required this.location,
    required this.locating,
    required this.busy,
    required this.controller,
    required this.editorFocusNode,
    required this.editorFieldKey,
    required this.autoFocus,
    required this.deferredProgress,
    required this.hasPendingDeferredShareVideoTasks,
    required this.hasAttachmentsForSend,
    required this.expandCollapseKey,
    required this.closeKey,
    required this.topToolbarKey,
    required this.bottomToolbarKey,
    required this.sendButtonKey,
    required this.visibilityButtonKey,
    required this.onCollapse,
    required this.onClose,
    required this.onVisibilityPressed,
    required this.onSubmitOrVoice,
    required this.onRemoveLinkedMemo,
    required this.onRequestLocation,
    required this.onClearLocation,
    required this.onTagHighlight,
    required this.onTagSelect,
    required this.onEditorKeyEvent,
  });

  final bool isDark;
  final Color sheetColor;
  final Color chipBg;
  final Color chipText;
  final Color chipDelete;
  final String visibilityLabel;
  final IconData visibilityIcon;
  final Color visibilityColor;
  final List<TagStat> tagSuggestions;
  final int highlightedTagSuggestionIndex;
  final TagColorLookup tagColorLookup;
  final ActiveTagQuery? activeTagQuery;
  final TextStyle editorTextStyle;
  final MemoToolbarPreferences toolbarPreferences;
  final List<MemoComposeToolbarActionSpec> toolbarActions;
  final String editorHintText;
  final Widget attachmentPreview;
  final List<MemoComposerLinkedMemo> linkedMemos;
  final MemoLocation? location;
  final bool locating;
  final bool busy;
  final TextEditingController controller;
  final FocusNode editorFocusNode;
  final GlobalKey editorFieldKey;
  final bool autoFocus;
  final double? deferredProgress;
  final bool hasPendingDeferredShareVideoTasks;
  final bool hasAttachmentsForSend;
  final Key expandCollapseKey;
  final Key closeKey;
  final Key topToolbarKey;
  final Key bottomToolbarKey;
  final Key sendButtonKey;
  final GlobalKey visibilityButtonKey;
  final VoidCallback onCollapse;
  final VoidCallback onClose;
  final VoidCallback onVisibilityPressed;
  final VoidCallback onSubmitOrVoice;
  final ValueChanged<String> onRemoveLinkedMemo;
  final VoidCallback onRequestLocation;
  final VoidCallback onClearLocation;
  final ValueChanged<int> onTagHighlight;
  final void Function(ActiveTagQuery query, TagStat tag) onTagSelect;
  final FocusOnKeyEventCallback onEditorKeyEvent;

  @override
  Widget build(BuildContext context) {
    final background = isDark
        ? MemoFlowPalette.backgroundDark
        : MemoFlowPalette.backgroundLight;
    final borderColor = isDark
        ? MemoFlowPalette.borderDark
        : MemoFlowPalette.borderLight;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isDark ? 4 : 2,
          sigmaY: isDark ? 4 : 2,
        ),
        child: ColoredBox(
          color: background.withValues(alpha: 0.96),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                color: sheetColor,
                child: Column(
                  children: [
                    _FullscreenHeader(
                      isDark: isDark,
                      sheetColor: sheetColor,
                      collapseKey: expandCollapseKey,
                      closeKey: closeKey,
                      busy: busy,
                      onCollapse: onCollapse,
                      onClose: onClose,
                    ),
                    Divider(height: 1, color: borderColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            attachmentPreview,
                            NoteInputLinkedMemoChips(
                              linkedMemos: linkedMemos,
                              chipBg: chipBg,
                              chipText: chipText,
                              chipDelete: chipDelete,
                              busy: busy,
                              onRemove: onRemoveLinkedMemo,
                            ),
                            NoteInputLocationState(
                              location: location,
                              locating: locating,
                              chipBg: chipBg,
                              chipText: chipText,
                              chipDelete: chipDelete,
                              busy: busy,
                              onRequestLocation: onRequestLocation,
                              onClearLocation: onClearLocation,
                            ),
                            Expanded(
                              child: _FullscreenEditor(
                                controller: controller,
                                editorFocusNode: editorFocusNode,
                                editorFieldKey: editorFieldKey,
                                autoFocus: autoFocus,
                                editorTextStyle: editorTextStyle,
                                editorHintText: editorHintText,
                                isDark: isDark,
                                activeTagQuery: activeTagQuery,
                                tagSuggestions: tagSuggestions,
                                tagColorLookup: tagColorLookup,
                                highlightedTagSuggestionIndex:
                                    highlightedTagSuggestionIndex,
                                onTagHighlight: onTagHighlight,
                                onTagSelect: onTagSelect,
                                onEditorKeyEvent: onEditorKeyEvent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: borderColor),
                    _FullscreenBottomToolbar(
                      isDark: isDark,
                      sheetColor: sheetColor,
                      preferences: toolbarPreferences,
                      actions: toolbarActions,
                      topRowKey: topToolbarKey,
                      bottomRowKey: bottomToolbarKey,
                      visibilityLabel: visibilityLabel,
                      visibilityIcon: visibilityIcon,
                      visibilityColor: visibilityColor,
                      visibilityButtonKey: visibilityButtonKey,
                      sendButtonKey: sendButtonKey,
                      busy: busy,
                      deferredProgress: deferredProgress,
                      hasPendingDeferredShareVideoTasks:
                          hasPendingDeferredShareVideoTasks,
                      hasAttachmentsForSend: hasAttachmentsForSend,
                      controller: controller,
                      onVisibilityPressed: onVisibilityPressed,
                      onSubmitOrVoice: onSubmitOrVoice,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenHeader extends StatelessWidget {
  const _FullscreenHeader({
    required this.isDark,
    required this.sheetColor,
    required this.collapseKey,
    required this.closeKey,
    required this.busy,
    required this.onCollapse,
    required this.onClose,
  });

  final bool isDark;
  final Color sheetColor;
  final Key collapseKey;
  final Key closeKey;
  final bool busy;
  final VoidCallback onCollapse;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      color: sheetColor,
      child: Row(
        children: [
          IconButton(
            key: closeKey,
            tooltip: context.t.strings.legacy.msg_close,
            onPressed: busy ? null : onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            splashRadius: 16,
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const Spacer(),
          IconButton(
            key: collapseKey,
            tooltip: context.t.strings.legacy.msg_restore_window,
            onPressed: busy ? null : onCollapse,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            splashRadius: 16,
            icon: Icon(
              Icons.fullscreen_exit_rounded,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenBottomToolbar extends StatelessWidget {
  const _FullscreenBottomToolbar({
    required this.isDark,
    required this.sheetColor,
    required this.preferences,
    required this.actions,
    required this.topRowKey,
    required this.bottomRowKey,
    required this.visibilityLabel,
    required this.visibilityIcon,
    required this.visibilityColor,
    required this.visibilityButtonKey,
    required this.sendButtonKey,
    required this.busy,
    required this.deferredProgress,
    required this.hasPendingDeferredShareVideoTasks,
    required this.hasAttachmentsForSend,
    required this.controller,
    required this.onVisibilityPressed,
    required this.onSubmitOrVoice,
  });

  final bool isDark;
  final Color sheetColor;
  final MemoToolbarPreferences preferences;
  final List<MemoComposeToolbarActionSpec> actions;
  final Key topRowKey;
  final Key bottomRowKey;
  final String visibilityLabel;
  final IconData visibilityIcon;
  final Color visibilityColor;
  final GlobalKey visibilityButtonKey;
  final Key sendButtonKey;
  final bool busy;
  final double? deferredProgress;
  final bool hasPendingDeferredShareVideoTasks;
  final bool hasAttachmentsForSend;
  final TextEditingController controller;
  final VoidCallback onVisibilityPressed;
  final VoidCallback onSubmitOrVoice;

  @override
  Widget build(BuildContext context) {
    final hasTopActions = _hasVisibleToolbarActionsForRow(
      preferences: preferences,
      actions: actions,
      row: MemoToolbarRow.top,
    );
    final hasBottomActions = _hasVisibleToolbarActionsForRow(
      preferences: preferences,
      actions: actions,
      row: MemoToolbarRow.bottom,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      color: sheetColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTopActions)
                  NoteInputFullscreenToolbarStrip(
                    isDark: isDark,
                    preferences: preferences,
                    actions: actions,
                    row: MemoToolbarRow.top,
                    rowKey: topRowKey,
                  ),
                if (hasTopActions && hasBottomActions)
                  const SizedBox(height: 2),
                if (hasBottomActions)
                  NoteInputFullscreenToolbarStrip(
                    isDark: isDark,
                    preferences: preferences,
                    actions: actions,
                    row: MemoToolbarRow.bottom,
                    rowKey: bottomRowKey,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NoteInputFullscreenVisibilityButton(
                isDark: isDark,
                visibilityLabel: visibilityLabel,
                visibilityIcon: visibilityIcon,
                visibilityColor: visibilityColor,
                visibilityButtonKey: visibilityButtonKey,
                busy: busy,
                onPressed: onVisibilityPressed,
              ),
              const SizedBox(height: 2),
              NoteInputFullscreenSendButton(
                key: sendButtonKey,
                isDark: isDark,
                busy: busy,
                deferredProgress: deferredProgress,
                hasPendingDeferredShareVideoTasks:
                    hasPendingDeferredShareVideoTasks,
                hasAttachmentsForSend: hasAttachmentsForSend,
                controller: controller,
                onPressed: onSubmitOrVoice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NoteInputFullscreenToolbarStrip extends StatelessWidget {
  const NoteInputFullscreenToolbarStrip({
    super.key,
    required this.isDark,
    required this.preferences,
    required this.actions,
    required this.row,
    required this.rowKey,
  });

  final bool isDark;
  final MemoToolbarPreferences preferences;
  final List<MemoComposeToolbarActionSpec> actions;
  final MemoToolbarRow row;
  final Key rowKey;

  @override
  Widget build(BuildContext context) {
    final rowActions = _visibleToolbarActionsForRow(
      preferences: preferences,
      actions: actions,
      row: row,
    );
    if (rowActions.isEmpty) {
      return const SizedBox.shrink();
    }

    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final disabledColor = iconColor.withValues(alpha: 0.45);

    Widget buildActionButton(MemoComposeToolbarActionSpec action) {
      final tooltip =
          action.label ?? action.id.resolveLabel(context, preferences);
      final actionIcon = action.icon ?? action.id.resolveIcon(preferences);
      return IconButton(
        key: action.buttonKey,
        tooltip: tooltip,
        onPressed: action.enabled ? action.onPressed : null,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 30, height: 30),
        splashRadius: 16,
        icon: Icon(
          actionIcon,
          size: 18,
          color: action.enabled ? iconColor : disabledColor,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        key: rowKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rowActions.length; i++) ...[
            buildActionButton(rowActions[i]),
            if (i != rowActions.length - 1) const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}

class NoteInputFullscreenVisibilityButton extends StatelessWidget {
  const NoteInputFullscreenVisibilityButton({
    super.key,
    required this.isDark,
    required this.visibilityLabel,
    required this.visibilityIcon,
    required this.visibilityColor,
    required this.visibilityButtonKey,
    required this.busy,
    required this.onPressed,
  });

  final bool isDark;
  final String visibilityLabel;
  final IconData visibilityIcon;
  final Color visibilityColor;
  final GlobalKey visibilityButtonKey;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.t.strings.legacy.msg_visibility_2(
        visibilityLabel: visibilityLabel,
      ),
      child: InkResponse(
        key: visibilityButtonKey,
        onTap: busy ? null : onPressed,
        radius: 17,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(visibilityIcon, size: 16, color: visibilityColor),
        ),
      ),
    );
  }
}

class NoteInputFullscreenSendButton extends StatelessWidget {
  const NoteInputFullscreenSendButton({
    super.key,
    required this.isDark,
    required this.busy,
    required this.deferredProgress,
    required this.hasPendingDeferredShareVideoTasks,
    required this.hasAttachmentsForSend,
    required this.controller,
    required this.onPressed,
  });

  final bool isDark;
  final bool busy;
  final double? deferredProgress;
  final bool hasPendingDeferredShareVideoTasks;
  final bool hasAttachmentsForSend;
  final TextEditingController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonEnabled = !busy && !hasPendingDeferredShareVideoTasks;
    final buttonColor = buttonEnabled
        ? MemoFlowPalette.primary
        : Theme.of(context).colorScheme.outline;
    return Tooltip(
      message: context.t.strings.legacy.msg_create_memo,
      child: InkResponse(
        onTap: buttonEnabled ? onPressed : null,
        radius: 17,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (deferredProgress != null)
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: deferredProgress,
                    strokeWidth: 2,
                    color: MemoFlowPalette.primary,
                    backgroundColor: MemoFlowPalette.primary.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
              Center(
                child: busy
                    ? SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: buttonColor,
                        ),
                      )
                    : ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (context, value, _) {
                          final hasText = value.text.trim().isNotEmpty;
                          final showSend = hasText || hasAttachmentsForSend;
                          return Icon(
                            showSend ? Icons.send_rounded : Icons.graphic_eq,
                            size: showSend ? 17 : 18,
                            color: buttonColor,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteInputLinkedMemoChips extends StatelessWidget {
  const NoteInputLinkedMemoChips({
    super.key,
    required this.linkedMemos,
    required this.chipBg,
    required this.chipText,
    required this.chipDelete,
    required this.busy,
    required this.onRemove,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  final List<MemoComposerLinkedMemo> linkedMemos;
  final Color chipBg;
  final Color chipText;
  final Color chipDelete;
  final bool busy;
  final ValueChanged<String> onRemove;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (linkedMemos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: linkedMemos
            .map(
              (memo) => InputChip(
                label: Text(
                  memo.label,
                  style: TextStyle(fontSize: 12, color: chipText),
                ),
                backgroundColor: chipBg,
                deleteIconColor: chipDelete,
                onDeleted: busy ? null : () => onRemove(memo.name),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class NoteInputLocationState extends StatelessWidget {
  const NoteInputLocationState({
    super.key,
    required this.location,
    required this.locating,
    required this.chipBg,
    required this.chipText,
    required this.chipDelete,
    required this.busy,
    required this.onRequestLocation,
    required this.onClearLocation,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  final MemoLocation? location;
  final bool locating;
  final Color chipBg;
  final Color chipText;
  final Color chipDelete;
  final bool busy;
  final VoidCallback onRequestLocation;
  final VoidCallback onClearLocation;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (locating) {
      return Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              context.t.strings.legacy.msg_locating,
              style: TextStyle(fontSize: 12, color: chipText),
            ),
          ],
        ),
      );
    }
    final currentLocation = location;
    if (currentLocation == null) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          avatar: Icon(Icons.place_outlined, size: 16, color: chipText),
          label: Text(
            currentLocation.displayText(fractionDigits: 6),
            style: TextStyle(fontSize: 12, color: chipText),
          ),
          backgroundColor: chipBg,
          deleteIconColor: chipDelete,
          onPressed: busy ? null : onRequestLocation,
          onDeleted: busy ? null : onClearLocation,
        ),
      ),
    );
  }
}

class _FullscreenEditor extends StatelessWidget {
  const _FullscreenEditor({
    required this.controller,
    required this.editorFocusNode,
    required this.editorFieldKey,
    required this.autoFocus,
    required this.editorTextStyle,
    required this.editorHintText,
    required this.isDark,
    required this.activeTagQuery,
    required this.tagSuggestions,
    required this.tagColorLookup,
    required this.highlightedTagSuggestionIndex,
    required this.onTagHighlight,
    required this.onTagSelect,
    required this.onEditorKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode editorFocusNode;
  final GlobalKey editorFieldKey;
  final bool autoFocus;
  final TextStyle editorTextStyle;
  final String editorHintText;
  final bool isDark;
  final ActiveTagQuery? activeTagQuery;
  final List<TagStat> tagSuggestions;
  final TagColorLookup tagColorLookup;
  final int highlightedTagSuggestionIndex;
  final ValueChanged<int> onTagHighlight;
  final void Function(ActiveTagQuery query, TagStat tag) onTagSelect;
  final FocusOnKeyEventCallback onEditorKeyEvent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: KeyedSubtree(
            key: editorFieldKey,
            child: Focus(
              canRequestFocus: false,
              onKeyEvent: onEditorKeyEvent,
              child: TextField(
                key: const ValueKey<String>('note-input-fullscreen-text-field'),
                controller: controller,
                focusNode: editorFocusNode,
                autofocus: autoFocus,
                inputFormatters: const [SmartEnterTextInputFormatter()],
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                style: editorTextStyle,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: editorHintText,
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF666666)
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (editorFocusNode.hasFocus &&
            activeTagQuery != null &&
            tagSuggestions.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: TagAutocompleteOverlay(
                editorKey: editorFieldKey,
                value: controller.value,
                textStyle: editorTextStyle,
                tags: tagSuggestions,
                tagColors: tagColorLookup,
                highlightedIndex: highlightedTagSuggestionIndex,
                onHighlight: onTagHighlight,
                onSelect: (tag) => onTagSelect(activeTagQuery!, tag),
              ),
            ),
          ),
      ],
    );
  }
}

bool _hasVisibleToolbarActionsForRow({
  required MemoToolbarPreferences preferences,
  required List<MemoComposeToolbarActionSpec> actions,
  required MemoToolbarRow row,
}) {
  return _visibleToolbarActionsForRow(
    preferences: preferences,
    actions: actions,
    row: row,
  ).isNotEmpty;
}

List<MemoComposeToolbarActionSpec> _visibleToolbarActionsForRow({
  required MemoToolbarPreferences preferences,
  required List<MemoComposeToolbarActionSpec> actions,
  required MemoToolbarRow row,
}) {
  final actionMap = <MemoToolbarItemId, MemoComposeToolbarActionSpec>{
    for (final action in actions) action.id: action,
  };
  final supportedItems = actions
      .where((action) => action.supported)
      .map((action) => action.id)
      .toSet();
  return preferences
      .visibleItemIdsForRow(row, supportedItems: supportedItems)
      .map((id) => actionMap[id])
      .whereType<MemoComposeToolbarActionSpec>()
      .toList(growable: false);
}
