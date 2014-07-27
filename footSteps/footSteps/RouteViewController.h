//
//  RouteViewController.h
//  footSteps
//
//  Created by Sumit Chaudhary on 12/05/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import "ViewController.h"

#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>

#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>

#import <OpenEars/OpenEarsEventsObserver.h>


@interface RouteViewController : ViewController<OpenEarsEventsObserverDelegate>{
  
  PocketsphinxController *pocketsphinxController;
  
  FliteController *fliteController;
  Slt *slt;
  
  OpenEarsEventsObserver *openEarsEventsObserver;

}

@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;

@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;

@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

@end
