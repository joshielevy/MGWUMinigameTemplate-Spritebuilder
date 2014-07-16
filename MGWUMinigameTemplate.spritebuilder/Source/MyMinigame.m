//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

// idea: flying through space, avoiding streams of stuff, popping enemies (or avoiding?), getting special items, movement is horiz back and forth, impulses proportional to dist b/t character and touch
// use animation of jumping since from the back it looks like falling, and when turning turn to the side animation of jumping


#import "MyMinigame.h"

@implementation MyMinigame

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"These are the game instructions :D";
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    [self.hero setScale:0.5f];
    // first turn him around, which will set up flying, too
    [self.hero rotateToFlyingPosition];
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
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
