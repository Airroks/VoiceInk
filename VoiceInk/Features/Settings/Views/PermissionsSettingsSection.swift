import AVFoundation
import SwiftUI

/// Settings section that shows the live status of all system permissions VoiceInk
/// depends on and deep-links into the matching System Settings panes. Reuses the
/// permission model from onboarding (OnboardingPermissionKind / -Status), which is
/// otherwise unreachable after onboarding has completed.
struct PermissionsSettingsSection: View {
    @State private var statuses: [OnboardingPermissionKind: OnboardingPermissionStatus] = [:]

    var body: some View {
        Section {
            ForEach(OnboardingPermissionKind.allCases) { permission in
                permissionRow(permission)
            }
        } header: {
            Text("Permissions")
        } footer: {
            Text(
                "After changing a permission in System Settings, restart VoiceInk so all features pick it up."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .onAppear(perform: refreshStatuses)
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        ) { _ in
            refreshStatuses()
        }
    }

    @ViewBuilder
    private func permissionRow(_ permission: OnboardingPermissionKind) -> some View {
        let status = statuses[permission] ?? .unknown

        LabeledContent {
            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(badgeColor(for: status))
                        .frame(width: 7, height: 7)
                    Text(status.label)
                        .foregroundStyle(.secondary)
                }

                Button("Open Settings") {
                    openSystemSettings(for: permission)
                }
                .controlSize(.small)
            }
        } label: {
            Text(permission.descriptor.title)
            Text(permission.descriptor.subtitle)
        }
    }

    private func badgeColor(for status: OnboardingPermissionStatus) -> Color {
        switch status {
        case .granted:
            return .green
        case .needsAccess:
            return .orange
        case .denied, .restricted:
            return .red
        case .unknown:
            return .gray
        }
    }

    private func refreshStatuses() {
        for permission in OnboardingPermissionKind.allCases {
            statuses[permission] = Self.diagnose(permission)
        }
    }

    private static func diagnose(_ permission: OnboardingPermissionKind) -> OnboardingPermissionStatus {
        switch permission {
        case .microphone:
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                return .granted
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            case .notDetermined:
                return .needsAccess
            @unknown default:
                return .unknown
            }

        case .accessibility:
            return AXIsProcessTrusted() ? .granted : .needsAccess

        case .screenRecording:
            return CGPreflightScreenCaptureAccess() ? .granted : .needsAccess
        }
    }

    private func openSystemSettings(for permission: OnboardingPermissionKind) {
        let pane: PrivacySettingsPane
        switch permission {
        case .microphone:
            pane = .microphone
            if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { _ in
                    DispatchQueue.main.async { refreshStatuses() }
                }
                return
            }
        case .accessibility:
            pane = .accessibility
        case .screenRecording:
            pane = .screenRecording
        }

        if let url = URL(string: pane.urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
