//
//  RouteViewController.m
//  footSteps
//
//  Created by Sumit Chaudhary on 12/05/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import "RouteViewController.h"
#import "PESGraph.h"
#import "AppDelegate.h"
#import "PESGraphRouteStep.h"
#import "PESGraphNode.h"
#import "PESGraphEdge.h"
#import "PESGraphRoute.h"
#import <OpenEars/LanguageModelGenerator.h>
#import <CoreMotion/CoreMotion.h>



@interface RouteViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *graphsArray;
@property (nonatomic, strong) PESGraph *selectedGraph;
@property (nonatomic, strong) PESGraphNode *startNode;
@property (nonatomic, strong) PESGraphNode *endNode;
@property (nonatomic, strong) NSMutableArray *routeDescArray;
@property (nonatomic, strong) NSMutableArray *stepsToTake;
@property(nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic, strong) NSOperationQueue *queue;
@end

@implementation RouteViewController


@synthesize openEarsEventsObserver;

@synthesize pocketsphinxController;

@synthesize fliteController;
@synthesize slt;
int listenState  =0;
int followstate = 0;
int stepsBeforeChange = 0;

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
 self.graphsArray = ((AppDelegate*)([UIApplication sharedApplication].delegate)).graphsArray;
    // Do any additional setup after loading the view.
  self.motionManager = [[CMMotionManager alloc]init];
  self.queue = [[NSOperationQueue alloc] init];
  LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
  
  NSArray *words = [NSArray arrayWithObjects:@"KITCHEN", @"BATHROOM", @"LIVING ROOM", @"BEDROOM", @"QUIT", @"NEXT", @"E BLOCK",@"D BLOCK",@"F BLOCK",@"MAIN GATE", nil];
  NSString *name = @"NameIWantForMyLanguageModelFiles";
  NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
  
  
  NSDictionary *languageGeneratorResults = nil;
  
  NSString *lmPath = nil;
  NSString *dicPath = nil;
	
  if([err code] == noErr) {
    
    languageGeneratorResults = [err userInfo];
		
    lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
    dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
  } else {
    NSLog(@"Error: %@",[err localizedDescription]);
  }
  
  
  [self.openEarsEventsObserver setDelegate:self];
  [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
}

-(void)viewDidAppear:(BOOL)animated{
  self.selectedGraph = [self.graphsArray objectAtIndex:0];
  
  NSArray *nodes = [self.selectedGraph.nodes allValues];
  NSString *checkpoints = @"Check Points Are ";
  for (PESGraphNode * node in nodes) {
    if ([node.additionalData objectForKey:@"checkpoint"]!=nil) {
      checkpoints = [checkpoints stringByAppendingString:[node.additionalData objectForKey:@"checkpoint"]];
      checkpoints = [checkpoints stringByAppendingString:@" , "];
      
    }
  }
  self.slt.duration_stretch_default = 2;
  checkpoints = [checkpoints stringByAppendingString:@"PLEASE SELECT STARTING POINT"];
  listenState = 1;
  NSLog(@"check %@",checkpoints);
  [self.fliteController say:checkpoints withVoice:self.slt];

}

-(void)findRoute{
  PESGraphRoute *route = [self.selectedGraph shortestRouteFromNode:self.startNode toNode:self.endNode];
  NSMutableArray *routeArray = [NSMutableArray array];
  for (int i=0; i<route.steps.count; ++i) {
    PESGraphRouteStep *step = (PESGraphRouteStep *)[route.steps objectAtIndex:i];
    PESGraphNode *node = step.node;
    NSLog(@"node no.%@ : dir %@:",node.identifier, [node.additionalData valueForKeyPath:@"direction"]);
    [routeArray addObject:[node.additionalData valueForKeyPath:@"direction"]];
  }
  [self processRoute:routeArray];
}


-(void)processRoute:(NSMutableArray*)routeArray{
  NSArray *dirStrings = @[@"straight", @"right", @"left", @"back"];
  NSString *routeDesc = @"";
  self.routeDescArray = [NSMutableArray array];
  int index = 0;
  int sameCount = 0;
  for (; index<routeArray.count; ++index) {
    NSNumber *direction = [routeArray objectAtIndex:index];
    int dir = direction.intValue;
    if (dir == 0) {
      sameCount ++;
      if(index == routeArray.count-1){
        routeDesc =  [routeDesc stringByAppendingString:[NSString stringWithFormat:@"%d steps in straight direction \n", sameCount]];
        [self.routeDescArray addObject:[NSString stringWithFormat:@"%d steps in straight direction \n", sameCount]];
        [self.stepsToTake addObject:[NSNumber numberWithInt:sameCount]];
        sameCount = 0;
      }
    }
    else{
      if (sameCount>0) {
        routeDesc =  [routeDesc stringByAppendingString:[NSString stringWithFormat:@"%d steps in straight direction \n", sameCount]];
         [self.routeDescArray addObject:[NSString stringWithFormat:@"%d steps in straight direction \n", sameCount]];
        [self.stepsToTake addObject:[NSNumber numberWithInt:sameCount]];
      }
      routeDesc =  [routeDesc stringByAppendingString:[NSString stringWithFormat:@"Take a %@ turn \n",[dirStrings objectAtIndex:dir]]];
       [self.routeDescArray addObject:[NSString stringWithFormat:@"Take a %@ turn \n",[dirStrings objectAtIndex:dir]]];
      [self.stepsToTake addObject:[NSNumber numberWithInt:1]];
      sameCount = 0;
    }
  }
  NSLog(@"route map: %@",routeDesc);
  listenState = 4;
  [self.fliteController say:[self.routeDescArray objectAtIndex:0] withVoice:self.slt];
  followstate++;
  [self.motionManager startDeviceMotionUpdatesToQueue:self.queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
    [self startWalking:motion];
  }];
}

-(void)startWalking:(CMDeviceMotion *)motion{
  CMAcceleration acceleration = motion.userAcceleration;
  const float violence = 0.29;
  const float yawChange = 1;
  static BOOL beenhere;
  BOOL shake = FALSE;
  int trn = 0;
  if (beenhere) return;
  beenhere = TRUE;
  if (acceleration.x > violence || acceleration.x < (-1* violence))
    shake = TRUE;
  if (acceleration.y > violence || acceleration.y < (-1* violence))
    shake = TRUE;
  if (acceleration.z > violence || acceleration.z < (-1* violence))
    shake = TRUE;
  
  if (shake) {
    dispatch_async(dispatch_get_main_queue(), ^{
      });
    stepsBeforeChange++;
    if (stepsBeforeChange>= ((NSNumber*)([self.stepsToTake objectAtIndex:followstate])).intValue) {
      if (followstate<self.routeDescArray.count) {
        [self.fliteController say:[self.routeDescArray objectAtIndex:followstate] withVoice:self.slt];
        followstate++;
        stepsBeforeChange = [self.stepsToTake objectAtIndex:followstate];
      }
      else{
        [self.fliteController say:@"You have reached, say quit to exit" withVoice:self.slt];
      }

    }
  }
}

-(PESGraphNode *)findNode:(NSString *)identifier inGraph:(PESGraph*)graph{
  PESGraphNode *node = [graph.nodes objectForKey:identifier];
  return node;
}


#pragma mark - TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  PESGraph *graph =   [self.graphsArray objectAtIndex:0];
  return graph.nodes.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteVCCell"];
   PESGraph *graph =   [self.graphsArray objectAtIndex:0];
  return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//  self.selectedGraph = [self.graphsArray objectAtIndex:indexPath.row];
//  
//  NSArray *nodes = [self.selectedGraph.nodes allValues];
//  NSString *checkpoints = @"Check Points Are ";
//  for (PESGraphNode * node in nodes) {
//    if ([node.additionalData objectForKey:@"checkpoint"]!=nil) {
//      checkpoints = [checkpoints stringByAppendingString:[node.additionalData objectForKey:@"checkpoint"]];
//      checkpoints = [checkpoints stringByAppendingString:@" AND "];
//
//    }
//  }
//  checkpoints = [checkpoints stringByAppendingString:@" SELECT START POINT "];
//  NSLog(@"check %@",checkpoints);
//  [self.fliteController say:checkpoints withVoice:self.slt];
//}

- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}


- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}


- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

#pragma mark - Open Ears Delegates

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
  if ([hypothesis isEqualToString: @"QUIT"]) {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                               
                             }];
  }
  
//  if (listenState==4) {
//    if ([hypothesis isEqualToString: @"NEXT"]){
//      if (followstate<self.routeDescArray.count) {
//        [self.fliteController say:[self.routeDescArray objectAtIndex:followstate] withVoice:self.slt];
//        followstate++;
//      }
//      else{
//        [self.fliteController say:@"You have reached, say quit to exit" withVoice:self.slt];
//      }
//    }
//  }
  
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
  if (listenState==1 && hypothesis!=nil) {
    for (PESGraphNode *node in [self.selectedGraph.nodes allValues]) {
      NSString *chec = [node.additionalData valueForKeyPath:@"checkpoint"];
      if ([hypothesis isEqualToString: [chec uppercaseString]]) {
        self.startNode = node;
        listenState = 2;
      }
    }
    if (listenState == 2) {
       [self.fliteController say:[NSString stringWithFormat:@"You selected %@, now pick second checkpoint", hypothesis] withVoice:self.slt];
    }
    else{
      [self.fliteController say:[NSString stringWithFormat:@"can not find checkpoint"] withVoice:self.slt];
      listenState = 1;
    }
   
  }
  
  else if (listenState==2 && hypothesis!=nil) {
    for (PESGraphNode *node in [self.selectedGraph.nodes allValues]) {
      NSString *chec = [node.additionalData valueForKeyPath:@"checkpoint"];
      if ([hypothesis isEqualToString: [chec uppercaseString]]) {
        self.endNode = node;
        listenState = 0;
        [self performSelector:@selector(findRoute) withObject:nil afterDelay:1];
      }
    }
  }
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
