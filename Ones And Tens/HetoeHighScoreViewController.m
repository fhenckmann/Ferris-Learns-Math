//
//  HetoeHighScoreViewController.m
//  Ones And Tens
//
//  Created by Fabian Henckmann on 21/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import "HetoeHighScoreViewController.h"
#import "Score.h"

@interface HetoeHighScoreViewController ()

@end

@implementation HetoeHighScoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (int i=0; i<10; i++) {
        
        UILabel* nameLabel = (UILabel*)[[self view] viewWithTag:(i*10)+1];
        [nameLabel setText:[Score getScoreAtPosition:i].playerName];
        UILabel* scoreLabel = (UILabel*)[[self view] viewWithTag:(i*10)+2];
        [scoreLabel setText:[NSString stringWithFormat:@"%d",[Score getScoreAtPosition:i].score]];
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd-MMM-YYYY"];
        UILabel* dateLabel = (UILabel*)[[self view] viewWithTag:(i*10)+2];
        [dateLabel setText:[format stringFromDate:[Score getScoreAtPosition:i].scoreDate]];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)return 10; else return 1;
}


@end
