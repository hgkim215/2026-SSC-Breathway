import AVFAudio
import Foundation

@MainActor
final class BackgroundMusicPlayer: ObservableObject {
    static let shared = BackgroundMusicPlayer()

    private var player: AVAudioPlayer?
    private var isConfigured = false
    private var shouldPlay = false
    private var keepAliveTimer: Timer?

    func setPlaybackEnabled(_ enabled: Bool) {
        shouldPlay = enabled
        configureIfNeeded()

        if enabled {
            resumeIfNeeded()
        } else {
            player?.pause()
        }
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true
        configureAudioSession()
        createPlayer()
        startKeepAliveTimer()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[BGM] Failed to configure audio session: \(error)")
        }
    }

    private func createPlayer() {
        guard player == nil else { return }

        let url = Bundle.main.url(forResource: "main_bgm", withExtension: "mp3", subdirectory: "music")
            ?? Bundle.main.url(forResource: "main_bgm", withExtension: "mp3")

        guard let url else {
            print("[BGM] main_bgm.mp3 not found in bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.5
            player.prepareToPlay()
            self.player = player
        } catch {
            print("[BGM] Failed to create player: \(error)")
        }
    }

    private func startKeepAliveTimer() {
        keepAliveTimer?.invalidate()
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                guard self.shouldPlay else { return }
                self.resumeIfNeeded()
            }
        }
        keepAliveTimer?.tolerance = 0.2
    }

    private func resumeIfNeeded() {
        guard let player else { return }
        guard !player.isPlaying else { return }
        _ = player.play()
    }
}
