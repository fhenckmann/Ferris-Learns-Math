//
//  Score.h
//  Ones And Tens
//
//  Created by Fabian Henckmann on 14/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject <NSCoding>

@property (strong, nonatomic) NSString* playerName;
@property (strong, nonatomic) NSDate* scoreDate;
@property (nonatomic) int score;

- (Score*) initWithName:(NSString*)playerName andScore:(int)score andDate:(NSDate*)date;
- (BOOL) saveScore;
+ (Score*) getScoreAtPosition:(int)position;
+ (NSArray*) getScores;
- (BOOL) isEqualToScore:(Score*)compareScore;
- (BOOL) isHighScore;
- (BOOL) isInTopTen;
+ (NSArray*) getDefaultScores;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
