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

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.playerName = [decoder decodeObjectForKey:@"playerName"];
        self.score = [decoder decodeIntForKey:@"score"];
        self.scoreDate = [decoder decodeObjectForKey:@"date"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.playerName forKey:@"playerName"];
    [encoder encodeInt:self.score forKey:@"score"];
    [encoder encodeObject:self.scoreDate forKey:@"date"];
}

- (BOOL) saveScore {
    
    BOOL currentScoreWasAdded = NO;
    
    NSData *archiveScore = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSMutableArray* highScores = [NSMutableArray arrayWithArray:[Score getScores]];
    
    for (int i = 0; i < 10; i++) {
        
        Score* currentScore = [Score getScoreAtPosition:i];
        
        if (self.score > currentScore.score) {
            
            [highScores insertObject:archiveScore atIndex:i];
            [highScores removeObjectAtIndex:10];
            currentScoreWasAdded = YES;
            break;
            
        } 
        
    }
    
    if (currentScoreWasAdded) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:highScores forKey:@"highScores"];
        [defaults synchronize];
        
    }
    
    return currentScoreWasAdded;
    
}


+ (Score*) getScoreAtPosition:(int)position {
    
    NSData *archivedObject = (NSData*)[[self getScores] objectAtIndex:position];
    Score *returnScore = (Score*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    
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
    
    NSArray* scores = [Score getScores];
    NSData *archivedObject = (NSData*)[scores objectAtIndex:0];
    Score *highestScore = (Score*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    
    if (self.score >= [highestScore score]) {
        return YES;
    } else {
        return NO;
    }
    
}


- (BOOL) isInTopTen
{
    
    NSArray* scores = [Score getScores];
    NSData *archivedObject = (NSData*)[scores objectAtIndex:9];
    Score *lowestScore = (Score*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    
    if (self.score >= [lowestScore score]) {
        return YES;
    } else {
        return NO;
    }
    
}

+ (NSArray*) getScores
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSArray *)[defaults objectForKey:@"highScores"];
    
}

+ (NSArray*) getDefaultScores
{
    
    NSMutableArray* scores = [NSMutableArray array];
    Score* score1 = [[Score alloc] initWithName:@"Anabelle" andScore:50000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject1 = [NSKeyedArchiver archivedDataWithRootObject:score1];
    [scores addObject:archiveObject1];
    
    Score* score2 = [[Score alloc] initWithName:@"Billy" andScore:45000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject2 = [NSKeyedArchiver archivedDataWithRootObject:score2];
    [scores addObject:archiveObject2];
    
    Score* score3 = [[Score alloc] initWithName:@"Charlotte" andScore:40000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject3 = [NSKeyedArchiver archivedDataWithRootObject:score3];
    [scores addObject:archiveObject3];
    
    Score* score4 = [[Score alloc] initWithName:@"Dennis" andScore:35000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject4 = [NSKeyedArchiver archivedDataWithRootObject:score4];
    [scores addObject:archiveObject4];
    
    Score* score5 = [[Score alloc] initWithName:@"Eva" andScore:30000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject5 = [NSKeyedArchiver archivedDataWithRootObject:score5];
    [scores addObject:archiveObject5];
    
    Score* score6 = [[Score alloc] initWithName:@"Fritz" andScore:25000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject6 = [NSKeyedArchiver archivedDataWithRootObject:score6];
    [scores addObject:archiveObject6];
    
    Score* score7 = [[Score alloc] initWithName:@"Gabrielle" andScore:20000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject7 = [NSKeyedArchiver archivedDataWithRootObject:score7];
    [scores addObject:archiveObject7];
    
    Score* score8 = [[Score alloc] initWithName:@"Henry" andScore:15000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject8 = [NSKeyedArchiver archivedDataWithRootObject:score8];
    [scores addObject:archiveObject8];
    
    Score* score9 = [[Score alloc] initWithName:@"Isobelle" andScore:10000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject9 = [NSKeyedArchiver archivedDataWithRootObject:score9];
    [scores addObject:archiveObject9];
    
    Score* score10 = [[Score alloc] initWithName:@"Jake" andScore:50000 andDate:[NSDate dateWithTimeIntervalSinceReferenceDate:315360000]];
    NSData* archiveObject10 = [NSKeyedArchiver archivedDataWithRootObject:score10];
    [scores addObject:archiveObject10];
    
    
    return scores;
    
    
}

@end
