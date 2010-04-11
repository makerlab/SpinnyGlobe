
#import "AppDelegate.h"
#import "GlobeController.h"
#import "PostController.h"

/*********************************************************************************************/

@implementation AppDelegate

	@synthesize window;
	@synthesize nav;
	@synthesize globe;
	@synthesize post;

	#pragma mark -
	#pragma mark Application lifecycle
	- (void)applicationDidFinishLaunching:(UIApplication *)application {    
		NSLog(@"AppDelegate: finished launching");
		// application.statusBarHidden = YES;
		// application.statusBarStyle = UIStatusBarStyleBlackOpaque;
		window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		window.backgroundColor = [UIColor redColor];

		// a nav controller; we're not using it for now
		//nav = [[UINavigationController alloc] initWithRootViewController: post];
		//[window addSubview:nav.view];

		// the main page
		globe = [[GlobeController alloc] init];
		[window addSubview:globe.view];

		// the posting page
//		post = [[PostController alloc] init];
//		[window addSubview:post.view];

		[window makeKeyAndVisible];
	}

	- (void)showGlobe {
		[window bringSubviewToFront: globe.view];
	}

	- (void)applicationWillTerminate:(UIApplication *)application {	
		NSError *error;
		if (managedObjectContext != nil) {
			if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				exit(-1);
			}
		}
	}

	#pragma mark -
	#pragma mark Saving
	- (IBAction)saveAction:(id)sender {	
		NSError *error;
		if (![[self managedObjectContext] save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);
		}
	}

	#pragma mark -
	#pragma mark Core Data stack
	- (NSManagedObjectContext *) managedObjectContext {
		if (managedObjectContext != nil) {
			return managedObjectContext;
		}
		NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
		if (coordinator != nil) {
			managedObjectContext = [[NSManagedObjectContext alloc] init];
			[managedObjectContext setPersistentStoreCoordinator: coordinator];
		}
		return managedObjectContext;
	}

	- (NSManagedObjectModel *)managedObjectModel {	
		if (managedObjectModel != nil) {
			return managedObjectModel;
		}
		managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
		return managedObjectModel;
	}

	- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {	
		if (persistentStoreCoordinator != nil) {
			return persistentStoreCoordinator;
		}
		NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Locative.sqlite"]];
		NSError *error;
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
			// Handle error TODO
		}
		return persistentStoreCoordinator;
	}

	#pragma mark -
	#pragma mark Application's documents directory
	- (NSString *)applicationDocumentsDirectory {	
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		return basePath;
	}

	#pragma mark -
	#pragma mark Memory management
	- (void)dealloc {
		[managedObjectContext release];
		[managedObjectModel release];
		[persistentStoreCoordinator release];
		[nav release];
		[globe release];
		[window release];
		[super dealloc];
	}

@end
