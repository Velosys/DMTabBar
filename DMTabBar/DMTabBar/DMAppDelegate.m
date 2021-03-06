//
//  DMAppDelegate.m
//  DMTabBar
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMTabBar.h"

#define kTabBarElements     [NSArray arrayWithObjects: \
                                [NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"tabBarItem1"],@"image",@"Tab #1",@"title",nil], \
                                [NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"tabBarItem2"],@"image",@"Tab #2",@"title",nil], \
                                [NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"tabBarItem3"],@"image",@"Tab #3",@"title",nil],nil]

@interface DMAppDelegate() {
    IBOutlet    DMTabBar*   tabBar;
    IBOutlet    NSTabView*  tabView;
}

@end

@implementation DMAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];

    NSColor* whiteColor = [NSColor whiteColor];
    NSColor* blackColor = [NSColor blackColor];
    NSColor* greenColor = [NSColor greenColor];
    NSColor* grayColor  = [NSColor grayColor];
    
    // Create an array of DMTabBarItem objects
    [kTabBarElements enumerateObjectsUsingBlock:^(NSDictionary* objDict, NSUInteger idx, BOOL *stop) {
        NSImage *iconImage = [objDict objectForKey:@"image"];
        [iconImage setTemplate:YES];
        
        DMTabBarItem *item1 = [DMTabBarItem tabBarItemWithIcon:iconImage tag:idx];
//        DMTabBarItem *item1 = [DMTabBarItem tabBarItemWithIcon:iconImage tag:idx];
//        DMTabBarItem* item1 = [DMTabBarItem tabBarItemWithTitle:objDict[@"title"] tag:idx];
        item1.buttonTextColor                   = whiteColor;
        item1.alternateButtonTextColor          = blackColor;
        item1.buttonBackgroundColor             = grayColor;
        item1.alternateButtonBackgroundColor    = greenColor; 
        

        item1.toolTip = [objDict objectForKey:@"title"];
        item1.keyEquivalent = [NSString stringWithFormat:@"%ld",(unsigned long)idx];
        item1.keyEquivalentModifierMask = NSCommandKeyMask;
        [items addObject:item1];
    }];
    
    // Load them
    tabBar.tabBarItems = items;
    
    // Handle selection events
    [tabBar handleTabBarItemSelection:^(DMTabBarItemSelectionType selectionType, DMTabBarItem *targetTabBarItem, NSUInteger targetTabBarItemIndex) {
        if (selectionType == DMTabBarItemSelectionType_WillSelect) {
            //NSLog(@"Will select %lu/%@",targetTabBarItemIndex,targetTabBarItem);
            [tabView selectTabViewItem:[tabView.tabViewItems objectAtIndex:targetTabBarItemIndex]];
        } else if (selectionType == DMTabBarItemSelectionType_DidSelect) {
            //NSLog(@"Did select %lu/%@",targetTabBarItemIndex,targetTabBarItem);
        }
    }];
}

@end
