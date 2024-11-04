open UIKit

let greetings =
  [| "English", "Hello World!"
   ; "Spanish", "Hola Mundo!"
   ; "French", "Bonjour, le monde !"
   |]

let hello_vc text =
  let vc = _new_ UIViewController.self
  and label = _new_ UILabel.self in
  let view = vc |> UIViewController.view
  and frame = UIScreen.self |> UIScreenClass.mainScreen |> UIScreen.bounds
  in
  view |> UIView.setFrame frame;
  view |> UIView.setBackgroundColor (UIColor.self |> UIColorClass.systemBackgroundColor);

  label |> UILabel.setText text;
  label |> UILabel.setTextColor (UIColor.self |> UIColorClass.systemBlackColor);
  label |> UILabel.setTextAlignment _UITextAlignmentCenter;
  label |> UIView.setFrame frame;

  view |> UIView.addSubview label;
  vc

module GreetingsTVC = struct
  module LLong = Objc.LLong

  let cellID = new_string "Cell"

  let numberOfSectionsInTableView =
    UITableViewControllerMethods.numberOfSectionsInTableView'
      (fun _self _cmd _tv -> LLong.of_int 1)

  let titleForHeaderInSection =
    UITableViewControllerMethods.tableView'titleForHeaderInSection'
      (fun _self _cmd _tv _section -> new_string "Language")

  let numberOfRowsInSection =
    UITableViewControllerMethods.tableView'numberOfRowsInSection'
      (fun _self _cmd _tv _section -> LLong.of_int (Array.length greetings))

  let cellForRowAtIndexPath =
    UITableViewControllerMethods.tableView'cellForRowAtIndexPath'
      (fun _self _cmd tv index_path ->
        let cell =
          tv |> UITableView.dequeueReusableCellWithIdentifier' cellID
            ~forIndexPath: index_path
        and i = index_path |> NSIndexPath.row in
        cell
        |> UITableViewCell.textLabel
        |> UILabel.setText (new_string (fst greetings.(i)));
        cell
        |> UITableViewCell.setAccessoryType _UITableViewCellAccessoryDisclosureIndicator;
        cell)

  let didSelectRowAtIndexPath =
    UITableViewDelegate.tableView'didSelectRowAtIndexPath'
      (fun self _cmd _tv index_path ->
        let i = index_path |> NSIndexPath.row in
        let vc = hello_vc (new_string (snd greetings.(i))) in
        let nav_vc =
          alloc UINavigationController.self
          |> UINavigationController.initWithRootViewController vc
        in
        self
        |> UIViewController.parentViewController
        |> UISplitViewController.showDetailViewController nav_vc ~sender: self)

  let viewDidLoad =
    UIViewControllerMethods.viewDidLoad
      (fun self cmd ->
        msg_super cmd ~self ~args: Objc_type.noargs ~return: Objc_type.void;
        self |> UIViewController.setTitle (new_string "Greetings");
        self
        |> UITableViewController.tableView
        |> UITableView.registerClass UITableViewCell.self
            ~forCellReuseIdentifier: cellID)

  let self =
    Class.define "GreetingsTVC"
      ~superclass: UITableViewController.self
      ~methods:
        [ numberOfSectionsInTableView
        ; titleForHeaderInSection
        ; numberOfRowsInSection
        ; cellForRowAtIndexPath
        ; didSelectRowAtIndexPath
        ; viewDidLoad
        ]
end

module SceneDelegate = struct
  let willConnectToSession =
    UISceneDelegate.scene'willConnectToSession'options'
      (fun self _cmd scene _session _opts ->
        let win = alloc UIWindow.self |> UIWindow.initWithWindowScene scene
        and vc =
          alloc UISplitViewController.self
          |> UISplitViewController.initWithStyle _UISplitViewControllerStyleDoubleColumn
        and master_vc = _new_ GreetingsTVC.self
        in
        vc
        |> UISplitViewController.setViewController master_vc
            ~forColumn: _UISplitViewControllerColumnPrimary;
        self |> UIWindowController.setWindow win;
        win |> UIWindow.setRootViewController vc;
        vc |> UISplitViewController.showColumn _UISplitViewControllerColumnPrimary;
        win |> UIWindow.makeKeyAndVisible)

  (* This class is referenced in Info.plist, UISceneConfigurations key.
    It is instantiated from UIApplicationMain. *)
  let _self =
    Class.define "SceneDelegate"
      ~superclass: UIResponder.self
      ~protocols: [Objc.get_protocol "UIWindowSceneDelegate"]
      ~properties: [Property.define "window" Objc_type.id]
      ~methods: [willConnectToSession]
end

module AppDelegate = struct
  (* This class is referenced in main.m. It is instantiated from UIApplicationMain. *)
  let _self =
    Class.define "AppDelegate"
      ~superclass: UIResponder.self
      ~methods:
        [ UIApplicationDelegate.application'didFinishLaunchingWithOptions'
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
          ~args: Objc_type.[id]
          ~return: Objc_type.void
          (fun _self _cmd _scene -> Printf.eprintf "sceneActivated...\n%!")

        ; UIApplicationDelegate.application'configurationForConnectingSceneSession'options'
          (fun _self _cmd _app conn_session _opts ->
            alloc UISceneConfiguration.self
            |> UISceneConfiguration.initWithName (new_string "Default Configuration")
                ~sessionRole: (UISceneSession.role conn_session))
        ]
end