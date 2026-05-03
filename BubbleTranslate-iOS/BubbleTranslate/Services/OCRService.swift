import UIKit
import Vision
import CoreImage

// MARK: - OCR Service

/// Uses Vision framework to capture the screen and recognize Chinese text.
/// Works on iOS 15+ with VNRecognizeTextRequest supporting Chinese.
class OCRService {
    
    /// Capture the current screen content using iOS-compatible method
    func captureScreen(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async {
            let screenshot = self.captureKeyWindow()
            completion(screenshot)
        }
    }
    
    /// Capture the key window screenshot (iOS-compatible)
    private func captureKeyWindow() -> UIImage? {
        // iOS 15+ compatible way to find the key window
        let keyWindow: UIWindow?
        if #available(iOS 15.0, *) {
            keyWindow = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        } else {
            keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
        
        guard let window = keyWindow else { return nil }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
    }
    
    /// Recognize Chinese text in an image using Vision framework
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            var recognizedLines: [String] = []
            
            for observation in observations {
                if let candidate = observation.topCandidates(1).first {
                    let text = candidate.string
                    if text.containsChinese || self.looksLikeRelevantText(text) {
                        recognizedLines.append(text)
                    }
                }
            }
            
            let fullText = recognizedLines.joined(separator: "\n")
            completion(fullText.isEmpty ? nil : fullText)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.02
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([request])
            } catch {
                print("Vision request failed: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /// Check if text looks relevant (prices, product names, etc.)
    private func looksLikeRelevantText(_ text: String) -> Bool {
        let hasNumbers = text.range(of: "\\d", options: .regularExpression) != nil
        let hasPrice = text.contains("¥") || text.contains("￥") || text.contains("$")
        let isLongEnough = text.count >= 2
        return (hasNumbers || hasPrice) && isLongEnough
    }
}
