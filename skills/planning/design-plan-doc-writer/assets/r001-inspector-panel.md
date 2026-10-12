# r001-inspector-panel

This example shows a design and development plan in the same requirement document. Requirement clarification is complete. The example ID is illustrative; increment the project's existing IDs for new requirements.

## Requirement Clarification

The user needs a collapsible auxiliary panel on the right side of the macOS paper detail view, with toolbar visibility control and switching between Notes and Chat placeholder panels. This round establishes only the UI containers and state structure; actual notes, networking, and model calls belong to later requirements. Acceptance focuses on visibility, panel switching, empty states, and stable layout of the tag bar at the bottom of the detail view.

## Design Document

### Core Features

#### Background

The current macOS main interface uses a three-column `NavigationSplitView`:

- Left: `MainSidebarView`
- Middle: `PaperListView`
- Right: `PaperDetailView`

The user wants a collapsible fourth column on the right of the main interface for auxiliary workflows related to the current paper. The target interaction follows the Xcode/Apple workbench style:

1. A button on the right side of the main toolbar shows and hides the fourth column.
2. The fourth column attaches to the right of the detail column without changing the left-side navigation semantics.
3. An icon-only segmented control at the top switches between subpanels.

Given the existing code structure and Apple's SwiftUI capabilities, use `NavigationSplitView + inspector` for this requirement rather than restructuring the main window into four actual split columns.

#### Goals

This requirement covers only the fourth-column UI foundation:

1. Add a collapsible right-side inspector to the macOS main window.
2. Add an inspector toggle button to the detail toolbar.
3. Establish a stable top panel switcher inside the inspector using an icon-only `Picker + .segmented`.
4. Build the inspector container, panel enum, and empty/selected-state UI skeleton to support future `Notes` and `Chat` integration.
5. Preserve the existing layout semantics of the `TagEditorBar` at the bottom of `PaperDetailView`: its width follows only detail content and does not include inspector width.

#### Scope Boundaries

##### In scope

- The inspector container on the right of the macOS main window and its visibility state.
- Panel switching UI at the top of the inspector.
- Inspector empty/placeholder states and column width constraints.
- An inspector toggle in the detail toolbar.
- View hierarchy and state model design, with APIs reserved for future panel integration.

##### Out of scope

- Data loading, list presentation, editing, and creation logic for `Notes`.
- Fetching, extracting, and caching paper content from arXiv HTML, and LLM conversations.
- Any business-level network requests, persistence writes, or model calls inside the inspector.
- Equivalent interaction adaptations for iOS.

### Implementation Flow

#### 1. Findings from the Current Implementation

##### 1.1 Main window structure

- `ArxivDailyReader/ContentView.swift`
  - `mainSplitView` uses `NavigationSplitView { sidebar } content: { list } detail: { detail }`.
  - The existing three columns have width constraints and use `.navigationSplitViewStyle(.balanced)`.
- `ArxivDailyReader/Views/PaperDetailView.swift`
  - The detail column already owns a toolbar.
  - `TagEditorBar` is attached at the bottom through `safeAreaInset(edge: .bottom)`.

##### 1.2 Apple platform capabilities

According to Apple's WWDC23 session `Inspectors in SwiftUI`:

1. An `inspector` can attach directly to the detail path of a `NavigationSplitView`.
2. A Boolean state can control inspector visibility.
3. An inspector supports independent column width configuration.
4. Inspector content can use system controls for toolbars and segmented switching.

The most suitable fourth-column structure is therefore:

- Keep the main structure as a three-column `NavigationSplitView`.
- Use an `inspector` for the fourth column.
- Build the inspector's panel switcher inside its content using `Picker + .segmented`.

#### 2. Target Structure

##### 2.1 Top-level container: `ContentView`

Add basic inspector state to `ContentView`:

- `isInspectorPresented: Bool`
- `selectedInspectorPanel: PaperInspectorPanel`

Recommended responsibilities:

1. `ContentView`, as the main window container, owns inspector visibility state.
2. `ContentView` passes the currently selected `PaperSummary?` to the inspector container.
3. Attach the inspector to the `detail` path so it semantically belongs to the current paper's details, not the sidebar or list.

Target structure:

- Keep the three-column `NavigationSplitView`.
- `PaperDetailView(...)`
  - Contains detail content and the bottom `TagEditorBar`.
  - Exposes an inspector toggle callback.
  - Has `.inspector(isPresented:)` attached by the outer or detail layer.

##### 2.2 Inspector container: `PaperInspectorView`

Add a dedicated inspector container view with these responsibilities:

1. Provide a fixed top panel-switching area.
2. Switch the content area based on `selectedInspectorPanel`.
3. Provide a shared empty state when `paper == nil`, instead of separate handling in each business panel.
4. Provide stable attachment points for future `Notes` and `Chat` features.

Suggested structure:

- Top: `Picker(selection:)`
  - `pickerStyle(.segmented)`
  - Icons only, with no visible text.
- Below: `Group` / `switch selectedInspectorPanel`
  - Show a shared empty state when `paper == nil`.
  - Show the selected panel's placeholder container when `paper != nil`.

##### 2.3 Panel enum: `PaperInspectorPanel`

Add a stable enum representing the currently selected fourth-column panel.

Initial cases:

- `.notes`
- `.chat`

Enum responsibilities:

1. Serve as the `Picker` selection value.
2. Centralize mappings for icons, `accessibilityIdentifier`, and future localized labels.
3. Provide a controlled extension point for panels, avoiding scattered hardcoded branches in views.

##### 2.4 Detail toolbar integration

Add an inspector toggle button to the macOS toolbar in `PaperDetailView`:

1. Position: place it in the existing right-side action group without proactively rearranging business buttons.
2. Purpose: control fourth-column visibility.
3. Interaction:
   - When the inspector is visible, clicking closes it.
   - When it is hidden, clicking opens it and preserves the last selected panel.

The user has explicitly confirmed that the current detail toolbar is not visually crowded, so this requirement does not rearrange existing icons to make room.

##### 2.5 `TagEditorBar` layout constraints

The current `TagEditorBar` sits at the bottom of `PaperDetailView` and belongs to detail content.

Preserve these requirements:

1. `TagEditorBar` stays attached below the detail column.
2. When the inspector opens, `TagEditorBar` continues to match detail width.
3. The inspector does not contain tag editing UI or change the safe-area attachment point of `TagEditorBar`.

The inspector must therefore exist as an additional column to the right of detail; do not wrap `PaperDetailView` itself inside inspector content.

#### 3. Suggested View Decomposition

##### 3.1 Suggested new view files

- `ArxivDailyReader/Views/PaperInspectorView.swift`
  - Inspector container and top segmented picker.
- `ArxivDailyReader/Views/PaperInspectorNotesPanel.swift`
  - Notes panel placeholder shell.
- `ArxivDailyReader/Views/PaperInspectorChatPanel.swift`
  - Chat panel placeholder shell.

At this stage, the `Notes` and `Chat` panels may remain placeholder skeletons. Extend their corresponding files for later features without crowding `ContentView` and `PaperDetailView`.

##### 3.2 State and dependency boundaries

Pass only this minimal context during the UI foundation stage:

- Current `paper: PaperSummary?`
- `selectedPanel`
- Inspector visibility

Do not introduce at this stage:

- Note repository reads or writes.
- arXiv HTML fetching.
- LLM streaming state.
- New asynchronous task orchestration.

#### 4. Column Width and Layout Strategy

##### 4.1 Inspector column width

Set independent inspector width constraints, with suggested values:

- `min`: around 280
- `ideal`: 320-360
- `max`: around 420

Design principles:

1. The `Notes` panel needs room for a readable list and input area.
2. The future `Chat` panel needs room for a message stream and composer, so it must not be too narrow.
3. Do not compress the detail reading area until it becomes unreadable.

Exact values may be adjusted during implementation, but the design requires explicit column widths rather than system defaults.

##### 4.2 Structural stability

Follow the repository's existing macOS layout stability constraints:

1. Keep the inspector container structure resident and control it through visibility state; avoid frequently creating and destroying nested subtrees during rapid state changes.
2. Keep a fixed top panel-switcher structure and switch only the content area.
3. Do not trigger persistence writes in layout paths.
4. If panel switching causes implicit animation jitter, first disable the relevant animation transaction at the inspector layer rather than changing interaction semantics.

#### 5. Connection to Future Features

##### 5.1 Future Notes panel integration

Later `Notes` work will add:

1. Loading the current paper's note list.
2. An entry point for adding notes.
3. Possible note editing and deletion.

This design requires:

- Establish the input shape, scrolling container, and tool-area skeleton of `PaperInspectorNotesPanel` now.
- Do not implement real data binding in this task.

##### 5.2 Future Chat panel integration

The technical direction for the later `Chat` panel is:

1. Do not embed an HTML page UI directly.
2. Use extracted paper content from the arXiv HTML version as LLM input context.
3. Make the panel a conversation UI, not an HTML browser.

This design requires:

- Reserve a layout skeleton with a message area, input area, and context status indicator in `PaperInspectorChatPanel`.
- Do not connect networking or the LLM in this task.

### i18n

#### New keys

Expected new namespaced keys:

- `content.inspector.toggle`
- `content.inspector.panel.notes`
- `content.inspector.panel.chat`
- `content.inspector.empty.title`
- `content.inspector.empty.description`
- `content.inspector.notes.placeholder`
- `content.inspector.chat.placeholder`

Even if the segmented picker uses icons without visible text, retain the corresponding localization keys for `help`, `accessibilityLabel`, and empty-state copy.

#### Placeholders

- No dynamic placeholders are expected in this requirement.

#### zh-Hans/en mappings

- `content.inspector.toggle`
  - zh-Hans: 打开或关闭辅助面板
  - en: Toggle Inspector
- `content.inspector.panel.notes`
  - zh-Hans: 笔记
  - en: Notes
- `content.inspector.panel.chat`
  - zh-Hans: 对话
  - en: Chat
- `content.inspector.empty.title`
  - zh-Hans: 未选择论文
  - en: No Paper Selected
- `content.inspector.empty.description`
  - zh-Hans: 选择一篇论文后可查看辅助面板内容。
  - en: Select a paper to view inspector content.
- `content.inspector.notes.placeholder`
  - zh-Hans: 笔记面板将在后续任务接入。
  - en: Notes panel will be connected in a follow-up task.
- `content.inspector.chat.placeholder`
  - zh-Hans: 对话面板将在后续任务接入。
  - en: Chat panel will be connected in a follow-up task.

#### Fallback strategy and affected areas

1. Put all user-visible text in `ArxivDailyReader/Resources/Localizable.xcstrings`.
2. When a language is missing, the corresponding control falls back to the catalog's default language.
3. Changes affect only the fourth-column UI in the macOS main window, leaving existing iOS pages unchanged.

### Test Cases

#### Build verification

1. The macOS Debug build passes:
   - `xcodebuild -scheme ArxivDailyReader -destination "platform=macOS,arch=arm64" -configuration Debug build`

#### Functional verification (manual)

1. The new detail toolbar button opens and closes the inspector.
2. The expanded inspector appears to the right of detail, preserving the semantics of the main window's three left columns.
3. An icon-only segmented picker appears at the top of the inspector.
4. Switching between `Notes` and `Chat` keeps the top switcher stable and changes content correctly.
5. The inspector shows a shared empty state when no paper is selected.
6. When the inspector is expanded, the bottom `TagEditorBar` still spans only the detail area.

#### Regression verification

1. Existing favorite, translation, summary, sharing, and other buttons in `PaperDetailView` retain their behavior.
2. Three-column width constraints in `NavigationSplitView` remain effective.
3. No persistence writes are added to render paths.
4. No hardcoded user-visible text is added.

## Development Plan

Related design: [Design Document](#design-document).

### Stage 1: Basic Inspector Container

#### Task #1: Establish top-level inspector state and attachment

**Status:** Designed

**Files:** Modify `ArxivDailyReader/ContentView.swift`

- Functionality: introduce fourth-column state in `ContentView` and attach the inspector to the detail path.
- Implementation notes:
  - Add `isInspectorPresented` and `selectedInspectorPanel`.
  - Preserve the existing three-column `NavigationSplitView` structure.
  - Explicitly configure inspector column widths.
- Expected validation: the build passes; the control shows and hides the right-side fourth column.

#### Task #2: Add the inspector container and panel switcher

**Status:** Designed

**Files:** Create `ArxivDailyReader/Views/PaperInspectorView.swift`

- Functionality: establish `PaperInspectorView` and its top icon-only segmented picker.
- Implementation notes:
  - Define the `PaperInspectorPanel` enum.
  - Use `Picker + .segmented` to switch between `notes` and `chat`.
  - Keep a fixed skeleton and switch only the content area.
- Expected validation: panel switching preserves structural stability and the correct selected state.

#### Task #3: Integrate the inspector toggle into the detail toolbar

**Status:** Designed

**Files:** Modify `ArxivDailyReader/Views/PaperDetailView.swift`

- Functionality: add a fourth-column visibility button to the macOS toolbar in `PaperDetailView`.
- Implementation notes:
  - Preserve existing toolbar grouping and visual layout without additional compression.
  - Provide localized `help` and `accessibilityLabel`, plus an `accessibilityIdentifier`, for the new button.
  - Connect it to `ContentView` state through a callback or binding.
- Expected validation: existing detail toolbar behavior does not regress; the new button reliably toggles the fourth column.

#### Task #4: Preserve the bottom TagEditorBar layout boundary

**Status:** Designed

**Files:** Verify `ArxivDailyReader/Views/PaperDetailView.swift`

- Functionality: verify that the bottom `TagEditorBar` continues to follow only detail width after inspector integration.
- Implementation notes:
  - Keep the inspector out of `PaperDetailView.safeAreaInset(edge: .bottom)`.
  - Check that detail and tag bar widths track correctly when expanding and collapsing the inspector.
- Expected validation: TagEditorBar does not extend beneath the inspector and remains stable in both empty and content states.

#### Task #5: Minimal localization and build verification

**Status:** Designed

**Files:** Modify `ArxivDailyReader/Resources/Localizable.xcstrings`

- Functionality: add the minimal i18n resources required by the UI foundation and run the macOS build.
- Implementation notes:
  - Add inspector-related String Catalog keys.
  - Run the macOS arm64 Debug build.
- Expected validation: the build passes with no new hardcoded user-visible text.

### Stage 2: Panel Skeletons and Future Integration Points

#### Task #6: Establish the Notes panel placeholder skeleton

**Status:** Designed

**Files:** Create `ArxivDailyReader/Views/PaperInspectorNotesPanel.swift`

- Functionality: provide a stable inspector subview shell for future paper-level note integration.
- Implementation notes:
  - Add `PaperInspectorNotesPanel`.
  - Provide a basic list, input, or placeholder layout without connecting real data.
  - Reserve an input parameter for the current paper context.
- Expected validation: switching to Notes shows stable placeholder UI with no data pipeline dependency.

#### Task #7: Establish the Chat panel placeholder skeleton

**Status:** Designed

**Files:** Create `ArxivDailyReader/Views/PaperInspectorChatPanel.swift`

- Functionality: provide a stable shell for future LLM conversations using arXiv HTML paper content as context.
- Implementation notes:
  - Add `PaperInspectorChatPanel`.
  - Reserve message, input, and context indicator areas.
  - Keep embedded HTML page UI, networking, and LLM integration out of this stage.
- Expected validation: switching to Chat shows stable placeholder UI with a structure suitable for later extension.

#### Task #8: Regression verification and plan updates

**Status:** Designed

**Files:** Verify `ArxivDailyReader/ContentView.swift`; Modify the Development Plan section of the current requirement document.

- Functionality: complete incremental validation of the fourth-column UI foundation and update plan status.
- Implementation notes:
  - Perform manual regression checks of the macOS main window.
  - Update tasks through `Designed -> Coding -> Testing -> Finished`.
  - Record requirements discovered outside the current scope in a follow-up plan instead of expanding this implementation.
- Expected validation: the fourth-column UI foundation is complete, while concrete Notes/Chat functionality remains scoped to later tasks.
