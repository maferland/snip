.PHONY: build test release install clean

VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
NEXT_VERSION ?= $(VERSION)

build:
	swift build -c release

test:
	swift test

install: build
	sudo cp .build/release/CleanCopy /usr/local/bin/

clean:
	rm -rf .build *.dmg

# Usage: make release VERSION=v1.1.0
release: test build
	@if [ "$(VERSION)" = "$(NEXT_VERSION)" ]; then \
		echo "Error: specify VERSION=vX.Y.Z"; exit 1; \
	fi
	@echo "Creating DMG..."
	@rm -rf /tmp/CleanCopy-dmg
	@mkdir -p /tmp/CleanCopy-dmg
	@cp .build/release/CleanCopy /tmp/CleanCopy-dmg/
	@ln -s /usr/local/bin /tmp/CleanCopy-dmg/Install\ Here
	hdiutil create -volname "CleanCopy $(NEXT_VERSION)" \
		-srcfolder /tmp/CleanCopy-dmg \
		-ov -format UDZO \
		CleanCopy-$(NEXT_VERSION)-macos.dmg
	@rm -rf /tmp/CleanCopy-dmg
	gh release create $(NEXT_VERSION) CleanCopy-$(NEXT_VERSION)-macos.dmg \
		--title "CleanCopy $(NEXT_VERSION)" \
		--generate-notes
	@rm CleanCopy-$(NEXT_VERSION)-macos.dmg
	@echo "Released: https://github.com/maferland/clean-copy/releases/tag/$(NEXT_VERSION)"
