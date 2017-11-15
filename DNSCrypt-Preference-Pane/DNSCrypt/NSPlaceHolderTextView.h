#ifndef NSPlaceHolderTextView_h
#define NSPlaceHolderTextView_h

#import <Foundation/Foundation.h>

IB_DESIGNABLE
@interface NSPlaceHolderTextView : NSTextView

@property (nonatomic, retain) IBInspectable NSAttributedString *placeHolder;

- (void)setPlaceHolderText:(NSString *)txt;

@end

#endif /* NSPlaceHolderTextView_h */
