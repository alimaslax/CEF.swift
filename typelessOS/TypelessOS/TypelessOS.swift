import SwiftUI
import UniformTypeIdentifiers
import AppKit

@main
struct TypelessOS: App {
    @StateObject var whisper = WhisperState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init(){
        print("Typeless Init")
        NSApplication.shared.setActivationPolicy(.regular)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(whisperState: whisper)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @ObservedObject var whisperState: WhisperState

    var body: some View {
        VStack(spacing: 20) {
            Text("TypelessOS Audio")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button(action: {
                Task {
                    await whisperState.toggleRecord()
                }
            }) {
                Image(systemName: whisperState.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(whisperState.isRecording ? .red : .accentColor)
            }
            .buttonStyle(PlainButtonStyle())
            
            if whisperState.isRecording {
                Text("Recording...")
                    .foregroundColor(.secondary)
            }
            
            if !whisperState.recentMessage.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Last Transcription:")
                        .font(.headline)
                    Text(whisperState.recentMessage)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 400)
    }
}
