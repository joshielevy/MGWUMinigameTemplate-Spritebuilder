//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

// idea: flying through space, avoiding streams of stuff, popping enemies (or avoiding?), getting special items, movement is horiz back and forth, impulses proportional to dist b/t character and touch
// use animation of jumping since from the back it looks like falling, and when turning turn to the side animation of jumping


#import "MyMinigame.h"
#import "JoshLevyObstacleSprite1.h"
#import "JoshLevyObstacle1.h"
#import "JoshLevyObstacle2.h"
#import "JoshLevyObstacle3.h"
#import "JoshLevyObstacle4.h"
#import "JoshLevyObstacle5.h"

@implementation MyMinigame {
    CGPoint lastTouchLocation;
    CCNode *_moveNode;
    CCPhysicsJoint *_moveJoint;
    
    NSMutableArray *_leftObstacles;
    NSMutableArray *_rightObstacles;
    float timeSinceObstacle;
    
    JoshLevyObstacleSprite1 *_testObstacle;
}

-(void)initialize {
    timeSinceObstacle = 0.0f;
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
    [self.hero setScale:0.5f];
    // first turn him around, which will set up flying, too
    [self.hero rotateToFlyingPosition];
    lastTouchLocation = self.hero.position;
    self.hero.physicsBody.allowsRotation = NO;
    self.hero.physicsBody.affectedByGravity = NO;
    
    // set up obstacle arrays
    _testObstacle = (JoshLevyObstacleSprite1 *)[CCBReader load:@"JoshLevyObstacleSprite1"];
    _testObstacle.position = ccp(_hero.position.x-50.0f, _hero.position.y-50.0f);
    _testObstacle.visible=YES;
    [self.physicsNode addChild:_testObstacle];

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
    
    timeSinceObstacle += delta; // delta is approximately 1/60th of a second
    
    // Check to see if two seconds have passed
    if (timeSinceObstacle > 2.0f)
    {
        // Add a new obstacle
        //[self addObstacleSprite];
        
        // Then reset the timer.
        timeSinceObstacle = 0.0f;
    }
    
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint heroPosition = self.hero.positionInPoints;
    
    _moveNode.position = ccp(touchLocation.x,heroPosition.y);
    
    _moveJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_moveNode.physicsBody bodyB:self.hero.physicsBody anchorA:ccp(0.0f,0.0f) anchorB:ccp(0.0f,0.0f) restLength:0.0f stiffness:10.0f damping:1.0f];
    
    
    //if (abs(distanceToHero) > 10) {
        // apply impulse proportional to distance
        //[self.hero.physicsBody applyImpulse:ccp(distanceToHero*10.0f, 0)];
        //self.hero.physicsNode.gravity = ccp(distanceToHero,0.0f);
    //}
    lastTouchLocation = touchLocation;
}

- (void)addObstacleSprite {
    JoshLevyObstacleSprite1 *obstacle;
    obstacle = (JoshLevyObstacleSprite1 *)[CCBReader load:@"JoshLevyObstacleSprite1"];
    obstacle.position = ccp(_hero.position.x-50.0f, _hero.position.y-50.0f);
    [self.physicsNode addChild:obstacle];
    [_leftObstacles addObject:obstacle];

}

- (void)addObstacle {
    // randomly pick an obstacle
    int obstacleType = arc4random() % 4;
    JoshLevySideObstacle *obstacle;
    switch (obstacleType) {
        case 0:
            obstacle = (JoshLevyObstacle1 *)[CCBReader load:@"JoshLevyObstacle1"];
            break;
        case 1:
            obstacle = (JoshLevyObstacle2 *)[CCBReader load:@"JoshLevyObstacle2"];
            break;
        case 2:
            obstacle = (JoshLevyObstacle3 *)[CCBReader load:@"JoshLevyObstacle3"];
            break;
        case 3:
            obstacle = (JoshLevyObstacle4 *)[CCBReader load:@"JoshLevyObstacle4"];
            break;
        case 4:
            obstacle = (JoshLevyObstacle5 *)[CCBReader load:@"JoshLevyObstacle5"];
            break;
        default:
            break;
    }
    //CGPoint screenPosition = [self convertToWorldSpace:ccp(10, 400)];
    //CGPoint worldPosition = [self.physicsNode convertToNodeSpace:screenPosition];
    //obstacle.position = worldPosition;
    obstacle.position = ccp(100.0f, 100.0f);
    //obstacle.physicsBody.velocity = ccp(0.0f, -10.0f);
    //[obstacle setupRandomPosition];
    //obstacle.zOrder = DrawingOrderPipes;
    //[self.physicsNode addChild:obstacle];
    [_leftObstacles addObject:obstacle];
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
