//
//  HetoeMaking10sViewController.m
//  Ones And Tens
//
//  Created by Fabian Henckmann on 11/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import "HetoeMaking10sViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HetoeMaking10sViewController ()
{
    
    //numbers to be added that form the result
    int _number1;
    int _number2;
    int _result;
    
    //current level of play, from 1 to 3
    int _level;
    
    //how many bars left in the timing device
    int _barsLeft;
    
    //timer objects to count down bars and bonus points
    NSTimer* _barTimer;
    NSTimer* _bonusTimer;
    
    //bonus points left to win
    int _bonusPoints;
    
    //player's score
    int _score;
    
    //whether user can press a button now (game play) or not (game paused)
    BOOL _buttonsActive;
    
    //frequency with which timing device runs down
    float _barTimerFrequency;
    
    //number of rounds that player must complete to enter next round
    int _roundsLeftInLevel;
    
}

- (void) generateButtons;

@end

@implementation HetoeMaking10sViewController

static const NSString* _level2Intro = @"Level 2: Now the numbers are not in the right order anymore!";
static const NSString* _level3Intro = @"Level 3: Now the result can be multiples of ten!";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _level = 1;
    _barTimerFrequency = 0.25;
    
    //set up audio
	NSError* error;
    NSURL* url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_bar_tick.wav", [[NSBundle mainBundle] resourcePath]]];
	
	self.barTickSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	
	if (self.barTickSoundPlayer == nil) {
		NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_single_tick.wav", [[NSBundle mainBundle] resourcePath]]];
    self.bonusTickSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.bonusTickSoundPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_right_number.wav", [[NSBundle mainBundle] resourcePath]]];
    self.rightNumberSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.rightNumberSoundPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_wrong_number.wav", [[NSBundle mainBundle] resourcePath]]];
    self.wrongNumberSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.wrongNumberSoundPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_switch.wav", [[NSBundle mainBundle] resourcePath]]];
    self.nextGoSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.nextGoSoundPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    //set buttons inactive until GO button is pressed
    
    _buttonsActive = NO;
    
    //basic set-up for buttons and labels in the top rows
    
    for (int i = 0; i < 9; i++) {
        
        //create buttons for top row
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(32.0 + (80 * i), 186.0, 68.0, 68.0);
        button.backgroundColor = [UIColor clearColor];
        button.tag = 1 + i;
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"" forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24.0]];
        
        [button addTarget:self action:@selector(pressNumberButton:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
        
        //create labels for bottom row
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(32.0 + (80 * i), 350.0, 68.0, 68.0)];
        label.tag = 11 + i;
        
        [label setTextColor:[UIColor blackColor]];
        [label setText:@""];
        [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24.0]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:label];
    }
    
    //setting up the count-down meter
    
    for (int i = 0; i < 44; i++) {
        
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(60.0 + (15 * i), 684.0, 12.0, 59.0)];
        NSString* imageName;
        
        if (i < 5)          {imageName = @"meter_red.png";}
        else if (i < 18)    {imageName = @"meter_amber.png";}
        else                {imageName = @"meter_green.png";}
        
        image.image = [UIImage imageNamed:imageName];
        image.tag = 50 + i;
        
        [[self view] addSubview:image];
        
    }
    
    _barsLeft = 44;;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) resetButtonColors
{
    
    for (int i=101; i<121; i++) {
        
        UIImageView* correspondingImage = ((UIImageView*)[[self view] viewWithTag:i]);
        [correspondingImage setImage:[UIImage imageNamed:@"circle_white.png"]];
        
    }
    
}


- (void) generateButtons
{
    
    //reset button colors
    [self resetButtonColors];
    
    switch (_level) {
        
    case 1:
            
        //level 1: standard numbers 1-9 in ascending order
        
            for (int i = 0; i < 9; i++) {
                
                UIButton* button = (UIButton*)[[self view] viewWithTag:i+1];
                [button setAccessibilityIdentifier:[NSString stringWithFormat:@"%d", (i+1)]];
                
                [button setTitle:[NSString stringWithFormat:@"%d", (i+1)] forState:UIControlStateNormal];
                
                //create labels for bottom row
                UILabel* label = (UILabel*)[[self view] viewWithTag:i+11];
                [label setAccessibilityIdentifier:[NSString stringWithFormat:@"%d", (i+1)]];
                
                [label setText:[NSString stringWithFormat:@"%d", (i+1)]];
                
                _result = 10;

            }
            
            _bonusPoints = 10000;
        
        break;
        
    }
    
    //update the wanted result
    [self resultLabel].text = [NSString stringWithFormat:@"%d", _result];
    
    //determine the active button
    int activeNumber = ( (arc4random() % (9-1+1)) + 1);
    NSLog(@"The ball number pulled out of the hat today is %d", activeNumber);
    
    UIImageView* chosenImage = (UIImageView*)[[self view] viewWithTag:(110 + activeNumber)];
    chosenImage.image = [UIImage imageNamed:@"circle_green.png"];
    
    UILabel* chosenLabel = (UILabel*)[[self view] viewWithTag:(10 + activeNumber)];
    _number2 = [[chosenLabel accessibilityIdentifier] intValue];
    
    NSLog(@"And the number on that ball is %d", _number2);
    _number1 = _result - _number2;
    
    //set the bonus
    [[self bonusLabel] setText:[NSString stringWithFormat:@"%d", _bonusPoints]];
    
    
}


- (void) pressNumberButton:(id)sender
{
    if (_buttonsActive) {
        
        //stop the timers
        [_bonusTimer invalidate];
        [_barTimer invalidate];
        
        
        UIImageView* correspondingImage = ((UIImageView*)[[self view] viewWithTag:[(UIButton*)sender tag]+100]);
        
        if (_number1 == [[sender accessibilityIdentifier] intValue]) {
            
            //correct answer
            [correspondingImage setImage:[UIImage imageNamed:@"circle_green.png"]];
            
            //play success sound
            [self.rightNumberSoundPlayer play];
            
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateBonusAndScoreLabels) userInfo:nil repeats:NO];
            
        } else {
            
            //incorrect answer
            [correspondingImage setImage:[UIImage imageNamed:@"circle_red.png"]];
            
            [self.wrongNumberSoundPlayer play];
            
            //show right number
            
            
        }
        
    } else {
        
        //do some animation that shows GO button must be pressed first
        
    }
}

- (IBAction)startTimer:(id)sender {
    
    //change go button to grey
    [[self goButton] setBackgroundImage:[UIImage imageNamed:@"button_grey_large.png"] forState:UIControlStateNormal];
    
    //activate the buttons
    _buttonsActive = YES;
    
    //generate numbers for the buttons
    [self generateButtons];
    
    _barTimer = [NSTimer scheduledTimerWithTimeInterval:_barTimerFrequency target:self selector:@selector(removeBar:) userInfo:nil repeats:YES];
    _bonusTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(decreaseBonus:) userInfo:nil repeats:YES];
    
}

- (void)removeBar:(id)sender
{
    
    //play remove-bar tick sound
    [[self barTickSoundPlayer] stop];
    [[self barTickSoundPlayer] play];
    
    UIImageView* bar = (UIImageView*)[[self view] viewWithTag:(50 + _barsLeft - 1)];
    [bar setHidden:YES];
    _barsLeft--;
    
    if (_barsLeft < 1) {
        
        [_barTimer invalidate];
        [_bonusTimer invalidate];
        
        //game over
        UIAlertView* gameOverWindow = [[UIAlertView alloc] initWithTitle:@"GAME OVER" message:[NSString stringWithFormat:@"Congratulations! Your final score is %d", _score] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [gameOverWindow show];
        
    }
    
}

- (void)decreaseBonus:(id) sender
{
    
    _bonusPoints -= ((100 * _barTimerFrequency) + (25/_level));
    [[self bonusLabel] setText:[NSString stringWithFormat:@"%d", _bonusPoints]];
    
}

- (void)resetBars
{
    
    for (int i = 0; i < 44; i++) {
        
        UIImageView* bar = (UIImageView*)[[self view] viewWithTag:(50 + i)];
        [bar setHidden:NO];
        
    }
    
    _barsLeft = 44;
    
}

- (void) updateBonusAndScoreLabels
{
    if (_bonusPoints > 47 ) {
        
        [self.bonusTickSoundPlayer stop];
        [self.bonusTickSoundPlayer play];
        
        _score = _score + 47;
        _bonusPoints = _bonusPoints - 47;
        
        [self scoreLabel].text = [NSString stringWithFormat:@"%d",_score];
        [self bonusLabel].text = [NSString stringWithFormat:@"%d",_bonusPoints];
        [[self view] setNeedsDisplay];
            
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateBonusAndScoreLabels) userInfo:nil repeats:NO];
    
    } else {
        
        _score = _score + _bonusPoints;
        _bonusPoints = 0;
        
        [self scoreLabel].text = [NSString stringWithFormat:@"%d",_score];
        [self bonusLabel].text = [NSString stringWithFormat:@"%d",_bonusPoints];
        [[self view] setNeedsDisplay];
        
        [self getReadyForNextRound];
        
    }
    
}

- (void) getReadyForNextRound
{
    
    [self resetButtonColors];
    [self resetBars];
    [self.nextGoSoundPlayer play];
    [[self goButton] setBackgroundImage:[UIImage imageNamed:@"button_green_large.png"] forState:UIControlStateNormal];
    _buttonsActive = NO;
    _barTimerFrequency = _barTimerFrequency * 0.8;
    
}
@end
