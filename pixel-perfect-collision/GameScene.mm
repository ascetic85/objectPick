
#import "GameScene.h"
#include <map>

@interface GameScene() {
std::map<int, NSString*> m_colorSpriteMap;
}
@end

@implementation GameScene

@synthesize _ship;
@synthesize _enemy1;
@synthesize _enemy2;
@synthesize _rt;


/*--------------------------------------------------*/

+(id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer* layer = [GameScene node];
    [scene addChild:layer];
    return scene;
}

/*--------------------------------------------------*/

-(void) createColorTestSprite:(CCNode*) parent
{
    m_dict = [NSMutableDictionary dictionary];
    
    int z = -1;
    // create some test color sprite
    _red = [CCSprite spriteWithFile:@"red.png"];
    [[_red texture] setAliasTexParameters];
    _red.position = ccp(10, 10);
    _red.visible = NO; // 看不见 检测不到
    [parent addChild:_red z:z];
    
    m_colorSpriteMap[255] = @"red";
    

    _green = [CCSprite spriteWithFile:@"green.png"];
    [[_green texture] setAliasTexParameters];
    _green.position = ccp(100, 100);
    [parent addChild:_green z:z];
    
    m_colorSpriteMap[59] = @"green";

}

-(id) init
{
    if ((self = [super init]))
    {
        self.isTouchEnabled = YES;
        _pressed = NO;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCNode* cameraSprite = [CCNode node];
        [self addChild:cameraSprite];
        
        // Background from Mosquito's Insomnia title screen :D
        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
        [[bg texture] setAliasTexParameters];
        bg.anchorPoint = ccp(0,0);
        bg.position = ccp(0,0);
//        bg.opacity = 100;
        [cameraSprite addChild:bg];
        
        // Add text
        CCLabelTTF *l = [CCLabelTTF labelWithString:@"PIXEL PERFECT COLLISION DETECTION" fontName:@"Arial" fontSize:14];
        l.anchorPoint = ccp(0.5f,1);
        l.position = ccp(winSize.width*0.5f,winSize.height*0.95f);
        [bg addChild:l];
        
        CCLabelTTF *l2 = [CCLabelTTF labelWithString:@"Touch to move the player ship" fontName:@"Arial" fontSize:14];
        l2.anchorPoint = ccp(0.5f,1);
        l2.position = ccp(winSize.width*0.5f,winSize.height*0.9f);
        [bg addChild:l2];
        
        // create render texture and make it visible for testing purposes
        _rt = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
        _rt.position = ccp(winSize.width*0.5f,winSize.height*0.1f);
        [bg addChild:_rt];
        _rt.visible = YES;
        
        // create player ship
        _ship = [CCSprite spriteWithFile:@"ship1.png"];
        [[_ship texture] setAliasTexParameters];
        _ship.rotation = 90;
        _ship.position = ccp(winSize.width*0.5f, winSize.height*0.4);
        [bg addChild:_ship z:1];
        
        // create some enemies
        _enemy1 = [CCSprite spriteWithFile:@"ship2.png"];
        [[_enemy1 texture] setAliasTexParameters];
        _enemy1.rotation = 0;
        _enemy1.position = ccp(winSize.width*0.4f, winSize.height*0.65);
        [bg addChild:_enemy1 z:-1];
        
        _enemy2 = [CCSprite spriteWithFile:@"ship2.png"];
        [[_enemy2 texture] setAliasTexParameters];
        _enemy2.rotation = 270;
        _enemy2.position = ccp(winSize.width*0.6f, winSize.height*0.65);
        [bg addChild:_enemy2 z:0];
        
        
        [self createColorTestSprite:cameraSprite];
        
        CCCamera* camera = [cameraSprite camera];
        float x, y, z;
        [camera eyeX:&x eyeY:&y eyeZ:&z];
        [camera setEyeX:x eyeY:y-0.0000001 eyeZ:z];
        
        m_rgbInfo = [CCLabelTTF labelWithString:@"........" fontName:@"Arial" fontSize:20];
        m_rgbInfo.position = ccp(winSize.width/2, winSize.height*0.8);
        
        [self addChild:m_rgbInfo];
        
        // schedule update method
        [self scheduleUpdate];
    }
    return self;
}

/*--------------------------------------------------*/

-(void) dealloc
{
    [super dealloc];
}

/*--------------------------------------------------*/

-(void) update:(ccTime)delta
{
    [self checkCollisions];
}

/*--------------------------------------------------*/

-(void) checkCollisions
{
    // let's make it in a hard way :D
    
    if ([self isCollisionBetweenSpriteA:_ship spriteB:_enemy1 pixelPerfect:YES])
    {
        _enemy1.color = ccc3(255,0,0);
    }
    else
    {
        _enemy1.color = ccc3(255,255,255);
    }
    
    if ([self isCollisionBetweenSpriteA:_ship spriteB:_enemy2 pixelPerfect:YES])
    {
        _enemy2.color = ccc3(255,0,0);
    }
    else
    {
        _enemy2.color = ccc3(255,255,255);
    }
    
//    if ([self isCollisionBetweenSpriteA:_ship spriteB:_green pixelPerfect:YES])
//        _green.color = ccc3(255, 0, 0);
//    else
//        _green.color = ccc3(255, 255, 255);
}

/*--------------------------------------------------*/

-(BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp
{
    BOOL isCollision = NO; 
    CGRect intersection = CGRectIntersection([spr1 boundingBox], [spr2 boundingBox]);
    
    // Look for simple bounding box collision
    if (!CGRectIsEmpty(intersection))
    {
        // If we're not checking for pixel perfect collisions, return true
        if (!pp) {return YES;}
        
        // Get intersection info
        unsigned int x = intersection.origin.x;
        unsigned int y = intersection.origin.y;
        unsigned int w = intersection.size.width;
        unsigned int h = intersection.size.height;
        unsigned int numPixels = w * h;
        
        //NSLog(@"\nintersection = (%u,%u,%u,%u), area = %u",x,y,w,h,numPixels);
        
        // Draw into the RenderTexture
        [_rt beginWithClear:0 g:0 b:0 a:0];


        // Render both sprites: first one in RED and second one in GREEN
        glColorMask(1, 0, 0, 1);
        [spr1 visit];
        glColorMask(0, 1, 0, 1);
        [spr2 visit];
        glColorMask(1, 1, 1, 1);
        
        // Get color values of intersection area
        ccColor4B *buffer = (ccColor4B*) malloc( sizeof(ccColor4B) * numPixels );
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        /******* All this is for testing purposes *********/
         
        // Draw the first sprite bounding box
        CGRect r1 = [spr1 boundingBox];
        glColor4f(1, 0, 0, 1);
        glLineWidth(0.5f);
        ccDrawLine(ccp(r1.origin.x,r1.origin.y), ccp(r1.origin.x+r1.size.width,r1.origin.y));
        ccDrawLine(ccp(r1.origin.x,r1.origin.y), ccp(r1.origin.x,r1.origin.y+r1.size.height));
        ccDrawLine(ccp(r1.origin.x+r1.size.width,r1.origin.y), ccp(r1.origin.x+r1.size.width,r1.origin.y+r1.size.height));
        ccDrawLine(ccp(r1.origin.x,r1.origin.y+r1.size.height), ccp(r1.origin.x+r1.size.width,r1.origin.y+r1.size.height));
        
        // Draw the second sprite bounding box
        CGRect r2 = [spr2 boundingBox];
        glColor4f(0, 1, 0, 1);
        glLineWidth(0.5f);
        ccDrawLine(ccp(r2.origin.x,r2.origin.y), ccp(r2.origin.x+r2.size.width,r2.origin.y));
        ccDrawLine(ccp(r2.origin.x,r2.origin.y), ccp(r2.origin.x,r2.origin.y+r2.size.height));
        ccDrawLine(ccp(r2.origin.x+r2.size.width,r2.origin.y), ccp(r2.origin.x+r2.size.width,r2.origin.y+r2.size.height));
        ccDrawLine(ccp(r2.origin.x,r2.origin.y+r2.size.height), ccp(r2.origin.x+r2.size.width,r2.origin.y+r2.size.height));
        
        // Draw the intersection rectangle in BLUE (testing purposes)
        glColor4f(0, 0, 1, 1);
        glLineWidth(0.5f);
        ccDrawLine(ccp(x,y), ccp(x+w,y));
        ccDrawLine(ccp(x,y), ccp(x,y+h));
        ccDrawLine(ccp(x+w,y), ccp(x+w,y+h));
        ccDrawLine(ccp(x,y+h), ccp(x+w,y+h));
        
        /**************************************************/
        
        [_rt end];
        
        // Read buffer
        unsigned int step = 1;
        for(unsigned int i=0; i<numPixels; i+=step)
        {
            ccColor4B color = buffer[i];
                        
            if (color.r > 0 && color.g > 0)
            {
//                CCLOG(@"%d,%d,%d,%d", color.r, color.g, color.b, color.a);
                isCollision = YES;
                break;
            }
        }
       
        // Free buffer memory
        free(buffer);
    }
    
    return isCollision;
}

-(BOOL) isCollisionBetweenSpriteA2:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp position:(CGPoint) pos
{
    BOOL isCollision = NO;

    // Get intersection info
    unsigned int x = pos.x;
    unsigned int y = pos.y;
    unsigned int w = 1;
    unsigned int h = 1;
    unsigned int numPixels = w * h;
        

    // Draw into the RenderTexture
    [_rt beginWithClear:0 g:0 b:0 a:0];

    // Render both sprites: first one in RED and second one in GREEN
    [_red visit];
    [_green visit];
    glColorMask(1, 1, 1, 1);
    
//    [_rt end];
    
    
    // Get color values of intersection area
    ccColor4B *buffer = (ccColor4B*) malloc( sizeof(ccColor4B) * numPixels );
    glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
    [_rt end];
    
    
        
    // Read buffer
    unsigned int step = 1;
    for(unsigned int i=0; i<numPixels; i+=step)
    {
        ccColor4B color = buffer[i];
        CCLOG(@"#########%d %d %d", color.r, color.g, color.b);
        int r = color.r;
        [m_rgbInfo setString:[NSString stringWithFormat:@"%d %d %d %d :%@"
                              , color.r, color.g, color.b, color.a, m_colorSpriteMap[r]]];
        
//        if (color.r == 255) {
//            gDict[255].color = ccc3(0, 255, 0);
//        } else {
//            gDict[255].color = ccc3(255, 255, 255);
//        }
//        
//        if (color.g == 255)
//            gDict[254].color = ccc3(255,0,0);
//        else
//            gDict[254].color = ccc3(255,255,255);
        
        if (color.r > 0 && color.g > 0)
        {
            isCollision = YES;
            break;
        }
        
    
    }

        
    
    // Free buffer memory
    free(buffer);
  
    return isCollision;
}


/*******************************************************************************************/

#pragma mark -
#pragma mark TOUCH ENGINE

-(CGPoint) getTouchLocation:(UITouch*)touch
{
	return [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
}

-(CGPoint) getTouchesLocation:(NSSet*)touches
{
	return [self getTouchLocation:[touches anyObject]];
}

/*_________________________________________________________________________________________*/

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_ship.position = [self getTouchesLocation:touches];
    
    //
    //
    //
    [self isCollisionBetweenSpriteA2:_ship
                             spriteB:_red
                        pixelPerfect:YES
                            position:[self getTouchesLocation:touches]];
    
    
}

/*_________________________________________________________________________________________*/

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	_ship.position = [self getTouchesLocation:touches];
    
    [self isCollisionBetweenSpriteA2:_ship
                             spriteB:_red
                        pixelPerfect:YES
                            position:[self getTouchesLocation:touches]];
}

/*_________________________________________________________________________________________*/

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	
}

/*--------------------------------------------------*/

@end
