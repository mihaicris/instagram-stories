SWIFT_VERSION := $(shell swift --version 2>&1 | awk '/Swift version/ {print $$0}' | sed 's/^[^S]*\Swift version \(.*\)/\1/')
XCODE_VERSION := $(shell xcodebuild -version | awk 'NR==1{v=$$2} NR==2{print v, $$0}')

DEVICE ?= "iPhone 16e"
DEVICE_NO_QUOTES := $(shell echo $(DEVICE) | sed 's/"//g')
PLATFORM := iOS Simulator
ARCH := arm64
IOS_SDK := 18.5
DESTINATION := "platform=$(PLATFORM),arch=$(ARCH),name=$(DEVICE_NO_QUOTES),OS=$(IOS_SDK)"
CONFIGURATION ?= Debug
PROJECT_NAME := Instagram
PROJECT_FILE := $(PROJECT_NAME).xcodeproj
BUNDLE_ID := ro.mihaicris.$(PROJECT_NAME)
SCHEME := $(PROJECT_NAME)
PARAMETERS := -project $(PROJECT_FILE) -scheme $(SCHEME) -destination $(DESTINATION)
DERIVED_DATA := $(shell echo $$HOME)/Library/Developer/Xcode/DerivedData

COLOR := \033[1;32m
RESET := \033[0m

default: install

.PHONY: environment
environment:
	@echo ""
	@echo "$(COLOR)Xcode: $(RESET)$(XCODE_VERSION)"
	@echo "$(COLOR)Swift: $(RESET)$(SWIFT_VERSION)"
	@echo "$(COLOR)macOS: $(RESET)$(shell sw_vers -productVersion)"
	@echo "$(COLOR)Swiftlint: $(RESET)$(shell swiftlint version)"

.PHONY: build
build: environment
	@echo "$(COLOR)Project configuration: $(RESET)$(CONFIGURATION)"
	@echo "$(COLOR)Destination: $(RESET)$(DESTINATION)"
	@set -o pipefail && xcodebuild $(PARAMETERS) -configuration $(CONFIGURATION) build | xcbeautify

.PHONY: debug
debug:
	@$(MAKE) CONFIGURATION=Debug build
	
.PHONY: release
release:
	@$(MAKE) CONFIGURATION=Release build
	
.PHONY: install
install: build
	@echo "$(COLOR)Booting simulator$(RESET)"
	@xcrun simctl boot $(DEVICE) >/dev/null 2>&1 || true
	@open -a Simulator
	@APP_PATH=$$(find $(DERIVED_DATA) -path "*/Build/Products/$(CONFIGURATION)-iphonesimulator/$(PROJECT_NAME).app" -type d | head -n 1); \
	if [ -z "$$APP_PATH" ]; then \
		echo "❌ .app not found"; exit 1; \
	fi; \
	BASENAME=$$(basename "$$APP_PATH"); \
	echo "$(COLOR)Installing $$BASENAME$(RESET)"; \
	xcrun simctl install booted "$$APP_PATH" >/dev/null; \
	echo "$(COLOR)Launching $(BUNDLE_ID)$(RESET)"; \
	xcrun simctl launch booted $(BUNDLE_ID)

.PHONY: test
test: environment 
	@set -o pipefail && xcodebuild $(PARAMETERS) test | xcbeautify --renderer github-actions

.PHONY: clean
clean: environment
	@set -o pipefail && xcodebuild $(PARAMETERS) clean | xcbeautify
	@rm -rf DerivedData

.PHONY: spm-update
spm-update:
	rm -f $(PROJECT_FILE)/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
	@set -o pipefail && xcodebuild -resolvePackageDependencies $(PARAMETERS) | xcbeautify

.PHONY: fresh
fresh:
	@echo "Removing git repo untracked content..."
	@git clean -Xdff

.PHONY: linter-swift
linter-swift:
	@swiftlint --config .swiftlint.yml --fix

.PHONY: formatter-swift
formatter-swift:
	@swift format --in-place --parallel --recursive Main Modules

.PHONY: pretty
pretty: formatter-swift linter-swift 

.PHONY: unused
unused:
	@periphery scan --project $(PROJECT_FILE) --schemes $(SCHEME) --retain-swift-ui-previews --retain-objc-accessible

.PHONY: derived-data
derived-data:
	@open $(DERIVED_DATA)

