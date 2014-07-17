//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

// idea: flying through space, avoiding streams of stuff, popping enemies (or avoiding?), getting special items, movement is horiz back and forth, impulses proportional to dist b/t character and touch
// use animation of jumping since from the back it looks like falling, and when turning turn to the side animation of jumping


#import "MyMinigame.h"

@implementation MyMinigame {
    CGPoint lastTouchLocation;
    CCNode *_moveNode;
    CCPhysicsJoint *_moveJoint;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"These are the game instructions :D";
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    //[self.hero setScale:0.5f];
    // first turn him around, which will set up flying, too
    [self.hero rotateToFlyingPosition];
    lastTouchLocation = self.hero.position;
    self.hero.physicsBody.allowsRotation = NO;
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    //float distanceToHero = lastTouchLocation.x-self.hero.positionInPoints.x;
    //self.hero.physicsNode.gravity = ccp(distanceToHero,0.0f);
    self.hero.physicsBody.velocity = ccp(self.hero.physicsBody.velocity.x, 0.0f);
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint heroPosition = self.hero.positionInPoints;
    
    _moveNode.position = ccp(touchLocation.x,heroPosition.y);
    
    _moveJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_moveNode.physicsBody bodyB:self.hero.physicsBody anchorA:ccp(0.0,0.0) anchorB:ccp(0,0) restLength:0.0f stiffness:3.0f damping:1.0f];
    
    
    //if (abs(distanceToHero) > 10) {
        // apply impulse proportional to distance
        //[self.hero.physicsBody applyImpulse:ccp(distanceToHero*10.0f, 0)];
        //self.hero.physicsNode.gravity = ccp(distanceToHero,0.0f);
    //}
    lastTouchLocation = touchLocation;
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    [self endMinigameWithScore:arc4random()%100 + 1];
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!

@end
