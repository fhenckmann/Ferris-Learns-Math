//
//  HetoeGridViewController.h
//  Ones And Tens
//
//  Created by Fabian Henckmann on 4/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVAudioPlayer;

@interface HetoeGridViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *firstNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *subtractButton;
@property (weak, nonatomic) IBOutlet UIButton *equalsButton;
@property (nonatomic, retain) AVAudioPlayer *errorSoundPlayer;
@property (nonatomic, retain) AVAudioPlayer *switchSoundPlayer;
@property (nonatomic, retain) AVAudioPlayer *boxSoundPlayer;

- (IBAction)addButtonPressed:(UIButton *)sender;
- (IBAction)subtractButtonPressed:(UIButton *)sender;
- (IBAction)equalsButtonPressed:(UIButton *)sender;
- (IBAction)clearContents:(UIButton *)sender;

@end
