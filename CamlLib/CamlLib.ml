open Foundation
open Uikit
open Uikit_globals
open Runtime

let hello_vc frame =
  let vc = _new_ UIViewController._class_
  and label = _new_ UILabel._class_
  in
  let view = vc |> UIViewController.view in
  view |> UIView.setFrame frame;
  view |> UIView.setBackgroundColor
    (UIColor._class_ |> UIColor.C.systemBackgroundColor);

  label |> UILabel.setText (new_string "Hello world!");
  label |> UILabel.setTextColor
    (UIColor._class_ |> UIColor.C.systemBlackColor);
  label |> UILabel.setTextAlignment _UITextAlignmentCenter;
  label |> UIView.setFrame frame;
  view |> UIView.addSubview label;
  vc

module SceneDelegate = struct
  let scene_willConnectToSession self _cmd scene _session _opts =
    let win =
      alloc UIWindow._class_ |> UIWindow.initWithWindowScene scene
    and screen_bounds =
      UIScreen._class_ |> UIScreen.C.mainScreen |> UIScreen.bounds
    and vc_style = _UISplitViewControllerStyleDoubleColumn
    and col_primary = _UISplitViewControllerColumnPrimary
    in
    let vc =
      alloc UISplitViewController._class_
      |> UISplitViewController.initWithStyle vc_style
    and master_vc = hello_vc screen_bounds
    in
    vc |> UISplitViewController.setViewController master_vc ~forColumn: col_primary;
    self |> Property.set "window" win ~typ: Objc_t.id;
    win |> UIWindow.setRootViewController vc;
    vc |> UISplitViewController.showColumn col_primary;
    win |> UIWindow.makeKeyAndVisible

  let methods =
    Property._object_ "window" Objc_t.id () @
    [ Define._method_ scene_willConnectToSession
      ~cmd: (selector "scene:willConnectToSession:options:")
      ~args: Objc_t.[id; id; id]
      ~return: Objc_t.void
    ]

  let _class_ = Define._class_ "SceneDelegate"
    ~superclass: UIResponder._class_
    ~protocols: [Objc.get_protocol "UIWindowSceneDelegate"]
    ~ivars: [Define.ivar "window" Objc_t.id]
    ~methods
end

module AppDelegate = struct
  let _class_ = Define._class_ "AppDelegate"
    ~superclass: UIResponder._class_
    ~methods:
      [
        Define._method_
          ~cmd: (selector "application:didFinishLaunchingWithOptions:")
          ~args: Objc_t.[id; id]
          ~return: Objc_t.bool
          (fun self _cmd _app _opts ->
            Printf.eprintf "App launched...\n%!";
            let nc =
              NSNotificationCenter._class_ |> NSNotificationCenter.C.defaultCenter
            in
            nc |> NSNotificationCenter.addObserver self
              ~selector_: (selector "sceneActivated")
              ~name: (new_string "UISceneDidActivateNotification")
              ~object_: nil;
            true)

        ; Define._method_
          ~cmd: (selector "sceneActivated")
          ~args: Objc_t.[id]
          ~return: Objc_t.void
          (fun _self _cmd _scene -> Printf.eprintf "sceneActivated...\n%!")

        ; Define._method_
          ~cmd: (selector "application:configurationForConnectingSceneSession:options:")
          ~args: Objc_t.[id; id; id]
          ~return: Objc_t.id
          (fun _self _cmd _app conn_session _opts ->
            alloc UISceneConfiguration._class_
            |> UISceneConfiguration.initWithName (new_string "Default Configuration")
                ~sessionRole: (UISceneSession.role conn_session))
      ]
end