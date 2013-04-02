//
//  HetoeMaking10sViewController.m
//  Ones And Tens
//
//  Created by Fabian Henckmann on 11/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import "HetoeMaking10sViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Score.h"

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
    float _roundsLeftInLevel;
    
    NSInteger _level_x_games[4][10];
    
    NSMutableArray* _instructionText;

    
}

- (void) pressNumberButton:(id)sender;
- (void) initializeMakingTensForLevel:(int)level;
- (void) initializeEvenOrOddForLevel:(int)level;
- (void) initializeLowerThanOrGreaterThanForLevel:(int)level;
- (void) removeBar:(id)sender;
- (void) decreaseBonus:(id)sender;
- (void) initializeBars;
- (void) resetBars;
- (void) updateBonusAndScoreLabels;
- (void) getReadyForNextRound;
- (void) prepareMakingTensGame;
- (void) scrollInHeaderLabelForGame:(NSInteger)game;
- (void) showInstructionsForLevel:(int)level;
- (void) generateNextGame:(NSTimer*)timer;

@end

@implementation HetoeMaking10sViewController

static const NSInteger _GAME_MAKING_TENS = 1;
static const NSInteger _GAME_EVEN_OR_ODD = 2;
static const NSInteger _GAME_LESS_THAN_OR_GREATER_THAN = 3;

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
    
    //setting up some standard parameters
    
    _level = 1;
    _barTimerFrequency = 0.25;
    _roundsLeftInLevel = 100.0;
    
    _level_x_games[0][0] = _GAME_MAKING_TENS;
    _level_x_games[0][1] = _GAME_MAKING_TENS;
    _level_x_games[0][2] = _GAME_MAKING_TENS;
    _level_x_games[0][3] = _GAME_MAKING_TENS;
    _level_x_games[0][4] = _GAME_MAKING_TENS;
    _level_x_games[0][5] = _GAME_MAKING_TENS;
    _level_x_games[0][6] = _GAME_MAKING_TENS;
    _level_x_games[0][7] = _GAME_MAKING_TENS;
    _level_x_games[0][8] = _GAME_MAKING_TENS;
    _level_x_games[0][9] = _GAME_MAKING_TENS;
    _level_x_games[1][0] = _GAME_MAKING_TENS;
    _level_x_games[1][1] = _GAME_MAKING_TENS;
    _level_x_games[1][2] = _GAME_MAKING_TENS;
    _level_x_games[1][3] = _GAME_MAKING_TENS;
    _level_x_games[1][4] = _GAME_MAKING_TENS;
    _level_x_games[1][5] = _GAME_MAKING_TENS;
    _level_x_games[1][6] = _GAME_MAKING_TENS;
    _level_x_games[1][7] = _GAME_EVEN_OR_ODD;
    _level_x_games[1][8] = _GAME_EVEN_OR_ODD;
    _level_x_games[1][9] = _GAME_EVEN_OR_ODD;
    _level_x_games[2][0] = _GAME_MAKING_TENS;
    _level_x_games[2][1] = _GAME_MAKING_TENS;
    _level_x_games[2][2] = _GAME_MAKING_TENS;
    _level_x_games[2][3] = _GAME_MAKING_TENS;
    _level_x_games[2][4] = _GAME_MAKING_TENS;
    _level_x_games[2][5] = _GAME_MAKING_TENS;
    _level_x_games[2][7] = _GAME_EVEN_OR_ODD;
    _level_x_games[2][8] = _GAME_EVEN_OR_ODD;
    _level_x_games[2][9] = _GAME_LESS_THAN_OR_GREATER_THAN;
    _level_x_games[3][0] = _GAME_LESS_THAN_OR_GREATER_THAN;
    _level_x_games[3][1] = _GAME_MAKING_TENS;
    _level_x_games[3][2] = _GAME_MAKING_TENS;
    _level_x_games[3][3] = _GAME_MAKING_TENS;
    _level_x_games[3][4] = _GAME_MAKING_TENS;
    _level_x_games[3][5] = _GAME_LESS_THAN_OR_GREATER_THAN;
    _level_x_games[3][6] = _GAME_LESS_THAN_OR_GREATER_THAN;
    _level_x_games[3][7] = _GAME_LESS_THAN_OR_GREATER_THAN;
    _level_x_games[3][8] = _GAME_EVEN_OR_ODD;
    _level_x_games[3][9] = _GAME_EVEN_OR_ODD;
    
    _instructionText = [NSArray arrayWithObjects:@"Your goal is to match two numbers that add up to make 10. \r But careful - when the timer hits zero, the game is over! \r Once in a while, I will spice up the game by asking if a certain number is even or odd. \r Have fun!",
                        @"In this level, I will make things \r more difficult by shuffling \r the numbers around!", @"", @"", nil];
    
        
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
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_making_ten.wav", [[NSBundle mainBundle] resourcePath]]];
    self.makingTenPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.makingTenPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_even_or_odd.wav", [[NSBundle mainBundle] resourcePath]]];
    self.evenOrOddPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.evenOrOddPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_lower_or_greater.wav", [[NSBundle mainBundle] resourcePath]]];
    self.lowerOrGreaterPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.lowerOrGreaterPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    //set buttons inactive until GO button is pressed
    
    _buttonsActive = NO;
    
    //run programmatically created views
    [self prepareMakingTensGame];
    
    //setting up the count-down meter
    [self initializeBars];
    
    //start game
    [self showInstructionsForLevel:_level];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 
 GAME PLAY FUNCTIONS
 
 */

#pragma mark GAME PLAY

- (IBAction)selectNextGame
{
    
    //hide go button
    [self.goButton setHidden:YES];
    
    
    //choose what game to play
    NSInteger randomNumber = (arc4random_uniform(10));
    int nextGame = _level_x_games[_level-1][randomNumber];
    
    //scroll in game header
    [self scrollInHeaderLabelForGame:nextGame];
    
    //wait 2 secs and then generate the game
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:nextGame] forKey:@"gameType"];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(generateNextGame:) userInfo:userInfo repeats:NO];

    
}

- (void) generateNextGame:(NSTimer*) timer
{
    
    NSDictionary* userInfo = [timer userInfo];
    int gameType = [[userInfo objectForKey:@"gameType"] intValue];
    
    switch (gameType) {
            
        case _GAME_MAKING_TENS: {
            
            [self showMakingTensContent:YES];
            [self showEvenOrOddGame:NO];
            [self showLessOrGreaterThanGame:NO];
            [self initializeMakingTensForLevel:_level];
            
            break;
        }
            
        case _GAME_EVEN_OR_ODD:
            
            [self showMakingTensContent:NO];
            [self showEvenOrOddGame:YES];
            [self showLessOrGreaterThanGame:NO];
            [self initializeEvenOrOddForLevel:_level];
            break;
            
            
        case _GAME_LESS_THAN_OR_GREATER_THAN:
            
            [self showMakingTensContent:NO];
            [self showEvenOrOddGame:NO];
            [self showLessOrGreaterThanGame:YES];
            [self initializeLowerThanOrGreaterThanForLevel:_level];
            break;
            
            
    }
    
    //set the bonus
    [[self bonusLabel] setText:[NSString stringWithFormat:@"%d", _bonusPoints]];
    
    //start timer
    [self startTimer];
    
    
}



- (void) scrollInHeaderLabelForGame:(NSInteger)game
{
    
    NSString* titleText;
    
    switch (game) {
            
        case _GAME_MAKING_TENS:
            
            titleText = @"Making Ten";
            [self.makingTenPlayer play];
            
            break;
            
        case _GAME_EVEN_OR_ODD:
            
            titleText = @"Even Or Odd";
            [self.evenOrOddPlayer play];
            
            break;
            
        case _GAME_LESS_THAN_OR_GREATER_THAN:
            
            titleText = @"Less Than Or Greater Than";
            [self.lowerOrGreaterPlayer play];
            
            break;
            
    }
    
    [self.titleLabel setText:titleText];
    
    [self.titleLabel setCenter:CGPointMake(-384, self.titleLabel.center.y)];
    
    [UIView animateWithDuration:1.0 animations:^{
		self.titleLabel.center = CGPointMake(384, self.titleLabel.center.y);
	}];
    
}

- (void) showInstructionsForLevel:(int)level
{
    
    [self showMakingTensContent:NO];
    [self showEvenOrOddGame:NO];
    [self showLessOrGreaterThanGame:NO];
    [self.goButton setHidden:YES];
    
    [self.titleLabel setText:@"Instructions"];
    
    [self.instructionLabelHeader setText:[NSString stringWithFormat:@"Level %d", level]];
    [self.instructionLabelHeader setHidden:NO];
    
    [self.instructionLabelText setText:(NSString*)[_instructionText objectAtIndex:level-1]];
    [self.instructionLabelText setHidden:NO];
    
    [self.instructionOKButton setHidden:NO];
    
}



/*

 MAKING TENS
 
 */

#pragma mark Making Tens

- (void) prepareMakingTensGame
{
    
    //one-off set-up of programmatically created buttons for Making Tens game
    
    for (int i = 0; i < 9; i++) {
        
        //create buttons for top row
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(32.0 + (80 * i), 263.0, 68.0, 68.0);
        [button setBackgroundImage:[UIImage imageNamed:@"circle_white.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"circle_white_clicked.png"] forState:UIControlStateHighlighted];
        button.tag = 1 + i;
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"" forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24.0]];
        
        [button addTarget:self action:@selector(pressNumberButton:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
        
        //create disabled buttons for bottom row
        UIButton* label = [UIButton buttonWithType:UIButtonTypeCustom];
        label.frame = CGRectMake(32.0 + (80 * i), 428.0, 68.0, 68.0);
        [label setBackgroundImage:[UIImage imageNamed:@"circle_white.png"] forState:UIControlStateDisabled];
        [label setBackgroundImage:[UIImage imageNamed:@"circle_green.png"] forState:UIControlStateSelected | UIControlStateDisabled];
        label.tag = 11 + i;
        
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [label setTitle:@"" forState:UIControlStateNormal];
        [[label titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24.0]];
        
        [label setEnabled:NO];
        [self.view addSubview:label];
        
    }
    
}

- (void) initializeMakingTensForLevel:(int)level
{
    NSInteger inputSet[10];
    NSInteger offerSet[10];
    int randomNumber;
    
    //initialize both sets with basic ascending numbers
    
    for (NSInteger i=0; i<9; i++) {
        
        inputSet[i] = i+1;
        offerSet[i] = i+1;
    }
    
    //set _result and change / randomize input and offer sets, if required by level
    
    switch (level) {
            
        case 1: //leave input and offer sets as they are, set result to 10
                        
            _result = 10;
            _bonusPoints = 5000;
            
            //determine a random number to be selected from bottom row
            randomNumber = (arc4random_uniform(9) + 1);
            NSLog(@"The ball number pulled out of the hat today is %d", randomNumber);
            
            _number2 = offerSet[randomNumber-1];
            
            NSLog(@"And the number on that ball is %d", _number2);
            _number1 = _result - _number2;
            
            break;
            
        case 2: //both input and offer sets range from 1 to 10, but in arbitrary order. Result is always 10
                        
            //shake up both input and offer sets
            for (NSUInteger i = 0; i < 9; ++i) {
                // Select a random element between i and end of array to swap with.
                NSInteger nElements = 9 - i;
                NSInteger n1 = (arc4random_uniform(nElements) + i);
                NSInteger n2 = (arc4random_uniform(nElements) + i);
                NSInteger temp1 = inputSet[i];
                NSInteger temp2= offerSet[i];
                inputSet[i] = inputSet[n1];
                inputSet[n1] = temp1;
                offerSet[i] = offerSet[n2];
                offerSet[n2] = temp2;
                
            }
            
            _result = 10;
            _bonusPoints = 10000;
            
            //determine a random number to be selected from bottom row
            randomNumber = (arc4random_uniform(9) + 1);
            NSLog(@"The ball number pulled out of the hat today is %d", randomNumber);
            
            _number2 = offerSet[randomNumber-1];
            
            NSLog(@"And the number on that ball is %d", _number2);
            _number1 = _result - _number2;
            break;
            
        case 3: //input set contains various numbers, _result can be 10, 20, 30, 40...
            
            //shake up offer set
            for (NSUInteger i = 0; i < 9; ++i) {
                // Select a random element between i and end of array to swap with.
                NSInteger nElements = 9 - i;
                NSInteger n = (arc4random_uniform(nElements) + i);
                NSInteger temp= offerSet[i];
                offerSet[i] = offerSet[n];
                offerSet[n] = temp;
            }
            
            //determine result
            _result = (arc4random_uniform(9) + 1) * 10;
            
            //determine a random number to be selected from bottom row
            randomNumber = (arc4random_uniform(9) + 1);
            NSLog(@"The ball number pulled out of the hat today is %d", randomNumber);
            
            _number2 = offerSet[randomNumber-1];
            NSLog(@"And the number on that ball is %d", _number2);
            
            _number1 = _result - _number2;
            
            //create input set
            inputSet[0] = _number1; //this is the correct result
            
            if (_number1 < 90) {
                inputSet[1] = _number1 + 10;
            } else {
                inputSet[1] = _number1 - 20;
            }
            
            if (_number1 > 10) {
                inputSet[2] = _number1 - 10;
            } else {
                inputSet[2] = _number1 + 20;
            }
            
            inputSet[3] = _number1 + 1;
            inputSet[4] = _number1 - 1;
            inputSet[5] = inputSet[1] + 1;
            inputSet[6] = inputSet[2] - 1;
            inputSet[7] = (arc4random_uniform(99) + 1);
            inputSet[8] = (arc4random_uniform(99) + 1);
            
            //shake up inputSet
            for (NSUInteger i = 0; i < 9; ++i) {
                // Select a random element between i and end of array to swap with.
                NSInteger nElements = 9 - i;
                NSInteger n = (arc4random_uniform(nElements) + i);
                NSInteger temp = inputSet[i];
                inputSet[i] = inputSet[n];
                inputSet[n] = temp;
            }
            
            break;
            
        case 4:
            
            //single-digit numbers are verstreut between both sets
            
            break;
            
    }
    

    
    
//create button visualisations
    
    for (NSInteger i = 0; i < 9; i++) {
        
    //create buttons for top row
        UIButton* button = (UIButton*)[[self view] viewWithTag:i+1];
        [button setAccessibilityIdentifier:[NSString stringWithFormat:@"%d", inputSet[i]]];
        
        [button setTitle:[NSString stringWithFormat:@"%d", inputSet[i]] forState:UIControlStateNormal];
        
        if (inputSet[i] != _number1) {
            //incorrect button
            [button setBackgroundImage:[UIImage imageNamed:@"circle_red.png"] forState:UIControlStateSelected];
        } else {
            //correct button
            [button setBackgroundImage:[UIImage imageNamed:@"circle_green.png"] forState:UIControlStateSelected];
        }
        [button setSelected:NO];
        
    //create labels for bottom row
        UIButton* label = (UIButton*)[[self view] viewWithTag:i+11];
        [label setAccessibilityIdentifier:[NSString stringWithFormat:@"%d", offerSet[i]]];
        [label setSelected:NO];
        
        [label setTitle:[NSString stringWithFormat:@"%d", offerSet[i]] forState:UIControlStateNormal];
        
    }
    
    //show number picked
    UIButton* randomNumberButton = (UIButton*)[[self view] viewWithTag:(10 + randomNumber)];
    [randomNumberButton setSelected:YES];
    
    //update the wanted result
    [self resultLabel].text = [NSString stringWithFormat:@"%d", _result];
    
}

- (void) showMakingTensContent:(BOOL)show
{
    
    for (int i=1; i<30; i++) {
        
        UIView* view = [[self view] viewWithTag:i];
        [view setHidden:!show];
        
    }
    
    
}

#pragma mark Even Or Odd

- (void) initializeEvenOrOddForLevel:(int)level
{
    
    
    
}

- (void) showEvenOrOddGame:(BOOL)show
{
    
    for (int i=41; i<44; i++) {
        
        UIView* view = [[self view] viewWithTag:i];
        [view setHidden:!show];
        
    }
    
}


- (void) initializeLowerThanOrGreaterThanForLevel:(int)level
{
    
    
    
}


- (void) showLessOrGreaterThanGame:(BOOL)show
{
    
    for (int i=51; i<56; i++) {
        
        UIView* view = [[self view] viewWithTag:i];
        [view setHidden:!show];
        
    }
    
}



- (void) pressNumberButton:(id)sender
{
    if (_buttonsActive) {
        
        _buttonsActive = NO;
        
        [sender setSelected:YES];
        
        //stop the timers
        [_bonusTimer invalidate];
        [_barTimer invalidate];
        
        if (_number1 == [[sender accessibilityIdentifier] intValue]) {
            
            //correct answer
            
            //play success sound
            [self.rightNumberSoundPlayer play];
            
            //update rounds left in current level
            _roundsLeftInLevel -= powf((_bonusPoints/1000.0),2.0);
            
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateBonusAndScoreLabels) userInfo:nil repeats:NO];
            
        } else {
            
            //incorrect answer
            
            [self.wrongNumberSoundPlayer play];
            
            //show right number
            for (int i=0; i < 9; i++) {
                
                UIButton* correspondingButton = ((UIButton*)[[self view] viewWithTag:[(UIButton*)sender tag]+1]);
                
                if (_number1 == [[correspondingButton accessibilityIdentifier] intValue]) {
                    
                    [correspondingButton setSelected:YES];
                    
                }
            }
            
            _score -= _bonusPoints;
            _bonusPoints = 0;
            [self.scoreLabel setText:[NSString stringWithFormat:@"%d", _score]];
            [self.bonusLabel setText:[NSString stringWithFormat:@"%d", _bonusPoints]];
            
            if (_score < 0) {
                _score = 0;
                [self gameOver];
            } else {
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getReadyForNextRound) userInfo:nil repeats:NO];
            }
        }
        
    } else {
        
        //do some animation that shows GO button must be pressed first
        
    }
}

/*
 
 TIMER AND BONUS FUNCTIONS
 
 */

#pragma mark Timer & Bonus Functions


- (void)startTimer {
    
    //activate the buttons
    _buttonsActive = YES;
    
    _barTimer = [NSTimer scheduledTimerWithTimeInterval:_barTimerFrequency target:self selector:@selector(removeBar:) userInfo:nil repeats:YES];
    _bonusTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(decreaseBonus:) userInfo:nil repeats:YES];
    
}

- (IBAction)pressEvenButton:(id)sender {
}

- (IBAction)pressOddButton:(id)sender {
}

- (void) removeBar:(id)sender
{
    
    //play remove-bar tick sound
    //[[self barTickSoundPlayer] stop];
    [[self barTickSoundPlayer] play];
    
    UIImageView* bar = (UIImageView*)[[self view] viewWithTag:(150 + _barsLeft - 1)];
    [bar setHidden:YES];
    _barsLeft--;
    
    if (_barsLeft < 1) {
        
        //game over
        [_barTimer invalidate];
        [_bonusTimer invalidate];
        [self gameOver];
        
    }
    
}

- (void) initializeBars
{
    
    for (int i = 0; i < 44; i++) {
        
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(60.0 + (15 * i), 850.0, 12.0, 59.0)];
        NSString* imageName;
        
        if (i < 5)          {imageName = @"meter_red.png";}
        else if (i < 18)    {imageName = @"meter_amber.png";}
        else                {imageName = @"meter_green.png";}
        
        image.image = [UIImage imageNamed:imageName];
        image.tag = 150 + i;
        
        [[self view] addSubview:image];
        
    }
    
    _barsLeft = 44;
    
}


- (void) resetBars
{
    
    for (int i = 0; i < 44; i++) {
        
        UIImageView* bar = (UIImageView*)[[self view] viewWithTag:(150 + i)];
        [bar setHidden:NO];
        
    }
    
    _barsLeft = 44;
    
}


- (void) decreaseBonus:(id) sender
{
    
    _bonusPoints -= ((100 * _barTimerFrequency) + (25/_level));
    [[self bonusLabel] setText:[NSString stringWithFormat:@"%d", _bonusPoints]];
    
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

#pragma mark OTHERS

- (void) getReadyForNextRound
{
    
    [self resetBars];
    [self.nextGoSoundPlayer play];
    [self showMakingTensContent:NO];
    [self showEvenOrOddGame:NO];
    [self showLessOrGreaterThanGame:NO];
    
    if (_roundsLeftInLevel > 0) {
        
        [self.goButton setHidden:NO];
        _buttonsActive = NO;
        _barTimerFrequency = _barTimerFrequency * 0.8;
        
        
    } else {
        
        //new level reached
        _level++;
        _barTimerFrequency = 0.25;
        _roundsLeftInLevel = 100.0;
        [self showInstructionsForLevel:_level];
        
    }
    

    
}


- (IBAction)confirmInstructions:(id)sender
{
    
    [self.instructionLabelHeader setHidden:YES];
    [self.instructionLabelText setHidden:YES];
    [self.instructionOKButton setHidden:YES];
    [self.titleLabel setText:@""];
    [self.goButton setHidden:NO];
    [self.goButton setEnabled:YES];
    
}

- (void)gameOver
{
    
    Score* userScore = [[Score alloc] initWithName:@"Paul" andScore:_score andDate:[NSDate date]];
    [userScore saveScore];
    [self performSegueWithIdentifier:@"showHighScores" sender:self];
    
    
}
@end
