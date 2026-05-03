# Makefile for Bubble Translate iOS App
# Build .ipa for jailbroken iPhone 6s (iOS 15.8.5)

APP_NAME = BubbleTranslate
BUNDLE_ID = com.bubbletranslate.app
SCHEME = BubbleTranslate
ARCHIVE_PATH = build/$(APP_NAME).xcarchive
IPA_PATH = build/$(APP_NAME).ipa
EXPORT_OPTIONS = ExportOptions.plist

.PHONY: all clean project build archive ipa install

# Generate Xcode project from project.yml using xcodegen
project:
	@echo "🔧 Generating Xcode project..."
	xcodegen generate
	@echo "✅ Project generated: $(APP_NAME).xcodeproj"

# Build for device (no signing)
build:
	@echo "🔨 Building $(APP_NAME)..."
	xcodebuild clean build \
		-project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		-sdk iphoneos \
		-arch arm64 \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		DEVELOPMENT_TEAM="" \
		ONLY_ACTIVE_ARCH=NO

# Archive for IPA export
archive:
	@echo "📦 Archiving $(APP_NAME)..."
	xcodebuild archive \
		-project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		-sdk iphoneos \
		-arch arm64 \
		-archivePath $(ARCHIVE_PATH) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		DEVELOPMENT_TEAM=""

# Export IPA from archive
ipa: archive
	@echo "📱 Exporting IPA..."
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath build \
		-exportOptionsPlist $(EXPORT_OPTIONS) \
		-allowProvisioningUpdates
	@echo "✅ IPA created: $(IPA_PATH)"

# Manual IPA creation (if xcodebuild export fails)
manual-ipa: archive
	@echo "📱 Creating IPA manually..."
	mkdir -p build/Payload
	cp -r $(ARCHIVE_PATH)/Products/Applications/$(APP_NAME).app build/Payload/
	ldid -S build/Payload/$(APP_NAME).app/$(APP_NAME)
	cd build && zip -r $(APP_NAME).ipa Payload/
	rm -rf build/Payload
	@echo "✅ IPA created: $(IPA_PATH)"

# Install to device via usbmuxd/iproxy (jailbroken)
install: ipa
	@echo "📲 Installing to device..."
	scp $(IPA_PATH) root@localhost:$(IPA_PATH)
	ssh root@localhost "dpkg -i $(IPA_PATH)"
	@echo "✅ Installed! Respring..."
	ssh root@localhost "killall SpringBoard"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	rm -rf build/
	rm -rf $(APP_NAME).xcodeproj
	@echo "✅ Clean complete"

all: project ipa
