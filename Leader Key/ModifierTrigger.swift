import Cocoa
import Combine
import Defaults

protocol ModifierTriggerTarget: AnyObject {
  func show()
  func hide(afterClose: (() -> Void)?)
}

class ModifierTrigger {
  private var globalMonitor: Any?
  private var localMonitor: Any?
  private var cancellables = Set<AnyCancellable>()
  private weak var target: ModifierTriggerTarget?

  init(target: ModifierTriggerTarget) {
    self.target = target

    Defaults.publisher(.modifierActivationMask)
      .sink { [weak self] _ in
        self?.setupMonitors()
      }
      .store(in: &cancellables)

    Defaults.publisher(.isModifierTriggerEnabled)
      .sink { [weak self] _ in
        self?.setupMonitors()
      }
      .store(in: &cancellables)

    setupMonitors()
  }

  private func setupMonitors() {
    if let monitor = globalMonitor {
      NSEvent.removeMonitor(monitor)
      globalMonitor = nil
    }
    if let monitor = localMonitor {
      NSEvent.removeMonitor(monitor)
      localMonitor = nil
    }

    let maskValue = Defaults[.modifierActivationMask]
    let isEnabled = Defaults[.isModifierTriggerEnabled]
    guard isEnabled && maskValue > 0 else { return }

    globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
      self?.handleFlagsChanged(event)
    }

    localMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
      self?.handleFlagsChanged(event)
      return event
    }
  }

  func handleFlagsChanged(_ event: NSEvent) {
    let maskValue = Defaults[.modifierActivationMask]
    let isEnabled = Defaults[.isModifierTriggerEnabled]
    guard isEnabled && maskValue > 0 else { return }

    let relevantFlags: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
    let currentFlags = event.modifierFlags.intersection(relevantFlags)
    let targetFlags = NSEvent.ModifierFlags(rawValue: maskValue).intersection(relevantFlags)

    if currentFlags.rawValue == targetFlags.rawValue {
      DispatchQueue.main.async {
        self.target?.show()
      }
    } else {
      DispatchQueue.main.async {
        self.target?.hide(afterClose: nil)
      }
    }
  }

  deinit {
    if let monitor = globalMonitor {
      NSEvent.removeMonitor(monitor)
    }
    if let monitor = localMonitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}
