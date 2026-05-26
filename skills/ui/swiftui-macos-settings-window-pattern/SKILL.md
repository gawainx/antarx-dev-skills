---
name: swiftui-macos-settings-window-pattern
description: Build or refactor native-feeling Settings/Preferences windows for SwiftUI + macOS apps. Use when creating a dedicated Settings window scene, implementing sidebar-plus-detail Settings architecture with NavigationSplitView, stabilizing title/toolbar behavior, designing Form/Section/LabeledContent/TextField rows, choosing draft/save/immediate persistence patterns, and enforcing localization/accessibility/concurrency-safe settings workflows.
---

# swiftui-macos-settings-window-pattern

## Core principles
1. Use a dedicated `Window` scene for Settings instead of the `Settings {}` scene scaffold.
2. Route app Settings menu and shortcut to that window with `CommandGroup(replacing: .appSettings)` and `openWindow(id:)`.
3. Use `NavigationSplitView` as the root structure.
4. Keep sidebar width constrained and stable.
5. Normalize all detail panes with a shared container/modifier and shared layout tokens.
6. Stabilize title/toolbar geometry with a root title strategy and a principal toolbar placeholder when needed.
7. Prefer native SwiftUI controls (`Form`, `Section`, `List`, `Toolbar`, `sheet`, dialogs) over custom chrome.
8. Treat `Form`, `Section`, `LabeledContent`, and form controls as layout participants with their own labels, insets, and intrinsic sizing.

## Recommended architecture
- Implement `SettingsWindow` as split root (`NavigationSplitView`) with selected tab state.
- Implement `SettingsSidebarView` as a tab list backed by a stable enum.
- Implement `SettingsContentView` to switch detail pages by tab.
- Implement `SettingsDetailContainer` for shared background/layout modifiers and tokens.
- Implement domain pages (appearance, integrations, prompts, backup, about, or equivalent project domains).
- Implement `AppSettingsCommands` for menu and shortcut routing.

## Form field composition
Use this pattern for editable Settings rows:

```swift
LabeledContent("settings.retrieval.baseURL.label") {
    TextField(
        "",
        text: $baseURL,
        prompt: Text("settings.retrieval.baseURL.placeholder")
    )
    .textFieldStyle(.roundedBorder)
}
```

- Let `LabeledContent`, `Text`, or the surrounding `Form` row own the visible field label.
- Use an empty `TextField` title plus `prompt:` when the row already has a visible label.
- Put examples such as `https://host.example/v1` in placeholder text or secondary help text, not in persisted state.
- Keep URL/Base URL/API endpoint fields empty unless the app truly has a safe persisted default.
- Show each example once. Do not repeat the same sample in the field value, placeholder, and help text.
- Keep field labels, placeholders, help text, and accessibility labels localized with semantic keys.

Avoid these patterns:

```swift
TextField("https://host.example/v1", text: $baseURL)
```

```swift
LabeledContent("Base URL") {
    TextField("https://host.example/v1", text: $baseURL)
}
```

In SwiftUI forms, the first `TextField` argument is a title/label participant, not a neutral placeholder. Using it as an example inside an already-labeled row can make the row look prefilled, duplicate the label role, compress typed text, or create misleading alignment.

## Persistence interaction matrix
Choose one pattern per setting flow.

1. Draft state + explicit commit (`Done`)
- Use for complex forms with cross-field dependencies, async availability checks, or flows where cancel must discard edits.
- Keep local draft state (`@State`) and bootstrap once from persisted values.
- Persist only on explicit confirmation.

2. Local editor state + Save/Cancel (sheet editor)
- Use for standard editor forms.
- Mutate local/view-model state while editing.
- Persist only on Save.

3. Immediate apply
- Use for low-risk toggles with clear, reversible behavior.
- Persist directly on change.

## Concurrency and layout stability
- Keep heavy sync/merge/network/storage work off the main thread.
- Return UI state updates to main thread.
- Prefer fixed view structure with `disabled`/`opacity` over creating and destroying controls for high-frequency state changes.
- Disable animations for sensitive state transitions when layout churn is observed.
- Avoid persistence writes from render/layout paths.

## Localization and accessibility requirements
- Localize all user-visible strings via String Catalog.
- Use semantic localization keys (for example: `settings.<module>.<element>.<purpose>`).
- Localize accessibility labels.
- Keep UI test selectors stable via `accessibilityIdentifier` independent of display text.

## Implementation workflow
1. Create a dedicated Settings window scene and wire menu/shortcut routing.
2. Build split root with stable tab enum and sidebar list.
3. Add shared detail container/modifiers/tokens.
4. Implement domain pages using native controls.
5. Compose form fields with one visible label owner and placeholder/example text in `prompt:` or help text.
6. Apply the persistence interaction matrix per page.
7. Verify title/toolbar stability while switching tabs.
8. Run localization hardcoding checks for newly added UI text.

## Validation checklist
- [ ] Use a dedicated `Window` scene for Settings.
- [ ] Ensure Settings menu and shortcut open the custom Settings window.
- [ ] Use `NavigationSplitView` as root.
- [ ] Constrain sidebar width and keep it stable.
- [ ] Share a normalized detail container/background across pages.
- [ ] Keep title/toolbar stable during section switching.
- [ ] Ensure every editable form row has exactly one visible label owner.
- [ ] Use `TextField("", text: ..., prompt: Text(...))` for already-labeled rows.
- [ ] Keep examples out of persisted defaults unless they are real safe defaults.
- [ ] Apply the correct persistence pattern per page (draft/save/immediate).
- [ ] Keep heavy work off the main thread in settings flows.
- [ ] Avoid introducing hardcoded user-facing text.

## Anti-patterns
- Use `@MainActor` as a blanket workaround for concurrency isolation errors.
- Write persistence data in render/layout lifecycle hotspots.
- Insert/remove form controls frequently for fast-changing states.
- Scatter hardcoded display strings.
- Use `TextField("example value", text:)` as a placeholder inside an already-labeled form row.
- Pre-fill URL/API endpoint fields with example values just to show users the expected format.
- Replace native controls with heavy custom chrome without strong justification.
