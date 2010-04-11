
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#ifdef DEBUGON
	#define DEBUGLOG if (DEBUGON) NSLog
#else
	#define DEBUGLOG
#endif


@protocol GLTriangleViewDelegate;

typedef struct {
		BOOL rotstop; // stop self rotation
		BOOL touchInside; // finger tap inside of the object ?
		BOOL scalestart; // start to scale the obejct ?
		CGPoint pos; // position of the object on the screen
		CGPoint startTouchPosition; // Start Touch Position
		CGPoint currentTouchPosition; // Current Touch Position
		GLfloat pinchDistance; // distance between two fingers pinch
		GLfloat pinchDistanceShown; // distance that have shown on screen
		GLfloat scale; // OpenGL scale factor of the object
		GLfloat rotation; // OpenGL rotation factor of the object
		GLfloat rotspeed; // control rotation speed of the object
} ObjectData;


// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.

@interface GlobeView:

	UIView {
		@private
			GLint backingWidth;
			GLint backingHeight;
			EAGLContext *context;
			GLuint viewRenderbuffer, viewFramebuffer;
			GLuint depthRenderbuffer;
			NSTimer *animationTimer;
			NSTimeInterval animationInterval;
			id<GLTriangleViewDelegate> delegate;
			BOOL delegateSetup;
	}

	@property NSTimeInterval animationInterval;
	@property(nonatomic, assign) id<GLTriangleViewDelegate> delegate;
	- (void)startAnimation;
	- (void)stopAnimation;
	- (void)drawView;
	- (void)setupView;
@end

@protocol GLTriangleViewDelegate<NSObject>
	@required
		-(void)drawView:(GlobeView*)view;
	@optional
		-(void)setupView:(GlobeView*)view;
@end


@interface GlobeController:
	UIViewController {
		GlobeView *globeview;
	}
	@property (nonatomic, retain) GlobeView *globeview;
@end