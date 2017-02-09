#import "NSPlaceHolderTextView.h"

@implementation NSPlaceHolderTextView

@synthesize placeHolder = _placeHolder;

- (void)setPlaceHolderText:(NSString *)txt {
    NSColor *txtColor = [NSColor grayColor];
    NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName, nil];
    _placeHolder = [[NSAttributedString alloc] initWithString:txt attributes:txtDict];
}

- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if ([[self string] isEqualToString:@""] && self != [[self window] firstResponder])
        [_placeHolder drawAtPoint:NSMakePoint(0,0)];
}

- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}


@end
