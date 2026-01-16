# Implementation Plan - Modifier Mode

## Phase 1: Configuration & Data
- [x] Add `modifierActivationMask` to `Defaults` (store as `UInt` or comparable).
- [ ] Create `ModifierPicker` view in `Settings/GeneralPane.swift` to allow selecting combinations (Cmd, Opt, Ctrl, Shift).
- [ ] Add toggle to enable/disable this feature in Settings.

## Phase 2: Core Logic (Event Monitoring)
- [ ] In `AppDelegate.swift` (or a new `ModifierTrigger.swift` controller), setup `NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged)`.
- [ ] Implement logic to compare current flags with configured mask.
    - [ ] `strictMatch`: triggers only if flags == target (ignoring caps lock/fn usually).
- [ ] Connect trigger to `controller.show()`.
- [ ] Connect release (flags mismatch) to `controller.hide()`.

## Phase 3: Execution Refinement
- [ ] Modify `Controller.handleKey` to ensure `hide()` is called immediately on execution, overriding any "stay open" logic if triggered via Modifier Mode.
    - *Note:* Existing logic usually hides on execution, but verify sticky key behavior doesn't conflict.

## Phase 4: Safety & Cleanup
- [ ] Ensure `windowDidResignKey` acts as a fail-safe to hide the window.
- [ ] Verify no "focus wars" occur if the user holds the keys while switching spaces.
