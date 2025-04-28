import SwiftUI
import AVFoundation
import Foundation
import GoogleGenerativeAI


struct ContentView: View {
    @StateObject var whisperState = WhisperState()
    let modelGenAI = GenerativeModel(name: "gemini-2.0-flash", apiKey: APIKey.default) // gemini api
    @State var textInput = ""
    @State var geminiResponse = "Hello! I am M.A.V.I.S, how can I help?"
    @StateObject private var speechManager = SpeechManager()
    @State private var isFirstCall = true
 
    var body: some View {
        NavigationStack {
            ZStack{
                Color.black
                    .ignoresSafeArea()
            VStack {
                HStack {
                    Button(whisperState.isRecording ? "Done" : "Ask M.A.V.I.S. (Start Recording)", action: {
                        Task {
                            await whisperState.toggleRecord()
                        }
                    })
                    .disabled(!whisperState.canTranscribe)
                    .foregroundColor(Color(red: 1, green: 1, blue: 1))
                    .font(.custom("SF Pro Display", size: 12))
                    .padding(.bottom, 0.0047)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(red: 0.173, green: 0.255, blue: 1))
                            .padding(.top, 25)
                            .edgesIgnoringSafeArea(.bottom)
                    )
                }

                ScrollView {
                    Text(geminiResponse) // load gemini response
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
            
                    Text(verbatim: whisperState.messageLog) // message log, whisper
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                    
                    // integrate voice input, send to Gemini
                    .onChange(of: whisperState.messageLog) { newLog in
                        // ignore first call (when model is loaded)
                        guard !newLog.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        if isFirstCall {
                            isFirstCall = false
                            } else {
                            sendLogToGemini(log: newLog)
                        }
                    }
                }
                .font(.custom("SF Pro Display", size: 14))
                .padding()
                .background(Color(red: 0.0747, green: 0.0747, blue: 0.0817))
                .cornerRadius(10)
                
                HStack {
                    Button("Clear Logs", action: {
                        whisperState.messageLog = ""
                        geminiResponse = ""
                    })
                    .foregroundColor(Color(red: 1, green: 1, blue: 1))
                    .frame(minWidth: 100)
                    .font(.custom("SF Pro Display", size: 12))
                    .padding(.bottom, 0.0047)
                    .overlay(
                        Rectangle() // Create a rectangle for the bottom border
                            .frame(height: 2) // Set the height of the border
                            .foregroundColor(Color(red: 0.173, green: 0.255, blue: 1)) // Set the color to red
                            .padding(.top, 25) // Ensure it is at the bottom (adjust as needed)
                            .edgesIgnoringSafeArea(.bottom) // Ignore safe areas if necessary
                    )
                    
                    NavigationLink(destination: ModelsView(whisperState: whisperState)
                    ) {
                        Text("View Models")
                            .frame(minWidth: 100)
                            .font(.custom("SF Pro Display", size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(red: 0.173, green: 0.255, blue: 1))
                            .padding(.top, 25)
                            .edgesIgnoringSafeArea(.bottom)
                    )
                    
                    Button("Copy Logs", action: {
                        UIPasteboard.general.string = whisperState.messageLog
                    })
                    .foregroundColor(Color(red: 1, green: 1, blue: 1))
                    .frame(minWidth: 100)
                    .font(.custom("SF Pro Display", size: 12))
                    .padding(.bottom, 0.0047)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(red: 0.173, green: 0.255, blue: 1))
                            .padding(.top, 25)
                            .edgesIgnoringSafeArea(.bottom)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0){
                        Text("M.A.V.I.S: My Average Very Intelligent System")
                            .font(.custom("SF Pro Display", size: 16))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 10)
                    .multilineTextAlignment(.center)
                }
            }
            .padding(10)
        }
        }
    }

    struct ModelsView: View {
        @ObservedObject var whisperState: WhisperState
        @Environment(\.dismiss) var dismiss
        
        private static let models: [Model] = [
            Model(name: "tiny", info: "(F16, 75 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin", filename: "tiny.bin"),
            Model(name: "tiny-q5_1", info: "(31 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny-q5_1.bin", filename: "tiny-q5_1.bin"),
            Model(name: "tiny-q8_0", info: "(42 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny-q8_0.bin", filename: "tiny-q8_0.bin"),
            Model(name: "tiny.en", info: "(F16, 75 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin", filename: "tiny.en.bin"),
            Model(name: "tiny.en-q5_1", info: "(31 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en-q5_1.bin", filename: "tiny.en-q5_1.bin"),
            Model(name: "tiny.en-q8_0", info: "(42 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en-q8_0.bin", filename: "tiny.en-q8_0.bin"),
            Model(name: "base", info: "(F16, 142 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin", filename: "base.bin"),
            Model(name: "base-q5_1", info: "(57 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base-q5_1.bin", filename: "base-q5_1.bin"),
            Model(name: "base-q8_0", info: "(78 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base-q8_0.bin", filename: "base-q8_0.bin"),
            Model(name: "base.en", info: "(F16, 142 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin", filename: "base.en.bin"),
            Model(name: "base.en-q5_1", info: "(57 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en-q5_1.bin", filename: "base.en-q5_1.bin"),
            Model(name: "base.en-q8_0", info: "(78 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en-q8_0.bin", filename: "base.en-q8_0.bin"),
            Model(name: "small", info: "(F16, 466 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin", filename: "small.bin"),
            Model(name: "small-q5_1", info: "(181 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small-q5_1.bin", filename: "small-q5_1.bin"),
            Model(name: "small-q8_0", info: "(252 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small-q8_0.bin", filename: "small-q8_0.bin"),
            Model(name: "small.en", info: "(F16, 466 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin", filename: "small.en.bin"),
            Model(name: "small.en-q5_1", info: "(181 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en-q5_1.bin", filename: "small.en-q5_1.bin"),
            Model(name: "small.en-q8_0", info: "(252 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en-q8_0.bin", filename: "small.en-q8_0.bin"),
            Model(name: "medium", info: "(F16, 1.5 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin", filename: "medium.bin"),
            Model(name: "medium-q5_0", info: "(514 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium-q5_0.bin", filename: "medium-q5_0.bin"),
            Model(name: "medium-q8_0", info: "(785 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium-q8_0.bin", filename: "medium-q8_0.bin"),
            Model(name: "medium.en", info: "(F16, 1.5 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin", filename: "medium.en.bin"),
            Model(name: "medium.en-q5_0", info: "(514 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en-q5_0.bin", filename: "medium.en-q5_0.bin"),
            Model(name: "medium.en-q8_0", info: "(785 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en-q8_0.bin", filename: "medium.en-q8_0.bin"),
            Model(name: "large-v1", info: "(F16, 2.9 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin", filename: "large.bin"),
            Model(name: "large-v2", info: "(F16, 2.9 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v2.bin", filename: "large-v2.bin"),
            Model(name: "large-v2-q5_0", info: "(1.1 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v2-q5_0.bin", filename: "large-v2-q5_0.bin"),
            Model(name: "large-v2-q8_0", info: "(1.5 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v2-q8_0.bin", filename: "large-v2-q8_0.bin"),
            Model(name: "large-v3", info: "(F16, 2.9 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin", filename: "large-v3.bin"),
            Model(name: "large-v3-q5_0", info: "(1.1 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-q5_0.bin", filename: "large-v3-q5_0.bin"),
            Model(name: "large-v3-turbo", info: "(F16, 1.5 GiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin", filename: "large-v3-turbo.bin"),
            Model(name: "large-v3-turbo-q5_0", info: "(547 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin", filename: "large-v3-turbo-q5_0.bin"),
            Model(name: "large-v3-turbo-q8_0", info: "(834 MiB)", url: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q8_0.bin", filename: "large-v3-turbo-q8_0.bin"),
        ]

        static func getDownloadedModels() -> [Model] {
            return models.filter { // Filter models that have been downloaded
                FileManager.default.fileExists(atPath: $0.fileURL.path())
            }
        }
        func loadModel(model: Model) {
            Task {
                dismiss()
                whisperState.loadModel(path: model.fileURL)
            }
        }
        var body: some View {
            List {
                Section(header: Text("Models")) {
                    ForEach(ModelsView.models) { model in
                        DownloadButton(model: model)
                            .onLoad(perform: loadModel)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Models", displayMode: .inline)
            .toolbar{
            }
        }
    }
    func sendLogToGemini(log: String) { // fetch gemini response
        geminiResponse = ""
        Task {
            do {
                let response = try await modelGenAI.generateContent(log + "\nAnswer in a witty way. Limit your output to under 100 words.")
                guard let text = response.text else {
                    geminiResponse = "Sorry, I didn’t catch that. Please try again."
                    return
                }
                geminiResponse = text
                speechManager.speak(text)// use tts
            } catch {
                print("Error: \(error)")
                geminiResponse = "Something went wrong. \(error.localizedDescription)"
            }
        }
    }

    // added to fetch response
    func sendMessage(){
        geminiResponse = ""
        Task {
            do {
                let response = try await modelGenAI.generateContent(textInput + "Answer in a witty way. Do not use emojis.")
                
                guard let text = response.text else {
                    textInput = "Sorry, I did not catch that. \n Please try again."
                    return
                }
                textInput = ""
                geminiResponse = text
                speechManager.speak(text)
                } catch{
                    print("Full error: \(error)")
                    geminiResponse = "Something went wrong. \n\(error.localizedDescription)"
            }
        }
    }
    class SpeechManager: ObservableObject { // tts
        let synthesizer = AVSpeechSynthesizer()
        func speak(_ text: String) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            synthesizer.speak(utterance)
        }
    }
}
