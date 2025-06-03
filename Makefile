SWIFT_VERSION := $(shell swift --version 2>&1 | awk '/Swift version/ {print $$0}' | sed 's/^[^S]*\(Swift version.*\)/\1/')
XCODE_VERSION := $(shell xcodebuild -version)
BUILD_DESTINATION := "platform=iOS Simulator,arch=arm64,name=iPhone 16e,OS=18.5"

default: debug

.PHONY: environment
environment:
	@echo "→ $(XCODE_VERSION)"
	@echo "→ $(SWIFT_VERSION)"
	@echo "→ macOS $(shell sw_vers -productVersion)"

.PHONY: release
release: environment
	@xcodebuild build -project Instagram.xcodeproj -scheme Instagram -configuration Release -destination $(BUILD_DESTINATION) | xcbeautify

.PHONY: debug
debug: environment
	@xcodebuild build -project Instagram.xcodeproj -scheme Instagram -configuration Debug -destination $(BUILD_DESTINATION) | xcbeautify

.PHONY: test
test: environment 
	@set -o pipefail && xcodebuild test -scheme Instagram -destination "platform=iOS Simulator,name=iPhone 16 Pro" | xcbeautify --renderer github-actions

.PHONY: clean
clean:
	@xcodebuild clean -project Instagram.xcodeproj -scheme Instagram -configuration Debug -destination $(BUILD_DESTINATION) | xcbeautify
	@rm -rf DerivedData

fresh:
	@echo "Removing git repo untracked content..."
	@git clean -Xdff

.PHONY: linter-swift
linter-swift:
	swiftlint --config .swiftlint.yml --fix

.PHONY: formatter-swift
formatter-swift:
	swift format --in-place --parallel --recursive Main Modules

.PHONY: pretty
pretty: formatter-swift linter-swift 

.PHONY: unused
unused:
	periphery scan --project Instagram.xcodeproj --schemes Instagram --targets Instagram --retain-swift-ui-previews --retain-objc-accessible
