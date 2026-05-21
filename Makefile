APP_NAME := PetCompanion
BUILD_DIR := .build/local
MODULE_CACHE := .build/module-cache
SOURCES := $(shell find Sources/PetCompanion -name '*.swift' | sort)
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
APP_EXECUTABLE := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
ARCH := $(shell uname -m)

.PHONY: build run clean

build:
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS $(APP_BUNDLE)/Contents/Resources $(MODULE_CACHE)
	CLANG_MODULE_CACHE_PATH=$(MODULE_CACHE) swiftc \
		-target $(ARCH)-apple-macosx13.0 \
		-framework AppKit \
		-framework SpriteKit \
		-o $(APP_EXECUTABLE) \
		$(SOURCES)
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/Info.plist

run: build
	open $(APP_BUNDLE)

clean:
	rm -rf .build
