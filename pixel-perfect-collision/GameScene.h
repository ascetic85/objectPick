
#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCLayer
{
    CCSprite *_ship;
    CCSprite *_enemy1;
    CCSprite *_enemy2;
    CCRenderTexture* _rt;
    
    CCSprite *_red;
    CCSprite *_green;
    
    BOOL    _pressed;
}

@property (nonatomic,assign) CCSprite *_ship;
@property (nonatomic,assign) CCSprite *_enemy1;
@property (nonatomic,assign) CCSprite *_enemy2;
@property (nonatomic,assign) CCRenderTexture *_rt;

+(id) scene;

-(void) checkCollisions;
-(BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)p;

-(BOOL) isCollisionBetweenSpriteA2:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp position:(CGPoint) pos;

@end
