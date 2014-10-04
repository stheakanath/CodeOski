//
//  ViewController.h
//  CodeOski
//
//  Created by Sony Theakanath on 10/4/14.
//  Copyright (c) 2014 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CustomIOS7AlertViewDelegate> {
    UITableView *alarms;
}

@end

