.PHONY: build clean open

PRODUCT := CamlLib.xcframework
BUILD_DIR := _build
LIB_DIR := CamlLib

$(PRODUCT): build
	rm -rf $@
	xcodebuild -create-xcframework -output $@ \
		-library $(BUILD_DIR)/device.ios/$(LIB_DIR)/libCamlLib.a \
		-library $(BUILD_DIR)/simulator.ios/$(LIB_DIR)/libCamlLib.a \
		-allow-internal-distribution

build:
	dune build @default

clean:
	dune clean

open:
	open CamlApp.xcodeproj
