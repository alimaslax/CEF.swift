//
//  SettingsRepository.swift
//  TypelessOS
//
//  Abstraction layer for UserDefaults-based settings persistence.
//  Separates storage concerns from the Settings observable object.

import Foundation
import Combine

/// Keys for UserDefaults storage
enum SettingsKey: String {
    // Window
    case windowBreakpoint
    case windowTransparency
    case chatWindowX
    case chatWindowY
    case chatWindowPositionSaved
    
    // Provider
    case chatProvider
    
    // API Keys
    case groqKey
    case googleKey
    case openaiKey
    case googleClientID
    
    // Preferences
    case systemPrompt
    case chatFontSize
}

/// Protocol for settings persistence operations
protocol SettingsRepositoryProtocol {
    func getString(_ key: SettingsKey) -> String?
    func setString(_ value: String?, for key: SettingsKey)
    
    func getDouble(_ key: SettingsKey) -> Double
    func setDouble(_ value: Double, for key: SettingsKey)
    
    func getBool(_ key: SettingsKey) -> Bool
    func setBool(_ value: Bool, for key: SettingsKey)
    
    func getPoint(_ xKey: SettingsKey, _ yKey: SettingsKey) -> CGPoint?
    func setPoint(_ point: CGPoint?, xKey: SettingsKey, yKey: SettingsKey, savedKey: SettingsKey)
}

/// Concrete implementation using UserDefaults
final class SettingsRepository: SettingsRepositoryProtocol {
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults? = nil) {
        // Use App Group if available, fall back to standard
        let appGroupIdentifier = "group.com.rahyan.dev.shared"
        if let shared = UserDefaults(suiteName: appGroupIdentifier) {
            self.defaults = shared
            print("SettingsRepository: Using shared App Group storage")
        } else {
            self.defaults = defaults ?? .standard
            print("SettingsRepository: Using standard storage (App Group not found)")
        }
    }
    
    // MARK: - String
    
    func getString(_ key: SettingsKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    func setString(_ value: String?, for key: SettingsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    // MARK: - Double
    
    func getDouble(_ key: SettingsKey) -> Double {
        defaults.double(forKey: key.rawValue)
    }
    
    func setDouble(_ value: Double, for key: SettingsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    // MARK: - Bool
    
    func getBool(_ key: SettingsKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }
    
    func setBool(_ value: Bool, for key: SettingsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    // MARK: - Point (for window position)
    
    func getPoint(_ xKey: SettingsKey, _ yKey: SettingsKey) -> CGPoint? {
        let x = defaults.double(forKey: xKey.rawValue)
        let y = defaults.double(forKey: yKey.rawValue)
        
        // Return nil if never saved
        if x == 0 && y == 0 && !defaults.bool(forKey: SettingsKey.chatWindowPositionSaved.rawValue) {
            return nil
        }
        return CGPoint(x: x, y: y)
    }
    
    func setPoint(_ point: CGPoint?, xKey: SettingsKey, yKey: SettingsKey, savedKey: SettingsKey) {
        if let point = point {
            defaults.set(point.x, forKey: xKey.rawValue)
            defaults.set(point.y, forKey: yKey.rawValue)
            defaults.set(true, forKey: savedKey.rawValue)
        }
    }
    
    // MARK: - Convenience Accessors
    
    var windowBreakpoint: String {
        get { getString(.windowBreakpoint) ?? "medium" }
        set { setString(newValue, for: .windowBreakpoint) }
    }
    
    var windowTransparency: String {
        get { getString(.windowTransparency) ?? "transparent" }
        set { setString(newValue, for: .windowTransparency) }
    }
    
    var chatProvider: String {
        get { getString(.chatProvider) ?? "google" }
        set { setString(newValue, for: .chatProvider) }
    }
    
    var groqKey: String {
        get { getString(.groqKey) ?? "" }
        set { setString(newValue, for: .groqKey) }
    }
    
    var googleKey: String {
        get { getString(.googleKey) ?? "" }
        set { setString(newValue, for: .googleKey) }
    }
    
    var openaiKey: String {
        get { getString(.openaiKey) ?? "" }
        set { setString(newValue, for: .openaiKey) }
    }
    
    var googleClientID: String {
        get { getString(.googleClientID) ?? "" }
        set { setString(newValue, for: .googleClientID) }
    }
    
    var systemPrompt: String {
        get { getString(.systemPrompt) ?? "You are a powerful macOS assistant with deep terminal access. You help users automate tasks, write clean code, and execute bash commands efficiently." }
        set { setString(newValue, for: .systemPrompt) }
    }
    
    var chatFontSize: Double {
        get {
            let size = getDouble(.chatFontSize)
            return size == 0 ? 14 : size
        }
        set { setDouble(newValue, for: .chatFontSize) }
    }
    
    var savedWindowOrigin: CGPoint? {
        get { getPoint(.chatWindowX, .chatWindowY) }
        set { setPoint(newValue, xKey: .chatWindowX, yKey: .chatWindowY, savedKey: .chatWindowPositionSaved) }
    }
}
