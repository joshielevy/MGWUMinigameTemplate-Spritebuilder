//
//  JoshLevyObstacle1.m
//  MGWUMinigameTemplate
//
//  Created by Josh Levy on 7/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "JoshLevyObstacle1.h"

@implementation JoshLevyObstacle1

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        
        // We initialize _isIdling to be YES, because we want the character to start idling
        // (Our animation code relies on this)
        // by default, a BOOL's value is NO, so the other BOOLs are NO right now
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    [self.animationManager runAnimationsForSequenceNamed:@"rotation"];
}

-(void)update:(CCTime)delta {
    if ([[self.animationManager lastCompletedSequenceName] isEqualToString:@"rotation"] && ![[self.animationManager runningSequenceName] isEqualToString:@"rotation"]) {
        [self.animationManager runAnimationsForSequenceNamed:@"rotation"];
    }
}
    
@end
