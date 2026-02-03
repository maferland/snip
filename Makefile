.PHONY: build test release install clean app

VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
NEXT_VERSION ?= $(VERSION)

build:
	swift build -c release

test:
	swift test

app: test
	./scripts/package_app.sh $(NEXT_VERSION)

install: app
	cp -R CleanCopy.app /Applications/
	@echo "✅ Installed CleanCopy.app to /Applications"

clean:
	rm -rf .build *.dmg CleanCopy.app

# Usage: make release VERSION=v1.1.0 NEXT_VERSION=v1.2.0
release: app
	@if [ "$(VERSION)" = "$(NEXT_VERSION)" ]; then \
		echo "Error: specify NEXT_VERSION=vX.Y.Z"; exit 1; \
	fi
	gh release create $(NEXT_VERSION) CleanCopy-$(NEXT_VERSION)-macos.dmg \
		--title "CleanCopy $(NEXT_VERSION)" \
		--generate-notes
	@rm CleanCopy-$(NEXT_VERSION)-macos.dmg
	@echo "Released: https://github.com/maferland/clean-copy/releases/tag/$(NEXT_VERSION)"
