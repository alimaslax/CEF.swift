//
//  DependencyContainer.swift
//  TypelessOS
//
//  Central dependency injection container for service and repository access.
//  Provides lazy initialization and single source of truth for dependencies.

import Foundation
import SwiftUI

/// Central container for dependency injection across the app.
/// Access via `DependencyContainer.shared` or inject via `@EnvironmentObject`.
@MainActor
final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    // MARK: - Repositories (Data Layer)
    
    lazy var settingsRepository: SettingsRepository = SettingsRepository()

    // MARK: - Services (Business Logic Layer)
    
    lazy var speechService: SpeechService = SpeechService()
    
    private init() {}
}

// MARK: - Environment Key

private struct DependencyContainerKey: EnvironmentKey {
    static var defaultValue: DependencyContainer {
        MainActor.assumeIsolated {
            DependencyContainer.shared
        }
    }
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    @MainActor
    func withDependencies(_ container: DependencyContainer? = nil) -> some View {
        self.environment(\.dependencies, container ?? .shared)
    }
}
