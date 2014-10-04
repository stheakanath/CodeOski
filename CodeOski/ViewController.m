//
//  ViewController.m
//  CodeOski
//
//  Created by Sony Theakanath on 10/4/14.
//  Copyright (c) 2014 Sony Theakanath. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ViewController

UIDatePicker *datePicker;

#pragma mark - Table View Functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    } else {
        for (UIView *subview in cell.contentView.subviews)
            [subview removeFromSuperview];
    }
    
    //Time Stamp
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 70)];
    [time setText:[_items[indexPath.row][1] substringToIndex:[_items[indexPath.row][1] length]-2]];
    [time setFont:[UIFont fontWithName:@"Roboto-Regular" size:45]];
    [cell addSubview:time];
    
    //AM or PM
    UILabel *ampm;
    if([[_items[indexPath.row][1] substringToIndex:[_items[indexPath.row][1] length]-2] length] > 5)
        ampm = [[UILabel alloc] initWithFrame:CGRectMake(137, 17, 200, 70)];
    else
        ampm = [[UILabel alloc] initWithFrame:CGRectMake(113, 17, 200, 70)];
    [ampm setText:[_items[indexPath.row][1] substringFromIndex:[_items[indexPath.row][1] length]-2]];
    [ampm setFont:[UIFont fontWithName:@"Roboto-Regular" size:20]];
    [cell addSubview:ampm];
    
    //Name of Alarm -- Can be changed to dates later
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(23, 70, 200, 20)];
    [name setText:@"Alarm Name"];
    [name setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    [cell addSubview:name];
    
    //On/Off switch
    UISwitch *onoff = [[UISwitch alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 70, 35, 0, 0)];
    onoff.tag = indexPath.row;
    [onoff addTarget:self action:@selector(switchChanged:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];

    [_items[indexPath.row][2]  isEqual: @"1"] ? [onoff setOn:YES] : [onoff setOn:NO];
    [cell addSubview:onoff];
    
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [alarms deselectRowAtIndexPath:indexPath animated:YES];
    [self loadOldAlarms];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 100; }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return _items.count; }


#pragma mark - User Clickers (IBActions)

- (IBAction)switchChanged:(id)sender {
    UISwitch *switchInCell = (UISwitch *)sender;
    UITableViewCell * cell = (UITableViewCell*) switchInCell.superview;
    NSIndexPath * indexpath = [alarms indexPathForCell:cell];
    
    NSString *boolean = @"1";
    if (!switchInCell.on) boolean = @"0";
    
    //Saving Items
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath]) data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    NSArray *alarm = @[@"Alarm Name1", data[indexpath.row][1], boolean];
    [data replaceObjectAtIndex:indexpath.row withObject:alarm];
    _items = data;
    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
    [alarms reloadData];
}

- (IBAction)addalarm:(id)sender {
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    [alertView setContainerView:[self createTimePicker]];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Add Alarm", nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:false];
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"];
        NSString *dateString = [outputFormatter stringFromDate:datePicker.date];
        NSArray *alarm = @[@"Alarm Name1", dateString, @"1"];
        
        //Saving New Alarm
        NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
            data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
        [data addObject:alarm];
        _items = data;
        [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
        [alertView close];
        [alarms reloadData];
    }
}

#pragma mark - Database Functions

- (void) loadOldAlarms {
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath]) data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    _items = data;
    [alarms reloadData];
}

#pragma mark - Interface Functions

- (void)viewDidLoad {
    alarms = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    alarms.delegate = self;
    alarms.dataSource = self;
    [alarms setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:alarms];
    [self setNeedsStatusBarAppearanceUpdate];
    UIBarButtonItem *addAlert = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addalarm:)];
    [self.navigationItem setRightBarButtonItem:addAlert];
    [self.navigationItem setTitle:@"CodeOski"];
    [self loadOldAlarms];
    [super viewDidLoad];
}

- (UIView *)createTimePicker {
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 250)];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 290, 20)];
    [header setFont:[UIFont fontWithName:@"Roboto-Regular" size:25]];
    [header setTextAlignment:NSTextAlignmentCenter];
    [header setText:@"Set Alarm Time"];
    [demoView addSubview:header];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 290, 200)];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.hidden = NO;
    datePicker.date = [NSDate date];
    [demoView addSubview:datePicker];
    return demoView;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
