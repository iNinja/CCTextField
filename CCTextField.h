//
//  CCTextField.h
//  
//
//  Created by Ignacio Inglese on 12/27/11.
//  Copyright 2011 Ignacio Inglese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCTextField;

@protocol CCTextFieldDelegate <NSObject>

- (void)textFieldDidReturn:(CCTextField *)textField;
- (BOOL)textField:(CCTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

@interface CCTextField : CCNode <UITextFieldDelegate, CCTargetedTouchDelegate> {
	BOOL showingTicker;
	BOOL hidingTicker;
	BOOL sharedTextField;
	
	NSString * realString;
}

@property (nonatomic, assign) id<CCTextFieldDelegate> delegate;
@property (nonatomic, assign) UITextField * textField;
@property (nonatomic, assign) CCLabelTTF * label;
@property (nonatomic, assign) NSUInteger maxLength;
@property (nonatomic, assign) BOOL password;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) NSString * text;

+ (id)textFieldWithFieldSize:(CGSize)textFieldSize;
+ (id)textFieldWithFieldSize:(CGSize)textFieldSize fontName:(NSString *)fontName andFontSize:(CGFloat)fontSize;
+ (id)textFieldWithLabel:(CCLabelTTF *)label andTextField:(UITextField *)textfield;
- (id)initWithFieldSize:(CGSize)textFieldSize;
- (id)initWithFieldSize:(CGSize)textFieldSize fontName:(NSString *)fontName andFontSize:(CGFloat)fontSize;
- (id)initWithLabel:(CCLabelTTF *)label andTextField:(UITextField *)textfield;

- (void)setTextColor:(ccColor3B)color;

@end
