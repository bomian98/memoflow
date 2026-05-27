## 1. Source Transfer Records

- [x] 1.1 Record `fix-desktop-inline-compose-resize` manual smoke items as transferred here without claiming platform verification.
- [x] 1.2 Record `unify-settings-ui-platform-experience` manual review items as transferred here without claiming visual verification.
- [x] 1.3 Record `fix-desktop-settings-nested-navigation` manual review items as transferred here without claiming native window verification.
- [x] 1.4 Record `add-desktop-share-task-window` macOS runtime and manual smoke items as transferred here without claiming share-window runtime verification.
- [x] 1.5 Record `move-macos-quick-actions-to-titlebar` macOS titlebar smoke and screenshot items as transferred here without claiming traffic-light verification.

## 2. Inline Compose Resize Smoke

- [ ] 2.1 From `fix-desktop-inline-compose-resize`: on Windows desktop, open the initial home memo list and drag the inline compose right/bottom/corner handles.
- [ ] 2.2 From `fix-desktop-inline-compose-resize`: on Windows desktop, navigate away and return to all memos via drawer; confirm resize still works.
- [ ] 2.3 From `fix-desktop-inline-compose-resize`: confirm resized layout persists after window close/reopen or route rebuild.
- [ ] 2.4 From `fix-desktop-inline-compose-resize`: confirm inline compose draft, attachment previews, and right-side memo preview are not lost during resize.
- [ ] 2.5 From `fix-desktop-inline-compose-resize`: if macOS resize is enabled in that batch, smoke macOS separately for traffic-light/titlebar safety and resize usability.

## 3. Settings UI Platform Review

- [ ] 3.1 From `unify-settings-ui-platform-experience`: open Settings -> Preferences and Settings -> Components on phone width.
- [ ] 3.2 From `unify-settings-ui-platform-experience`: open both pages on iPad/tablet width.
- [ ] 3.3 From `unify-settings-ui-platform-experience`: open both pages on macOS desktop width.
- [ ] 3.4 From `unify-settings-ui-platform-experience`: open both pages on Windows desktop width if available.
- [ ] 3.5 From `unify-settings-ui-platform-experience`: compare page title/chrome, background color, grouped sections, row density, toggle geometry and active color, navigation row trailing indicators, desktop bounded width, and dark mode.
- [ ] 3.6 From `unify-settings-ui-platform-experience`: confirm Components no longer looks like a separate card system from Preferences.
- [ ] 3.7 From `unify-settings-ui-platform-experience`: confirm no setting behavior changed while UI shell changed.

## 4. Settings Nested Navigation Review

- [ ] 4.1 From `fix-desktop-settings-nested-navigation`: on macOS, open settings home, navigate to `ComponentsSettingsScreen`, then open a child detail page.
- [ ] 4.2 From `fix-desktop-settings-nested-navigation`: confirm the child detail page shows `Back + Page Title`.
- [ ] 4.3 From `fix-desktop-settings-nested-navigation`: confirm title/back controls do not overlap macOS traffic lights.
- [ ] 4.4 From `fix-desktop-settings-nested-navigation`: click App-level back and confirm it returns to the parent settings page.
- [ ] 4.5 From `fix-desktop-settings-nested-navigation`: from a nested settings page, click the macOS red close button and confirm the settings window closes.
- [ ] 4.6 From `fix-desktop-settings-nested-navigation`: reopen settings and confirm it starts at settings home.
- [ ] 4.7 From `fix-desktop-settings-nested-navigation`: review one full-page share route on desktop and confirm it follows the same secondary page rules.
- [ ] 4.8 From `fix-desktop-settings-nested-navigation`: review phone/tablet navigation for migrated pages and confirm platform back behavior still feels native.

## 5. Share Task Window Runtime Smoke

- [ ] 5.1 From `add-desktop-share-task-window`: verify macOS share sub-window creation, IPC, and capture runtime before treating macOS share task windows as manually confirmed.
- [ ] 5.2 From `add-desktop-share-task-window`: verify macOS share sub-window can run the required share capture path, including `ShareCaptureInAppWebViewEngine` or its replacement.
- [ ] 5.3 From `add-desktop-share-task-window`: on macOS, trigger a text URL share and confirm a share task window opens when capability is enabled.
- [ ] 5.4 From `add-desktop-share-task-window`: confirm native close / `Cmd+W` cancels only the share task and leaves the main window alive.
- [ ] 5.5 From `add-desktop-share-task-window`: confirm successful save/link-only/media result closes the share window, foregrounds the main window, and opens the existing composer.
- [ ] 5.6 From `add-desktop-share-task-window`: confirm the share preview root has no App-owned generic close/cancel UI.
- [ ] 5.7 From `add-desktop-share-task-window`: confirm an internal share child page, such as video preview, can still use Back to return to the share task root.
- [ ] 5.8 From `add-desktop-share-task-window`: confirm capability-disabled platforms fall back to the old main-window share flow.

## 6. macOS Titlebar Smoke

- [ ] 6.1 From `move-macos-quick-actions-to-titlebar`: verify traffic lights remain visible, clickable, and keep system hover / inactive states.
- [ ] 6.2 From `move-macos-quick-actions-to-titlebar`: on macOS, smoke traffic lights, titlebar dragging, pill buttons, search/sort actions, and normal close/minimize/zoom behavior.
- [ ] 6.3 From `move-macos-quick-actions-to-titlebar`: screenshot-check light/dark/inactive titlebar states and confirm content does not overlap traffic lights or window edges.
