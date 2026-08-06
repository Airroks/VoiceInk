import Foundation
import LLMkit
import SwiftUI

class OllamaService: ObservableObject {
    static let defaultBaseURL = "http://localhost:11434"

    // MARK: - Published Properties
    @Published var baseURL: String {
        didSet {
            UserDefaults.standard.set(baseURL, forKey: "ollamaBaseURL")
        }
    }

    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "ollamaSelectedModel")
        }
    }

    @Published var availableModels: [OllamaModel] = []
    @Published var isConnected: Bool = false
    @Published var isLoadingModels: Bool = false

    private let defaultTemperature: Double = 0.3

    // Context window pinned on every request (load and generate). Without it,
    // current Ollama loads models with their full advertised context window,
    // which explodes the KV cache (qwen3: 262k -> ~24 GB). Overridable via
    // UserDefaults key "OllamaNumCtx".
    private static var contextWindow: Int {
        let stored = UserDefaults.standard.integer(forKey: "OllamaNumCtx")
        return stored > 0 ? stored : 8192
    }

    init() {
        self.baseURL = UserDefaults.standard.string(forKey: "ollamaBaseURL") ?? Self.defaultBaseURL
        self.selectedModel = UserDefaults.standard.string(forKey: "ollamaSelectedModel") ?? "llama2"
    }

    private var baseURLValue: URL? {
        URL(string: baseURL)
    }

    @MainActor
    func checkConnection() async {
        guard let url = baseURLValue else {
            isConnected = false
            return
        }
        isConnected = await OllamaClient.checkConnection(baseURL: url)
    }

    @MainActor
    func refreshModels() async {
        _ = await refreshConnectionAndModels()
    }

    @MainActor
    func refreshConnectionAndModels() async -> Result<[OllamaModel], Error> {
        isLoadingModels = true
        defer { isLoadingModels = false }

        guard let url = baseURLValue else {
            isConnected = false
            availableModels = []
            return .failure(LocalAIError.invalidURL)
        }

        do {
            let models = try await OllamaClient.fetchModels(baseURL: url)
            isConnected = true
            availableModels = models

            if !models.contains(where: { $0.name == selectedModel }) && !models.isEmpty {
                selectedModel = models[0].name
            }

            return .success(models)
        } catch {
            isConnected = false
            availableModels = []
            return .failure(error)
        }
    }

    /// Loads the selected model into memory without generating tokens, so the
    /// first real request (e.g. the offline enhancement fallback) skips the
    /// cold start. Fire-and-forget: errors are intentionally ignored.
    func prewarmSelectedModel() async {
        guard let url = baseURLValue?.appendingPathComponent("api/generate") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        let payload: [String: Any] = [
            "model": selectedModel,
            "prompt": "",
            "keep_alive": "15m",
            "options": ["num_ctx": Self.contextWindow],
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        _ = try? await URLSession.shared.data(for: request)
    }

    func enhance(
        _ text: String, withSystemPrompt systemPrompt: String? = nil, model: String? = nil, timeout: TimeInterval = 30
    ) async throws -> String {
        guard let systemPrompt = systemPrompt else {
            throw LocalAIError.invalidRequest
        }

        guard let url = baseURLValue else {
            throw LocalAIError.invalidURL
        }

        let trimmedModel = model?.trimmingCharacters(in: .whitespacesAndNewlines)
        let requestModel = (trimmedModel?.isEmpty == false ? trimmedModel : nil) ?? selectedModel

        // Direct request instead of LLMkit's OllamaClient: we must pin num_ctx.
        // Without it, current Ollama loads the model with its full context window
        // (262k for qwen3 -> ~24 GB KV cache) and generation slows to a crawl.
        var request = URLRequest(url: url.appendingPathComponent("api/generate"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout
        let payload: [String: Any] = [
            "model": requestModel,
            "prompt": text,
            "system": systemPrompt,
            "stream": false,
            "think": false,
            "options": [
                "num_ctx": Self.contextWindow,
                "temperature": defaultTemperature,
            ],
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            throw LocalAIError.invalidRequest
        }
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw LocalAIError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                if http.statusCode == 404 { throw LocalAIError.modelNotFound }
                if (500...599).contains(http.statusCode) { throw LocalAIError.serverError }
                throw LocalAIError.invalidResponse
            }

            struct GenerateResponse: Decodable {
                let response: String
            }
            guard let decoded = try? JSONDecoder().decode(GenerateResponse.self, from: data) else {
                throw LocalAIError.invalidResponse
            }
            let trimmed = decoded.response.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw LocalAIError.invalidResponse
            }
            return trimmed
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw LocalAIError.timeout
            case .cannotConnectToHost, .networkConnectionLost, .cannotFindHost:
                throw LocalAIError.serviceUnavailable
            default:
                throw LocalAIError.serviceUnavailable
            }
        }
    }

}

// MARK: - Error Types
enum LocalAIError: Error, LocalizedError {
    case invalidURL
    case serviceUnavailable
    case invalidResponse
    case modelNotFound
    case serverError
    case invalidRequest
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "Invalid Ollama server URL")
        case .serviceUnavailable:
            return String(localized: "Ollama service is not available")
        case .invalidResponse:
            return String(localized: "Invalid response from Ollama server")
        case .modelNotFound:
            return String(localized: "Selected model not found")
        case .serverError:
            return String(localized: "Ollama server error")
        case .invalidRequest:
            return String(localized: "System prompt is required")
        case .timeout:
            return String(localized: "Ollama request timed out")
        }
    }
}
