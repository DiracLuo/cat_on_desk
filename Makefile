APP_NAME := PetCompanion
BUILD_DIR := .build/local
MODULE_CACHE := .build/module-cache
SOURCES := $(shell find Sources/PetCompanion -name '*.swift' | sort)
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
APP_EXECUTABLE := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
USER_APP_BUNDLE := $(HOME)/Applications/萌宠陪伴.app
ARCH := $(shell uname -m)

.PHONY: build run install-user run-installed reveal quit clean

build:
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS $(APP_BUNDLE)/Contents/Resources $(MODULE_CACHE)
	CLANG_MODULE_CACHE_PATH=$(MODULE_CACHE) swiftc \
		-target $(ARCH)-apple-macosx13.0 \
		-framework AppKit \
		-framework ServiceManagement \
		-framework SpriteKit \
		-o $(APP_EXECUTABLE) \
		$(SOURCES)
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/Info.plist

run: build
	open $(APP_BUNDLE)

install-user: build
	mkdir -p $(HOME)/Applications
	ditto $(APP_BUNDLE) $(USER_APP_BUNDLE)

run-installed: install-user
	open $(USER_APP_BUNDLE)

reveal: build
	open -R $(APP_BUNDLE)

quit:
	osascript -e 'tell application "萌宠陪伴" to quit'

clean:
	rm -rf .build
