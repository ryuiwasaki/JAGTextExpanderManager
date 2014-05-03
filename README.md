JAGTextExpanderManager
======================

This Class is The TextExpander SDK Wrapper.
Getting & Updating Snippets will easily.
So, Fill-in delegate is converted to Blocks method.

## Usage

Getting snippets code is following under the code.

Write this code in App Delegate.
// First 
	@interface AppDelegate ()

	@property (nonatomic) JAGTextExpanderManager *textExpanderManager;

	@end


// Second
	- (void)_initialize{
    
   	 _textExpanderManager = [JAGTextExpanderManager sharedManagerWithAppName:@"Your app name"
                                                       getSnippetsScheme:@"snippets url scheme"
                                                    fillCompletionScheme: @"Fill-in url scheme"];

	}
 
 
 // Third
 - (BOOL)applicationDidLaunch
 
    [self _initialize];
    
    }
    

Next,Call getSnippets method.

For instance UISwitch Object in UIViewController.

- (void)changeOption:(id)sender{
    UISwitch *swt = sender;
    

}


And,Catch callback with url scheme.

- (BOOL)-

[_textExpanderManager handleURL:url];

}


Last step, add UITextObjects for JAGTextExpanderManager instance.
 
 [JAGTextExpander sharedManager] addObjects:@[a,b]
 

Using Fill-in function is Only one step.


Add UITextObjects for JAGTextExpanderManager instance.


Stop snippets attempting is Only one step.

Call Remove method.

 
