PREFIX = /usr/local

.PHONY : compile
compile:
	swift build --disable-sandbox -c release

.PHONY : install
install: compile
	sudo mkdir -p $(PREFIX)/bin
	sudo cp -p ./.build/release/ls2xsR $(PREFIX)/bin

.PHONY : xcodeproj
xcodeproj:
	swift package generate-xcodeproj
