## Overview

This is a starter template for an iOS application built with
[Camlkit](https://github.com/dboris/camlkit) in OCaml. The template features
a minimal Xcode project useful for testing the application on an iOS
simulator, installing it on a device, debugging, etc.

The bulk of the application is built in OCaml and packaged as an _xcframework_,
which gets linked with the Xcode project. The application follows the
[Main program in C](https://ocaml.org/manual/5.2/intfc.html#ss:main-c) pattern,
and the [`main` function](https://github.com/dboris/camlkit-starter-nostoryboard/blob/master/CamlApp/main.m)
is very minimal:

```c
int main(int argc, char * argv[]) {
    caml_startup(argv);
    return UIApplicationMain(argc, argv, nil, @"AppDelegate");
}
```

The call to `caml_startup` initializes the OCaml runtime and causes the
evaluation of [the OCaml code](https://github.com/dboris/camlkit-starter-nostoryboard/blob/master/CamlLib/CamlLib.ml).
As a result of this evaluation, three Objective-C classes are defined and
registered with the Objective-C runtime: `GreetingsTVC`, `SceneDelegate`,
and `AppDelegate`.

The next call is to `UIApplicationMain`, which doesn't exit for the duration
of running the application. `UIApplicationMain` instantiates `UIApplication`
and `AppDelegate`, and when appropriate calls back the delegate's
`application:didFinishLaunchingWithOptions:` method. This is the
entry point in the OCaml part of the application, suitable for performing
global initialization tasks.

`UIApplicationMain` creates a `UISceneSession`, a `UIWindowScene`, and an
instance that will serve as the window scene’s delegate. The class of the
window scene’s delegate is specified in [`Info.plist`](https://github.com/dboris/camlkit-starter-nostoryboard/blob/master/CamlApp/Info.plist),
under the key `UISceneDelegateClassName`. The delegate's method
`scene:willConnectToSession:options:` is the place where the application
creates a `UIWindow` and sets up the user interface. After this point,
the application is running and ready to process user events.


## Setup

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

## Building

Use `make` to build the _xcframework_ and `make open` to open the project in Xcode.