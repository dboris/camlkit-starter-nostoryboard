# Setup

```sh
opam repository add ios https://github.com/ocaml-cross/opam-cross-ios.git

opam switch create 4.14.2-device 4.14.2 --repos=default,ios
eval $(opam env)
ARCH=arm64 SUBARCH=arm64 PLATFORM=iPhoneOS SDK=$(xcrun --sdk iphoneos --show-sdk-version) VER=13.0 opam install conf-ios
opam install camlkit-ios

opam switch create 4.14.2-simulator 4.14.2 --repos=default,ios
eval $(opam env)
opam install conf-simulator-ios
ARCH=amd64 SUBARCH=x86_64 PLATFORM=iPhoneSimulator SDK=$(xcrun --sdk iphonesimulator --show-sdk-version) VER=13.0 opam install conf-ios
opam install camlkit-ios

opam switch create 4.14.2-simulator-arm 4.14.2 --repos=default,ios
eval $(opam env)
opam install conf-simulator-ios
ARCH=arm64 SUBARCH=arm64 PLATFORM=iPhoneSimulator SDK=$(xcrun --sdk iphonesimulator --show-sdk-version) VER=13.0 opam install conf-ios
opam install camlkit-ios
```