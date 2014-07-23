//
//  JoshLevySideObstacle.m
//  MGWUMinigameTemplate
//
//  Created by Josh Levy on 7/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "JoshLevySideObstacle.h"

@implementation JoshLevySideObstacle {
    CCNode *_obstacle;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    self.physicsBody.collisionType = @"obstacle";
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    if ([[self.animationManager lastCompletedSequenceName] isEqualToString:@"rotation"] && ![[self.animationManager runningSequenceName] isEqualToString:@"rotation"]) {
        [self.animationManager runAnimationsForSequenceNamed:@"rotation"];
    }
}

@end
