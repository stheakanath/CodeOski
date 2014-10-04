//
//  AppDelegate.m
//  CodeOski
//
//  Created by Sony Theakanath on 10/4/14.
//  Copyright (c) 2014 Sony Theakanath. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

ViewController *viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Making the Navigation Controller and Setting ViewController
    viewController = (ViewController *)self.window.rootViewController;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:23/255.0f green:23/255.0f blue:23/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self.window addSubview:self.navigationController.view];
    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];
    return YES;
}

@end
