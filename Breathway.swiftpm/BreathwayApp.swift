import SwiftUI

@main
struct BreathwayApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppStorageKeys.backgroundMusicEnabled) private var isBackgroundMusicEnabled = true

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .preferredColorScheme(.light)
                .onAppear {
                    syncBackgroundMusicPlayback(for: scenePhase)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            syncBackgroundMusicPlayback(for: newPhase)
        }
        .onChange(of: isBackgroundMusicEnabled) { _, _ in
            syncBackgroundMusicPlayback(for: scenePhase)
        }
    }

    private func syncBackgroundMusicPlayback(for phase: ScenePhase) {
        switch phase {
        case .active:
            BackgroundMusicPlayer.shared.setPlaybackEnabled(isBackgroundMusicEnabled)
        case .inactive, .background:
            BackgroundMusicPlayer.shared.setPlaybackEnabled(false)
        @unknown default:
            BackgroundMusicPlayer.shared.setPlaybackEnabled(false)
        }
    }
}
