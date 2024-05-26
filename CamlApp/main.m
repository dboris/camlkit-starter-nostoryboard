//
//  main.m
//  CamlApp
//

#import <UIKit/UIKit.h>

void caml_startup(char ** argv);

int main(int argc, char * argv[]) {
    caml_startup(argv);
    return UIApplicationMain(argc, argv, nil, @"AppDelegate");
}
