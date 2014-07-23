//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MyCharacter.h"

@implementation MyCharacter {
    float _velYPrev, _velXPrev; // this tracks the previous velocity, it's used for animation
    BOOL _isIdling; // these BOOLs track what animations have been triggered.  By default, they're set to NO
    BOOL _isJumping;
    BOOL _isFalling;
    BOOL _isLanding;
    BOOL _isFlying;
    BOOL _startFlying;
    BOOL _isRotatingToFlyingPosition;
    
    // set up 2 CCNode arrays of obstacles (left and right)
    // we want the path of these to start tight and angle out left and right to create a sort of space road
    // wher the sides are the same, just different side and angle.
    // We also need random center ones to quickly dart through - like the dart, spinning buzz saw, etc.
    // also need a particle effect for the begginning where he appears

}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        
        // We initialize _isIdling to be YES, because we want the character to start idling
        // (Our animation code relies on this)
        _isIdling = YES;
        // by default, a BOOL's value is NO, so the other BOOLs are NO right now
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    self.physicsBody.collisionType = @"character";
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    // This sample method is called every update to handle character animation
    [self updateAnimations:delta];
}

-(void)updateAnimations:(CCTime)delta {
    // START FLYING
    if (_startFlying) {
        [self.animationManager setPlaybackSpeed:0.5f];
        [self resetBools];
        _isFlying = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimBackJump"];
    }
    // FLYING
    else if (_isFlying && [[self.animationManager lastCompletedSequenceName] isEqualToString:@"AnimBackJump"]) {
        [self.animationManager setPlaybackSpeed:1.0f];
        [self.animationManager runAnimationsForSequenceNamed:@"AnimBackJumping"];
        _isFlying = NO;
    } else if (_isRotatingToFlyingPosition) {
        [self resetBools];
        _isRotatingToFlyingPosition = NO;
        [self.animationManager setPlaybackSpeed:8.0f];
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoIdling"];
    } else if ([[self.animationManager lastCompletedSequenceName] isEqualToString:@"AnimIsoIdling"] && ![[self.animationManager runningSequenceName] isEqualToString:@"AnimSideIdling"]) {
        [self.animationManager runAnimationsForSequenceNamed:@"AnimSideIdling"];
    } else if ([[self.animationManager lastCompletedSequenceName] isEqualToString:@"AnimSideIdling"] && !_isFlying) {
        [self fly];
    }
    /*
    // IDLE
    // The animation should be idle if the character was and is stationary
    // The character may only start idling if he or she was not already idling or falling
    else if (_velYPrev == 0 && self.physicsBody.velocity.y == 0 && !_isIdling && !_isFalling) {
        [self resetBools];
        _isIdling = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoIdling"];
    }
    // JUMP
    // The animation should be jumping if the character wasn't moving up, but now is
    // The character may only start jumping if he or she was idling and isn't jumping
    else if (_velYPrev == 0 && self.physicsBody.velocity.y > 0 && _isIdling && !_isJumping) {
        [self resetBools];
        _isJumping = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoJump"];
    }
    // FALLING
    // The animation should be falling if the character's moving down, but was moving up or stalled
    // The character may only start falling if he or she was jumping and isn't falling
    else if (_velYPrev >= 0 && self.physicsBody.velocity.y < 0 && _isJumping && !_isFalling) {
        [self resetBools];
        _isFalling = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoFalling" tweenDuration:0.5f];
    }
    // LANDING
    // The animation sholud be landing if the character's stopped moving down (hit something)
    // The character may only start landing if he or she was falling and isn't landing
    else if (_velYPrev < 0 && self.physicsBody.velocity.y >= 0 && _isFalling && !_isLanding) {
        [self resetBools];
        _isLanding = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoLand"];
    }
    */
    // We track the previous velocity, since it's important to determining how the character is and was moving for animations
    _velYPrev = self.physicsBody.velocity.y;
    _velXPrev = self.physicsBody.velocity.x;
    
}

// This method is called before setting one to YES, so that only one is ever YES at a time
-(void)resetBools {
    _isIdling = NO;
    _isJumping = NO;
    _isFalling = NO;
    _isLanding = NO;
    _isFlying = NO;
    _startFlying = NO;
    _isRotatingToFlyingPosition = NO;
}

// This method tells the character to jump by giving it an upward velocity.
// It's been added to a physics node in the main scene, like the penguins Peeved Penguins, so it will fall automatically!
-(void)jump {
    self.physicsBody.velocity = ccp(0,122);
}

// this starts the flying, which is just a jump from the back, followed by jumping
-(void)fly {
    _startFlying = YES;
}

-(void)rotateToFlyingPosition {
    _isRotatingToFlyingPosition = YES;
}

@end
