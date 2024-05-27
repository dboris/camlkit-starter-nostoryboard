open Foundation
open Uikit
open Uikit_globals
open Runtime

let greetings =
  [| "English", "Hello World!"
   ; "Spanish", "Hola Mundo!"
   |]

let hello_vc text =
  let vc = _new_ UIViewController._class_
  and label = _new_ UILabel._class_
  in
  let view = vc |> UIViewController.view
  and frame =
    UIScreen._class_ |> UIScreen.C.mainScreen |> UIScreen.bounds
  in
  view |> UIView.setFrame frame;
  view |> UIView.setBackgroundColor
    (UIColor._class_ |> UIColor.C.systemBackgroundColor);

  label |> UILabel.setText text;
  label |> UILabel.setTextColor
    (UIColor._class_ |> UIColor.C.systemBlackColor);
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
      alloc UINavigationController._class_
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
    |> UITableView.registerClass UITableViewCell._class_
        ~forCellReuseIdentifier: cellID

  let _class_ = Define._class_ "GreetingsTVC"
    ~superclass: UITableViewController._class_
    ~methods:
      [ Define._method_ numberOfSectionsInTableView
        ~args: Objc_t.[id]
        ~return: Objc_t.llong
        ~cmd: (selector "numberOfSectionsInTableView:")

      ; Define._method_ titleForHeaderInSection
        ~args: Objc_t.[id; llong]
        ~return: Objc_t.id
        ~cmd: (selector "tableView:titleForHeaderInSection:")

      ; Define._method_ numberOfRowsInSection
        ~args: Objc_t.[id; llong]
        ~return: Objc_t.llong
        ~cmd: (selector "tableView:numberOfRowsInSection:")

      ; Define._method_ cellForRowAtIndexPath
        ~args: Objc_t.[id; id]
        ~return: Objc_t.id
        ~cmd: (selector "tableView:cellForRowAtIndexPath:")

      ; Define._method_ didSelectRowAtIndexPath
        ~args: Objc_t.[id; id]
        ~return: Objc_t.void
        ~cmd: (selector "tableView:didSelectRowAtIndexPath:")

      ; Define._method_ viewDidLoad
        ~args: Objc_t.[]
        ~return: Objc_t.void
        ~cmd: (selector "viewDidLoad")
      ]
end

module SceneDelegate = struct
  let scene_willConnectToSession self _cmd scene _session _opts =
    let win =
      alloc UIWindow._class_ |> UIWindow.initWithWindowScene scene
    and col_primary = _UISplitViewControllerColumnPrimary
    in
    let vc =
      alloc UISplitViewController._class_
      |> UISplitViewController.initWithStyle _UISplitViewControllerStyleDoubleColumn
    and master_vc = _new_ GreetingsTVC._class_
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
            NSNotificationCenter._class_
            |> NSNotificationCenter.C.defaultCenter
            |> NSNotificationCenter.addObserver self
              ~selector_: (selector "sceneActivated")
              ~name: _UISceneDidActivateNotification
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