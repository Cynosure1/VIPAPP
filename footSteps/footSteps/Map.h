//
//  Map.h
//  footSteps
//
//  Created by Sumit Chaudhary on 27/07/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GraphNode;

@interface Map : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *nodes;
@end

@interface Map (CoreDataGeneratedAccessors)

- (void)addNodesObject:(GraphNode *)value;
- (void)removeNodesObject:(GraphNode *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

@end
