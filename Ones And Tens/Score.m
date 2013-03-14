//
//  Score.m
//  Ones And Tens
//
//  Created by Fabian Henckmann on 14/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import "Score.h"

@interface Score ()
{
    
}

@end

@implementation Score

- (Score*) initWithName:(NSString*)playerName andScore:(int)score andDate:(NSDate *)date
{
    
   self = [super init];
    
    if (self != NULL) {
        
        self.playerName = playerName;
        self.score = score;
        self.scoreDate = date;
        
    }
    
    return self;
    
}

- (BOOL) saveScore {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* highScores = [NSMutableArray arrayWithArray:(NSArray *)[defaults objectForKey:@"highScores"]];
    BOOL currentScoreWasAdded = NO;
    
    for (int i = 0; i < 10; i++) {
        
        Score* currentScore = [highScores objectAtIndex:i];
        
        if (self.score > currentScore.score) {
            
            [highScores insertObject:self atIndex:i];
            [highScores removeObjectAtIndex:10];
            currentScoreWasAdded = YES;
            break;
            
        } 
        
    }
    
    if (currentScoreWasAdded) {
        
        [defaults setObject:highScores forKey:@"highScores"];
        [defaults synchronize];
        
    }
    
    return currentScoreWasAdded;
    
}


- (Score*) getScoreAtPosition:(int)position {
    
    Score* returnScore = [[self getScores] objectAtIndex:position];
    
    return returnScore;
    
}


- (BOOL) isEqualToScore:(Score*)compareScore
{
    
    if ((self.score == compareScore.score) && ([self.scoreDate isEqualToDate:compareScore.scoreDate]) && ([self.playerName isEqualToString:compareScore.playerName])) {
        return YES;
    } else {
        return NO;
    }
    
}


- (BOOL) isHighScore
{
    
    NSArray* scores = [self getScores];
    
    if (self.score >= [(Score*)[scores objectAtIndex:0] score]) {
        
        return YES;
    } else {
        return NO;
    }
    
}


- (BOOL) isInTopTen
{
    
    NSArray* scores = [self getScores];
    
    if (self.score >= [(Score*)[scores objectAtIndex:9] score]) {
        
        return YES;
    } else {
        return NO;
    }
    
}

- (NSArray*) getScores
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSArray *)[defaults objectForKey:@"highScores"];
    
}

+ (NSArray*) getDefaultScores
{
    
    NSMutableArray* scores = [NSMutableArray array];
    Score* score1 = [[Score alloc] initWithName:@"Anabelle" andScore:50000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score1];
    Score* score2 = [[Score alloc] initWithName:@"Billy" andScore:45000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score2];
    Score* score3 = [[Score alloc] initWithName:@"Charlotte" andScore:40000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score3];
    Score* score4 = [[Score alloc] initWithName:@"Dennis" andScore:35000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score4];
    Score* score5 = [[Score alloc] initWithName:@"Eva" andScore:30000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score5];
    Score* score6 = [[Score alloc] initWithName:@"Fritz" andScore:25000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score6];
    Score* score7 = [[Score alloc] initWithName:@"Gabrielle" andScore:20000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score7];
    Score* score8 = [[Score alloc] initWithName:@"Henry" andScore:15000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score8];
    Score* score9 = [[Score alloc] initWithName:@"Isobelle" andScore:10000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score9];
    Score* score10 = [[Score alloc] initWithName:@"Jake" andScore:50000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    [scores addObject:score10];
    
    return scores;
    
    
}

@end
