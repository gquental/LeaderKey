# Implementation Plan - Modifier Mode

## Phase 1: Configuration & Data
- [x] Add `modifierActivationMask` to `Defaults` (store as `UInt` or comparable).
- [x] Create `ModifierPicker` view in `Settings/GeneralPane.swift` to allow selecting combinations (Cmd, Opt, Ctrl, Shift).
- [x] Add toggle to enable/disable this feature in Settings.

## Phase 2: Core Logic (Event Monitoring)
- [x] In `AppDelegate.swift` (or a new `ModifierTrigger.swift` controller), setup `NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged)`.
- [x] Implement logic to compare current flags with configured mask.
    - [x] `strictMatch`: triggers only if flags == target (ignoring caps lock/fn usually).
- [x] Connect trigger to `controller.show()`.
- [x] Connect release (flags mismatch) to `controller.hide()`.

## Phase 3: Execution Refinement
- [x] Modify `Controller.handleKey` to ensure `hide()` is called immediately on execution, overriding any "stay open" logic if triggered via Modifier Mode.
    - *Note:* Existing logic usually hides on execution, but verify sticky key behavior doesn't conflict.
- [x] Implement debounce logic (e.g. 50ms) for activation to prevent flickering when rolling keys.

## Phase 4: Safety & Cleanup

- [x] Ensure `windowDidResignKey` acts as a fail-safe to hide the window.

- [x] Verify no "focus wars" occur if the user holds the keys while switching spaces.



## Phase 5: Verification

- [x] Create integration tests (`ModifierModeIntegrationTests`) to verify end-to-end user stories.

- [x] Run full test suite to ensure no regression.
- [x] Verified all tests pass (including plugin validation workaround).

