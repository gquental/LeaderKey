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
