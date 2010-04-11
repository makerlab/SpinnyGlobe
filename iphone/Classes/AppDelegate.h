
@class GlobeController;
@class PostController;

@interface AppDelegate:
	NSObject <UIApplicationDelegate> {
		NSManagedObjectModel *managedObjectModel;
		NSManagedObjectContext *managedObjectContext;	    
		NSPersistentStoreCoordinator *persistentStoreCoordinator;
		UIWindow *window;
		UINavigationController *nav;
		GlobeController *globe;
		PostController *post;
	}
	@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
	@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
	@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
	@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
	@property (nonatomic, retain) UIWindow *window;
	@property (nonatomic, retain) UINavigationController *nav;
	@property (nonatomic, retain) GlobeController *globe;
	@property (nonatomic, retain) PostController *post;

	- (void) showGlobe;

@end

