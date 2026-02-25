//
//  SpeechService.swift
//  TypelessOS
//
//  Speech recognition service wrapping Whisper functionality.
//  Extracted from WhisperState to separate concerns.

import Foundation
import AVFoundation

/// Protocol for speech recognition operations
protocol SpeechServiceProtocol {
    var isRecording: Bool { get }
    var isModelLoaded: Bool { get }
    var audioLevel: Float { get }
    
    func toggleRecord() async
    func transcribe() async -> String?
}

/// Delegate for speech service events
protocol SpeechServiceDelegate: AnyObject {
    func speechServiceDidStartRecording()
    func speechServiceDidStopRecording()
    func speechServiceDidTranscribe(text: String)
    func speechServiceDidUpdateAudioLevel(_ level: Float)
}

/// Service managing speech-to-text via Whisper
/// Note: This wraps WhisperState for now, will be refactored to own the logic in Phase 3
@MainActor
final class SpeechService: ObservableObject {
    
    @Published private(set) var isRecording = false
    @Published private(set) var isModelLoaded = false
    @Published private(set) var audioLevel: Float = -160.0
    @Published private(set) var lastTranscription: String = ""
    
    weak var delegate: SpeechServiceDelegate?
    
    private var whisperState: WhisperState?
    
    init() {}
    
    /// Inject WhisperState dependency (bridge to existing implementation)
    func configure(with whisperState: WhisperState) {
        self.whisperState = whisperState
        
        // Sync state
        self.isRecording = whisperState.isRecording
        self.isModelLoaded = whisperState.isModelLoaded
        self.audioLevel = whisperState.audioLevel
    }
    
    // MARK: - Recording Control
    
    func toggleRecord() async {
        guard let whisperState = whisperState else { return }
        
        await whisperState.toggleRecord()
        
        // Sync state after toggle
        self.isRecording = whisperState.isRecording
        
        if isRecording {
            delegate?.speechServiceDidStartRecording()
        } else {
            delegate?.speechServiceDidStopRecording()
            
            // Get transcription result
            if !whisperState.recentMessage.isEmpty {
                lastTranscription = whisperState.recentMessage
                delegate?.speechServiceDidTranscribe(text: lastTranscription)
            }
        }
    }
    
    func startRecording() async {
        if !isRecording {
            await toggleRecord()
        }
    }
    
    func stopRecording() async {
        if isRecording {
            await toggleRecord()
        }
    }
    
    // MARK: - Audio Level Updates
    
    func updateAudioLevel() {
        guard let whisperState = whisperState else { return }
        audioLevel = whisperState.audioLevel
        delegate?.speechServiceDidUpdateAudioLevel(audioLevel)
    }
}
