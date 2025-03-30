.PHONY: build sim clean open

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
		$(BUILD_DIR)/simulator-x86.ios/$(LIB_DIR)/libCamlLib.a

build:
	dune build @default

sim:
	dune build @default --workspace dune-workspace.simulator
	rm -rf CamlLib.xcframework
	xcodebuild -create-xcframework -output CamlLib.xcframework \
		-library _build/simulator.ios/CamlLib/libCamlLib.a \
		-allow-internal-distribution

clean:
	dune clean

open:
	open CamlApp.xcodeproj
