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
	cp -R Snip.app /Applications/
	@echo "✅ Installed Snip.app to /Applications"

clean:
	rm -rf .build *.dmg Snip.app

# Usage: make release NEXT_VERSION=v1.2.0
# Tags and pushes — CI handles build, sign, notarize, GitHub release, and homebrew tap.
release: test
	@if [ "$(VERSION)" = "$(NEXT_VERSION)" ]; then \
		echo "Error: specify NEXT_VERSION=vX.Y.Z"; exit 1; \
	fi
	git tag $(NEXT_VERSION)
	git push origin main $(NEXT_VERSION)
	@echo "Tagged $(NEXT_VERSION) — CI will build, sign, notarize, and release."
	@echo "Watch: gh run watch"
