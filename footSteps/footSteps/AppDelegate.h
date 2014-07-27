//
//  AppDelegate.h
//  footSteps
//
//  Created by stc-fueled on 5/6/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PESGraph.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PESGraph *mainGraph;
@property (strong, nonatomic) NSMutableArray *graphsArray;
@end
