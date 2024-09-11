open Foundation
open UIKit
open Runtime

let greetings =
  [| "English", "Hello World!"
   ; "Spanish", "Hola Mundo!"
   |]

let hello_vc text =
  let vc = _new_ UIViewController.self
  and label = _new_ UILabel.self
  in
  let view = vc |> UIViewController.view
  and frame =
    UIScreen.self |> UIScreenClass.mainScreen |> UIScreen.bounds
  in
  view |> UIView.setFrame frame;
  view |> UIView.setBackgroundColor
    (UIColor.self |> UIColorClass.systemBackgroundColor);

  label |> UILabel.setText text;
  label |> UILabel.setTextColor
    (UIColor.self |> UIColorClass.systemBlackColor);
  label |> UILabel.setTextAlignment _UITextAlignmentCenter;
  label |> UIView.setFrame frame;
  view |> UIView.addSubview label;
  vc

module GreetingsTVC = struct
  open Objc

  let cellID = new_string "Cell"

  let numberOfSectionsInTableView _self _cmd _tv = LLong.of_int 1

  let titleForHeaderInSection _self _cmd _tv _section = new_string "Language"

  let numberOfRowsInSection _self _cmd _tv _section =
    LLong.of_int (Array.length greetings)

  let cellForRowAtIndexPath _self _cmd tv indexPath =
    let cell = tv |> UITableView.dequeueReusableCellWithIdentifier' cellID
      ~forIndexPath: indexPath
    and i =
      indexPath |> Property.get "row" ~typ: Objc_t.llong |> LLong.to_int
    in
    cell
    |> UITableViewCell.textLabel
    |> UILabel.setText (new_string (fst greetings.(i)));
    cell |> UITableViewCell.setAccessoryType _UITableViewCellAccessoryDisclosureIndicator;
    cell

  let didSelectRowAtIndexPath self _cmd _tv indexPath =
    let i =
      indexPath |> Property.get "row" ~typ: Objc_t.llong |> LLong.to_int
    in
    let vc = hello_vc (new_string (snd greetings.(i))) in
    let nav_vc =
      alloc UINavigationController.self
      |> UINavigationController.initWithRootViewController vc
    in
    self
    |> UIViewController.parentViewController
    |> UISplitViewController.showDetailViewController nav_vc ~sender: self

  let viewDidLoad self cmd =
    self |> msg_super cmd ~args: Objc_t.[] ~return: Objc_t.void;
    self |> UIViewController.setTitle (new_string "Greetings");
    self
    |> UITableViewController.tableView
    |> UITableView.registerClass UITableViewCell.self
        ~forCellReuseIdentifier: cellID

  let self = Class.define "GreetingsTVC"
    ~superclass: UITableViewController.self
    ~methods:
      [ Method.define numberOfSectionsInTableView
        ~args: Objc_t.[id]
        ~return: Objc_t.llong
        ~cmd: (selector "numberOfSectionsInTableView:")

      ; Method.define titleForHeaderInSection
        ~args: Objc_t.[id; llong]
        ~return: Objc_t.id
        ~cmd: (selector "tableView:titleForHeaderInSection:")

      ; Method.define numberOfRowsInSection
        ~args: Objc_t.[id; llong]
        ~return: Objc_t.llong
        ~cmd: (selector "tableView:numberOfRowsInSection:")

      ; Method.define cellForRowAtIndexPath
        ~args: Objc_t.[id; id]
        ~return: Objc_t.id
        ~cmd: (selector "tableView:cellForRowAtIndexPath:")

      ; Method.define didSelectRowAtIndexPath
        ~args: Objc_t.[id; id]
        ~return: Objc_t.void
        ~cmd: (selector "tableView:didSelectRowAtIndexPath:")

      ; Method.define viewDidLoad
        ~args: Objc_t.[]
        ~return: Objc_t.void
        ~cmd: (selector "viewDidLoad")
      ]
end

module SceneDelegate = struct
  let scene_willConnectToSession self _cmd scene _session _opts =
    let win =
      alloc UIWindow.self |> UIWindow.initWithWindowScene scene
    and col_primary = _UISplitViewControllerColumnPrimary
    in
    let vc =
      alloc UISplitViewController.self
      |> UISplitViewController.initWithStyle _UISplitViewControllerStyleDoubleColumn
    and master_vc = _new_ GreetingsTVC.self
    in
    vc |> UISplitViewController.setViewController master_vc ~forColumn: col_primary;
    self |> UIWindowController.setWindow win;
    win |> UIWindow.setRootViewController vc;
    vc |> UISplitViewController.showColumn col_primary;
    win |> UIWindow.makeKeyAndVisible

  let self = Class.define "SceneDelegate"
    ~superclass: UIResponder.self
    ~protocols: [Objc.get_protocol "UIWindowSceneDelegate"]
    ~ivars: [Define.ivar "window" Objc_t.id]
    ~methods:
      (Property._object_ "window" Objc_t.id () @
      [ Method.define scene_willConnectToSession
        ~cmd: (selector "scene:willConnectToSession:options:")
        ~args: Objc_t.[id; id; id]
        ~return: Objc_t.void
      ])
end

module AppDelegate = struct
  let self = Class.define "AppDelegate"
    ~superclass: UIResponder.self
    ~methods:
      [
        Method.define
          ~cmd: (selector "application:didFinishLaunchingWithOptions:")
          ~args: Objc_t.[id; id]
          ~return: Objc_t.bool
          (fun self _cmd _app _opts ->
            NSNotificationCenter.self
            |> NSNotificationCenterClass.defaultCenter
            |> NSNotificationCenter.addObserver self
              ~selector_: (selector "sceneActivated")
              ~name: _UISceneDidActivateNotification
              ~object_: nil;
            true)

        ; Method.define
          ~cmd: (selector "sceneActivated")
          ~args: Objc_t.[id]
          ~return: Objc_t.void
          (fun _self _cmd _scene -> Printf.eprintf "sceneActivated...\n%!")

        ; Method.define
          ~cmd: (selector "application:configurationForConnectingSceneSession:options:")
          ~args: Objc_t.[id; id; id]
          ~return: Objc_t.id
          (fun _self _cmd _app conn_session _opts ->
            alloc UISceneConfiguration.self
            |> UISceneConfiguration.initWithName (new_string "Default Configuration")
                ~sessionRole: (UISceneSession.role conn_session))
      ]
end