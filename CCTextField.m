//
//  CCTextField.m
//  
//
//  Created by Ignacio Inglese on 12/27/11.
//  Copyright 2011 Ignacio Inglese. All rights reserved.
//

#import "CCTextField.h"

#define kTagDebugLayer 100

@interface CCTextField ()

- (void)updateTicker;
- (void)initContent;

@end

@implementation CCTextField

@synthesize delegate = delegate_;
@synthesize label = label_;
@synthesize textField = textField_;
@synthesize maxLength = maxLength_;
@synthesize password = password_;
@synthesize debugMode = debugMode_;

@dynamic text;

+ (id)textFieldWithFieldSize:(CGSize)textFieldSize {
	return [[[self alloc] initWithFieldSize:textFieldSize] autorelease];
}

- (id)initWithFieldSize:(CGSize)textFieldSize {
	return [self initWithFieldSize:textFieldSize fontName:@"Helvetica" andFontSize:12];
}

+ (id)textFieldWithFieldSize:(CGSize)textFieldSize fontName:(NSString *)fontName andFontSize:(CGFloat)fontSize {
	return [[[self alloc] initWithFieldSize:textFieldSize fontName:fontName andFontSize:fontSize] autorelease];
}

- (id)initWithFieldSize:(CGSize)textFieldSize fontName:(NSString *)fontName andFontSize:(CGFloat)fontSize {
	if (self = [super init]) {
		
		// Redundant, but helps keep things clear
		sharedTextField = NO;
		CGSize s = [[CCDirector sharedDirector] winSize];		
		
		self.label = [CCLabelTTF labelWithString:@"" dimensions:textFieldSize alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize];
		[self.label setColor:ccBLACK];
		
		self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(s.width * 2, s.height * 2, textFieldSize.width, textFieldSize.height)] autorelease];
		
		[[[CCDirector sharedDirector] openGLView] addSubview:self.textField];
		
		[self initContent];
		
	}
	return self;	
}

+ (id)textFieldWithLabel:(CCLabelTTF *)label andTextField:(UITextField *)textfield {
	return [[[self alloc] initWithLabel:label andTextField:textfield] autorelease];
}

- (id)initWithLabel:(CCLabelTTF *)label andTextField:(UITextField *)textfield {
	if (self = [super init]) {
		
		sharedTextField = YES;
		
		self.textField = textfield;
		self.label = label;
		
		[self.textField addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:NULL];
		
		[self initContent];
	}
	return self;
}

- (void)initContent {
	
	self.contentSize = self.label.contentSize;
	
	CCLayerColor * lc = [CCLayerColor layerWithColor:ccc4(120, 0, 50, 255) width:self.contentSize.width height:self.contentSize.height];
	
	[self addChild:lc z:0 tag:kTagDebugLayer];
	[lc setVisible:NO];
	
	[self.label setPosition:ccp(self.label.contentSize.width * 0.5, self.label.contentSize.height * 0.5)];
	[self addChild:self.label];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.textField && [keyPath isEqualToString:@"delegate"]) {
		if (showingTicker) {
			[self updateTicker];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	[self.textField resignFirstResponder];
	
	if ([delegate_ respondsToSelector:@selector(textFieldDidReturn:)]) {
		[delegate_ textFieldDidReturn:self];
	}
	
	return YES;
	
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (showingTicker) {
		hidingTicker = NO;
		[self updateTicker];
	}

	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([delegate_ respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
		if (![delegate_ textField:self shouldChangeCharactersInRange:range replacementString:string]) {
			return NO;
		}
	}
	
	NSString * str = [[realString copy] autorelease];
	
	if (showingTicker) {
		[self updateTicker];
		
		if (str.length == 0 && string.length == 0) {
			return NO;
		}
	}
		
	str = [str stringByReplacingCharactersInRange:range withString:string];
	
	
	if (self.maxLength > 0 && [str length] > self.maxLength && string.length > 0) {
		return NO;
	}
	
	if (self.password) {
		[self.label setString:[@"************************************************************************************" substringToIndex:str.length]];
	}
	else {
		[self.label setString:str];
	}
	
	[realString release];
	realString = [str retain];
	
	hidingTicker = YES;
	
	return YES;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGPoint p = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
	CGRect r = self.boundingBox;
	r.origin = CGPointZero;
	
	
	if (CGRectContainsPoint(r, p)) {
		
		BOOL reset = NO;
		
		if ([self.textField delegate] != self) {
			reset = YES;
		}
		
		[self.textField setDelegate:self];
		
		if (reset) {
			[realString release];
			realString = [self.label.string retain];
			[self.textField setText:realString];
		}
		
		[self.textField becomeFirstResponder];
		return YES;
	}
	
	return NO;
}

- (void)onEnter {
	[super onEnter];
	
	[[CCTouchDispatcher sharedDispatcher]  addTargetedDelegate:self priority:0 swallowsTouches:YES];
	
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(updateTicker) forTarget:self interval:0.5 paused:NO];
}

- (void)onExit {
	[super onExit];
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
	
}

- (void)setText:(NSString *)text {
	[realString release];
	realString = [text retain];
	self.textField.text = text;
	self.label.string = text;
	showingTicker = NO;
}

- (NSString *)text {
	
	if (showingTicker) {
		return [realString substringToIndex:realString.length - 1];
	}
	else {
		return realString;
	}
	
}

- (void)setTextColor:(ccColor3B)color {
	[self.label setColor:color];
}

- (void)setDebugMode:(BOOL)debugMode {
	debugMode_ = debugMode;
	[(CCLayerColor *)[self getChildByTag:kTagDebugLayer] setVisible:debugMode_];
}

- (void)dealloc {
	
	[textField_ removeObserver:self forKeyPath:@"delegate"];
	
	if (textField_.delegate == self) {
		[textField_ setDelegate:nil];
	}
	
	[realString release];
	
	[super dealloc];
}

- (void)updateTicker {
	
	if (!showingTicker && (![self.textField isFirstResponder] || self.textField.delegate != self)) {
		return;
	}
	
	if (hidingTicker) {
		hidingTicker = NO;
		return;
	}
	
	showingTicker = !showingTicker;
	
	NSString * str = [self.label string];
	
	if (showingTicker) {
		[self.label setString:[str stringByAppendingString:@"|"]];
	}
	else {
		[self.label setString:[str substringToIndex:str.length - 1]];
	}
	
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
	
	// If UITextField isn't shared, forward messages to it
	if (!sharedTextField && [self.textField respondsToSelector:aSelector]) {
		NSLog(@"passing %@", NSStringFromSelector(aSelector));
		[self.textField performSelector:aSelector];
	}
	else {
		[super doesNotRecognizeSelector:aSelector];
	}
	
}

@end
