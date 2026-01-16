import XCTest
import Defaults
@testable import Leader_Key

class MockModifierTriggerTarget: ModifierTriggerTarget {
  var showCalled = false
  var hideCalled = false
  var showExpectation: XCTestExpectation?
  var hideExpectation: XCTestExpectation?
  
  func show() {
    showCalled = true
    showExpectation?.fulfill()
  }
  
  func hide(afterClose: (() -> Void)?) {
    hideCalled = true
    afterClose?()
    hideExpectation?.fulfill()
  }
}

final class ModifierTriggerTests: XCTestCase {
  var trigger: ModifierTrigger!
  var target: MockModifierTriggerTarget!
  var originalSuite: UserDefaults!

  override func setUp() {
    super.setUp()
    originalSuite = defaultsSuite
    defaultsSuite = UserDefaults(suiteName: UUID().uuidString)!
    
    target = MockModifierTriggerTarget()
    trigger = ModifierTrigger(target: target)
  }
  
  override func tearDown() {
    Defaults[.modifierActivationMask] = 0
    defaultsSuite = originalSuite
    trigger = nil
    target = nil
    super.tearDown()
  }
  
  func testTriggerActivation() {
    let cmd = NSEvent.ModifierFlags.command
    Defaults[.modifierActivationMask] = cmd.rawValue
    
    let expectation = XCTestExpectation(description: "Show called")
    target.showExpectation = expectation
    
    if let event = NSEvent.keyEvent(with: .flagsChanged, location: .zero, modifierFlags: cmd, timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 55) {
        trigger.handleFlagsChanged(event)
    }
    
    wait(for: [expectation], timeout: 1.0)
    XCTAssertTrue(target.showCalled)
  }
  
  func testTriggerDeactivation() {
    let cmd = NSEvent.ModifierFlags.command
    Defaults[.modifierActivationMask] = cmd.rawValue
    
    let expectation = XCTestExpectation(description: "Hide called")
    target.hideExpectation = expectation
    
    if let event = NSEvent.keyEvent(with: .flagsChanged, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 55) {
        trigger.handleFlagsChanged(event)
    }
    
    wait(for: [expectation], timeout: 1.0)
    XCTAssertTrue(target.hideCalled)
  }
  
  func testPartialMatchDeactivates() {
    let mask = NSEvent.ModifierFlags.command.union(.shift)
    Defaults[.modifierActivationMask] = mask.rawValue
    
    let expectation = XCTestExpectation(description: "Hide called")
    target.hideExpectation = expectation
    
    if let event = NSEvent.keyEvent(with: .flagsChanged, location: .zero, modifierFlags: .command, timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 55) {
        trigger.handleFlagsChanged(event)
    }
    
    wait(for: [expectation], timeout: 1.0)
    XCTAssertTrue(target.hideCalled)
    XCTAssertFalse(target.showCalled)
  }
}

final class ControllerBehaviorTests: XCTestCase {
  var originalSuite: UserDefaults!

  override func setUp() {
    super.setUp()
    originalSuite = defaultsSuite
    defaultsSuite = UserDefaults(suiteName: UUID().uuidString)!
  }
  
  override func tearDown() {
    defaultsSuite = originalSuite
    super.tearDown()
  }

  func testBehaviorForAction_NoModifiers_ReturnsRunAndHide() {
    let action = Action(key: "a", type: .command, value: "echo hello")
    let behavior = Controller.behaviorForAction(action, modifiers: nil)
    XCTAssertEqual(behavior, .runAndHide)
  }

  func testBehaviorForAction_ModifierMode_ReturnsRunAndHide() {
    // Configure Modifier Mode to be Hyper (Cmd+Opt+Ctrl+Shift)
    let hyper = NSEvent.ModifierFlags([.command, .option, .control, .shift])
    Defaults[.modifierActivationMask] = hyper.rawValue
    
    // Even if sticky mode logic would catch it (e.g. it has Option), Modifier Mode takes precedence
    let action = Action(key: "a", type: .command, value: "echo hello")
    let behavior = Controller.behaviorForAction(action, modifiers: hyper)
    
    XCTAssertEqual(behavior, .runAndHide)
  }

  func testBehaviorForAction_StickyMode_ReturnsRunAndStay() {
    // Default config: controlGroupOptionSticky
    // So Option key means sticky
    Defaults[.modifierKeyConfiguration] = .controlGroupOptionSticky
    Defaults[.modifierActivationMask] = 0 // Modifier mode disabled
    
    let action = Action(key: "a", type: .command, value: "echo hello")
    let behavior = Controller.behaviorForAction(action, modifiers: .option)
    
    XCTAssertEqual(behavior, .runAndStay)
  }

  func testBehaviorForAction_StickyModeAlternative_ReturnsRunAndStay() {
    // Switch config: optionGroupControlSticky
    // So Control key means sticky
    Defaults[.modifierKeyConfiguration] = .optionGroupControlSticky
    Defaults[.modifierActivationMask] = 0
    
    let action = Action(key: "a", type: .command, value: "echo hello")
    let behavior = Controller.behaviorForAction(action, modifiers: .control)
    
    XCTAssertEqual(behavior, .runAndStay)
  }

  func testBehaviorForAction_NormalModifiers_ReturnsRunAndHide() {
    Defaults[.modifierKeyConfiguration] = .controlGroupOptionSticky
    Defaults[.modifierActivationMask] = NSEvent.ModifierFlags.command.rawValue
    
    // Using Shift, which is neither sticky nor configured modifier mode
    let action = Action(key: "a", type: .command, value: "echo hello")
    let behavior = Controller.behaviorForAction(action, modifiers: .shift)
    
    XCTAssertEqual(behavior, .runAndHide)
  }
  
  func testIsModifierMode_ExactMatch() {
    let cmd = NSEvent.ModifierFlags.command
    Defaults[.modifierActivationMask] = cmd.rawValue
    
    XCTAssertTrue(Controller.isModifierMode(cmd))
    XCTAssertFalse(Controller.isModifierMode(.option))
    XCTAssertFalse(Controller.isModifierMode(cmd.union(.option))) // Strict match? Implementation intersects relevant flags.
  }
  
  func testIsModifierMode_IgnoresIrrelevantFlags() {
    let cmd = NSEvent.ModifierFlags.command
    Defaults[.modifierActivationMask] = cmd.rawValue
    
    // capsLock should be ignored
    XCTAssertTrue(Controller.isModifierMode(cmd.union(.capsLock)))
  }
}