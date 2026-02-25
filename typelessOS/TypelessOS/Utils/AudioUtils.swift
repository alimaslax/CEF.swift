//
//  AudioUtils.swift
//  TypelessOS
//
//  Created by mali on 12/20/25.
//

import Foundation
import AVFoundation
import AudioToolbox



actor Recorder {
    private var recorder: AVAudioRecorder?
    
    enum RecorderError: Error {
        case couldNotStartRecording
        case couldNotSetInputDevice
    }
    
    func startRecording(toOutputFile url: URL, delegate: AVAudioRecorderDelegate?) throws {
        // Set the selected microphone as the system default input device before recording
        let sharedDefaults = UserDefaults(suiteName: "group.com.rahyan.dev.shared") ?? .standard
        if let selectedMicID = sharedDefaults.string(forKey: "SelectedMicrophone"),
           let deviceID = AudioDeviceID(selectedMicID) {
            setDefaultInputDevice(deviceID: deviceID)
        }
        
        let recordSettings: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let recorder = try AVAudioRecorder(url: url, settings: recordSettings)
        recorder.delegate = delegate
        recorder.isMeteringEnabled = true
        if recorder.record() == false {
            print("Could not start recording")
            throw RecorderError.couldNotStartRecording
        }
        self.recorder = recorder
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }
    
    func getAveragePower() -> Float {
        guard let recorder = recorder else { return -160.0 }
        recorder.updateMeters()
        return recorder.averagePower(forChannel: 0)
    }
    
    /// Sets the system default input device to the specified device ID
    private func setDefaultInputDevice(deviceID: AudioDeviceID) {
        var deviceID = deviceID
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &deviceID
        )
        
        if status != noErr {
            print("[Recorder] Failed to set default input device: \(status)")
        } else {
            print("[Recorder] Set default input device to: \(deviceID)")
        }
    }
}


/// Creates a pseudo-random looking wave based on the audio level.
/// - Parameters:
///   - audioLevel: The audio level in dB (typically -50dB to 0dB range)
///   - index: The bar index (0-4, center index 2 is highest)
/// - Returns: A normalized level between 0.1 and 1.0
func normalizedLevel(for index: Int, audioLevel: Float) -> Float {
    let baseLevel = max(0, (audioLevel + 50) / 50) // map -50dB...0dB to 0...1
    // Vary the height based on index to make it look like a wave
    let variation = Float(abs(index - 2)) * 0.15 // Center (index 2) is highest
    return max(0.1, baseLevel - variation)
}

// MARK: - Wave File Decoding

/// Decodes a RIFF WAVE file into an array of normalized float samples.
/// - Parameter url: The URL of the wave file to decode
/// - Returns: Array of float samples normalized to the range [-1.0, 1.0]
func decodeWaveFile(_ url: URL) throws -> [Float] {
    let data = try Data(contentsOf: url)
    let floats = stride(from: 44, to: data.count, by: 2).map {
        return data[$0..<$0 + 2].withUnsafeBytes {
            let short = Int16(littleEndian: $0.load(as: Int16.self))
            return max(-1.0, min(Float(short) / 32767.0, 1.0))
        }
    }
    return floats
}
