
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#include <math.h>

#import "GlobeController.h"
#include "globe.h"

/////////////////////////////////////////////////////////////////////////////////////////////
// GLOBE VIEW
/////////////////////////////////////////////////////////////////////////////////////////////

#define USE_DEPTH_BUFFER 0
#define kMinimumTouchLength 30
#define kMaximumScale 7.0f
#define kMinimumPinchDelta 15
#define degreesToRadians(__ANGLE__) (M_PI * (__ANGLE__) / 180.0)
#define radiansToDegrees(__ANGLE__) (180.0 * (__ANGLE__) / M_PI)

@interface GlobeView()
	@property (nonatomic, retain) EAGLContext *context;
	@property (nonatomic, assign) NSTimer *animationTimer;
	- (id)initGLES;
	- (BOOL) createFramebuffer;
	- (void) destroyFramebuffer;
@end

@implementation GlobeView

	@synthesize context;
	@synthesize animationTimer;
	@synthesize animationInterval;

	+ (Class)layerClass {
		// Apparently this magic mystery code is mandatory - anselm
		return [CAEAGLLayer class];
	}

	-(id)initWithFrame:(CGRect)frame {
		self = [super initWithFrame:frame];
		if(self != nil) {
			self = [self initGLES];
		}
		return self;
	}

	-(id)initGLES {
		NSLog(@"GlobeView: Initializing the opengl layer" );
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [
										NSDictionary dictionaryWithObjectsAndKeys:
											[NSNumber numberWithBool:NO],
											kEAGLDrawablePropertyRetainedBacking,
											kEAGLColorFormatRGBA8,
											kEAGLDrawablePropertyColorFormat,
											nil
										];
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		if (!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer] ) {
			NSLog(@"GlobeView: Initialization error" );
			[self release];
			return nil;
		}
		NSLog(@"GlobeView: Initialized 3!!" );
		animationInterval = 1.0 / 60.0;
		[self setupView];
		return self;
	}

	- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
		UITouch *ui = [touches anyObject];
		CGPoint touch = [ui locationInView:self];
		globe_event(GLOBE_MOUSEDOWN,touch.x,touch.y,320,480);
		NSLog(@"test2");
		//UITouch *touch = [[touches allObjects] objectAtIndex:0];	
	}

	- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
		UITouch *ui = [touches anyObject];
		CGPoint touch = [ui locationInView:self];
		globe_event(GLOBE_MOUSEDRAG,touch.x,touch.y,320,480);
		NSLog(@"touches moving ");
	}

	- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		UITouch *ui = [touches anyObject];
		CGPoint touch = [ui locationInView:self];
		globe_event(GLOBE_MOUSEUP,touch.x,touch.y,320,480);
	}

	- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	}

	- (void)setupView {
		// Enable Multi Touch of the view
		self.multipleTouchEnabled = YES;
	}

	// Updates the OpenGL view when the timer fires
	- (void)drawView {

		// TODO why the delegate thing?
		if(!delegateSetup) {
			[delegate setupView:self];
			delegateSetup = YES;
		}

		[EAGLContext setCurrentContext:context];

		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

		float* mat = globe_event(GLOBE_UPDATE,0,0,backingWidth,backingHeight);
		NSLog(@"**********");
		NSLog(@"floats %f,%f,%f,%f",mat[0],mat[1],mat[2],mat[3]);
		NSLog(@"floats %f,%f,%f,%f",mat[4],mat[5],mat[6],mat[7]);
		NSLog(@"floats %f,%f,%f,%f",mat[8],mat[9],mat[10],mat[11]);
		NSLog(@"floats %f,%f,%f,%f",mat[12],mat[13],mat[14],mat[15]);

		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
		GLenum err = glGetError();
		if(err) {
			NSLog(@"%x error", err);
		}
	}

	- (void)layoutSubviews {
		[EAGLContext setCurrentContext:context];
		[self destroyFramebuffer];
		[self createFramebuffer];
		[self drawView];
	}

	- (BOOL)createFramebuffer {
		glGenFramebuffersOES(1, &viewFramebuffer);
		glGenRenderbuffersOES(1, &viewRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
		if (USE_DEPTH_BUFFER) {
			glGenRenderbuffersOES(1, &depthRenderbuffer);
			glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
			glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
			glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
		}
		if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
			NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
			return NO;
		}
		return YES;
	}

	- (void)destroyFramebuffer {
		glDeleteFramebuffersOES(1, &viewFramebuffer);
		viewFramebuffer = 0;
		glDeleteRenderbuffersOES(1, &viewRenderbuffer);
		viewRenderbuffer = 0;
		if(depthRenderbuffer) {
			glDeleteRenderbuffersOES(1, &depthRenderbuffer);
			depthRenderbuffer = 0;
		}
	}

	- (void)startAnimation {
		self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
	}

	- (void)stopAnimation {
		self.animationTimer = nil;
	}

	- (void)setAnimationTimer:(NSTimer *)newTimer {
		[animationTimer invalidate];
		animationTimer = newTimer;
	}

	- (void)setAnimationInterval:(NSTimeInterval)interval {
		animationInterval = interval;
		if (animationTimer) {
			[self stopAnimation];
			[self startAnimation];
		}	
	}

	- (void)dealloc {
		[self stopAnimation];
		if ([EAGLContext currentContext] == context) {
			[EAGLContext setCurrentContext:nil];
		}
		[context release];
		[super dealloc];
	}

	-(id<GLTriangleViewDelegate>)delegate {
		return delegate;
	}

	-(void)setDelegate:(id<GLTriangleViewDelegate>)d {
		// Update the delegate, and if it needs a -setupView: call, set our internal flag so that it will be called.
		delegate = d;
		delegateSetup = ![delegate respondsToSelector:@selector(setupView:)];
	}

@end

/////////////////////////////////////////////////////////////////////////////////////////////
// GLOBE CONTROLLER
/////////////////////////////////////////////////////////////////////////////////////////////

@implementation GlobeController

@synthesize globeview;

- (GlobeController *) init {
	NSLog(@"GlobeController: init called");
	self.title = @"globe view";
	return self;
}

- (void)loadView {
	if(globeview == NULL) {
		CGRect frame = [[UIScreen mainScreen] applicationFrame]; //CGRectMake(0, 0, 320, 480);
		globeview = [[GlobeView alloc] initWithFrame:frame];
		globeview.animationInterval = 1.0 / 60.0;
		self.view = globeview;
		//[globeview release];
		[globeview startAnimation];
		NSLog(@"GlobeController: initialization complete!");
	} else {
		NSLog(@"GlobeController: trying to initialize more than once!? Why?");
	}
}

- (void)viewDidLoad {
	[globeview startAnimation];
	NSLog(@"GlobeController: view did load");
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"GlobeController: Resigned Active");
	globeview.animationInterval = 1.0 / 5.0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"GlobeController: Became Active");
	globeview.animationInterval = 1.0 / 60.0;
}

- (void)dealloc {
	NSLog(@"GlobeController: Released");
	[globeview release];
	[super dealloc];
}

@end

