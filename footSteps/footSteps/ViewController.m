//
//  ViewController.m
//  footSteps
//
//  Created by stc-fueled on 5/6/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>
#import "PESGraph.h"
#import "PESGraphNode.h"
#import "PESGraphEdge.h"
#import "PESGraphRoute.h"
#import "PESGraphRouteStep.h"
#import "AppDelegate.h"
#import "Map.h"
#import "GraphNode.h"


@interface ViewController ()<UIAccelerometerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;
@property(nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) NSString *contentdata;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, assign)  int turn;
@property(nonatomic, assign)  CGFloat yaw;
@property(nonatomic, strong)  NSMutableArray *pointsArray;
@property(nonatomic, strong)  PESGraph *graph;
@property(nonatomic, strong) NSMutableArray *nodesArray;
@property(nonatomic, strong) PESGraphNode *prevNode;
@property(nonatomic, assign) BOOL isMapping;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation ViewController
int steps=0;
BOOL startingPoint;
int dir = 1;
int quadrant =0;
int x,y;
- (void)viewDidLoad
{
    [super viewDidLoad];
  self.turn = YES;
  self.motionManager = [[CMMotionManager alloc] init];
  self.queue = [[NSOperationQueue alloc] init];
  self.date = [NSDate date];
  self.pointsArray = [[NSMutableArray alloc] init];
  self.graph = [[PESGraph alloc] init];
  self.nodesArray = [[NSMutableArray alloc] init];
  self.isMapping = NO;
  startingPoint = YES;
  x=0;
  y=0;
}

-(void)didUpdateMotion:(CMDeviceMotion*)motion{
  int alpha = 0.2;
    // alpha is the filter value (instance variable)
  float filteredAcceleration[3];
  CMAcceleration newestAccel = motion.userAcceleration;
  filteredAcceleration[0] = filteredAcceleration[0] * (1.0-alpha) + newestAccel.x * alpha;
  filteredAcceleration[1] = filteredAcceleration[1] * (1.0-alpha) + newestAccel.y * alpha;
  filteredAcceleration[2] = filteredAcceleration[2] * (1.0-alpha) + newestAccel.z * alpha;
  [self processStep:motion.userAcceleration withYaw:motion.attitude.yaw];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addCheckpoint:(id)sender {
  if (!self.isMapping) {
    return;
  }
  
  self.isMapping = NO;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ADD CHECKPOINT" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  [alert show];
}

#pragma mark - alertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if ([alertView textFieldAtIndex:0].text != nil) {
    [self.prevNode.additionalData setValue:[alertView textFieldAtIndex:0].text forKeyPath:@"checkpoint"];
    self.isMapping = YES;
  }
}
#pragma mark -

- (IBAction)mailFile:(id)sender {
  if (!((UIButton*)sender).selected) {
    self.isMapping = YES;
    [self.motionManager startDeviceMotionUpdatesToQueue:self.queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
      [self didUpdateMotion:motion];
    }];
    ((UIButton*)sender).selected=YES;
  }
  else{
    self.isMapping = NO;
    [self.motionManager stopDeviceMotionUpdates];
    NSLog(@"ARRAY: %@", self.pointsArray);
    ((UIButton*)sender).selected=NO;
    //==================
//    NSArray *dummy = @[@"KITCHEN", @"BEDROOM", @"BATHROOM"];
    if (self.graph.nodes.allKeys.count == 0 ) {
        PESGraphNode *node1 = [PESGraphNode nodeWithIdentifier:@"KITCHEN"];
      [node1.additionalData setValue:@"KITCHEN" forKeyPath:@"checkpoint"];
        PESGraphNode *node2 = [PESGraphNode nodeWithIdentifier:@"BATHROOM"];
      [node2.additionalData setValue:@"BATHROOM" forKeyPath:@"checkpoint"];

      [self.graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-B" andWeight:[NSNumber numberWithInt:1]] fromNode:node1 toNode:node2];

    }
    //==================
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).graphsArray addObject:self.graph];
    
  }
}

- (void)processStep:(CMAcceleration)acceleration withYaw:(CGFloat)yaw{
  if (!self.isMapping) {
    return;
  }
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
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.date];
        if (time>0.4) {
          steps=steps+1;
          self.date = [NSDate date];
          float change = yaw - self.yaw;
          if (self.yaw <= 0.9 && self.yaw >= -0.9 && yaw <= -1.3 && yaw >= -1.7){
            self.turn = 1;
            NSLog(@"Right");
          }
          else if (self.yaw <= -1.3 && self.yaw >= -1.7 && (yaw <= -2.7 || yaw >=2.7)){
            self.turn = 1;
            NSLog(@"Right");
          }
          else if (yaw >= 1.3  && yaw <= 1.7 && (self.yaw <= -2.7 || self.yaw >= 2.7)){
            self.turn = 1;
            NSLog(@"Right");
          }
          else if ( yaw <=0.9 && yaw >= -0.9 && self.yaw >= 1.3 && self.yaw <= 1.7){
            self.turn = 1;
            NSLog(@"Right");
          }
          // Right cases END
          else if (self.yaw <= 0.9 && self.yaw >= -0.9 && yaw >=1.3 && yaw <=1.7){
            self.turn = 2;
            NSLog(@"Left");
          }
          else if (self.yaw >= 1.3 && self.yaw <= 1.7 && (yaw >= 2.7 || yaw <= -2.7)){
            self.turn = 2;
            NSLog(@"Left");
          }
          else if (yaw <= -1.3  && yaw >= -1.7 && (self.yaw >= 2.7 || self.yaw <= -2.7)){
            self.turn = 2;
            NSLog(@"Left");
          }
          else if ( self.yaw <= -1.3 && self.yaw >= -1.7 && yaw <=0.9 && yaw >= -0.9){
            self.turn = 2;
            NSLog(@"Left");
          }
          else if ( change > -0.1 &&  change < 0.1){
            self.turn = 0;
            NSLog(@"Straight");
          }
          
          
          self.yaw = yaw;
          
          NSString *turnString =@"";
          switch (self.turn) {
            case 0:
              turnString = @"str";
              break;
            case 1:
              turnString = @"right";
              break;
              
            case 2:
              turnString = @"left";
              break;
              
            default:
              break;
          }
          //==========
          if (dir == 1 && self.turn == 0)
            dir = 1;
          else if (dir == 1 && self.turn == 1)
            dir = 2;
          else if (dir == 1 && self.turn == 2)
            dir = 4;
          else if (dir == 1 && self.turn == 3)
            dir = 3;
            // north cases ends
            
          else if (dir == 2 && self.turn == 0)
            dir = 2;
          else if (dir == 2 && self.turn == 1)
            dir = 3;
          else if (dir == 2 && self.turn == 2)
            dir = 1;
          else if (dir == 2 && self.turn == 3)
            dir = 4;
            // east cases ends
            
          else if (dir == 3 && self.turn == 0)
            dir = 3;
          else if (dir == 3 && self.turn == 1)
            dir = 4;
          else if (dir == 3 && self.turn == 2)
            dir = 2;
          else if (dir == 3 && self.turn == 3)
            dir = 1;
          
          else if (dir == 4 && self.turn == 0)
            dir = 4;
          else if (dir == 4 && self.turn == 1)
            dir = 3;
          else if (dir == 4 && self.turn == 2)
            dir = 2;
          else if (dir == 4 && self.turn == 3)
            dir = 1;

          CGPoint coordinate;
           if ( dir == 1){
            ++y;
            coordinate = CGPointMake(x, y);
          }
          else if ( dir == 2){
            ++x;
            coordinate = CGPointMake(x, y);
          }
          else if ( dir == 4){
            --x;
            coordinate = CGPointMake(x, y);
          }
          else if ( dir == 3){
            --y;
            coordinate = CGPointMake(x, y);
          }
          
          StepPoint point = {steps,self.turn};
          NSValue *pointValue = [NSValue valueWithBytes:&point objCType:@encode(StepPoint)];
          [self.pointsArray addObject:pointValue];
          [self processPoint:point withCoordinate:coordinate direction:dir];
           self.label.text = [NSString stringWithFormat:@"STEPS: %d %@",steps,turnString];
        }}
        );
  }
  beenhere = false;
}

-(void)processPoint:(StepPoint)point withCoordinate:(CGPoint)coordinate direction:(NSInteger)dir{
  PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%d", point.number]];
  [aNode.additionalData setValue:[NSValue valueWithCGPoint:coordinate] forKey:@"coordinate"];
  [aNode.additionalData setValue:[NSNumber numberWithInt:self.turn] forKeyPath:@"direction"];
  if (startingPoint) {
    self.prevNode = aNode;
    [self.nodesArray addObject:aNode];
    startingPoint = NO;
    return;
  }
  int duplicateIndex = [self checkIfDuplicate:coordinate];

  if (duplicateIndex==-1) {
    [self.graph addBiDirectionalEdge:[PESGraphEdge edgeWithName: [NSString stringWithFormat:@"%@ <-> %@",aNode.identifier,self.prevNode.identifier] andWeight:[NSNumber numberWithInt:1]] fromNode:aNode toNode:self.prevNode];
    [self.nodesArray addObject:aNode];
    self.prevNode = aNode;
  }
  else{
    steps--;
    PESGraphNode *aNode = [self.nodesArray objectAtIndex:duplicateIndex];
    [self.graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%@ <-> %@",aNode.identifier,self.prevNode.identifier] andWeight:[NSNumber numberWithInt:1]] fromNode:aNode toNode:self.prevNode];
    aNode = nil;
    return;
  }
}

-(int)checkIfDuplicate:(CGPoint)coordinate{
  __block int index=-1;
  NSLog(@"coordinate : %@", [NSValue valueWithCGPoint:coordinate]);
  [self.nodesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSValue *coordinateValue  =[((PESGraphNode*)obj).additionalData valueForKey:@"coordinate"];
    CGPoint oldPoint = [coordinateValue CGPointValue];
    if (oldPoint.x == coordinate.x && oldPoint.y==coordinate.y) {
      NSLog(@"old point is duplicate %@", coordinateValue);
      index = idx;
    }
  }];
  return index;
}
@end
