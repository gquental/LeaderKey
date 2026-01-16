# LeaderKey - Spec-Driven Development Guidelines

## 1. Project Overview & Context
**LeaderKey** is a native macOS utility that brings "leader key" functionality (popularized by editors like Vim) to the system level. It captures keystroke sequences to execute configured commands, displaying a HUD or window to guide the user.

### Technology Stack
- **Language:** Swift 5+
- **Platform:** macOS (Targeting recent macOS versions)
- **Frameworks:**
  - **AppKit:** Core application lifecycle, window management (`NSWindow`), status bar items (`NSStatusItem`), and event handling.
  - **SwiftUI:** Used for modern view components and layouts where applicable (hybrid architecture).
  - **Foundation:** Configuration parsing (JSON), file management.
- **Architecture:** MVC/MVVM hybrid.
  - **Core Logic:** `CommandRunner`, `KeyCapture`, `UserConfig`.
  - **UI:** `MainWindow`, `StatusItem`, `Themes`.
- **Testing:** XCTest (`Leader KeyTests`).

## 2. Table of Contents
*This section is updated every time a new specification is added.*

| Index | Spec File | Description | Status |
|-------|-----------|-------------|--------|
| 001 | [Modifier Mode](001_modifier_mode.md) | Hold modifiers (e.g. HyperKey) to show window. | Implemented |

## 3. Spec Generation Guidelines
When creating a new specification (`.md` file) in this `specs/` directory, strict adherence to the project's existing conventions and architecture is required.

### Workflow & Maintenance
1.  **Update the Table of Contents:** Before or after creating the spec, add a new entry to the table in this `README.md`.
2.  **Spec Content:** Ensure the `.md` file matches the structure below.
3.  **Implementation Plan:** Generate the `_implementation_plan.md` file simultaneously.

### Spec File Structure
Each Spec file (e.g., `001_feature_name.md`) must contain:

1.  **Title & Summary:** A concise explanation of the feature or refactor.
2.  **Context:** How this fits into the current `Leader Key` ecosystem.
3.  **User Stories:** specific "As a user, I want..." statements.
4.  **Functional Requirements:** Detailed behavior description.
5.  **Technical Design:**
    - **Files to Modify:** List existing files (e.g., `Leader Key/AppDelegate.swift`) and new files needed.
    - **Data Models:** Structs/Classes changes.
    - **UI Components:** SwiftUI Views or AppKit NSViewControllers changes.
6.  **Edge Cases & Error Handling:** What happens if config is invalid? What if permissions are missing?

## 3. The Implementation Plan Rule (Mandatory)
**CRITICAL:** For every spec generated (e.g., `specs/001_new_feature.md`), you **MUST** generate a corresponding Implementation Plan file in the same directory.

**Naming Convention:**
- Spec: `specs/[name].md`
- Plan: `specs/[name]_implementation_plan.md`

**Plan Content Format:**
The implementation plan must be a checklist of actionable tasks using Markdown checkboxes (`- [ ]`). It should be granular enough to be followed step-by-step.

**Example Plan Structure:**
```markdown
# Implementation Plan - [Feature Name]

## Phase 1: Core Logic
- [ ] Create `NewModel.swift` struct to handle [data].
- [ ] Add unit tests in `Leader KeyTests/NewModelTests.swift`.
- [ ] Update `UserConfig.swift` to include new JSON fields.

## Phase 2: UI Implementation
- [ ] Create `NewView.swift` using SwiftUI.
- [ ] Integrate `NewView` into `MainWindow.swift`.

## Phase 3: Integration & Polish
- [ ] Connect `CommandRunner` to trigger the new action.
- [ ] Verify accessibility and keyboard navigation.
- [ ] Run full test suite.
```

## 4. Workflow for Agents
1.  **Read this README** to understand the constraints and stack.
2.  **Analyze the Codebase:** specific paths mentioned in the prompt.
3.  **Draft the Spec:** Ensure it matches the Swift/AppKit patterns used in `Leader Key`.
4.  **Generate the Plan:** Create the `_implementation_plan.md` file immediately after the spec.
