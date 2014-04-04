//
//  TextExpanderManager.h
//  Created by Ryu Iwasaki.
//  Copyright (c) 2014年 Ryu Iwasaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMTEDelegateController;

typedef id (^FillCompletionAction)(NSString *textIdentifier,BOOL userCanceledFill, NSInteger ioInsertionPointLocation);
typedef NSString *(^IdentifierForTextAreaAction)(id uiTextObject);
typedef BOOL  (^PrepareForFillSwitchAction)(NSString *textIdentifier);

@interface TextExpanderManager : NSObject

/**
 *  Singleton Class Method.
 *  @return sharedInstance
 **/
+ (id)sharedManager;

/**
 *  Singleton Class Method.
 *
 *  @param appName Input your app name. To be displayed in the fetch settings and/or fill-in window.
 *  @param getSnippetsScheme Your app's URL scheme to handle the getSnippets x-callback-url.
 *  @param fillCompletionScheme fill-in snippets callback url.URL scheme for fill-in snippet completion via x-callback-url. Leave nil to avoid the fill-in process.
 *
 *  @return sharedInstance
 *
 **/
+ (id)sharedManagerWithAppName:(NSString *)appName
             getSnippetsScheme:(NSString *)getSnippetsScheme
          fillCompletionScheme:(NSString *)fillCompletionScheme;
                    
@property (nonatomic,readonly) SMTEDelegateController <UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIWebViewDelegate, UISearchBarDelegate> *currentTextExpander;

@property (nonatomic) id nextDelegate;
@property (nonatomic) NSString *fillCompletionScheme;
@property (nonatomic) NSString *getSnippetsScheme;
@property (nonatomic) NSString *clientAppName;

@property (nonatomic, readonly) BOOL isAttemptingToExpandText;
@property (nonatomic, assign) BOOL provideUndoSupport;
@property (nonatomic, assign) BOOL expandPlainTextOnly;

@property (nonatomic, readonly) BOOL snippetExpanded; // already load snippets
@property (nonatomic, readonly) BOOL enableFillin;

/**
 * TextExpander Utility
 **/
+ (BOOL)isTextExpanderTouchInstalled;
+ (BOOL)textExpanderTouchSupportsFillins;
+ (void)clearSharedSnippets;
+ (BOOL)snippetsAreShared: (NSDate**)optionalModDate;

/**
 *  Enable TextExpander Snippets for TextObjects.
 *
 *  @param textObjects such as a UITextField for which you want to enable TextExpander Snippets.
 *  @param nextDelegate textObjects's delegate object.
 *
 **/
- (void)enableTextExpanderToTextObjects:(NSArray *)textObjects nextDelegate:(id)nextDelegate;

/**
 *  Enable TextExpander snippets and fill-in for TextObjects.
 *
 *  @param textObjects such as a UITextField for which you want to enable TextExpander snippets and fill-in.
 *  @param nextDelegate textObjects's delegate object.
 *
 **/
- (void)enableTextExpanderInAdditionFillinsToTextObjects:(NSArray *)textObjects nextDelegate:(id)nextDelegate;

/**
 *  Enable fill-in for TextObjects.
 *
 *  @param textObjects such as a UITextField for which you want to enable fill-in.
 *
 *
 **/
- (void)enableFillinsToTextObjects:(NSArray *)textObjects;

/**
 *  Disable fill-in for All TextObjects.
 *
 **/
- (void)disableFillins;


- (void)fillinsRequiredActionsAtIdentifierForTextArea:(IdentifierForTextAreaAction)identifierAction
                                   fillinCompletionHandler:(FillCompletionAction)fillCompletionAction;

- (void)fillinsAllActionsAtIdentifierForTextArea:(IdentifierForTextAreaAction)identifierAction
                         prepareForFillinSwitch:(PrepareForFillSwitchAction)prepareAction
                              fillinCompletionHandler:(FillCompletionAction)fillCompletionAction;

 
/**
 * 
 *  This method call getSnippets method in SMETDelegateController instance method.
 *
 **/
- (BOOL)getSnippets;
- (BOOL)updateSnippets; // Update snippets data.

/**
 *  Respose URL Scheme of GetSnippet or Open Fill-in.
 *  
 *  @param url callback url.
 *
 *
 **/
- (BOOL)handleSchemeURL:(NSURL *)url;

@end
