import AVFoundation

/// 背景音乐和音效都是代码里合成的正弦波(五声音阶,不会难听),不用找外部音频素材、
/// 不用考虑版权,完全离线。开关状态用 @AppStorage 存,首页和对局页共用同一个开关。
@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "soundEnabled")
            isEnabled ? startBGM() : stopBGM()
        }
    }

    private let engine = AVAudioEngine()
    private let bgmPlayer = AVAudioPlayerNode()
    private let sfxPlayer = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private let bgmBuffer: AVAudioPCMBuffer
    private var engineStarted = false

    private init() {
        isEnabled = UserDefaults.standard.object(forKey: "soundEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "soundEnabled")

        bgmBuffer = SoundManager.makeMelodyBuffer(format: format)

        engine.attach(bgmPlayer)
        engine.attach(sfxPlayer)
        engine.connect(bgmPlayer, to: engine.mainMixerNode, format: format)
        engine.connect(sfxPlayer, to: engine.mainMixerNode, format: format)

        if isEnabled { startBGM() }
    }

    func toggle() { isEnabled.toggle() }

    func playSelect() { play(SoundManager.makeTone(frequency: 660, duration: 0.09, amplitude: 0.12)) }
    func playMove() { play(SoundManager.makeTone(frequency: 440, duration: 0.14, amplitude: 0.16)) }

    func playWin() {
        guard isEnabled else { return }
        for (i, freq) in [523.25, 659.25, 783.99, 1046.5].enumerated() {
            let delay = Double(i) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.play(SoundManager.makeTone(frequency: freq, duration: 0.25, amplitude: 0.15))
            }
        }
    }

    private func play(_ buffer: AVAudioPCMBuffer) {
        guard isEnabled, ensureEngineRunning() else { return }
        sfxPlayer.scheduleBuffer(buffer, at: nil)
        if !sfxPlayer.isPlaying { sfxPlayer.play() }
    }

    private func startBGM() {
        guard ensureEngineRunning() else { return }
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

    /// 五声音阶(C 大调 do/re/mi/sol/la)按顺序上下起伏一圈,循环起来不会有半音冲突,
    /// 随便怎么排列都好听,不用真的谱曲。
    private static func makeMelodyBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let notes: [Double] = [261.63, 329.63, 392.00, 440.00, 392.00, 329.63, 293.66, 261.63]
        let noteDuration = 0.62
        let totalFrames = AVAudioFrameCount(format.sampleRate * noteDuration * Double(notes.count))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames)!
        buffer.frameLength = totalFrames
        let channel = buffer.floatChannelData![0]
        let framesPerNote = Int(format.sampleRate * noteDuration)

        for (noteIndex, freq) in notes.enumerated() {
            let base = noteIndex * framesPerNote
            for frame in 0..<framesPerNote {
                let t = Double(frame) / format.sampleRate
                let envelope = envelope(t: t, duration: noteDuration, attack: 0.04, release: 0.3)
                // 基频 + 半音量的八度泛音,听起来像木琴/音乐盒而不是纯电子哔哔声。
                let sample = (sin(2.0 * .pi * freq * t) + 0.5 * sin(2.0 * .pi * freq * 2 * t)) / 1.5
                channel[base + frame] = Float(sample * envelope * 0.11)
            }
        }
        return buffer
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
