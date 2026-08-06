import SwiftUI

/// Small badge shown in the recorder panels while the network is unreachable.
/// Signals that enhancement will run through the local Ollama fallback model.
struct OfflineIndicatorBadge: View {
    @ObservedObject private var networkStatus = NetworkStatusService.shared

    var body: some View {
        if !networkStatus.isOnline {
            Image(systemName: "wifi.slash")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.orange)
                .help(String(localized: "Offline — enhancement uses the local Ollama model"))
                .transition(.opacity)
                .accessibilityLabel(String(localized: "Offline"))
        }
    }
}
