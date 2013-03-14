//
//  HetoeOptionsViewController.m
//  Ones And Tens
//
//  Created by Fabian Henckmann on 8/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import "HetoeOptionsViewController.h"

@interface HetoeOptionsViewController ()

@end

@implementation HetoeOptionsViewController

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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[self switchPlaySpokenInstructions] setOn:[defaults boolForKey:@"playSpokenInstructions"] animated:NO];
    [[self switchPlaySounds] setOn:[defaults boolForKey:@"playSounds"] animated:NO];
    [[self switchShowOnes] setOn:[defaults boolForKey:@"showOnes"] animated:NO];
    [[self switchShowTens] setOn:[defaults boolForKey:@"showTens"] animated:NO];
    [[self switchHideSubtractions] setOn:[defaults boolForKey:@"hideSubtractions"] animated:NO];
    [[self switchAlwaysShowResult] setOn:[defaults boolForKey:@"alwaysShowResult"] animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"saveAndBack"]) {
        
        [self saveOptions:sender];
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)saveOptions:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"PlaySpokenInstructions switch is: %@", [NSNumber numberWithBool:[self switchPlaySpokenInstructions].isOn]);
    
    [defaults setBool:[self switchPlaySpokenInstructions].isOn forKey:@"playSpokenInstructions"];
    [defaults setBool:[self switchPlaySounds].isOn forKey:@"playSounds"];
    [defaults setBool:[self switchShowOnes].isOn forKey:@"showOnes"];
    [defaults setBool:[self switchShowTens].isOn forKey:@"showTens"];
    [defaults setBool:[self switchHideSubtractions].isOn forKey:@"hideSubtractions"];
    [defaults setBool:[self switchAlwaysShowResult].isOn forKey:@"alwaysShowResult"];

    [defaults synchronize];
    
}
@end
