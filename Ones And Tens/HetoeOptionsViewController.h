//
//  HetoeOptionsViewController.h
//  Ones And Tens
//
//  Created by Fabian Henckmann on 8/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HetoeOptionsViewController : UITableViewController
- (IBAction)saveOptions:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchPlaySpokenInstructions;
@property (weak, nonatomic) IBOutlet UISwitch *switchPlaySounds;
@property (weak, nonatomic) IBOutlet UISwitch *switchShowOnes;
@property (weak, nonatomic) IBOutlet UISwitch *switchShowTens;
@property (weak, nonatomic) IBOutlet UISwitch *switchHideSubtractions;
@property (weak, nonatomic) IBOutlet UISwitch *switchAlwaysShowResult;

@end
