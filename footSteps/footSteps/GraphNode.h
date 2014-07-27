//
//  GraphNode.h
//  footSteps
//
//  Created by Sumit Chaudhary on 27/07/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GraphNode, Map;

@interface GraphNode : NSManagedObject

@property (nonatomic, retain) NSString * nodeID;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSNumber * xCoordinate;
@property (nonatomic, retain) NSNumber * yCoordinate;
@property (nonatomic, retain) NSString * checkpoint;
@property (nonatomic, retain) Map *parentMap;
@property (nonatomic, retain) NSSet *edges;
@end

@interface GraphNode (CoreDataGeneratedAccessors)

- (void)addEdgesObject:(GraphNode *)value;
- (void)removeEdgesObject:(GraphNode *)value;
- (void)addEdges:(NSSet *)values;
- (void)removeEdges:(NSSet *)values;

@end
