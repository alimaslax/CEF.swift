import Foundation
import SwiftUI
import AVFoundation
#if os(macOS)
import AppKit
#endif

@MainActor
class WhisperState: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isModelLoaded = false
    @Published var messageLog = ""
    @Published var recentMessage = ""
    @Published var canTranscribe = false
    @Published var isRecording = false
    
    @Published var audioLevel: Float = -160.0
    
    private var whisperContext: WhisperContext?
    private let recorder = Recorder()
    private var recordedFile: URL? = nil
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private var modelUrl: URL? {
        WhisperModelService.shared.selectedModelURL()
    }
    
    private var sampleUrl: URL? {
        Bundle.main.url(forResource: "jfk", withExtension: "wav", subdirectory: "samples")
    }
    
    private enum LoadError: Error {
        case couldNotLocateModel
    }
    
    override init() {
        super.init()
        canTranscribe = true
    }
    
    private func loadModel() throws {
        messageLog += "Loading model...\n"
        if let modelUrl {
            whisperContext = try WhisperContext.createContext(path: modelUrl.path())
            isModelLoaded = true
            messageLog += "Loaded model \(modelUrl.lastPathComponent)\n"
        } else {
            messageLog += "Could not locate model\n"
        }
    }
    
    func unloadModel() {
        whisperContext = nil
        isModelLoaded = false
        messageLog += "Unloaded model\n"
    }

    func transcribeSample() async {
        if let sampleUrl {
            do {
                try loadModel()
                await transcribeAudio(sampleUrl)
            } catch {
                messageLog += "Error loading model: \(error.localizedDescription)\n"
            }
        } else {
            messageLog += "Could not locate sample\n"
        }
    }
    
    private func transcribeAudio(_ url: URL) async {
        if (!canTranscribe) {
            return
        }
        guard let whisperContext else {
            return
        }
        
        do {
            canTranscribe = false
            messageLog += "Reading wave samples...\n"
            let data = try readAudioSamples(url)
            messageLog += "Transcribing data...\n"
            await whisperContext.fullTranscribe(samples: data)
            let text = await whisperContext.getTranscription()
            messageLog += "Done: \(text)\n"
            recentMessage = text
        } catch {
            print(error.localizedDescription)
            messageLog += "\(error.localizedDescription)\n"
        }
        
        
        canTranscribe = true
        unloadModel()
    }
    
    private func readAudioSamples(_ url: URL) throws -> [Float] {
        //stopPlayback()
        //try startPlayback(url)
        return try decodeWaveFile(url)
    }
    
    func toggleRecord() async {
        if isRecording {
            timer?.invalidate()
            timer = nil
            await recorder.stopRecording()
            isRecording = false
            unmuteSystemAudio()
            if let recordedFile {
                await transcribeAudio(recordedFile)
            }
        } else {
            requestRecordPermission { granted in
                if granted {
                    Task {
                        do {
                            // Mute audio in background - don't block recording start
                            Task.detached { @MainActor [weak self] in
                                self?.muteSystemAudio()
                            }
                            
                            // Load model in background - will be ready by the time recording stops
                            Task { @MainActor [weak self] in
                                try? self?.loadModel()
                            }
                            
                            let file = FileManager.default.temporaryDirectory.appending(path: "output.wav")
                            
                            try await self.recorder.startRecording(toOutputFile: file, delegate: self)
                            self.isRecording = true
                            self.recordedFile = file
                            
                            DispatchQueue.main.async {
                                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                    Task {
                                        let level = await self.recorder.getAveragePower()
                                        DispatchQueue.main.async {
                                            self.audioLevel = level
                                        }
                                    }
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                            self.messageLog += "\(error.localizedDescription)\n"
                            self.isRecording = false
                        }
                    }
                }
            }
        }
    }
    
    private func requestRecordPermission(response: @escaping (Bool) -> Void) {
#if os(macOS)
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            response(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                response(granted)
            }
        case .denied, .restricted:
            response(false)
        @unknown default:
            response(false)
        }
#else
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            response(granted)
        }
#endif
    }
    
    private func startPlayback(_ url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    /// Mutes system audio when recording starts
    private func muteSystemAudio() {
#if os(macOS)
        let script = NSAppleScript(source: "set volume with output muted")
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        if let error = error {
            print("[WhisperState] Failed to mute: \(error)")
        } else {
            print("[WhisperState] System audio muted")
        }
#endif
    }
    
    /// Unmutes system audio when recording stops
    private func unmuteSystemAudio() {
#if os(macOS)
        let script = NSAppleScript(source: "set volume without output muted")
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        if let error = error {
            print("[WhisperState] Failed to unmute: \(error)")
        } else {
            print("[WhisperState] System audio unmuted")
        }
#endif
    }
    
    // MARK: AVAudioRecorderDelegate
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            Task {
                await handleRecError(error)
            }
        }
    }
    
    private func handleRecError(_ error: Error) {
        print(error.localizedDescription)
        messageLog += "\(error.localizedDescription)\n"
        isRecording = false
    }
    
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task {
            await onDidFinishRecording()
        }
    }
    
    private func onDidFinishRecording() {
        isRecording = false
    }
}

