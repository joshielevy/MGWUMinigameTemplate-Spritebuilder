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
    
    CCParticleSystem *death;
    NSMutableArray *_leftObstacles;
    NSMutableArray *_rightObstacles;
    NSMutableArray *_items;
    float timeSinceObstacle;
    float timeSinceItem;
    float timeSinceFlash;
    float itemInterval;
    float startingObstacleScale;
    float startingItemScale;
    float startingObstacleVerticalPosition;
    float startingItemVerticalPosition;
    float waveTime;
    float flashInterval;
    
    int score;
    
    JoshLevyObstacle1 *_testObstacle;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timerLabel;
    CCLabelTTF *_gameOverLabel;
    
    float timeSinceStart;
    float maxObstacleHoriz;
    float perspectiveAngle;
    
    bool flashToggle;
    bool gameOver;
    bool isDying;
    bool goodDeath;
}

-(void)initialize {
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"Beware the Tunnel of Terror! Catch goodies for points, but don't hit flaming enemies! And DON'T HIT THE SIDES! Can you last a full 60 seconds in the Tunnel of Terror?";
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    [self.hero setScale:0.4f];
    // first turn him around, which will set up flying, too
    [self.hero rotateToFlyingPosition];
    lastTouchLocation = self.hero.position;
    self.hero.physicsBody.allowsRotation = NO;
    self.hero.physicsBody.affectedByGravity = NO;
    _leftObstacles = [NSMutableArray array];
    _rightObstacles = [NSMutableArray array];
    _items = [NSMutableArray array];

    _physicsNode.collisionDelegate = self;
    startingObstacleScale = 0.1f;
    startingItemScale = 0.3f;
    waveTime = 2.0f;
    maxObstacleHoriz = 60;
    perspectiveAngle = 20.0f;

    timeSinceObstacle = 0.0f;
    timeSinceItem = 0.0f;
    timeSinceStart = 0.0f;
    itemInterval = 1.0f;
    flashInterval = 0.125f;
    timeSinceFlash = 0.0f;
    
    score = 0;
    
    flashToggle = true;
    gameOver = false;
    isDying = false;
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
    startingObstacleVerticalPosition = self.contentSizeInPoints.height/5*4;
    startingItemVerticalPosition = self.contentSizeInPoints.height/5*4;
}

-(void)update:(CCTime)delta {
    
    if (gameOver) {
        if (isDying) {
            if (!death.isRunningInActiveScene) {
                isDying=false;
            }
            return;
        } else {
            _gameOverLabel.visible = true;
            return;
        }
    }
    
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    //float distanceToHero = lastTouchLocation.x-self.hero.positionInPoints.x;
    //self.hero.physicsNode.gravity = ccp(distanceToHero,0.0f);
    self.hero.physicsBody.velocity = ccp(self.hero.physicsBody.velocity.x, 0.0f);
    
    timeSinceItem += delta; // delta is approximately 1/60th of a second
    timeSinceObstacle += delta; // delta is approximately 1/60th of a second
    timeSinceStart += delta;
    timeSinceFlash += delta;
    
    _timerLabel.string = [NSString stringWithFormat:@"%.0f", 60-truncf(timeSinceStart)];
    _scoreLabel.string = [NSString stringWithFormat:@"%d", score];
    
    // check for end of game
    if (60-truncf(timeSinceStart)==0) {
        // game over - good death
        goodDeath = true;
        gameOver = true;
        [self endMinigame];
    }
    
    // add items at certain intervals
    if (timeSinceItem > itemInterval && [self.hero readyToPlay])
    {
        // Add a new obstacle
        [self addItem];
        timeSinceItem = 0.0f;
    }

    NSMutableArray *offScreenItems = nil;
    
    for (CCSprite *item in _items) {
        CGPoint itemWorldPosition = [_physicsNode convertToWorldSpace:item.position];
        CGPoint itemScreenPosition = [self convertToNodeSpace:itemWorldPosition];
        if (itemScreenPosition.y < -item.contentSize.height) {
            if (!offScreenItems) {
                offScreenItems = [NSMutableArray array];
            }
            [offScreenItems addObject:item];
        } else {
            // increase size and speed
            CGFloat scaleFactor =  (startingItemVerticalPosition - itemScreenPosition.y) / startingItemVerticalPosition;
            item.scale = startingItemScale + (1.0f - startingItemScale) * scaleFactor;
            item.physicsBody.velocity = ccp(clampf(item.physicsBody.velocity.x+item.physicsBody.velocity.x*scaleFactor/5, -500.0f, 500.0f),  clampf(item.physicsBody.velocity.y+item.physicsBody.velocity.y*scaleFactor/5,-500.0f,500.0f));
            
            
            //NSLog(@"%f, %f, %f",self.contentSizeInPoints.height,itemScreenPosition.y,item.scale);
        }
    }

    for (CCNode *itemToRemove in offScreenItems) {
        [itemToRemove removeFromParent];
        [_items removeObject:itemToRemove];
        //NSLog(@"removing item");
    }
    
    // Check to see if need to add side obstacle
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

    [offScreenObstacles removeAllObjects];
    
    for (JoshLevySideObstacle *obstacle in _rightObstacles) {
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
            obstacle.physicsBody.velocity = ccp(obstacle.physicsBody.velocity.x+obstacle.physicsBody.velocity.x*scaleFactor/4,  obstacle.physicsBody.velocity.y+obstacle.physicsBody.velocity.y*scaleFactor/4);
            
            
            //NSLog(@"%f, %f, %f",self.contentSizeInPoints.height,obstacleScreenPosition.y,obstacle.scale);
        }
    }

    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_rightObstacles removeObject:obstacleToRemove];
        //NSLog(@"removing obstacle");
    }
    
    // flash items if need be
    /*
    if (timeSinceFlash > flashInterval) {
        for (CCSprite *item in _items) {
            if ([item.physicsBody.collisionType isEqualToString:@"obstacle"]) {
                if (flashToggle) {
                    [item updateDisplayedColor:ccc4f(255, 0, 0, 1)];
                } else {
                    [item updateDisplayedColor:ccc4f(255, 255, 255, 1)];
                }
            }
        }
        flashToggle = !flashToggle;
        timeSinceFlash = 0.0f;
    }
    */
     
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
    if (gameOver && !isDying) {
        // end game
        [self endMinigameWithScore:score];
    }
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
    
    /*
    NSLog(@"touchLocation: %f, %f",touchLocation.x,touchLocation.y);
    NSLog(@"touchWorldPosition: %f, %f",touchWorldPosition.x,touchWorldPosition.y);
    NSLog(@"touchScreenPosition: %f, %f",touchScreenPosition.x,touchScreenPosition.y);
    NSLog(@"hero.position: %f, %f",self.hero.position.x,self.hero.position.y);
    NSLog(@"heroWorldPosition: %f, %f",heroWorldPosition.x,heroWorldPosition.y);
    NSLog(@"heroScreenPosition: %f, %f",heroScreenPosition.x,heroScreenPosition.y);
    */
    
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

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair obstacle:(CCNode*)obstacle character:(CCNode*)character {
    // bad death
    goodDeath = false;
    
    // end game
    [self endMinigame];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair item:(CCSprite*)item character:(CCNode*)character {
    // do a particle thing
    
    [self acquireItem:item];
    score++;
    
    return FALSE;
}

- (void)acquireItem:(CCSprite*)item {
    CCParticleSystem *acquire = (CCParticleSystem *)[CCBReader load:@"JoshLevyAcquireParticle"];
    // make the particle effect clean itself up, once it is completed
    acquire.autoRemoveOnFinish = TRUE;
    // place the particle effect on the item's position
    acquire.position = item.position;
    // add the particle effect to the same node the item is on
    [item.parent addChild:acquire];
    // finally, remove the acquired item
    [item removeFromParent];

}

- (void)addItem {
    //
    CCSprite *currentItem;
    int itemType = arc4random() % 2;
    if (itemType==0) {
        // good item
        NSString *itemName;
        // get string name of random texture
        int itemNum = (arc4random() % 9);
        NSLog(@"itemNum: %d",itemNum);
        switch (itemNum) {
            case 0:
                itemName = @"items/item_duck_2.png";
                break;
            case 1:
                itemName = @"items/item_gem_1.png";
                break;
            case 2:
                itemName = @"items/item_gem_2.png";
                break;
            case 3:
                itemName = @"items/item_gem_3.png";
                break;
            case 4:
                itemName = @"items/item_gem_4.png";
                break;
            case 5:
                itemName = @"items/item_gem_5.png";
                break;
            case 6:
                itemName = @"items/item_gem_6.png";
                break;
            case 7:
                itemName = @"items/item_key_1.png";
                break;
            case 8:
                itemName = @"items/item_star_1.png";
                break;
                
            default:
                break;
        }
        // create new sprite based on above texture
        currentItem = [CCSprite spriteWithImageNamed:itemName];
        currentItem.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:currentItem.contentSize.width/2.0f andCenter:ccp(0,0)];
        
        // create collision type
        currentItem.physicsBody.collisionType=@"item";
        
    } else {
        // bad item
        NSString *itemName;
        // get string name of random texture
        int itemNum = arc4random() % 4;
        switch (itemNum) {
            case 0:
                itemName = @"items/item_saw_1.png";
                break;
            case 1:
                itemName = @"items/item_bomb_1.png";
                break;
            case 2:
                itemName = @"enemies/kingGobi_front_1.png";
                break;
            case 3:
                itemName = @"enemies/popper_front_1.png";
                break;
                
            default:
                break;
        }
        // create new sprite based on above texture
        currentItem = [CCSprite spriteWithImageNamed:itemName];
        currentItem.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:currentItem.contentSize.width/2.0f andCenter:ccp(0,0)];
        
        // add particle effect
        CCParticleSystem *badParticle = (CCParticleSystem *)[CCBReader load:@"JoshLevyBadGuyParticle"];
        // make the particle effect clean itself up, once it is completed
        badParticle.autoRemoveOnFinish = TRUE;
        // place the particle effect on the item's position
        badParticle.position = ccp(currentItem.contentSizeInPoints.width/2.0f,currentItem.contentSizeInPoints.height/2.0f);
        // add the particle effect to the same node the item is on
        [currentItem addChild:badParticle];

        
        // create collision type
        currentItem.physicsBody.collisionType=@"obstacle";
    }

    [_physicsNode addChild:currentItem];

    currentItem.anchorPoint = ccp(0.5f,0.5f);
    currentItem.physicsBody.type=CCPhysicsBodyTypeDynamic;
    currentItem.physicsBody.allowsRotation=FALSE;
    currentItem.scale=startingItemScale;
    currentItem.position=ccp(self.contentSizeInPoints.width/1.7, startingItemVerticalPosition);
    // choose a random trajectory
    int itemHorizTrajectory = (arc4random() % 60) - 30;
    currentItem.physicsBody.velocity=ccp(itemHorizTrajectory,-10.0f);
    currentItem.zOrder=-1;
    [_items addObject:currentItem];
}

- (void)addObstacle {
    // randomly pick an obstacle
    int obstacleType = arc4random() % 5;
    JoshLevySideObstacle *obstacle1;
    JoshLevySideObstacle *obstacle2;
    switch (obstacleType) {
        case 0:
            obstacle1 = (JoshLevyObstacle1 *)[CCBReader load:@"JoshLevyObstacle1"];
            obstacle2 = (JoshLevyObstacle1 *)[CCBReader load:@"JoshLevyObstacle1"];
            break;
        case 1:
            obstacle1 = (JoshLevyObstacle2 *)[CCBReader load:@"JoshLevyObstacle2"];
            obstacle2 = (JoshLevyObstacle2 *)[CCBReader load:@"JoshLevyObstacle2"];
            break;
        case 2:
            obstacle1 = (JoshLevyObstacle3 *)[CCBReader load:@"JoshLevyObstacle3"];
            obstacle2 = (JoshLevyObstacle3 *)[CCBReader load:@"JoshLevyObstacle3"];
            break;
        case 3:
            obstacle1 = (JoshLevyObstacle4 *)[CCBReader load:@"JoshLevyObstacle4"];
            obstacle2 = (JoshLevyObstacle4 *)[CCBReader load:@"JoshLevyObstacle4"];
            break;
        case 4:
            obstacle1 = (JoshLevyObstacle5 *)[CCBReader load:@"JoshLevyObstacle5"];
            obstacle2 = (JoshLevyObstacle5 *)[CCBReader load:@"JoshLevyObstacle5"];
            break;
        default:
            break;
    }
    
    obstacle1.position = ccp(self.contentSizeInPoints.width/3,startingObstacleVerticalPosition);
    obstacle2.position = ccp(self.contentSizeInPoints.width/3*2.5,startingObstacleVerticalPosition);

    [_physicsNode addChild:obstacle1];
    [_physicsNode addChild:obstacle2];
    
    obstacle1.scale=startingObstacleScale;
    obstacle2.scale=startingObstacleScale;
    
    // calculate angle based on wavetime, going from -40 to +40
    float timeSinceLastWave = fmodf(timeSinceStart, waveTime);
    float waveScale = timeSinceLastWave/waveTime;
    float obsXVelocity;
    if (waveScale < 0.5f) {
        obsXVelocity = maxObstacleHoriz * 2.0f * waveScale * 2.0f - maxObstacleHoriz;
    } else {
        obsXVelocity = maxObstacleHoriz * 2.0f * (1.0f-waveScale) * 2.0f - maxObstacleHoriz;
    }
    //obstacle1.physicsBody.velocity=ccp(obsXVelocity-perspectiveAngle,-50.0f);
    //obstacle2.physicsBody.velocity=ccp(obsXVelocity+perspectiveAngle,-50.0f);
    obstacle1.physicsBody.velocity=ccp(-perspectiveAngle,-50.0f);
    obstacle2.physicsBody.velocity=ccp(+perspectiveAngle,-50.0f);
    
    [_leftObstacles addObject:obstacle1];
    [_rightObstacles addObject:obstacle2];
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    gameOver=TRUE;
    
    // get rid of all obstacles, items
    for (CCNode *itemToRemove in _leftObstacles) {
        [itemToRemove removeFromParentAndCleanup:true];
    }
    for (CCNode *itemToRemove in _rightObstacles) {
        [itemToRemove removeFromParentAndCleanup:true];
    }
    for (CCNode *itemToRemove in _items) {
        [itemToRemove removeFromParentAndCleanup:true];
    }
    
    [_leftObstacles removeAllObjects];
    [_rightObstacles removeAllObjects];
    [_items removeAllObjects];
    

    if (goodDeath) {
        // make the hero invisible
        self.hero.visible=false;
        
        // run the explosion effect
        death = (CCParticleSystem *)[CCBReader load:@"JoshLevyGoodDeathParticle"];
        // make the particle effect clean itself up, once it is completed
        death.autoRemoveOnFinish = TRUE;
        
        // place the particle effect in the center
        death.position = ccp(self.contentSizeInPoints.width,self.contentSizeInPoints.height);
        [self addChild:death];
        isDying=TRUE;
    } else {
        // make the hero invisible
        self.hero.visible=false;
        
        // run the explosion effect
        death = (CCParticleSystem *)[CCBReader load:@"JoshLevyHeroDiesParticle"];
        // make the particle effect clean itself up, once it is completed
        death.autoRemoveOnFinish = TRUE;
        
        // place the particle effect on the item's position
        death.position = self.hero.positionInPoints;
        [self addChild:death];
        isDying=TRUE;
    }
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!

@end
