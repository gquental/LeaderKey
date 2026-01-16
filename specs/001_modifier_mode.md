# Spec: Modifier Mode (Issue #66)

## 1. Title & Summary
**Modifier Mode:** Allows the user to activate LeaderKey by holding down a specific combination of modifier keys (e.g., HyperKey: ⌃⌥⇧⌘). The window remains visible while the modifiers are held and dismisses upon release or command execution.

## 2. Context
Currently, LeaderKey is activated via a global hotkey (triggering `KeyboardShortcuts.onKeyDown`). The user wants an alternative "Hold-to-Show" interaction model, similar to how some launchers or specialized keyboard layers work. This reduces friction for power users who want quick access without a "toggle on, toggle off" mental model.

## 3. User Stories
- **As a user**, I want to configure a specific combination of modifier keys (e.g., HyperKey) to open LeaderKey.
- **As a user**, I want the LeaderKey window to appear when I press and hold these modifiers.
- **As a user**, I want the window to disappear immediately if I release the modifiers without typing a command.
- **As a user**, I want to execute a command by typing a key while holding the modifiers (e.g., Hold Hyper + press 'T').
- **As a user**, I want the window to close immediately after I execute a command, even if I'm still holding the modifiers.

## 4. Functional Requirements

### Configuration
- Add a new section in **Settings > General** for "Modifier Access".
- Provide a UI to capture/set the modifier combination (Checkboxes or a recorder, though checkboxes are clearer for pure modifiers: Command, Option, Control, Shift).
- Allow disabling this mode (default state).

### Activation (Hold)
- Monitor global `flagsChanged` events.
- When the currently pressed modifiers **exactly match** the configured combination, show the window.
    - *Note:* Must ensure we don't trigger if *additional* keys are pressed (though `flagsChanged` usually isolates modifiers).

### Deactivation (Release)
- If the modifiers change (user releases one or all), and no command has been executed yet, hide the window.

### Execution
- Standard `KeyCapture` logic continues to work.
- If a valid command key is pressed while the window is open (and modifiers are held):
    1. Execute the command.
    2. Immediately hide the window.
    3. Ignore the subsequent "flagsChanged" event (release) that would normally hide it (to avoid double-hiding logic issues, though idempotent hide is fine).

### Focus & Input
- When activated via modifiers, the window must steal focus (`makeKeyAndOrderFront`) to capture the subsequent character key press.

## 5. Technical Design

### Data Models
- **UserConfig/Defaults:**
    - Add `modifierTrigger: Int?` (storing the raw `NSEvent.ModifierFlags.rawValue` or a simplified struct).
    - Let's use a set of `NSEvent.ModifierFlags` logic.
    - New preference key: `Defaults.Keys.modifierActivationMask`.

### Core Logic (`Controller.swift` / `AppDelegate.swift`)
- **Event Monitoring:**
    - Need `NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged)` to detect activation when app is in background.
    - Need `NSEvent.addLocalMonitorForEvents(matching: .flagsChanged)` to handle it when app is active (edge cases).
- **Debounce:**
    - Adding a slight debounce (e.g., 50-100ms) might be necessary to avoid flickering if the user rolls their fingers onto the modifiers, though strict exact match usually handles this.

### UI Components
- **Settings/GeneralPane.swift:**
    - Add a `ModifierPicker` view (Row of toggle buttons: ⌘, ⌥, ⌃, ⇧).

## 6. Edge Cases
- **Interference:** If the user selects just "Command", they can't use system shortcuts. *Mitigation:* We will implement it, but user bears responsibility. The HyperKey use case is safe.
- **Accessibility:** Ensure `flagsChanged` monitoring doesn't block other apps (Global monitors are passive, so this is safe).
- **Stuck State:** If window shows and user cmd-tabs away? The `flagsChanged` should catch the release, but `windowDidResignKey` should also ensure it hides.
