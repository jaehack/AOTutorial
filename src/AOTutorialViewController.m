//
//  AOTutorialViewController.m
//  BabyPlanner
//
//  Created by Loïc GRIFFIE on 11/10/2013.
//  Copyright (c) 2013 Appsido. All rights reserved.
//

#import "AOTutorialViewController.h"

#define headerLeftMargin    20.0f
#define headerFontSize      15.0f
#define headerFontType      @"Helvetica"
#define headerColor         [UIColor whiteColor]

#define labelLeftMargin     40.0f
#define labelFontSize       12.0f
#define labelFontType       @"Helvetica-Light"
#define labelColor          [UIColor whiteColor]

#define buttonColorTop      @"#FFFFFF"
#define buttonColorBottom   @"#D5D5D5"

#define loginLabelColor     @"#000000"
#define signupLabelColor    @"#B80000"
#define dismissLabelColor   @"#000000"


@interface UIColor (AOAdditions)

/**
 * Generate UIColor with given Hexadecimal color such as 0x123456
 *
 * @param UInt32 The hexadecimal color
 * @return UIColor translation
 */

+ (UIColor *)colorWithHex:(UInt32)col;

/**
 * Generate UIColor with given Hexadecimal color string representationsuch as #123456
 *
 * @param NSString The hexadecimal color
 * @return UIColor translation
 */

+ (UIColor *)colorWithHexString:(NSString *)str;

@end

@implementation UIColor (AOAdditions)

+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:(int)x];
}

+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end

@interface AOButton : UIButton

@end

@implementation AOButton

- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *gradientColors = @[(id)[[UIColor colorWithHexString:buttonColorTop] CGColor], (id)[[UIColor colorWithHexString:buttonColorBottom] CGColor]];
    
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.size.width/2, 0), CGPointMake(rect.size.width/2, rect.size.height), 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end

@interface AOTutorialViewController ()
{
    NSUInteger _index;
}

@property (strong, nonatomic) NSMutableArray *backgroundImages;
@property (strong, nonatomic) NSMutableArray *informationLabels;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundBottomImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundTopImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet AOButton *signupButton;
@property (weak, nonatomic) IBOutlet AOButton *loginButton;
@property (weak, nonatomic) IBOutlet AOButton *dismissButton;

@end

@implementation AOTutorialViewController

#pragma mark - Helper function

CGSize ACMStringSize(NSString *string, CGSize size, NSDictionary *attributes)
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:string];
    [textStorage setAttributes:attributes range:NSMakeRange(0, [textStorage length])];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    return [layoutManager usedRectForTextContainer:textContainer].size;
}

#pragma mark - Life cycle methods

- (instancetype)initWithBackgroundImages:(NSArray *)images andInformations:(NSArray *)informations
{
    self = [self initWithNibName:@"AOTutorialViewController" bundle:nil];
    if (self)
    {
        self.backgroundImages = [NSMutableArray arrayWithArray:images];
        self.informationLabels = [NSMutableArray arrayWithArray:informations];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _index = 0;
        _buttons = AOTutorialButtonNone;
        
        self.backgroundImages = [NSMutableArray array];
        self.informationLabels = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.header)
    {
        [self.logo setHidden:NO];
        [self.logo setImage:self.header];
    }
    
    [self.pageController setNumberOfPages:[self.backgroundImages count]];
    [self.scrollview setContentSize:CGSizeMake(self.scrollview.frame.size.width * [self.backgroundImages count], self.scrollview.frame.size.height)];
    
    [self layoutViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButton
{
    [self.loginButton setTitleColor:[UIColor colorWithHexString:loginLabelColor] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor colorWithHexString:signupLabelColor] forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor colorWithHexString:dismissLabelColor] forState:UIControlStateNormal];
    
    [self.dismissButton setHidden:YES];
    
    switch (self.buttons) {
        case AOTutorialButtonSignup:
            [self.signupButton setHidden:NO];
            break;
        case AOTutorialButtonLogin:
            [self.loginButton setHidden:NO];
            break;
        case AOTutorialButtonSignup | AOTutorialButtonLogin:
            [self.signupButton setHidden:NO];
            [self.loginButton setHidden:NO];
            break;
        default:
            [self.signupButton setHidden:YES];
            [self.loginButton setHidden:YES];
            [self.dismissButton setHidden:NO];
    }
}

- (void)layoutViews
{
    [self addButton];
    [self addInformationsLabels];
    [self resetBackgroundImageState];
    
    [self.backgroundBottomImage setImage:[UIImage imageNamed:[self.backgroundImages objectAtIndex:_index+1]]];
}

- (void)addInformationsLabels
{
    NSUInteger index = 0;
    for (NSDictionary *labels in self.informationLabels)
    {
        CGSize hSize = ACMStringSize([labels valueForKey:@"Header"], CGSizeMake(([[UIScreen mainScreen] bounds].size.width - (headerLeftMargin * 2)), 60.0f), [self headerTextStyleAttributes]);
        CGSize lSize = ACMStringSize([labels valueForKey:@"Label"], CGSizeMake(([[UIScreen mainScreen] bounds].size.width - (labelLeftMargin * 2)), 60.0f), [self labelTextStyleAttributes]);
        
        NSLog(@"Frame > %@", NSStringFromCGRect(self.scrollview.frame));
        
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + ([[UIScreen mainScreen] bounds].size.width * index) + headerLeftMargin, [[UIScreen mainScreen] bounds].size.height - 120.0f - lSize.height, ([[UIScreen mainScreen] bounds].size.width - (headerLeftMargin * 2)), hSize.height + 5.0f)];
        [header setNumberOfLines:1];
        [header setLineBreakMode:NSLineBreakByTruncatingTail];
        [header setShadowOffset:CGSizeMake(1, 1)];
        [header setShadowColor:[UIColor blackColor]];
        [header setText:[labels valueForKey:@"Header"]];
        [header setTextAlignment:NSTextAlignmentCenter];
        [header setBackgroundColor:[UIColor clearColor]];
        [header setTextColor:headerColor];
        [header setFont:[UIFont fontWithName:headerFontType size:headerFontSize]];
        [self.scrollview addSubview:header];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + ([[UIScreen mainScreen] bounds].size.width * index) + labelLeftMargin, header.frame.origin.y + hSize.height + 5.0f, ([[UIScreen mainScreen] bounds].size.width - (labelLeftMargin * 2)), lSize.height)];
        [label setNumberOfLines:0];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setShadowOffset:CGSizeMake(1, 1)];
        [label setShadowColor:[UIColor blackColor]];
        [label setText:[labels valueForKey:@"Label"]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:labelColor];
        [label setFont:[UIFont fontWithName:labelFontType size:labelFontSize]];
        [self.scrollview addSubview:label];
        
        index++;
    }
}

- (void)resetBackgroundImageState
{
    [self.backgroundTopImage setImage:[UIImage imageNamed:[self.backgroundImages objectAtIndex:_index]]];
    [self.backgroundTopImage setAlpha:1.0];
    [self.backgroundBottomImage setAlpha:0.0];
}

- (void)setHeaderImage:(UIImage *)logo
{
    [self setHeader:logo];
}

#pragma mark - Labels methods

- (NSDictionary *)headerTextStyleAttributes
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineSpacing:5.0f];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    
    return @{NSFontAttributeName:[UIFont fontWithName:headerFontType size:headerFontSize], NSForegroundColorAttributeName:headerColor, NSParagraphStyleAttributeName:style, NSShadowAttributeName:shadow};
}

- (NSDictionary *)labelTextStyleAttributes
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineSpacing:5.0f];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    
    return @{NSFontAttributeName:[UIFont fontWithName:labelFontType size:labelFontSize], NSForegroundColorAttributeName:labelColor, NSParagraphStyleAttributeName:style, NSShadowAttributeName:shadow};
}

#pragma mark - User interface methods

- (IBAction)signup:(id)sender
{
    
}

- (IBAction)login:(id)sender
{
    
}

- (IBAction)dismiss:(id)sender
{
    
}

#pragma mark - Scrollview delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat alpha = [scrollView contentOffset].x / [[UIScreen mainScreen] bounds].size.width - _index;
    
    NSInteger newIndex = (alpha < 0 ? _index-1 : _index+1);
    
    UIImage *nextImage = [UIImage imageNamed:[self.backgroundImages objectAtIndex:(newIndex < 0 ? 0 : (newIndex >= [self.backgroundImages count] ? [self.backgroundImages count]-1 : newIndex))]];
    
    if (![[self.backgroundBottomImage image] isEqual:nextImage]) [self.backgroundBottomImage setImage:nextImage];
     
    [self.backgroundTopImage setAlpha:1-fabs(alpha)];
    [self.backgroundBottomImage setAlpha:fabs(alpha)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollview.frame.size.width;
    _index = floor((self.scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self.pageController setCurrentPage:_index];
    
    [self resetBackgroundImageState];
}

@end
