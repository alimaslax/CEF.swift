//
//  WhisperModelService.swift
//  TypelessOS
//
//  Service for downloading and managing Whisper speech recognition models.

import Foundation
import Combine

/// Available Whisper models with their metadata
enum WhisperModel: String, CaseIterable, Identifiable {
    case tinyEn = "tiny.en"
    case tiny = "tiny"
    case baseEn = "base.en"
    case base = "base"
    case smallEn = "small.en"
    case small = "small"
    case mediumEn = "medium.en"
    case medium = "medium"
    case largeV3Turbo = "large-v3-turbo"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .tinyEn: return "Tiny (English)"
        case .tiny: return "Tiny (Multilingual)"
        case .baseEn: return "Base (English)"
        case .base: return "Base (Multilingual)"
        case .smallEn: return "Small (English)"
        case .small: return "Small (Multilingual)"
        case .mediumEn: return "Medium (English)"
        case .medium: return "Medium (Multilingual)"
        case .largeV3Turbo: return "Large v3 Turbo"
        }
    }
    
    var description: String {
        switch self {
        case .tinyEn, .tiny: return "~75MB • Fastest, lower accuracy"
        case .baseEn, .base: return "~142MB • Fast, good accuracy"
        case .smallEn, .small: return "~466MB • Balanced speed/accuracy"
        case .mediumEn, .medium: return "~1.5GB • High accuracy"
        case .largeV3Turbo: return "~1.6GB • Best accuracy"
        }
    }
    
    var fileName: String { "ggml-\(rawValue).bin" }
    
    var downloadURL: URL {
        URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-\(rawValue).bin")!
    }
}

/// Download state for a model
enum ModelDownloadState: Equatable {
    case notDownloaded
    case downloading(progress: Double)
    case downloaded
    case failed(String)
}

/// Service for managing Whisper model downloads
@MainActor
class WhisperModelService: NSObject, ObservableObject {
    static let shared = WhisperModelService()
    
    @Published var downloadStates: [WhisperModel: ModelDownloadState] = [:]
    private var sharedDefaults = UserDefaults(suiteName: "group.com.rahyan.dev.shared") ?? .standard

    @Published var selectedModel: WhisperModel {
        didSet {
            sharedDefaults.set(selectedModel.rawValue, forKey: "SelectedWhisperModel")
        }
    }
    
    private var downloadTasks: [WhisperModel: URLSessionDownloadTask] = [:]
    private var urlSession: URLSession!
    
    private override init() {
        let savedModel = (UserDefaults(suiteName: "group.com.rahyan.dev.shared") ?? .standard).string(forKey: "SelectedWhisperModel") ?? "small.en"
        self.selectedModel = WhisperModel(rawValue: savedModel) ?? .smallEn
        
        super.init()
        
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        // Check which models are already downloaded
        refreshDownloadStates()
    }
    
    /// Refresh the download states by checking the filesystem
    func refreshDownloadStates() {
        for model in WhisperModel.allCases {
            let isDownloaded = isModelDownloaded(model)
            downloadStates[model] = isDownloaded ? .downloaded : .notDownloaded
            if isDownloaded {
                print("[WhisperModelService] Init: Found model \(model.rawValue)")
            }
        }
    }

    // MARK: - Model Directory
    
    var modelsDirectory: URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let modelsDir = homeDir.appendingPathComponent(".typelessOS/models", isDirectory: true)
        
        // Create directory if needed
        if !FileManager.default.fileExists(atPath: modelsDir.path) {
            do {
                try FileManager.default.createDirectory(at: modelsDir, withIntermediateDirectories: true, attributes: nil)
                print("[WhisperModelService] Created models directory: \(modelsDir.path)")
            } catch {
                print("[WhisperModelService] Failed to create models directory: \(error)")
            }
        }
        return modelsDir
    }
    
    func modelPath(for model: WhisperModel) -> URL {
        modelsDirectory.appendingPathComponent(model.fileName)
    }
    
    func isModelDownloaded(_ model: WhisperModel) -> Bool {
        // Check bundled models first
        if Bundle.main.url(forResource: "ggml-\(model.rawValue)", withExtension: "bin", subdirectory: "models") != nil {
            return true
        }
        // Check downloaded models in ~/.typelessOS/models/
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let downloadedPath = homeDir.appendingPathComponent(".typelessOS/models/\(model.fileName)")
        let exists = FileManager.default.fileExists(atPath: downloadedPath.path)
        return exists
    }
    
    /// Returns the URL for the selected model (bundled or downloaded)
    func selectedModelURL() -> URL? {
        // Check bundled first
        if let bundled = Bundle.main.url(forResource: "ggml-\(selectedModel.rawValue)", withExtension: "bin", subdirectory: "models") {
            print("[WhisperModelService] Using bundled model: \(bundled.path)")
            return bundled
        }
        // Check downloaded in ~/.typelessOS/models/
        let downloaded = modelPath(for: selectedModel)
        if FileManager.default.fileExists(atPath: downloaded.path) {
            print("[WhisperModelService] Using downloaded model: \(downloaded.path)")
            return downloaded
        }
        print("[WhisperModelService] No model found for: \(selectedModel.rawValue)")
        return nil
    }
    
    // MARK: - Download Management
    
    func downloadModel(_ model: WhisperModel) {
        guard downloadStates[model] != .downloading(progress: 0) else { return }
        
        downloadStates[model] = .downloading(progress: 0)
        
        let task = urlSession.downloadTask(with: model.downloadURL)
        task.taskDescription = model.rawValue
        downloadTasks[model] = task
        task.resume()
    }
    
    func cancelDownload(_ model: WhisperModel) {
        downloadTasks[model]?.cancel()
        downloadTasks[model] = nil
        downloadStates[model] = .notDownloaded
    }
    
    func deleteModel(_ model: WhisperModel) {
        let path = modelPath(for: model)
        try? FileManager.default.removeItem(at: path)
        downloadStates[model] = .notDownloaded
    }
    
    func selectModel(_ model: WhisperModel) {
        guard isModelDownloaded(model) else { return }
        selectedModel = model
    }
}

// MARK: - URLSessionDownloadDelegate

extension WhisperModelService: URLSessionDownloadDelegate {
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let modelName = downloadTask.taskDescription,
              let model = WhisperModel(rawValue: modelName) else { 
            print("[WhisperModelService] No model name in task description")
            return 
        }
        
        // Get destination path - must compute on main actor but file ops must happen NOW
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let modelsDir = homeDir.appendingPathComponent(".typelessOS/models", isDirectory: true)
        let destination = modelsDir.appendingPathComponent(model.fileName)
        
        print("[WhisperModelService] Download finished for \(model.rawValue)")
        print("[WhisperModelService] Temp location: \(location.path)")
        print("[WhisperModelService] Destination: \(destination.path)")
        
        // File operations MUST happen synchronously before this method returns
        // because the temp file at `location` is deleted immediately after
        do {
            // Ensure directory exists
            if !FileManager.default.fileExists(atPath: modelsDir.path) {
                try FileManager.default.createDirectory(at: modelsDir, withIntermediateDirectories: true, attributes: nil)
                print("[WhisperModelService] Created directory: \(modelsDir.path)")
            }
            
            // Remove existing file if present
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
                print("[WhisperModelService] Removed existing file")
            }
            
            // Copy the file (must happen before method returns!)
            try FileManager.default.copyItem(at: location, to: destination)
            print("[WhisperModelService] Copied file successfully")
            
            // Verify
            let attrs = try FileManager.default.attributesOfItem(atPath: destination.path)
            let size = attrs[.size] as? Int64 ?? 0
            print("[WhisperModelService] Saved file size: \(size) bytes")
            
            // Update UI on main thread
            Task { @MainActor in
                self.downloadStates[model] = .downloaded
                self.downloadTasks[model] = nil
            }
        } catch {
            print("[WhisperModelService] ERROR saving file: \(error)")
            Task { @MainActor in
                self.downloadStates[model] = .failed(error.localizedDescription)
                self.downloadTasks[model] = nil
            }
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let modelName = downloadTask.taskDescription,
              let model = WhisperModel(rawValue: modelName) else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        Task { @MainActor in
            downloadStates[model] = .downloading(progress: progress)
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask,
              let modelName = downloadTask.taskDescription,
              let model = WhisperModel(rawValue: modelName),
              let error = error else { return }
        
        // Ignore cancellation errors
        if (error as NSError).code == NSURLErrorCancelled { return }
        
        print("[WhisperModelService] Download failed: \(error)")
        
        Task { @MainActor in
            downloadStates[model] = .failed(error.localizedDescription)
            downloadTasks[model] = nil
        }
    }
}
