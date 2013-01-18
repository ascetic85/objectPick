//
//  AppDelegate.h
//  tutorial-01
//
//  Created by Daniel Vílchez on 08/07/11.
//  Copyright None 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
