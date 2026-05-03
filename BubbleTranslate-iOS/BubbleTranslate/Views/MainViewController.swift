import UIKit
import AVFoundation

// MARK: - Main View Controller

/// The main app view with settings and instructions.
/// This is what the user sees when they open the app directly.
class MainViewController: UIViewController {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconView = UIView()
    private let iconLabel = UILabel()
    private let statusCard = UIView()
    private let statusLabel = UILabel()
    private let statusDetailLabel = UILabel()
    private let bubbleToggle = UISwitch()
    private let instructionsCard = UIView()
    private let serverField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateStatus()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 0.06, green: 0.07, blue: 0.11, alpha: 1.0)
        
        // ScrollView
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // App Icon
        iconView.backgroundColor = UIColor.bubbleGradientStart
        iconView.layer.cornerRadius = 30
        iconView.clipsToBounds = true
        contentView.addSubview(iconView)
        
        iconLabel.text = "中→A"
        iconLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        iconLabel.textColor = .white
        iconView.addSubview(iconLabel)
        
        // Title
        titleLabel.text = "Bubble Translate"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Floating Chinese → English Translator"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.5)
        contentView.addSubview(subtitleLabel)
        
        // Status Card
        statusCard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        statusCard.layer.cornerRadius = 16
        statusCard.layer.borderColor = UIColor.panelBorder.cgColor
        statusCard.layer.borderWidth = 1
        contentView.addSubview(statusCard)
        
        statusLabel.text = "● Bubble Active"
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        statusLabel.textColor = .systemGreen
        statusCard.addSubview(statusLabel)
        
        statusDetailLabel.text = "The floating bubble is visible on your screen.\nSwitch to any app and tap the bubble to translate."
        statusDetailLabel.font = UIFont.systemFont(ofSize: 13)
        statusDetailLabel.textColor = UIColor(white: 1, alpha: 0.5)
        statusDetailLabel.numberOfLines = 0
        statusCard.addSubview(statusDetailLabel)
        
        // Bubble toggle
        let toggleLabel = UILabel()
        toggleLabel.text = "Show Floating Bubble"
        toggleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        toggleLabel.textColor = .white
        statusCard.addSubview(toggleLabel)
        
        bubbleToggle.isOn = true
        bubbleToggle.onTintColor = .panelAccent
        bubbleToggle.addTarget(self, action: #selector(toggleBubble), for: .valueChanged)
        statusCard.addSubview(bubbleToggle)
        
        // Instructions Card
        instructionsCard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        instructionsCard.layer.cornerRadius = 16
        instructionsCard.layer.borderColor = UIColor.panelBorder.cgColor
        instructionsCard.layer.borderWidth = 1
        contentView.addSubview(instructionsCard)
        
        let instructionsTitle = UILabel()
        instructionsTitle.text = "How to Use with Xianyu"
        instructionsTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instructionsTitle.textColor = .white
        instructionsCard.addSubview(instructionsTitle)
        
        let instructions = [
            "1. Open Xianyu (闲鱼) app",
            "2. Navigate to a product listing",
            "3. Tap the floating bubble on screen",
            "4. The app captures the screen & reads Chinese text",
            "5. You get instant English translation!",
            "",
            "💡 Tip: You can also copy Chinese text first, then tap the bubble to translate from clipboard."
        ]
        
        let instructionsLabel = UILabel()
        instructionsLabel.text = instructions.joined(separator: "\n")
        instructionsLabel.font = UIFont.systemFont(ofSize: 13)
        instructionsLabel.textColor = UIColor(white: 1, alpha: 0.6)
        instructionsLabel.numberOfLines = 0
        instructionsCard.addSubview(instructionsLabel)
        
        // Server URL Configuration
        let serverCard = UIView()
        serverCard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        serverCard.layer.cornerRadius = 16
        serverCard.layer.borderColor = UIColor.panelBorder.cgColor
        serverCard.layer.borderWidth = 1
        contentView.addSubview(serverCard)
        
        let serverTitle = UILabel()
        serverTitle.text = "Translation Server"
        serverTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        serverTitle.textColor = .white
        serverCard.addSubview(serverTitle)
        
        let serverDesc = UILabel()
        serverDesc.text = "Enter your translation API server URL"
        serverDesc.font = UIFont.systemFont(ofSize: 12)
        serverDesc.textColor = UIColor(white: 1, alpha: 0.4)
        serverCard.addSubview(serverDesc)
        
        serverField.text = AppConfig.translationAPIBaseURL
        serverField.font = UIFont.systemFont(ofSize: 14)
        serverField.textColor = .white
        serverField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        serverField.layer.cornerRadius = 10
        serverField.layer.borderColor = UIColor.panelAccent.withAlphaComponent(0.3).cgColor
        serverField.layer.borderWidth = 1
        serverField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        serverField.leftViewMode = .always
        serverField.keyboardType = .URL
        serverField.autocorrectionType = .no
        serverField.autocapitalizationType = .none
        serverCard.addSubview(serverField)
        
        saveButton.setTitle("Save & Test Connection", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .panelAccent
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveServerURL), for: .touchUpInside)
        serverCard.addSubview(saveButton)
        
        // Layout using frames
        let screenW = UIScreen.main.bounds.width
        let padding: CGFloat = 20
        let cardPadding: CGFloat = 16
        let contentWidth = screenW - padding * 2
        var y: CGFloat = 60 // Top safe area
        
        // Icon
        iconView.frame = CGRect(x: (screenW - 60) / 2, y: y, width: 60, height: 60)
        iconLabel.frame = iconView.bounds
        y += 76
        
        // Title
        titleLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: 34)
        titleLabel.textAlignment = .center
        y += 38
        
        // Subtitle
        subtitleLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: 20)
        subtitleLabel.textAlignment = .center
        y += 36
        
        // Status card
        statusCard.frame = CGRect(x: padding, y: y, width: contentWidth, height: 130)
        statusLabel.frame = CGRect(x: cardPadding, y: cardPadding, width: 200, height: 22)
        statusDetailLabel.frame = CGRect(x: cardPadding, y: 42, width: contentWidth - cardPadding * 2 - 60, height: 50)
        toggleLabel.frame = CGRect(x: cardPadding, y: 96, width: 200, height: 22)
        bubbleToggle.frame = CGRect(x: contentWidth - cardPadding - 51, y: 94, width: 51, height: 31)
        y += 146
        
        // Instructions card
        instructionsTitle.frame = CGRect(x: cardPadding, y: cardPadding, width: contentWidth - cardPadding * 2, height: 22)
        instructionsLabel.frame = CGRect(x: cardPadding, y: 38, width: contentWidth - cardPadding * 2, height: 180)
        instructionsCard.frame = CGRect(x: padding, y: y, width: contentWidth, height: 228)
        y += 244
        
        // Server card
        serverTitle.frame = CGRect(x: cardPadding, y: cardPadding, width: contentWidth - cardPadding * 2, height: 22)
        serverDesc.frame = CGRect(x: cardPadding, y: 36, width: contentWidth - cardPadding * 2, height: 18)
        serverField.frame = CGRect(x: cardPadding, y: 60, width: contentWidth - cardPadding * 2, height: 44)
        saveButton.frame = CGRect(x: cardPadding, y: 114, width: contentWidth - cardPadding * 2, height: 44)
        serverCard.frame = CGRect(x: padding, y: y, width: contentWidth, height: 174)
        y += 190
        
        // Set content size
        contentView.frame = CGRect(x: 0, y: 0, width: screenW, height: y)
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: screenW, height: y)
    }
    
    private func updateStatus() {
        let isActive = FloatingBubbleManager.shared.isBubbleVisible
        bubbleToggle.isOn = isActive
        statusLabel.text = isActive ? "● Bubble Active" : "● Bubble Inactive"
        statusLabel.textColor = isActive ? .systemGreen : .systemRed
    }
    
    @objc private func toggleBubble() {
        if bubbleToggle.isOn {
            FloatingBubbleManager.shared.start()
        } else {
            FloatingBubbleManager.shared.stop()
        }
        updateStatus()
    }
    
    @objc private func saveServerURL() {
        guard let url = serverField.text, !url.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid server URL")
            return
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(url, forKey: "translationAPIBaseURL")
        
        // Test connection
        saveButton.setTitle("Testing...", for: .normal)
        saveButton.isEnabled = false
        
        let testURL = URL(string: "\(url)/api/translate")!
        var request = URLRequest(url: testURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["text": "你好"])
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(title: "Connection Failed", message: error.localizedDescription)
                    self?.saveButton.setTitle("Save & Test Connection", for: .normal)
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self?.showAlert(title: "✓ Connected!", message: "Translation server is working correctly.")
                    self?.saveButton.setTitle("✓ Connected", for: .normal)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.saveButton.setTitle("Save & Test Connection", for: .normal)
                    }
                } else {
                    self?.showAlert(title: "Server Error", message: "Server responded with an error. Check the URL.")
                    self?.saveButton.setTitle("Save & Test Connection", for: .normal)
                }
            }
        }.resume()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
