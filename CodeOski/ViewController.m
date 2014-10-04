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








- (IBAction)switchChanged: (id)sender {
    UISwitch *switchInCell = (UISwitch *)sender;
    UITableViewCell * cell = (UITableViewCell*) switchInCell.superview;
    NSIndexPath * indexpath = [alarms indexPathForCell:cell];
    
    NSString *boolean = @"1";
    if (!switchInCell.on) {
        boolean = @"0";
    }
    
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    NSLog(@"%@", boolean);
    NSLog(@"%@", data[indexpath.row][2]);
    NSArray *alarm = @[@"Alarm Name1", data[indexpath.row][1], boolean];
    [data replaceObjectAtIndex:indexpath.row withObject:alarm];

    //[[data objectAtIndex:] objectAtIndex:2] = boolean;
  //  data[indexpath.row][2] = boolean;
    _items = data;
    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];


    [alarms reloadData];
    
}






- (void)viewDidLoad {
    alarms = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    alarms.delegate = self;
    alarms.dataSource = self;
    [alarms setBackgroundColor:[UIColor blackColor]];
    // [alarms setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:alarms];
    [self setNeedsStatusBarAppearanceUpdate];
    UIBarButtonItem *addAlert = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addalarm:)];
    [self.navigationItem setRightBarButtonItem:addAlert];
    [self.navigationItem setTitle:@"CodeOski"];
    [self loadOldAlarms];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) loadOldAlarms {
    NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
//    if([data count] == 0) {
//        [data insertObject:@"61" atIndex:0];
//        [data insertObject:@"Current Location, 00000" atIndex:1];
//        [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
//    }
    _items = data;
    NSLog(@"%@", _items);
    [alarms reloadData];
}

- (IBAction)addalarm:(id)sender
{
    // Here we need to pass a full frame
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Add Alarm", nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:false];
    
    // And launch the dialog
    [alertView show];

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    if(buttonIndex == 1) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"]; //24hr time format
        NSString *dateString = [outputFormatter stringFromDate:datePicker.date];

        NSArray *alarm = @[@"Alarm Name1", dateString, @"1"];
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

- (UIView *)createDemoView
{
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
   // datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    [demoView addSubview:datePicker];
    
    return demoView;
}





- (void) wakeup: (NSTimer *) theTimer{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm"
                                                    message:@"Wake up or pay up"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Snooze"];
    //[alert show]; need to call when NSTimer Runs out
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        //reset alarm and call paypal api
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
