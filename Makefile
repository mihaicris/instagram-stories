SWIFT_VERSION := $(shell swift --version 2>&1 | awk '/Swift version/ {print $$0}' | sed 's/^[^S]*\(Swift version.*\)/\1/')
XCODE_VERSION := $(shell xcodebuild -version)
DESTINATION := "platform=iOS Simulator,arch=arm64,name=iPhone 16e,OS=18.5"
PROJECT := Instagram.xcodeproj
SCHEME := Instagram
PARAMETERS := -project $(PROJECT) -scheme $(SCHEME) -destination $(DESTINATION)

default: debug

.PHONY: environment
environment:
	@echo "→ $(XCODE_VERSION)"
	@echo "→ $(SWIFT_VERSION)"
	@echo "→ macOS $(shell sw_vers -productVersion)"

.PHONY: release
release: environment
	xcodebuild $(PARAMETERS) -configuration Release build | xcbeautify

.PHONY: debug
debug: environment
	xcodebuild $(PARAMETERS) -configuration Debug build | xcbeautify

.PHONY: spm-update
spm-update:
	rm -f $(PROJECT)/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
	xcodebuild -resolvePackageDependencies $(PARAMETERS) | xcbeautify

.PHONY: test
test: environment 
	@set -o pipefail && xcodebuild test $(PARAMETERS) | xcbeautify --renderer github-actions

.PHONY: clean
clean:
	xcodebuild clean $(PARAMETERS) -configuration Debug  | xcbeautify
	@rm -rf DerivedData

.PHONY: fresh
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
	periphery scan --project $(PROJECT) --schemes Instagram --retain-swift-ui-previews --retain-objc-accessible
