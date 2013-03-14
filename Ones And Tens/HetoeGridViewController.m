//
//  HetoeGridViewController.m
//  Ones And Tens
//
//  Created by Fabian Henckmann on 4/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import "HetoeGridViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HetoeGridViewController ()

{
    BOOL _addButtonActive;
    BOOL _subtractButtonActive;
    BOOL _equalsButtonActive;
    int _systemState;
    int _firstNumber;
    int _secondNumber;
    int _result;
    
    UIColor* _blueTextColor;
    UIColor* _lightBlueTextColor;
    UIColor* _blackTextColor;
    UIColor* _redTextColor;
    UIColor* _greenTextColor;
    UIColor* _yellowTextColor;

    BOOL _playSpokenInstructions;
    BOOL _playSounds;
    BOOL _showOnes;
    BOOL _showTens;
    BOOL _hideSubtractions;
    BOOL _alwaysShowResult;
    
}

- (void) displayBoxesGoingUp:(BOOL)goingUp startAt:(int)startNumber switchNumber:(int)switchNumber firstImage:(NSString *)image1 firstColor:(UIColor*)color1 secondImage:(NSString *)image2 secondColor:(UIColor*)color2 numbering:(int)numberType sequencedAnimation:(BOOL)sequence;

- (void) displayBoxesGoingUp:(BOOL)goingUp startAt:(int)startNumber endAt:(int)endNumber switchNumber:(int)switchNumber firstImage:(NSString *)image1 firstColor:(UIColor*)color1 secondImage:(NSString *)image2 secondColor:(UIColor*)color2 numbering:(int)numberType sequencedAnimation:(BOOL)sequence;

- (void) displayBoxesGoingUp:(BOOL)goingUp startAt:(int)startNumber endAt:(int)endNumber currentNumber:(int)i switchNumber:(int)switchNumber firstImage:(NSString *)image1 firstColor:(UIColor*)color1 secondImage:(NSString *)image2 secondColor:(UIColor*)color2 numbering:(int)numberType sequencedAnimation:(BOOL)sequence;

- (void) clearAddSubtractButtons;
- (void) setStateToStart:(int)numberSelected;
- (void) toggleAddToSubtract;
- (void) toggleSubtractToAdd;
- (void) setStateToFirstNumberWithAddition:(BOOL)isAdd;

@end


@implementation HetoeGridViewController

static const int SYSTEM_STATE_START = 0;
static const int SYSTEM_STATE_FIRST_NUMBER_SET = 1;
static const int SYSTEM_STATE_SECOND_NUMBER_SET = 2;
static const int SYSTEM_STATE_RESULT_SHOWN = 3;

static const int NUMBER_TYPE_ALL = 0;
static const int NUMBER_TYPE_FIRST_PART = 1;
static const int NUMBER_TYPE_SECOND_PART = 2;
static const int NUMBER_TYPE_FIRST_PART_REVERSE = 3;

static const float _duration = 0.1f;

@synthesize errorSoundPlayer;
@synthesize switchSoundPlayer;
@synthesize boxSoundPlayer;


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
	// Do any additional setup after loading the view.
    
    _addButtonActive = NO;
    _subtractButtonActive = NO;
    _equalsButtonActive = NO;
    _systemState = SYSTEM_STATE_START;
    _firstNumber = 0;
    _secondNumber = 0;
    
    [[self equalsButton] setHidden:YES];
    [[self resultNumberLabel] setHidden:YES];
    [[self secondNumberLabel] setHidden:YES];
    
    _blueTextColor = [UIColor blueColor];
    _lightBlueTextColor = [UIColor colorWithRed:0.2 green:0.7 blue:1.0 alpha:1.0];
    _blackTextColor = [UIColor blackColor];
    _redTextColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    _greenTextColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    _yellowTextColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.0 alpha:1.0];
    
    NSURL* url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_error.wav", [[NSBundle mainBundle] resourcePath]]];
	
	NSError* error;
	self.errorSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	
	if (self.errorSoundPlayer == nil) {
		NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_switch.wav", [[NSBundle mainBundle] resourcePath]]];
    self.switchSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.switchSoundPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sound_box.wav", [[NSBundle mainBundle] resourcePath]]];
    NSLog(@"The URL is:%@", url.description);
    self.boxSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (self.boxSoundPlayer == nil) {
        NSLog([NSString stringWithFormat:@"Error loading sound:%@",[error description]]);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _playSpokenInstructions = [defaults boolForKey:@"playSpokenInstructions"];
    _playSounds = [defaults boolForKey:@"playSounds"];
    _showOnes = [defaults boolForKey:@"showOnes"];
    _showTens = [defaults boolForKey:@"showTens"];
    _hideSubtractions = [defaults boolForKey:@"hideSubtractions"];
    _alwaysShowResult = [defaults boolForKey:@"alwaysShowResult"];
    
//hide or display ones and tens guides
 
    if (!_showTens) {
        for (int i = 111; i < 121; i++) {
            [[self.view viewWithTag:i] setHidden:YES];
        }
    }
    
    if (!_showOnes) {
        for (int i = 101; i < 111; i++) {
            [[self.view viewWithTag:i] setHidden:YES];
        }
    }
    
    for (int row = 0; row < 10; row ++) {
        
        for (int column = 0; column < 10; column++) {
            
            UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_white.png"]];
            image.frame = CGRectMake(30 + (65 * column), 700 - (70 * row), 56.0, 56.0);
            image.tag = 200 + ((10 * row + column + 1));
            [image setAccessibilityIdentifier:@"box_white.png"];
            [self.view addSubview:image];
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(30 + (65 * column), 700 - (70 * row), 56.0, 56.0);
            //button.backgroundColor = [UIColor clearColor];
            button.tag = (10 * row) + column + 1;
            
            [button setTitleColor:_blackTextColor forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%d", button.tag] forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:button];

        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void) pressButton:(id)sender {
    
    int buttonNumber = [(UIButton*)sender tag];
        
    switch (_systemState) {
            
        case SYSTEM_STATE_START:
            
        //if the pressed button is higher than the current selection, animate upwards otherwise downwards
            
            if (buttonNumber > _firstNumber) {
                
                [self displayBoxesGoingUp:YES startAt:1 switchNumber:buttonNumber firstImage:@"box_blue.png" firstColor:_blueTextColor secondImage:@"box_white.png" secondColor:_blackTextColor numbering:NUMBER_TYPE_ALL sequencedAnimation:YES];
                
            } else {
                
                [self displayBoxesGoingUp:NO startAt:100 switchNumber:buttonNumber firstImage:@"box_white.png" firstColor:_blackTextColor secondImage:@"box_blue.png" secondColor:_blueTextColor numbering:NUMBER_TYPE_ALL sequencedAnimation:YES];
                
            }

            _firstNumber = buttonNumber;
            [self firstNumberLabel].text = [NSString stringWithFormat:@"%d", _firstNumber];
    
            break;
        
            
        case SYSTEM_STATE_FIRST_NUMBER_SET: 
            
            //states for first number set and second number set are the same...
            
        
            
        case SYSTEM_STATE_SECOND_NUMBER_SET: 
            
            if (_addButtonActive) {
                
                //we're adding a number to the first number, which is already set
                
                if (buttonNumber <= _firstNumber) {
                    
                    //ignore button press or perform "shake / buzz" animation to indicate button can't be pressed
                    [self.errorSoundPlayer play];
                    
                } else {
                    
                //if the button pressed is higher than the currently selected number, then animate upwards, otherwise downwards
                    
                    if (buttonNumber > (_secondNumber + _firstNumber)) {
                        
                        [self displayBoxesGoingUp:YES startAt:(_firstNumber+1) switchNumber:buttonNumber firstImage:@"box_green.png" firstColor:_greenTextColor secondImage:@"box_white.png" secondColor:_blackTextColor numbering:NUMBER_TYPE_ALL sequencedAnimation:YES];
                        
                    } else {
                        
                        [self displayBoxesGoingUp:NO startAt:(_firstNumber + _secondNumber) endAt:(_firstNumber+1) switchNumber:buttonNumber firstImage:@"box_white.png" firstColor:_blackTextColor secondImage:@"box_green.png" secondColor:_greenTextColor numbering:NUMBER_TYPE_ALL sequencedAnimation:YES];
                    }
                    
                    _secondNumber = buttonNumber - _firstNumber;
                    [self secondNumberLabel].text = [NSString stringWithFormat:@"%d", _secondNumber];
                    [[self equalsButton] setHidden:NO];
                    _systemState = SYSTEM_STATE_SECOND_NUMBER_SET;
                    
                }
                
            } else {
                
                //we're subtracting a number from the first number, which is already set
                
                if (buttonNumber > _firstNumber) {
                    
                //ignore button press or perform "shake / buzz" animation to indicate button can't be pressed
                    [self.errorSoundPlayer play];
                    
                } else {
                
                //if the button pressed is higher than the current second number, we animate upwards otherwise downwards
                    
                    if (buttonNumber <= _firstNumber - _secondNumber) {
                        
                        [self displayBoxesGoingUp:NO startAt:_firstNumber switchNumber:buttonNumber-1 firstImage:@"box_red.png" firstColor:_redTextColor secondImage:@"box_blue.png" secondColor:_blueTextColor numbering:NUMBER_TYPE_FIRST_PART_REVERSE sequencedAnimation:YES];
                        
                    } else {
                    
                        [self displayBoxesGoingUp:YES startAt:1 endAt:_firstNumber switchNumber:buttonNumber-1 firstImage:@"box_blue.png" firstColor:_blueTextColor secondImage:@"box_red.png" secondColor:_redTextColor numbering:NUMBER_TYPE_FIRST_PART_REVERSE sequencedAnimation:YES];
                        
                    }
                    
                    _secondNumber = _firstNumber + 1 - buttonNumber;
                    [self secondNumberLabel].text = [NSString stringWithFormat:@"%d", _secondNumber];
                    [[self equalsButton] setHidden:NO];
                    _systemState = SYSTEM_STATE_SECOND_NUMBER_SET;
                    
                }
                
            }
            
            break;
            
            
        case SYSTEM_STATE_RESULT_SHOWN: 
            
            [self setStateToStart:0];
            [self setStateToStart:buttonNumber];
            
            break;
    }
}


- (IBAction)addButtonPressed:(UIButton *)sender {
    
    switch (_systemState) {
            
        case SYSTEM_STATE_START: 
            
            if (_addButtonActive) {
                
                NSLog(@"this actually shouldn't happen, part 1");
                
            } else {
                
                [self setStateToFirstNumberWithAddition:YES];
                
            }
            
            break;
            
            
        case SYSTEM_STATE_FIRST_NUMBER_SET: 
            
            if (_addButtonActive) {
        //reset any second number already pressed, get back into "select first number" mode
                
                [self setStateToStart:_firstNumber];
                
            } else {
        //we're moving from subtract to add mode --> repaint all boxes light blue, rest white, remove second number
                
                [self setStateToFirstNumberWithAddition:YES];

            }
            
            break;
        
            
        case SYSTEM_STATE_SECOND_NUMBER_SET: {
            
            //erase all 2nd number fields and jump back to state "first number set", independent of whether plus button was already active or not
            [self setStateToFirstNumberWithAddition:YES];
            
        }
            
            
        case SYSTEM_STATE_RESULT_SHOWN: 
            
            //play error sound
            [self.errorSoundPlayer play];
            
            break;
        
    }
}

- (IBAction)subtractButtonPressed:(UIButton *)sender {
    
    switch (_systemState) {
            
        case SYSTEM_STATE_START: 
            
            if (_subtractButtonActive) {
                
                NSLog(@"this actually shouldn't happen, part 1");
                
            } else {
                
                //mark all buttons up to _firstNumber blue and the rest disabled white
                [self setStateToFirstNumberWithAddition:NO];
                
            }
            
            break;
            
        case SYSTEM_STATE_FIRST_NUMBER_SET: 
            
            if (_subtractButtonActive) {
                //reset any second number already pressed, get back into "select first number" mode
                
                [self setStateToStart:_firstNumber];
                
            } else {
                //we're moving from add to subtract mode --> repaint all boxes blue, rest disabled white, remove second number
                
                [self setStateToFirstNumberWithAddition:NO];
                
            }
            break;
        
            
        case SYSTEM_STATE_SECOND_NUMBER_SET:
            
            //erase all 2nd number fields and jump back to state "first number set", independent of whether subtract button was already active or not
            [self setStateToFirstNumberWithAddition:NO];
            
            break;
            
        case SYSTEM_STATE_RESULT_SHOWN: {
            
            //play error sound
            [self.errorSoundPlayer play];
            
            break;
            
        }
    }
}

- (IBAction)equalsButtonPressed:(UIButton *)sender {
    
    switch (_systemState) {
            
        case SYSTEM_STATE_START: 
            
            NSLog(@"Ouch - this should never happen!");
            
            break;
            
        
            
        case SYSTEM_STATE_FIRST_NUMBER_SET: 
            
            NSLog(@"Ouch - this should never happen!");
            
            break;
            
        
            
        case SYSTEM_STATE_SECOND_NUMBER_SET: 
            
            if (_addButtonActive) {
                _result = _firstNumber + _secondNumber;
            } else {
                _result = _firstNumber - _secondNumber;
            }
            
            [self resultNumberLabel].text = [NSString stringWithFormat:@"%d", _result];
            
            [self displayBoxesGoingUp:YES startAt:1 switchNumber:(_result) firstImage:@"box_yellow.png" firstColor:_yellowTextColor secondImage:@"box_white.png" secondColor:nil numbering:NUMBER_TYPE_FIRST_PART sequencedAnimation:NO];
            
            [[self resultNumberLabel] setHidden:NO];
            
            _systemState = SYSTEM_STATE_RESULT_SHOWN;
            
            break;
            
        
            
        case SYSTEM_STATE_RESULT_SHOWN: 
            
            
            // do something
            break;
            
            
    }
    
}

- (IBAction)clearContents:(UIButton *)sender {
    
    [self setStateToStart:0];
    
}


- (void) displayBoxesGoingUp:(BOOL)goingUp startAt:(int)startNumber switchNumber:(int)switchNumber firstImage:(NSString *)image1 firstColor:(UIColor*)color1 secondImage:(NSString *)image2 secondColor:(UIColor*)color2 numbering:(int)numberType sequencedAnimation:(BOOL)sequence
{
    int endNumber = (goingUp)? 100 : 1;
    
    [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:startNumber switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
    
}

- (void) displayBoxesGoingUp:(BOOL)goingUp startAt:(int)startNumber endAt:(int)endNumber switchNumber:(int)switchNumber firstImage:(NSString *)image1 firstColor:(UIColor*)color1 secondImage:(NSString *)image2 secondColor:(UIColor*)color2 numbering:(int)numberType sequencedAnimation:(BOOL)sequence {
    
    [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:startNumber switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
    
}

- (void) displayBoxesGoingUp:(BOOL)goingUp startAt:(int)startNumber endAt:(int)endNumber currentNumber:(int)i switchNumber:(int)switchNumber firstImage:(NSString *)image1 firstColor:(UIColor*)color1 secondImage:(NSString *)image2 secondColor:(UIColor*)color2 numbering:(int)numberType sequencedAnimation:(BOOL)sequence
{
    
    [[self boxSoundPlayer] stop];
    if (goingUp) {
        
        //animating bottom-up
        
        if (i <= endNumber) {
            
            NSString* transitionImage;
            UIButton* currentButton = ((UIButton*)[self.view viewWithTag:i]);
            int numberToShow = 0;
            
            if (i < switchNumber + 1) {
                
                transitionImage = image1;
                [currentButton setTitleColor:color1 forState:UIControlStateNormal];
                
                if (numberType == NUMBER_TYPE_FIRST_PART_REVERSE) {
                    
                    numberToShow =  _firstNumber - i + 1;
                    
                } else {
                    
                    numberToShow =  i - (startNumber - 1);
                    
                }
                
            } else {
                
                transitionImage = image2;
                [currentButton setTitleColor:color2 forState:UIControlStateNormal];
                
                if (numberType == NUMBER_TYPE_ALL) {
                    
                    numberToShow =  i - (startNumber -1);
                    
                } else if (numberType == NUMBER_TYPE_SECOND_PART) {
                    
                    numberToShow =  i - switchNumber;
                    
                } else if (numberType == NUMBER_TYPE_FIRST_PART_REVERSE) {
                    
                    numberToShow = _firstNumber - i + 1;
                    
                } 
                
            }
        
        if (numberToShow > 0) {
            
            [currentButton setTitle:[NSString stringWithFormat:@"%d", numberToShow] forState:UIControlStateNormal];
            
        } else {
            
            [currentButton setTitle:@"" forState:UIControlStateNormal];
            
        }
        
            UIImage * toImage = [UIImage imageNamed:transitionImage];

        //check if animation sequence required
            if (sequence) {

            //check if current image of view is identical to toImage and only perform animation if that is not the case
                if ([transitionImage isEqualToString:((UIImageView*)[self.view viewWithTag:200 + i]).accessibilityIdentifier]) {
                    
            //they're equal, so just move on to the next square
                    [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:i+1 switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
                    
                } else {
                    
            //they're not equal, so perform animation
                    ((UIImageView*)[self.view viewWithTag:200 + i]).accessibilityIdentifier = transitionImage;
                    
                    [self.boxSoundPlayer play];
                    
                    [UIView transitionWithView:[self view]
                                      duration:_duration
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        ((UIImageView*)[self.view viewWithTag:200 + i]).image = toImage;
                                    } completion:^(BOOL finished) {
                                        [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:i+1 switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
                                    }];
                }
                
            } else {
                
        //no animation sequence required, will do simple animation instead
                ((UIImageView*)[self.view viewWithTag:200 + i]).accessibilityIdentifier = transitionImage;
                [UIView transitionWithView:[self view]
                                  duration:0.25f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    ((UIImageView*)[self.view viewWithTag:200 + i]).image = toImage;
                                } completion:NULL];
                [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:i+1 switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
            }
        }
        
    } else {
        
        //animating top-down
        
        if (i >= endNumber) {
            
            NSString* transitionImage;
            UIButton* currentButton = ((UIButton*)[self.view viewWithTag:i]);
            int numberToShow = 0;
            
            if (i > switchNumber) {
                
                transitionImage = image1;
                [currentButton setTitleColor:color1 forState:UIControlStateNormal];
                
                if (numberType == NUMBER_TYPE_FIRST_PART_REVERSE) {
                    
                    numberToShow =  _firstNumber - i +1;
                    
                } else {
                    
                    numberToShow = i - endNumber + 1;
                    
                }
                
            } else {
                
                transitionImage = image2;
                [currentButton setTitleColor:color2 forState:UIControlStateNormal];
                
                if (numberType == NUMBER_TYPE_ALL) {
                    
                    numberToShow = i - endNumber + 1;
                    
                } else if (numberType == NUMBER_TYPE_SECOND_PART) {
                    
                    numberToShow = i - switchNumber;
                    
                } else {
                    
                    numberToShow = startNumber - i + 1;
                }
                
            }
            
            if (numberToShow > 0) {
                
                [currentButton setTitle:[NSString stringWithFormat:@"%d", numberToShow] forState:UIControlStateNormal];
                
            } else {
                
                [currentButton setTitle:@"" forState:UIControlStateNormal];
                
            }
            
            UIImage * toImage = [UIImage imageNamed:transitionImage];
            
            //check if animation sequence required
            if (sequence) {
                
                //check if current image of view is identical to toImage and only perform animation if that is not the case
                if ([transitionImage isEqualToString:((UIImageView*)[self.view viewWithTag:200 + i]).accessibilityIdentifier]) {
                    
                //they're equal, so just move on to the next square
                    [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:i-1 switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
                    
                } else {
                    
                //they're not equal, so perform animation
                    ((UIImageView*)[self.view viewWithTag:200 + i]).accessibilityIdentifier = transitionImage;
                    
                    [self.boxSoundPlayer play];
                    
                    [UIView transitionWithView:[self view]
                                      duration:_duration
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        ((UIImageView*)[self.view viewWithTag:200 + i]).image = toImage;
                                    } completion:^(BOOL finished) {
                                        [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:i-1 switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
                                    }];
                }
                
            } else {
                
                //no animation sequence required, will do simple animation instead
                ((UIImageView*)[self.view viewWithTag:200 + i]).accessibilityIdentifier = transitionImage;
                [UIView transitionWithView:[self view]
                                  duration:0.25f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    ((UIImageView*)[self.view viewWithTag:200 + i]).image = toImage;
                                } completion:NULL];
                [self displayBoxesGoingUp:goingUp startAt:startNumber endAt:endNumber currentNumber:i-1 switchNumber:switchNumber firstImage:image1 firstColor:color1 secondImage:image2 secondColor:color2 numbering:numberType sequencedAnimation:sequence];
            }
            
        }
    }
}
    

- (void) setStateToStart:(int)numberSelected
{
    
    //set numbers
    _firstNumber = numberSelected;
    _secondNumber = 0;
    
    //color selected blocks
    [self displayBoxesGoingUp:YES startAt:1 switchNumber:_firstNumber firstImage:@"box_blue.png" firstColor:_blueTextColor secondImage:@"box_white.png" secondColor:_blackTextColor numbering:NUMBER_TYPE_ALL sequencedAnimation:_firstNumber];
    
    //set labels
    [self firstNumberLabel].text = [NSString stringWithFormat:@"%d", _firstNumber ];
    [self secondNumberLabel].text = [NSString stringWithFormat:@"%d", _secondNumber];
    
    //hide labels
    [[self secondNumberLabel] setHidden:YES];
    [[self resultNumberLabel] setHidden:YES];
    [[self equalsButton] setHidden:YES];
    
    _systemState = SYSTEM_STATE_START;
    
    [self clearAddSubtractButtons];
    
}

- (void)setStateToFirstNumberWithAddition:(BOOL)isAdd
{
    
    _systemState = SYSTEM_STATE_FIRST_NUMBER_SET;
    _secondNumber = 0;
    
    //set labels
    [self firstNumberLabel].text = [NSString stringWithFormat:@"%d", _firstNumber ];
    [self secondNumberLabel].text = [NSString stringWithFormat:@"%d", _secondNumber];
    
    //show and hide labels
    [[self secondNumberLabel] setHidden:NO];
    [[self resultNumberLabel] setHidden:YES];
    [[self equalsButton] setHidden:YES];
    
    if (isAdd) {
        
        //mark all buttons up to _firstNumber light blue and the rest standard white
        [self displayBoxesGoingUp:YES startAt:1 switchNumber:_firstNumber firstImage:@"box_blue_disabled.png" firstColor:_lightBlueTextColor secondImage:@"box_white.png" secondColor:_blackTextColor numbering:NUMBER_TYPE_SECOND_PART sequencedAnimation:NO];
        [self toggleSubtractToAdd];
        
    } else {
        
        //mark all buttons up to _firstNumber light blue and the rest standard white
        [self displayBoxesGoingUp:YES startAt:1 switchNumber:_firstNumber firstImage:@"box_blue.png" firstColor:_blueTextColor secondImage:@"box_white_disabled.png" secondColor:nil numbering:NUMBER_TYPE_FIRST_PART_REVERSE sequencedAnimation:NO];
        [self toggleAddToSubtract];
        
    }
    
}


- (void) clearAddSubtractButtons
{
    
    [self.switchSoundPlayer play];
    _addButtonActive = NO;
    _subtractButtonActive = NO;
    [[self addButton] setBackgroundImage:[UIImage imageNamed:@"button_plus_inactive.png"] forState:UIControlStateNormal];
    [[self subtractButton] setBackgroundImage:[UIImage imageNamed:@"button_minus_inactive.png"] forState:UIControlStateNormal];
    
}

- (void) toggleAddToSubtract
{
    
    [self.switchSoundPlayer play];
    _addButtonActive = NO;
    _subtractButtonActive = YES;
    [self.addButton setBackgroundImage:[UIImage imageNamed:@"button_plus_inactive.png"] forState:UIControlStateNormal];
    [self.subtractButton setBackgroundImage:[UIImage imageNamed:@"button_minus_active.png"] forState:UIControlStateNormal];
    
}

- (void) toggleSubtractToAdd
{
    
    [self.switchSoundPlayer play];
    _addButtonActive = YES;
    _subtractButtonActive = NO;
    [self.addButton setBackgroundImage:[UIImage imageNamed:@"button_plus_active.png"] forState:UIControlStateNormal];
    [self.subtractButton setBackgroundImage:[UIImage imageNamed:@"button_minus_inactive.png"] forState:UIControlStateNormal];
    
}

@end
