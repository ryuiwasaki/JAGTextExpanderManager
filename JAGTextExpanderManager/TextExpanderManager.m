//
//  TextExpanderManager.m
//  Created by Ryu Iwasaki.
//  Copyright (c) 2014年 Ryu Iwasaki. All rights reserved.
//

#import "TextExpanderManager.h"
#import <TextExpander/SMTEDelegateController.h>

static NSString *const kSMTEExpansionEnabled = @"SMTEExpansionEnabled";

@interface  TextExpanderManager ()<SMTEFillDelegate>

@property (nonatomic,readwrite)SMTEDelegateController *currentTextExpander;
@property (nonatomic,readwrite) BOOL enableFillin;
@property (nonatomic) NSMutableDictionary *textObjectList;

@property (nonatomic,copy) FillCompletionAction fillCompletionAction;
@property (nonatomic,copy) PrepareForFillSwitchAction prepareForFillSwitchAction;
@property (nonatomic,copy) IdentifierForTextAreaAction identifierForTextAreaAction;

@end


@implementation TextExpanderManager

static TextExpanderManager *_sharedInstance;

+ (id)sharedManager{
    
    [self _updateTextExpanderExpansionLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[TextExpanderManager alloc]init];
        [_sharedInstance currentTextExpander];
    });
    
    return _sharedInstance;
}

+ (id)sharedManagerWithAppName:(NSString *)appName
             getSnippetsScheme:(NSString  *)getSnippetsScheme
          fillCompletionScheme:(NSString *)fillCompletionScheme{
    
    _sharedInstance = [self sharedManager];
    
    if (_sharedInstance) {
        
        _sharedInstance.clientAppName = appName;
        _sharedInstance.getSnippetsScheme = getSnippetsScheme;
        _sharedInstance.fillCompletionScheme = fillCompletionScheme;
        _sharedInstance.enableFillin = NO;
        _sharedInstance.textObjectList = [NSMutableDictionary new];
    }
    
    return _sharedInstance;
}

+ (void)_updateTextExpanderExpansionLoad{
    
    BOOL textExpanderEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTEExpansionEnabled];
    
    [SMTEDelegateController setExpansionEnabled:textExpanderEnabled];
    [SMTEDelegateController expansionStatusForceLoad:YES snippetCount:0 loadDate:nil error:nil];
    
}

- (SMTEDelegateController *)currentTextExpander{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _currentTextExpander = [[SMTEDelegateController alloc]init];
        _currentTextExpander.fillDelegate = self;
    });
    
    return _currentTextExpander;
}

//--------------------------------------------------------------//
#pragma mark - Enable Snippets and Fill-in
//--------------------------------------------------------------//

- (void)enableTextExpanderToTextObjects:(NSArray *)textObjects nextDelegate:(id)nextDelegate{
    
    for (id textObject in textObjects) {
        
        if ([textObject respondsToSelector:@selector(setDelegate:)]) {
            
            [textObject performSelector:@selector(setDelegate:) withObject:_currentTextExpander];
        }
    }
    
    self.nextDelegate = nextDelegate;
}


- (void)enableTextExpanderInAdditionFillinsToTextObjects:(NSArray *)textObjects nextDelegate:(id)nextDelegate{
    
    [self enableTextExpanderToTextObjects:textObjects nextDelegate:nextDelegate];
    [self enableFillinsToTextObjects:textObjects];
}

- (void)enableFillinsToTextObjects:(NSArray *)textObjects{
    
    _enableFillin = YES;
    
    for (id textObject in textObjects) {
        
        if ([textObject respondsToSelector:@selector(delegate)]) {
            id delegate = [textObject performSelector:@selector(delegate)];
            
            if ([_currentTextExpander isEqual:delegate]) {
                
                NSString *identifier = [[NSUUID UUID] UUIDString];
                _textObjectList[identifier] = textObject;
            }
        }
    }
}

//--------------------------------------------------------------//
#pragma mark - Fillins
//--------------------------------------------------------------//

- (void)fillinsRequiredActionsAtIdentifierForTextArea:(IdentifierForTextAreaAction)identifierAction
                                   fillinCompletionHandler:(FillCompletionAction)fillCompletionAction{
    _identifierForTextAreaAction = identifierAction;
    _prepareForFillSwitchAction = nil;
    _fillCompletionAction = fillCompletionAction;
}

- (void)fillinsAllActionsAtIdentifierForTextArea:(IdentifierForTextAreaAction)identifierAction
                         prepareForFillinSwitch:(PrepareForFillSwitchAction)prepareAction
                              fillinCompletionHandler:(FillCompletionAction)fillCompletionAction{
    
    _identifierForTextAreaAction = identifierAction;
    _prepareForFillSwitchAction = prepareAction;
    _fillCompletionAction = fillCompletionAction;
    
}

- (id)makeIdentifiedTextObjectFirstResponder:(NSString *)textIdentifier fillWasCanceled:(BOOL)userCanceledFill cursorPosition:(NSInteger *)ioInsertionPointLocation{
    
    if (_fillCompletionAction) {
        
        id textObject = _fillCompletionAction(textIdentifier,userCanceledFill,*ioInsertionPointLocation);
        
        return textObject;
        
    } else {
        
        if (_textObjectList.count) {
            
            return _textObjectList[textIdentifier];
        }
        
    }
    
    return nil;
}

- (NSString *)identifierForTextArea:(id)uiTextObject{
    
    NSString *identifier;
    
    if (_identifierForTextAreaAction) {
        
        identifier = _identifierForTextAreaAction(uiTextObject);
        
    } else {
        
        if (_textObjectList.count) {
            
            NSArray *keys = [_textObjectList allKeysForObject:uiTextObject];
            identifier = keys[0];
        }
    }
    
    return identifier;
}

- (BOOL)prepareForFillSwitch: (NSString *)textIdentifier{
    
    if (_prepareForFillSwitchAction) {
        BOOL switchOn = _prepareForFillSwitchAction(textIdentifier);
        
        return switchOn;
    } else {
        
        return YES;
    }
}

- (void)disableFillins{
    
    _enableFillin = NO;
    _textObjectList = [NSMutableDictionary new];
}

//--------------------------------------------------------------//
#pragma mark - Update TextExpander Data
//--------------------------------------------------------------//

- (BOOL)handleSchemeURL:(NSURL *)url{
    
    
    if ([_fillCompletionScheme isEqualToString:url.scheme] && _enableFillin) {
        
        [_currentTextExpander handleFillCompletionURL:url];
        
        return YES;
    }
    
    
    if ([_getSnippetsScheme isEqualToString:url.scheme]) {
        
        NSError *error = nil;
        BOOL cancel = NO;
        
        if ([_currentTextExpander handleGetSnippetsURL:url error:&error cancelFlag:&cancel] == YES) {
            
            if (cancel) {
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSMTEExpansionEnabled];
                
			} else if (error != nil) {
                
				
	        } else {
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSMTEExpansionEnabled];
                [SMTEDelegateController setExpansionEnabled:YES];
                
            }
            
			return YES;
            
            
        } else {
            
            
        }
        
    }
    
    return NO;
}

- (BOOL)updateSnippets{
    
    return [self getSnippets];
}

- (BOOL)getSnippets{
      
    return [_currentTextExpander getSnippets];
}

//--------------------------------------------------------------//
#pragma mark - Status
//--------------------------------------------------------------//

- (BOOL)snippetExpanded{

    return [[NSUserDefaults standardUserDefaults] boolForKey:kSMTEExpansionEnabled];
}

- (BOOL)isAttemptingToExpandText{
    
    return _currentTextExpander.isAttemptingToExpandText;
}

- (void)setProvideUndoSupport:(BOOL)provideUndoSupport{
    _currentTextExpander.provideUndoSupport =provideUndoSupport;
}

- (BOOL)provideUndoSupport{
    return _currentTextExpander.provideUndoSupport;
}

- (void)setExpandPlainTextOnly:(BOOL)expandPlainTextOnly{
    
    _currentTextExpander.expandPlainTextOnly = expandPlainTextOnly;
}

- (BOOL)expandPlainTextOnly{
    
    return _currentTextExpander.expandPlainTextOnly;
}

//--------------------------------------------------------------//
#pragma mark - TextExpander Utility
//--------------------------------------------------------------//

+ (BOOL)isTextExpanderTouchInstalled{
    
    return [SMTEDelegateController isTextExpanderTouchInstalled];
}

+ (BOOL)textExpanderTouchSupportsFillins{
    
    return [SMTEDelegateController textExpanderTouchSupportsFillins];
}

+ (void)clearSharedSnippets{
    
    [SMTEDelegateController clearSharedSnippets];
}

+ (BOOL)snippetsAreShared: (NSDate**)optionalModDate{
    return [SMTEDelegateController snippetsAreShared:optionalModDate];
}

- (void)setClientAppName:(NSString *)clientAppName{
    _clientAppName = clientAppName;
    _currentTextExpander.clientAppName = clientAppName;
}

- (void)setNextDelegate:(id)nextDelegate{
    _nextDelegate = nextDelegate;
    _currentTextExpander.nextDelegate = nextDelegate;
}

- (void)setFillCompletionScheme:(NSString *)fillCompletionScheme{
    _fillCompletionScheme = fillCompletionScheme;
    _currentTextExpander.fillCompletionScheme = fillCompletionScheme;
}

- (void)setGetSnippetsScheme:(NSString *)getSnippetsScheme{
    _getSnippetsScheme = getSnippetsScheme;
    _currentTextExpander.getSnippetsScheme = getSnippetsScheme;
}


@end
