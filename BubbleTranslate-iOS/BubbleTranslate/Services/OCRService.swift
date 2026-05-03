import UIKit
import Vision
import CoreImage

// MARK: - OCR Service

/// Uses Vision framework to capture the screen and recognize Chinese text.
/// Works on iOS 15+ with VNRecognizeTextRequest supporting Chinese.
class OCRService {
    
    /// Capture the current screen content
    func captureScreen(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Method 1: Use CGWindowListCreateImage to capture the screen
            // This works on jailbroken iOS to capture ALL app content
            let screenRect = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width * UIScreen.main.scale,
                height: UIScreen.main.bounds.height * UIScreen.main.scale
            )
            
            guard let cgImage = CGWindowListCreateImage(
                screenRect,
                .optionOnScreenBelowWindow,
                kCGNullWindowID,
                [.bestResolution]
            ) else {
                // Fallback: capture the key window
                DispatchQueue.main.async {
                    let screenshot = self.captureKeyWindow()
                    completion(screenshot)
                }
                return
            }
            
            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            completion(image)
        }
    }
    
    /// Fallback: capture the key window screenshot
    private func captureKeyWindow() -> UIImage? {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: keyWindow.bounds)
        return renderer.image { context in
            keyWindow.layer.render(in: context.cgContext)
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
            
            // Extract recognized text, preferring Chinese
            var recognizedLines: [String] = []
            
            for observation in observations {
                // Get the top candidate
                if let candidate = observation.topCandidates(1).first {
                    let text = candidate.string
                    // Only include lines that contain Chinese or could be relevant
                    if text.containsChinese || self.looksLikeRelevantText(text) {
                        recognizedLines.append(text)
                    }
                }
            }
            
            let fullText = recognizedLines.joined(separator: "\n")
            completion(fullText.isEmpty ? nil : fullText)
        }
        
        // Configure for Chinese text recognition
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.02 // Detect smaller text
        
        // Perform the request
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
        // Include lines with numbers, prices, common keywords
        let hasNumbers = text.range(of: "\\d", options: .regularExpression) != nil
        let hasPrice = text.contains("¥") || text.contains("￥") || text.contains("$")
        let isLongEnough = text.count >= 2
        
        return (hasNumbers || hasPrice) && isLongEnough
    }
}
