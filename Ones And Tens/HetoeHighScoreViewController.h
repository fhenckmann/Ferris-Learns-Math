//
//  HetoeHighScoreViewController.h
//  Ones And Tens
//
//  Created by Fabian Henckmann on 21/03/13.
//  Copyright (c) 2013 Fabian Henckmann. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Score;

@interface HetoeHighScoreViewController : UITableViewController

@property (nonatomic, retain) Score* highScores;

@end
