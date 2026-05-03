import Foundation

// Translation result model
struct TranslationResult: Codable {
    let translation: String?
    let original: String?
    let error: String?
    
    var isSuccess: Bool {
        return translation != nil && error == nil
    }
}

// History item for saved translations
struct HistoryItem: Codable {
    let id: UUID
    let original: String
    let translation: String
    let timestamp: Date
    let mode: TranslationMode
    
    enum TranslationMode: String, Codable {
        case text
        case ocr
    }
}

// App configuration
struct AppConfig {
    // Translation API endpoint - change this to your deployed server
    static let translationAPIBaseURL = "http://localhost:3000"
    
    // Or use your deployed URL:
    // static let translationAPIBaseURL = "https://your-server.com"
    
    static let translateTextEndpoint = "\(translationAPIBaseURL)/api/translate"
    static let translateImageEndpoint = "\(translationAPIBaseURL)/api/translate-image"
    
    // Bubble settings
    static let bubbleSize: CGFloat = 52
    static let bubbleCornerRadius: CGFloat = 26
    static let bubbleEdgePadding: CGFloat = 8
    static let translationPanelWidth: CGFloat = 320
    static let translationPanelMaxHeight: CGFloat = 400
    
    // Animation
    static let bubbleAppearAnimationDuration: TimeInterval = 0.3
    static let panelAppearAnimationDuration: TimeInterval = 0.25
}
