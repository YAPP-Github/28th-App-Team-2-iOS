import Foundation

final class CancellationRelay: @unchecked Sendable {
    private let lock = NSLock()
    private var action: (@Sendable () -> Void)?
    private var isCancelled = false

    func install(_ action: @escaping @Sendable () -> Void) {
        lock.lock()

        if isCancelled {
            lock.unlock()
            action()
        } else {
            self.action = action
            lock.unlock()
        }
    }

    func cancel() {
        lock.lock()
        isCancelled = true
        let action = action
        self.action = nil
        lock.unlock()

        action?()
    }
}
