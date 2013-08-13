//
//  DMTabBarItem.m
//  DMTabBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import "DMTabBarItem.h"
#import <CoreText/CoreText.h>
#import <AppKit/NSStringDrawing.h>


static CGFloat kDMTabBarItemGradientColor_Locations[] =     {0.0f, 0.5f, 1.0f};

#define kDMTabBarItemGradientColor1                         [NSColor colorWithCalibratedWhite:0.7f alpha:0.0f]
#define kDMTabBarItemGradientColor2                         [NSColor colorWithCalibratedWhite:0.7f alpha:1.0f]
#define kDMTabBarItemGradient                               [[NSGradient alloc] initWithColors: [NSArray arrayWithObjects: \
                                                                                                         kDMTabBarItemGradientColor1, \
                                                                                                         kDMTabBarItemGradientColor2, \
                                                                                                         kDMTabBarItemGradientColor1, nil] \
                                                                                   atLocations: kDMTabBarItemGradientColor_Locations \
                                                                                    colorSpace: [NSColorSpace genericGrayColorSpace]]
#define kDMTabBarItemTextPadding                            20.0f

@interface DMTabBarButtonCell : NSButtonCell { }
@end

@interface DMTabBarItem() {
    NSButton*       tabBarItemButton;
}
@property (nonatomic, strong) NSMutableAttributedString* attrTitle;

@end

@implementation DMTabBarItem

@synthesize enabled,icon,toolTip;
@synthesize keyEquivalent,keyEquivalentModifierMask;
@synthesize tag;
@synthesize tabBarItemButton;
@synthesize state;
@synthesize alternateIcon;
@synthesize originalIcon;

#pragma mark - Overridden Properties

- (void)setButtonBackgroundColor:(NSColor *)buttonBackgroundColor
{
    _buttonBackgroundColor = buttonBackgroundColor;

    [[tabBarItemButton cell] setBackgroundColor:_buttonBackgroundColor];
}

- (void)setAlternateButtonBackgroundColor:(NSColor *)alternateButtonBackgroundColor
{
    _alternateButtonBackgroundColor = alternateButtonBackgroundColor;
}

- (void)setButtonTextColor:(NSColor *)buttonTextColor
{
    if (self.itemType == DMTabBarItemTitleOnly)
    {
        _buttonTextColor = buttonTextColor;

        // set attributes on title

        NSMutableAttributedString* attributedTitle = [[[tabBarItemButton cell] attributedTitle] mutableCopy];
        [self setValue:self.buttonTextColor forAttribute:NSForegroundColorAttributeName forAttributedString:attributedTitle];
        [[tabBarItemButton cell] setAttributedTitle:attributedTitle];
    }

}

- (void)setAlternateButtonTextColor:(NSColor *)alternateButtonTextColor
{
    if (self.itemType == DMTabBarItemTitleOnly)
    {
        _alternateButtonTextColor = alternateButtonTextColor;

        NSMutableAttributedString* attributedAlternateTitle = [[[tabBarItemButton cell] attributedAlternateTitle] mutableCopy];
        [self setValue:self.alternateButtonTextColor forAttribute:NSForegroundColorAttributeName forAttributedString:attributedAlternateTitle];
        [[tabBarItemButton cell] setAttributedAlternateTitle:attributedAlternateTitle];
    }
}

+ (DMTabBarItem *) tabBarItemWithIcon:(NSImage *) iconImage tag:(NSUInteger) itemTag {
    return [[DMTabBarItem alloc] initWithIcon:iconImage tag:itemTag];
}

+ (DMTabBarItem *) tabBarItemWithTitle:(NSString *)title tag:(NSUInteger)itemTag
{
    return [[DMTabBarItem alloc] initWithTitle:title tag:itemTag];
}

- (id)initWithIcon:(NSImage *) iconImage tag:(NSUInteger) itemTag {
    self = [super init];
    if (self) {
        // Create associated NSButton to place inside the bar (it's customized by DMTabBarButtonCell with a special gradient for selected state)
        tabBarItemButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, iconImage.size.width, iconImage.size.height)];
        tabBarItemButton.cell = [[DMTabBarButtonCell alloc] init];
        [tabBarItemButton setImagePosition:NSImageOnly];
        tabBarItemButton.image = iconImage;
        [tabBarItemButton setEnabled:YES];
        tabBarItemButton.tag = itemTag;
        [tabBarItemButton sendActionOn:NSLeftMouseDownMask];
        [tabBarItemButton setBordered:NO];
        [tabBarItemButton setButtonType:NSToggleButton];


        [self setItemType:DMTabBarItemIconOnly];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title tag:(NSUInteger) itemTag
{
    self = [super init];
    if (self) {
        NSFont* font = [[NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:NSUnboldFontMask weight:8 size:13.0f];
        NSMutableParagraphStyle* centeredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [centeredStyle setAlignment:NSCenterTextAlignment];

        NSDictionary* attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: centeredStyle };
        NSDictionary* altAttributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: centeredStyle };
        NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:title attributes:attributes];
        NSAttributedString* altAttrString = [[NSAttributedString alloc] initWithString:title attributes:altAttributes];
        _attrTitle = [[NSMutableAttributedString alloc] initWithString:[title copy]];
        [_attrTitle setAttributes:@{ NSFontAttributeName : font.fontName} range:NSMakeRange(0, _attrTitle.length)];
        
        NSSize fitSize = [title sizeWithAttributes:@{ NSFontAttributeName: font}];
        tabBarItemButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, fitSize.width + kDMTabBarItemTextPadding, fitSize.height)];
        tabBarItemButton.cell = [[DMTabBarButtonCell alloc] init];
        
        [tabBarItemButton setImagePosition:NSNoImage];
        [tabBarItemButton setAttributedTitle:attrString];
        [tabBarItemButton setAttributedAlternateTitle:altAttrString];
        [tabBarItemButton setTag:itemTag];
        [tabBarItemButton sendActionOn:NSLeftMouseDownMask];
        [tabBarItemButton setBordered:NO];
        [tabBarItemButton setAlignment:NSCenterTextAlignment];
        [tabBarItemButton setButtonType:NSToggleButton];

        [self setItemType:DMTabBarItemTitleOnly];
    }
    return self;
}

// the size needed to display the title
- (NSSize)titleSize
{
    NSFont* font = [[NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:NSUnboldFontMask weight:8 size:13.0f];
    NSSize fitSize = [tabBarItemButton.title sizeWithAttributes:@{ NSFontAttributeName: font}];
    fitSize.width += kDMTabBarItemTextPadding;
    return fitSize;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[DMTabBarItem] tag=%i - title=%@", (int)self.tag,self.title];
}

#pragma mark - Properties redirects

// We simply redirects properties to the the NSButton class

- (void) setIcon:(NSImage *)newIcon { 
    tabBarItemButton.image = newIcon;   
}

- (NSImage *) icon {   
    return tabBarItemButton.image;  
}

- (void) setAlternateIcon:(NSImage *)newAlternateIcon {
    tabBarItemButton.alternateImage = newAlternateIcon;
}

- (NSImage *) alternateIcon
{
    return  tabBarItemButton.alternateImage;
}

- (void) setTag:(NSUInteger)newTag {  
    tabBarItemButton.tag = newTag; 
}

- (NSUInteger) tag {  
    return tabBarItemButton.tag;    
}

- (void) setToolTip:(NSString *)newToolTip {   
    tabBarItemButton.toolTip = newToolTip;  
}

- (NSString *) toolTip {  
    return tabBarItemButton.toolTip;    
}

- (void) setKeyEquivalentModifierMask:(NSUInteger)newKeyEquivalentModifierMask {
    tabBarItemButton.keyEquivalentModifierMask = newKeyEquivalentModifierMask; 
}

- (NSUInteger) keyEquivalentModifierMask {
    return tabBarItemButton.keyEquivalentModifierMask; 
}

- (void) setKeyEquivalent:(NSString *)newKeyEquivalent {
    tabBarItemButton.keyEquivalent = newKeyEquivalent;
}

- (NSString *) keyEquivalent { 
    return tabBarItemButton.keyEquivalent;  
}

- (void) setState:(NSInteger)value {
    if (tabBarItemButton.state != value)
    {
        tabBarItemButton.state = value;

        switch (value)
        {
            case NSOnState:
            {
                // Icon, if any
                self.originalIcon = [self icon];
                [self setIcon:[self alternateIcon]];
                [self setAlternateIcon:self.originalIcon];
                
                [[tabBarItemButton cell] setBackgroundColor:self.alternateButtonBackgroundColor];
                break;
            }

            case NSOffState:
            {
                if (self.originalIcon)
                {
                    [self setAlternateIcon:[self icon]];
                    [self setIcon:self.originalIcon];
                    self.originalIcon = nil;
                }
                
                [[tabBarItemButton cell] setBackgroundColor:self.buttonBackgroundColor];
                break;
            }
        }
    }
}

- (NSInteger) state {
    return tabBarItemButton.state;
}

#pragma mark - private
                                                                
- (NSMutableAttributedString*)setValue:(id)value forAttribute:(NSString*)attribute forAttributedString:(NSMutableAttributedString*)attributedString
{
    if (!attributedString || !value || !attribute)
        return attributedString;

    NSRange range;
    NSMutableDictionary* attributes = [[attributedString attributesAtIndex:0 effectiveRange:&range] mutableCopy];
    [attributes setValue:value forKey:attribute];
    [attributedString setAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    return attributedString;
}

@end


#pragma mark - DMTabBarButtonCell

@implementation DMTabBarButtonCell

- (id)init {
    self = [super init];
    if (self) {
        self.bezelStyle = NSTexturedRoundedBezelStyle;
        [self setHighlightsBy:NSContentsCellMask];
        [self setShowsStateBy:NSContentsCellMask];
//        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

- (NSInteger) nextState {
    return self.state;
}

//- (void) drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
//    if (self.state == NSOnState) { 
//        // If selected we need to draw the border new background for selection (otherwise we will use default back color)
//        // Save current context
//        [[NSGraphicsContext currentContext] saveGraphicsState];
//        
//        // Draw light vertical gradient
//        [kDMTabBarItemGradient drawInRect:frame angle:-90.0f];
//        
//        // Draw shadow on the left border of the item
//        NSShadow *shadow = [[NSShadow alloc] init];
//        shadow.shadowOffset = NSMakeSize(1.0f, 0.0f);
//        shadow.shadowBlurRadius = 2.0f;
//        shadow.shadowColor = [NSColor darkGrayColor];
//        [shadow set];
//        
//        [[NSColor blackColor] set];        
//        CGFloat radius = 50.0;
//        NSPoint center = NSMakePoint(NSMinX(frame) - radius, NSMidY(frame));
//        NSBezierPath *path = [NSBezierPath bezierPath];
//        [path moveToPoint:center];
//        [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:-90.0f endAngle:90.0f];
//        [path closePath];
//        [path fill];
//        
//        // shadow of the right border
//        shadow.shadowOffset = NSMakeSize(-1.0f, 0.0f);
//        [shadow set];
//        
//        center = NSMakePoint(NSMaxX(frame) + radius, NSMidY(frame));
//        path = [NSBezierPath bezierPath];
//        [path moveToPoint:center];
//        [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:90.0f  endAngle:270.0f];
//        [path closePath];
//        [path fill];
//        
//        // Restore context
//        [[NSGraphicsContext currentContext] restoreGraphicsState];
//    }
//}
@end
