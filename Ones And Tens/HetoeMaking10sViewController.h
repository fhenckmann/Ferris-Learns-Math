//
//  HetoeMaking10sViewController.h
//  Ones And Tens
//
//  Created by Fabian Henckmann on 11/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVAudioPlayer;

@interface HetoeMaking10sViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UILabel *bonusLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) AVAudioPlayer *rightNumberSoundPlayer;
@property (nonatomic, retain) AVAudioPlayer *wrongNumberSoundPlayer;
@property (nonatomic, retain) AVAudioPlayer *barTickSoundPlayer;
@property (nonatomic, retain) AVAudioPlayer *bonusTickSoundPlayer;
@property (nonatomic, retain) AVAudioPlayer *nextGoSoundPlayer;

- (IBAction)startTimer:(id)sender;

@end
