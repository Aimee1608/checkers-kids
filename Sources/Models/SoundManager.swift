import AVFoundation

/// 背景音乐是打包进 app 的真实曲子(CC0 授权,不涉及版权),音效是代码里现场合成的正弦波。
/// 两个开关各自独立存 @AppStorage,首页和对局页共用同一份状态。
@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
            musicEnabled ? startBGM() : stopBGM()
        }
    }

    @Published var sfxEnabled: Bool {
        didSet { UserDefaults.standard.set(sfxEnabled, forKey: "sfxEnabled") }
    }

    private let engine = AVAudioEngine()
    private let bgmPlayer = AVAudioPlayerNode()
    private let sfxPlayer = AVAudioPlayerNode()
    private let sfxFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private let bgmBuffer: AVAudioPCMBuffer?
    private var engineStarted = false

    private init() {
        musicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "musicEnabled")
        sfxEnabled = UserDefaults.standard.object(forKey: "sfxEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "sfxEnabled")

        bgmBuffer = SoundManager.loadBGMBuffer()

        engine.attach(bgmPlayer)
        engine.attach(sfxPlayer)
        if let bgmBuffer {
            engine.connect(bgmPlayer, to: engine.mainMixerNode, format: bgmBuffer.format)
        }
        engine.connect(sfxPlayer, to: engine.mainMixerNode, format: sfxFormat)

        if musicEnabled { startBGM() }
    }

    func playSelect() { play(SoundManager.makeTone(frequency: 660, duration: 0.09, amplitude: 0.12)) }
    func playMove() { play(SoundManager.makeTone(frequency: 440, duration: 0.14, amplitude: 0.16)) }

    func playWin() {
        guard sfxEnabled else { return }
        for (i, freq) in [523.25, 659.25, 783.99, 1046.5].enumerated() {
            let delay = Double(i) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.play(SoundManager.makeTone(frequency: freq, duration: 0.25, amplitude: 0.15))
            }
        }
    }

    private func play(_ buffer: AVAudioPCMBuffer) {
        guard sfxEnabled, ensureEngineRunning() else { return }
        sfxPlayer.scheduleBuffer(buffer, at: nil)
        if !sfxPlayer.isPlaying { sfxPlayer.play() }
    }

    private func startBGM() {
        guard let bgmBuffer, ensureEngineRunning() else { return }
        bgmPlayer.scheduleBuffer(bgmBuffer, at: nil, options: .loops)
        bgmPlayer.play()
    }

    private func stopBGM() {
        bgmPlayer.stop()
    }

    @discardableResult
    private func ensureEngineRunning() -> Bool {
        if engineStarted { return true }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            engine.prepare()
            try engine.start()
            engineStarted = true
            return true
        } catch {
            // 模拟器/无音频设备等环境下引擎起不来就静默放弃,音效只是锦上添花,不影响对局。
            return false
        }
    }

    /// 背景音乐是 CC0 授权的真实曲子(Children's March Theme, by Cleyton Kauffman,
    /// opengameart.org,无缝循环设计),自己合成的旋律太生硬,换成真人谱写的更好听。
    /// 打包成 96kbps AAC 减小体积,启动时一次性读进内存循环播,不用每次都读文件。
    private static func loadBGMBuffer() -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: "BackgroundMusic", withExtension: "m4a"),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        else { return nil }
        do {
            try file.read(into: buffer)
            return buffer
        } catch {
            return nil
        }
    }

    private static func makeTone(frequency: Double, duration: Double, amplitude: Double) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let frameCount = AVAudioFrameCount(format.sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let channel = buffer.floatChannelData![0]
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / format.sampleRate
            let env = envelope(t: t, duration: duration, attack: 0.01, release: duration * 0.6)
            channel[frame] = Float(sin(2.0 * .pi * frequency * t) * amplitude * env)
        }
        return buffer
    }

    private static func envelope(t: Double, duration: Double, attack: Double, release: Double) -> Double {
        if t < attack { return t / attack }
        if t > duration - release { return max(0, (duration - t) / release) }
        return 1.0
    }
}
