#import  <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SBFLockScreenDateView : UIView
- (void)openLightsaber;
- (void)closeLightsaber;
@property(nonatomic, strong)UIView* lightsaberView;
@property(nonatomic, strong)UIView* outerView;
@end

@interface BSUICAPackageView : UIView
@end


// State of the lightsaber
BOOL lightsaberOn = false;
BOOL previousAuthState = false;
BOOL viewAdded = false;
BOOL openedUp = false;

// prefs
id leiaEnabled;
double leiaPadding;
double leiaOpenTime;

// prefs
NSDictionary *bundleDefaults;


%hook SBDashBoardLockScreenEnvironment 

- (void) setAuthenticated:(BOOL)arg1 {
	%orig;

	previousAuthState = lightsaberOn;

	// Set the light saber state
	lightsaberOn = arg1;
}

%end

// Lock icon
%hook BSUICAPackageView 

- (void)layoutSubviews {

	// Hide the lock icon
	[self setHidden:YES];
}

%end

%hook SBFLockScreenDateView 

%property(nonatomic, strong)UIView* lightsaberView;
%property(nonatomic, strong)UIView* outerView;

- (void)layoutSubviews {
	%orig;

	if ([leiaEnabled isEqual:@1]) {

		// Check if the view does not already exist
		if (viewAdded == false) {

			viewAdded = true;

			// Create an outer layer view that holds vertical padding
			self.outerView = [[UIView alloc] initWithFrame:CGRectMake(0, -20,  self.frame.size.width, 80)];

			// Create the new UIView with 0 width so we can animate it out
			self.lightsaberView = [[UIView alloc] initWithFrame:CGRectMake(leiaPadding, 0, 0, 10)];

			// Set the color to red
			[self.lightsaberView setBackgroundColor:[UIColor colorWithRed:1 green:0.84 blue:0.84 alpha:1]];

			// Add lightsaber to outerView
			[self.outerView addSubview:self.lightsaberView];

			// outerview to SBFLockScreenDateView's view
			[self addSubview:self.outerView];

			// Add glow effect.
			self.lightsaberView.layer.shadowOffset = CGSizeZero;

			self.lightsaberView.layer.shadowColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1] CGColor];
		
			self.lightsaberView.layer.shadowRadius = 15;

			self.lightsaberView.layer.shadowOpacity = 1;
		}

		// Check if state changed

		if (previousAuthState != lightsaberOn) {

			if (lightsaberOn == true) {
				// Animate it
				[self openLightsaber];
			} else {
				[self closeLightsaber];
			}
		}

	} else {
		[self.outerView removeFromSuperview];
	}

}

%new - (void)openLightsaber {

	// Check if the lightsaber has already opened up
	if (!openedUp) {

		// Set to true so the logic doesn't get repeated.
		openedUp = true;

		// Max width
		CGFloat maxWidth = self.frame.size.width;

		// Lightsaber width
		CGFloat lighsaberWidth = maxWidth - leiaPadding * 2;

		// Rect for final size
		CGRect finalLightSaberRect = CGRectMake(leiaPadding, 0, lighsaberWidth, 10); 

		//Play sound 
		SystemSoundID soundID;

		// Get the file
		NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/LeiaPreferences.bundle"];

		NSString *soundFile = [bundle pathForResource:@"SaberOn" ofType:@"wav"];

		// Create the sound id
		AudioServicesCreateSystemSoundID((__bridge  CFURLRef)
										[NSURL fileURLWithPath:soundFile], & soundID);

		// Play the sound
		AudioServicesPlaySystemSound(soundID);

		// Animate towards the final size
		[UIView animateWithDuration:leiaOpenTime
			animations:^{
				self.lightsaberView.frame = finalLightSaberRect; 
			}
			completion:^(BOOL finished){ 
				// Perform post animation work
		}];
	}

}

%new - (void)closeLightsaber {

	if (openedUp) {
		// Rect for final size
		CGRect finalLightSaberRect = CGRectMake(leiaPadding, 0, 0, 10); 

		// Animate towards the final size
		[UIView animateWithDuration:leiaOpenTime
			animations:^{
				self.lightsaberView.frame = finalLightSaberRect; 
			}
			completion:^(BOOL finished){ 
				openedUp = false;
		}];
	}
}

%end

%ctor {

	// Get the prefs
	bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"dev.firewarm.leiapreferences"];

	// get individual settings
	leiaEnabled = [bundleDefaults valueForKey:@"leiaEnabled"];
	leiaPadding = [[bundleDefaults objectForKey:@"leiaPadding"] doubleValue];
	leiaOpenTime = [[bundleDefaults objectForKey:@"leiaOpenTime"] doubleValue];
}

// Hides the HomeGrabber everywhere except for the lockscreen/notification center
// https://developer.limneos.net/?ios=13.1.3&framework=SpringBoard&header=SBHomeGrabberView.h
// %hook SBHomeGrabberView

// - (void)setHidden:(BOOL)arg1 forReason:(id)arg2 withAnimationSettings:(id)arg3 {
// 	%orig(true, arg2, arg3);
// }

// %end