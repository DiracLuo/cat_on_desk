APP_NAME := PetCompanion
BUILD_DIR := .build/local
MODULE_CACHE := .build/module-cache
SOURCES := $(shell find Sources/PetCompanion -name '*.swift' | sort)
SPRITE_SOURCES := $(shell find Resources/CatSprites -name '*.png' 2>/dev/null | sort)
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
APP_EXECUTABLE := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
USER_APP_BUNDLE := $(HOME)/Applications/萌宠陪伴.app
VERSION := 1.0.0
DIST_DIR := dist/$(VERSION)
DIST_APP := $(DIST_DIR)/萌宠陪伴.app
DIST_DMG := $(DIST_DIR)/萌宠陪伴-$(VERSION).dmg
DIST_ZIP := $(DIST_DIR)/萌宠陪伴-$(VERSION).zip
ARCH := $(shell uname -m)

.PHONY: assets build package run install-user run-installed reveal quit clean

assets:
	@mkdir -p Resources/CatSprites $(MODULE_CACHE)
	CLANG_MODULE_CACHE_PATH=$(MODULE_CACHE) swift Tools/GenerateCatSprites.swift Resources/CatSprites

build: assets
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS $(APP_BUNDLE)/Contents/Resources $(MODULE_CACHE)
	CLANG_MODULE_CACHE_PATH=$(MODULE_CACHE) swiftc \
		-target $(ARCH)-apple-macosx13.0 \
		-framework AppKit \
		-framework ServiceManagement \
		-framework SpriteKit \
		-o $(APP_EXECUTABLE) \
		$(SOURCES)
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	ditto Resources/CatSprites $(APP_BUNDLE)/Contents/Resources/CatSprites

package: build
	@mkdir -p $(DIST_DIR)
	ditto $(APP_BUNDLE) $(DIST_APP)
	ditto -c -k --keepParent $(DIST_APP) $(DIST_ZIP)
	hdiutil create -volname "萌宠陪伴 $(VERSION)" -srcfolder $(DIST_APP) -ov -format UDZO $(DIST_DMG) || echo "DMG creation skipped; ZIP package is available at $(DIST_ZIP)"

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
