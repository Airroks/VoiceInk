import Foundation
import Network

/// Observes network reachability via NWPathMonitor. Used by the enhancement
/// offline fallback (route cloud enhancement to the local Ollama model while
/// offline) and by the recorder offline indicator badge.
final class NetworkStatusService: ObservableObject {
    static let shared = NetworkStatusService()

    @Published private(set) var isOnline: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.prakashjoshipax.voiceink.network-monitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            DispatchQueue.main.async {
                guard let self, self.isOnline != online else { return }
                self.isOnline = online
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
