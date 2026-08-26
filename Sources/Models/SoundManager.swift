import AVFoundation

/// 背景音乐和音效都是代码里合成的波形,不用找外部音频素材、不用考虑版权,完全离线。
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
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private let bgmBuffer: AVAudioPCMBuffer
    private var engineStarted = false

    private init() {
        musicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "musicEnabled")
        sfxEnabled = UserDefaults.standard.object(forKey: "sfxEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "sfxEnabled")

        bgmBuffer = SoundManager.makeMelodyBuffer(format: format)

        engine.attach(bgmPlayer)
        engine.attach(sfxPlayer)
        engine.connect(bgmPlayer, to: engine.mainMixerNode, format: format)
        engine.connect(sfxPlayer, to: engine.mainMixerNode, format: format)

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

    /// 五声音阶(C 大调 do/re/mi/sol/la)但时值错落成一个摇篮曲式的呼吸感,不是整齐划一的
    /// 考试铃声;音符之间留了重叠(legato),靠"下一个音符还没等上一个完全淡出就进来"
    /// 听起来才连贯。另外垫一条极轻的低音持续音打底,给旋律一个和声基础,不然纯旋律裸奏
    /// 会显得单薄。
    private static func makeMelodyBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer {
        struct Note { let freq: Double; let duration: Double }
        let notes: [Note] = [
            Note(freq: 261.63, duration: 0.9),
            Note(freq: 329.63, duration: 0.55),
            Note(freq: 392.00, duration: 0.55),
            Note(freq: 440.00, duration: 0.9),
            Note(freq: 392.00, duration: 0.55),
            Note(freq: 329.63, duration: 0.55),
            Note(freq: 293.66, duration: 0.9),
            Note(freq: 261.63, duration: 1.3),
        ]
        let overlap = 0.82 // 下一个音符在这个比例处就开始,跟上一个音符的尾音叠在一起。

        var onsets: [Double] = []
        var t = 0.0
        for note in notes {
            onsets.append(t)
            t += note.duration * overlap
        }
        let totalDuration = onsets.last! + notes.last!.duration
        let totalFrames = AVAudioFrameCount(format.sampleRate * totalDuration) + 1
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames)!
        buffer.frameLength = totalFrames
        let channel = buffer.floatChannelData![0]

        let droneFreq = 130.81 // 低八度的 C3,持续整个循环,音量很轻,只是垫个底。
        for frame in 0..<Int(totalFrames) {
            let time = Double(frame) / format.sampleRate
            let env = envelope(t: time, duration: totalDuration, attack: 0.6, release: 0.6)
            channel[frame] = Float(sin(2.0 * .pi * droneFreq * time) * 0.045 * env)
        }

        for (note, onset) in zip(notes, onsets) {
            let startFrame = Int(onset * format.sampleRate)
            let noteFrames = Int(note.duration * format.sampleRate)
            for frame in 0..<noteFrames {
                let idx = startFrame + frame
                guard idx < Int(totalFrames) else { break }
                let localT = Double(frame) / format.sampleRate
                let env = envelope(t: localT, duration: note.duration, attack: 0.06, release: note.duration * 0.75)
                // 极轻的颤音(±0.4%,5.2Hz)让音色暖一点,不是死板的纯音高。
                let vibrato = 1.0 + 0.004 * sin(2.0 * .pi * 5.2 * localT)
                let freq = note.freq * vibrato
                let sample = (sin(2.0 * .pi * freq * localT) + 0.4 * sin(2.0 * .pi * freq * 2 * localT)) / 1.4
                channel[idx] += Float(sample * env * 0.1)
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
