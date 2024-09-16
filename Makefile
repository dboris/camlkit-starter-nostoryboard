.PHONY: build clean open

PRODUCT := CamlLib.xcframework
BUILD_DIR := _build
LIB_DIR := CamlLib

$(PRODUCT): $(BUILD_DIR)/libCamlLib.a
	rm -rf $@
	xcodebuild -create-xcframework -output $@ \
		-library $(BUILD_DIR)/device.ios/$(LIB_DIR)/libCamlLib.a \
		-library $^ \
		-allow-internal-distribution

$(BUILD_DIR)/libCamlLib.a: build
	lipo -create -output $@ \
		$(BUILD_DIR)/simulator.ios/$(LIB_DIR)/libCamlLib.a \
		$(BUILD_DIR)/simulator-arm.ios/$(LIB_DIR)/libCamlLib.a

build:
	dune build @default

clean:
	dune clean

open:
	open CamlApp.xcodeproj
