//
//  AppDelegate.h
//  GHCSlave
//
//  Created by Moritz Angermann on 4/11/17.
//  Copyright © 2017 Moritz Angermann. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int pfd[2];
void setupPipe();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

