import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/drawer_navigation.dart';
import '../../state/memos/compose_draft_provider.dart';
import '../home/app_drawer.dart';
import '../home/app_drawer_destination_builder.dart';
import '../home/home_navigation_host.dart';
import '../notifications/notifications_screen.dart';
import 'draft_box_screen.dart';
import 'note_input_sheet.dart';

class DraftBoxNavigationScreen extends ConsumerStatefulWidget {
  const DraftBoxNavigationScreen({
    super.key,
    this.presentation = HomeScreenPresentation.standalone,
    this.embeddedNavigationHost,
  });

  final HomeScreenPresentation presentation;
  final HomeEmbeddedNavigationHost? embeddedNavigationHost;

  @override
  ConsumerState<DraftBoxNavigationScreen> createState() =>
      _DraftBoxNavigationScreenState();
}

class _DraftBoxNavigationScreenState
    extends ConsumerState<DraftBoxNavigationScreen> {
  final _screenKey = GlobalKey();
  var _openingDraft = false;

  void _navigateDrawer(AppDrawerDestination destination) {
    final host = widget.embeddedNavigationHost;
    if (host != null) {
      host.handleDrawerDestination(context, destination);
      return;
    }
    closeDrawerThenPushReplacement(
      context,
      buildDrawerDestinationScreen(context: context, destination: destination),
    );
  }

  void _openNotifications() {
    final host = widget.embeddedNavigationHost;
    if (host != null) {
      host.handleOpenNotifications(context);
      return;
    }
    closeDrawerThenPushReplacement(context, const NotificationsScreen());
  }

  Future<void> _handleDraftSelected(String draftUid) async {
    final normalizedUid = draftUid.trim();
    if (_openingDraft || normalizedUid.isEmpty) return;
    setState(() => _openingDraft = true);
    await NoteInputSheet.show(context, initialDraftUid: normalizedUid);
    if (!mounted) return;
    ref.invalidate(composeDraftsProvider);
    setState(() => _openingDraft = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraftBoxScreen(
      key: _screenKey,
      selected: AppDrawerDestination.draftBox,
      showDrawer: true,
      onSelect: _navigateDrawer,
      onOpenNotifications: _openNotifications,
      presentation: widget.presentation,
      embeddedNavigationHost: widget.embeddedNavigationHost,
      onDraftSelected: (draftUid) => unawaited(_handleDraftSelected(draftUid)),
    );
  }
}
