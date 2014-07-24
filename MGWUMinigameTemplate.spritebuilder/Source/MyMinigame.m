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
    CCPhysicsNode *_physicsNode;
    CGPoint lastTouchLocation;
    CCNode *_moveNode;
    CCPhysicsJoint *_moveJoint;
    
    NSMutableArray *_leftObstacles;
    NSMutableArray *_rightObstacles;
    float timeSinceObstacle;
    float startingObstacleScale;
    float startingObstacleVerticalPosition;
    
    JoshLevyObstacle1 *_testObstacle;
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
    _leftObstacles = [NSMutableArray array];
    _rightObstacles = [NSMutableArray array];

    _physicsNode.collisionDelegate = self;
    startingObstacleScale = 0.1f;
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
    startingObstacleVerticalPosition = self.contentSizeInPoints.height/5*4;
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
    if (timeSinceObstacle > 0.15f)
    {
        // Add a new obstacle
        [self addObstacle];
        
        // Then reset the timer.
        timeSinceObstacle = 0.0f;
    }

    NSMutableArray *offScreenObstacles = nil;
    
    for (JoshLevySideObstacle *obstacle in _leftObstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.y < -obstacle.contentSize.height) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        } else {
            // increase size and speed
            CGFloat scaleFactor =  (startingObstacleVerticalPosition - obstacleScreenPosition.y) / startingObstacleVerticalPosition;
            obstacle.scale = startingObstacleScale + (1.0f - startingObstacleScale) * scaleFactor;
            obstacle.physicsBody.velocity = ccp(obstacle.physicsBody.velocity.x+obstacle.physicsBody.velocity.x*scaleFactor/5,  obstacle.physicsBody.velocity.y+obstacle.physicsBody.velocity.y*scaleFactor/5);
            
            
            //NSLog(@"%f, %f, %f",self.contentSizeInPoints.height,obstacleScreenPosition.y,obstacle.scale);
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_leftObstacles removeObject:obstacleToRemove];
        //NSLog(@"removing obstacle");
    }
    
    CGPoint heroPosition = self.hero.positionInPoints;
    CGPoint heroWorldPosition = [_physicsNode convertToWorldSpace:heroPosition];
    CGPoint heroScreenPosition = [self convertToNodeSpace:heroWorldPosition];
    if (fabsf(lastTouchLocation.x-(heroScreenPosition.x)) < 10.0f) {
        self.hero.physicsBody.velocity=ccp(0.0f,0.0f);
    }

    //NSLog(@"hero.position: %f, %f",self.hero.position.x,self.hero.position.y);
    //NSLog(@"heroWorldPosition: %f, %f",heroWorldPosition.x,heroWorldPosition.y);
    //NSLog(@"heroScreenPosition: %f, %f",heroScreenPosition.x,heroScreenPosition.y);
    //NSLog(@"lastTouchLocation: %f, %f",lastTouchLocation.x,lastTouchLocation.y);

}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint heroPosition = self.hero.positionInPoints;
    CGPoint heroWorldPosition = [_physicsNode convertToWorldSpace:heroPosition];
    CGPoint heroScreenPosition = [self convertToNodeSpace:heroWorldPosition];
    
    CGPoint touchWorldPosition = [_physicsNode convertToWorldSpace:touchLocation];
    CGPoint touchScreenPosition = [self convertToNodeSpace:touchWorldPosition];
    
    //_moveNode.position = touchScreenPosition;
    //_moveJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_moveNode.physicsBody bodyB:self.hero.physicsBody anchorA:ccp(5.0f,0.0f) anchorB:ccp(0.5f,0.0f) restLength:0.0f stiffness:10.0f damping:10.0f];
    
    //if (abs(distanceToHero) > 10) {
        // apply impulse proportional to distance
        //[self.hero.physicsBody applyImpulse:ccp(distanceToHero*10.0f, 0)];
        //self.hero.physicsNode.gravity = ccp(distanceToHero,0.0f);
    //}
    
    if (touchLocation.x-heroScreenPosition.x > 10.0f) {
        self.hero.physicsBody.velocity=ccp(500.0f,0.0f);
    } else if (heroScreenPosition.x - touchLocation.x > 10.0f) {
        self.hero.physicsBody.velocity=ccp(-500.0f,0.0f);
    }
    
    NSLog(@"touchLocation: %f, %f",touchLocation.x,touchLocation.y);
    NSLog(@"touchWorldPosition: %f, %f",touchWorldPosition.x,touchWorldPosition.y);
    NSLog(@"touchScreenPosition: %f, %f",touchScreenPosition.x,touchScreenPosition.y);
    NSLog(@"hero.position: %f, %f",self.hero.position.x,self.hero.position.y);
    NSLog(@"heroWorldPosition: %f, %f",heroWorldPosition.x,heroWorldPosition.y);
    NSLog(@"heroScreenPosition: %f, %f",heroScreenPosition.x,heroScreenPosition.y);
    
    lastTouchLocation = touchLocation;
}

- (void)addObstacleSprite {
    JoshLevyObstacleSprite1 *obstacle;
    obstacle = (JoshLevyObstacleSprite1 *)[CCBReader load:@"JoshLevyObstacleSprite1"];
    obstacle.position = ccp(_hero.position.x-50.0f, _hero.position.y-50.0f);
    [self.physicsNode addChild:obstacle];
    [_leftObstacles addObject:obstacle];

}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair obstacle:(CCNode*)obstacle obstacle:(CCNode*)obstacle {
    return FALSE;
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
    //obstacle.position = ccp(100.0f, 100.0f);
    //obstacle.position = ccp(self.contentSizeInPoints.width/3,self.contentSizeInPoints.height+obstacle.contentSizeInPoints.height*3);
    obstacle.position = ccp(self.contentSizeInPoints.width/3,startingObstacleVerticalPosition);
    //obstacle.zOrder = DrawingOrderPipes;
    [_physicsNode addChild:obstacle];
    obstacle.scale=startingObstacleScale;
    obstacle.physicsBody.velocity=ccp(-40.0f,-100.0f);
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
