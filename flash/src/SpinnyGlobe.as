
package {

	import UI.Node;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.Security;
	import flash.text.*;
	import flash.utils.*;
	import flash.xml.*;
	
	import org.makerlab.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.utils.*;
	import org.papervision3d.events.*;
	import org.papervision3d.lights.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.shaders.*;
	import org.papervision3d.materials.special.*;
	import org.papervision3d.materials.utils.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.objects.special.*;
	import org.papervision3d.render.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.view.*;
	
	import support.DataLoader;

	[SWF(width="400", height="400", backgroundColor="#000000", frameRate="31")]
	public class SpinnyGlobe extends Sprite {

		// The planetary surface is always at 0,0,0 and always has this radius
		// Scaling is accomplished by a hack which renders a partial surface fragment on demand
		public var surface_radius:Number = 600;

		// The camera always points at 0,0,0 and has a fixed distance as well.
		// The manipulator rotates the camera while leaving it pointed at the origin.
		// The camera also has a zoom scaling factor and a clipping plane that we change in concert to fake zoom
		public var camera_distance:Number = 5000.0;
		public var camera_focus:Number = 300.0;
		public var camera_zoom:Number = 5.0;
		public var user_zoom:Number = 0.0;
		public var width_desired:Number = 400.0;
		public var height_desired:Number = 400.0;

		// Papervision3d Scenery
		public var spin_scene:Scene3D;
		public var spin_camera:LocalCamera3D;
		public var spin_viewport:Viewport3D;
		public var spin_renderer:BasicRenderEngine;
		public var manipulator:Manipulator = null;
		public var planet:WMSLayer;
		public var backing:Sprite;
		public var earthglow:Sprite;

		// Navigation button events [ look elsewhere for mouse move and drag events ]
		private function event_move_up   (event:MouseEvent):void { manipulator.event_move(  0, 50); }
		private function event_move_down (event:MouseEvent):void { manipulator.event_move(  0,-50); }
		private function event_move_left (event:MouseEvent):void { manipulator.event_move( 50,  0); }
		private function event_move_right(event:MouseEvent):void { manipulator.event_move(-50,  0); }
		private function event_zoom_out(event:MouseEvent):void {
			if(user_zoom>0) {
				user_zoom--;
				manipulator.zoom = user_zoom;
				spin_camera.zoom = spin_camera.zoom / 2;
			}
		}
		private function event_zoom_in(event:MouseEvent):void {
			if(user_zoom < 17 ) {
				user_zoom++;
				manipulator.zoom = user_zoom;
				spin_camera.zoom = spin_camera.zoom * 2;
			}
		}
		private function event_reset(event:MouseEvent):void {
			user_zoom = 0;
			manipulator.zoom = user_zoom;
			manipulator.reset();
			spin_camera.reset();
            if (ExternalInterface.available) {
                ExternalInterface.call("spinnyglobe_pos_to_js",0,0,0);
            }
		}
		public function event_focus_appropriately_on(_lat:Number,_lon:Number,_zoom:Number=8):void {
			state_target_lat = _lat;
			state_target_lon = _lon;
			user_zoom = _zoom;
			spin_camera.reset();
			spin_camera.set_zoom(user_zoom);
			manipulator.event_set_focus(user_zoom,_lat,_lon);
			// the manipulator will write to the camera and set it - but doesn't set camera zoom atm
		}

		// try make things less secure and open up gateways
		public function add_external_interfaces_and_security():void {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			Security.loadPolicyFile("http://civicmaps.org/cross-domain.xml");
            if (ExternalInterface.available) {
				ExternalInterface.addCallback("event_focus_appropriately_on",event_focus_appropriately_on);
				ExternalInterface.addCallback("markers_load_rss",markers_load_rss);
				ExternalInterface.addCallback("lines_load",lines_load);
            }
		}

		///////////////////////////////////////////////////////////////////////////////////////////////////
		// A STATE ENGINE ( unused and incomplete )
		///////////////////////////////////////////////////////////////////////////////////////////////////

		private var state_target_zoom:Number = 45;
		private var state_target_lon:Number = -122;
		private var state_target_lat:Number = 0;
		private var state_motion_x:Number = 0.1;
		private var state_motion_y:Number = 0.1;
		private var state_activity:Number = 0;
		
		private function sequence_suspend():void {
			state_activity = 30;
		}

		private function sequence_goto(lat:Number,lon:Number,zoom:Number = 0):void {
			state_target_lat = lat;
			state_target_lon = lon;
			state_target_zoom = zoom;
		}

		private function sequencing_engine():void {
			if(true) return;
			// a script driven state machine that incrementally moves things over time...
			if( state_activity > 0 ) {
				state_activity = state_activity - 1;
				return;
			}
			event_focus_appropriately_on(state_target_lat,state_target_lon-0.3,user_zoom);
		}

		///////////////////////////////////////////////////////////////////////////////////////////////////
		// KEY CAPTURE
		///////////////////////////////////////////////////////////////////////////////////////////////////

		/*
		// TODO: this does not work if inside of a manipulator - why?
		public override function event_key_down(e:KeyboardEvent):void {

			trace("got key "+ e.keyCode );

			switch(e.keyCode) {

				// NUMBERS
				case 48: // 0
					trace ("0");
					user_zoom = 0;
					break;
					
				case 49: // 1
					trace ("1");
					user_zoom = 1;
					break;
					
				case 50: // 2
					trace ("2");
					user_zoom = 2;
					break;
					
				case 51: // 3
					trace ("3");
					user_zoom = 3;
					break;
					
				case 52: // 4
					user_zoom = 4;
					break;
					
				case 53: // 5
					user_zoom = 5;
					break;
					
				case 54: // 6
					user_zoom = 6;
					break;
					
				case 55: // 7
					user_zoom = 7;
					break;
				
				case 56: // 8
					user_zoom = 8;
					break;
					
				case 57: // 9
					user_zoom = 9;
					break;
					
				default:
					break;
			}
		}
		public override function event_mouse_zoom(e:MouseEvent):void {
			//if( e.delta > 0 ) zoom = zoom + 1;
			//if( e.delta < 0 ) zoom = zoom - 1;
			//if( zoom > 10 ) zoom = 10;
			//if( zoom < 0 ) zoom = 0;
		}
		*/

		public function makerlab_listenener():void {
			navigateToURL(new URLRequest("http://makerlab.com"));
		}

		///////////////////////////////////////////////////////////////////////////////////////////////////
		// START
		///////////////////////////////////////////////////////////////////////////////////////////////////

		public function SpinnyGlobe():void {

			// let the outside world talk to us
			add_external_interfaces_and_security();

			opaqueBackground = 0;

			// some mumbo jumbo
			stage.scaleMode = "noScale"

			// width and height
			//if( stage.stageWidth > 0 ) {
			//	w = stage.stageWidth;
			//	h = stage.stageHeight;
			//}

			// A mandatory backdrop to catch mouse events
			if( true ) {
				backing = new Sprite();
				backing.x = width / 2;
				backing.y = height / 2;
				addChild(backing);
			}

			// papervision3d startup
			spin_viewport = new Viewport3D(width, height, true, true);
			addChild( spin_viewport );
			spin_renderer = new BasicRenderEngine();
			spin_scene = new Scene3D();

			// An optional pretty star-field - slow
			if (false) {
				var star_material:BitmapFileMaterial = new BitmapFileMaterial("assets/stars.png");
				star_material.doubleSided = false;
				star_material.smooth = false;
				var stars:Sphere = new Sphere( star_material, camera_distance*1.1, 32, 16 );
				spin_scene.addChild(stars);
			}

			// A WMS tiled sphere - the core of the whole project
			if (true) {
				planet = new WMSLayer(surface_radius);
				planet.focus(0,0,0);
				spin_scene.addChild(planet);
			}

			// An optional test object for debugging
			if (false) {
				var material2:BitmapFileMaterial = new BitmapFileMaterial("assets/earth.jpg");
				material2.doubleSided = false;
				material2.smooth = false;
				var globe:Sphere = new Sphere(null,surface_radius, 42, 42);
				spin_scene.addChild(globe);
			}

			// a logo rendered via ordinary flash
			if(true) {
				var loader:Loader = new Loader();
				this.addChild(loader);
				loader.x = 0;
				loader.y = height-22;
				loader.load(new URLRequest("assets/m.png"));
				//loader.addEventListener(MouseEvent.CLICK, makerlab_listener );
			}

			// Map navigation controls
			if( true ) {
				var s:Sprite;
				var size:Number = 20;

				// up
				s = new Sprite();
				s.x=2*size; s.y=1*size;
				s.graphics.beginFill(0xffff00);
				s.graphics.drawCircle(0,0,size/2);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_move_up);
				addChild(s);

				// down
				s = new Sprite();
				s.x=2*size; s.y=3*size;
				s.graphics.beginFill(0xffff00);
				s.graphics.drawCircle(0,0,size/2);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_move_down);
				addChild(s);

				// left
				s = new Sprite();
				s.x=1*size; s.y=2*size;
				s.graphics.beginFill(0xfff000);
				s.graphics.drawCircle(0,0,size/2);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_move_left);
				addChild(s);

				// right
				s = new Sprite();
				s.x=3*size; s.y=2*size;
				s.graphics.beginFill(0xfff000);
				s.graphics.drawCircle(0,0,size/2);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_move_right);
				addChild(s);

				// zoom out
				s = new Sprite();
				s.x=2*size; s.y=5*size-size/5;
				s.graphics.beginFill(0xff00ff);
				s.graphics.drawCircle(0,0,size/2);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_zoom_out);
				addChild(s);

				// zoom in
				s = new Sprite();
				s.x=2*size; s.y=6*size;
				s.graphics.beginFill(0xff00ff);
				s.graphics.drawCircle(0,0,10);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_zoom_in);
				addChild(s);

				// reset
				s = new Sprite();
				s.x=2*size; s.y=8*size;
				s.graphics.beginFill(0xff0000);
				s.graphics.drawCircle(0,0,10);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.CLICK,event_reset);
				addChild(s);

			}

			// Camera and controller over the scene
			if( true ) {
				spin_camera = new LocalCamera3D(camera_distance,camera_focus,camera_zoom);
				manipulator = new Rotater(surface_radius,width,height);
				manipulator.event_set_focus(user_zoom,40,-120);
			}

			event_focus_appropriately_on(45,-122,0);

			// Event handling for keyboard and mouse drag type events [ and not for mouse button click events ]
			if( manipulator ) {
				addEventListener(KeyboardEvent.KEY_DOWN, manipulator.event_key_down , true);
				addEventListener(MouseEvent.MOUSE_UP,    event_mouse_up , true);
				addEventListener(MouseEvent.MOUSE_DOWN,  event_mouse_down , true);
				addEventListener(MouseEvent.MOUSE_MOVE,  event_mouse_move , true);
				addEventListener(MouseEvent.MOUSE_WHEEL, event_mouse_zoom , true);
			}

			addEventListener(Event.ENTER_FRAME, event_update);

			// lets look at the flash variables
			this.loaderInfo.addEventListener(Event.COMPLETE, this.loaderComplete);

			// try do this last so it appears in center
			// An optional earth glow effect
			if (true) {
				earthglow = new Sprite();
				// TODO: scaling is not working properly
				var glowRadius:Number = surface_radius;
				var fillType:String = GradientType.RADIAL;
				var colors:Array = [0x0ACCFF, 0x003399];
				var alphas:Array = [100, 0];
				var ratios:Array = [140, 165];
				var matr:Matrix = new Matrix();
				matr.createGradientBox(glowRadius, glowRadius, 0, -(glowRadius/2), -(glowRadius/2));
				var spreadMethod:String = SpreadMethod.PAD;
				earthglow.visible = false;
				earthglow.graphics.beginGradientFill (
					fillType, colors, alphas, ratios, matr, spreadMethod);  
				earthglow.graphics.drawCircle(0, 0, glowRadius);
				earthglow.graphics.endFill();
				addChildAt(earthglow, 0);
			}

			// load some art in a time sequenced way

			sequencer_start();

		}

		//////////////////////////////////////////////
		// bizarre flash code to get at html parameters
		//////////////////////////////////////////////
		public function loaderComplete(myEvent:Event):void {
			// trace( this.loaderInfo.parameters );
		}

		//////////////////////////////////////////////
		// bizarre flash code to do double click
		//////////////////////////////////////////////
		private var lastclick:int = 0;
		private var clickstate:int = 0;
		private var lastx:int = 0;
		private var lasty:int = 0;

		public function event_mouse_down(e:MouseEvent):void {
			sequence_suspend();
			if( clickstate < 2 ) {
				clickstate = 1;
				lastclick = getTimer();
				lastx = e.stageX;
				lasty = e.stageY;
			} else {
				clickstate = 0;
				if( (getTimer() - lastclick) < 300 ) {
					//why is e.stageX zero? xxx if( lastx == e.stageX && lasty == e.stageY ) {
						event_zoom_in(e);
					//}
				}
			}
			manipulator.event_mouse_down(e);
		}

		public function event_mouse_up(e:MouseEvent):void {
			if( clickstate == 1 ) {
				clickstate = 2;
			}
			manipulator.event_mouse_up(e);
		}

		public function event_mouse_move(e:MouseEvent):void {
			if( e.buttonDown ) sequence_suspend();
			manipulator.event_mouse_move(e);
		}

		public function event_mouse_zoom(e:MouseEvent):void {
			sequence_suspend();
			manipulator.event_mouse_zoom(e);
		}

		// ************************************************************************************************************************
		// marker and lines
		// ************************************************************************************************************************

		public static var minzoom:int = 0;
		public static var maxzoom:int = 999;

		// load a pile of markers XXXX CANNOT GET THIS TO WORK
		private function markers_load_rss(filename:String,_minzoom:int = 0,_maxzoom:int = 999):void {
			minzoom = _minzoom;
			maxzoom = _maxzoom;
			var xmlSession:DataLoader = new DataLoader({ dataType: "XML", dataPath: filename, app: this, onLoad: markers_parse_rss });
			xmlSession.loadData();
		}

		// load a pile of markers
		private function markers_load_kml(filename:String,_minzoom:int = 0,_maxzoom:int = 999):void {
			minzoom = _minzoom;
			maxzoom = _maxzoom;
			var xmlSession:DataLoader = new DataLoader({ dataType: "XML", dataPath: filename, app: this, onLoad: markers_parse_kml });
			xmlSession.loadData();
		}

		public function markers_parse_rss(xml:XML):void {
			// TODO borked
			var ns:Namespace = xml.namespace();
			for each (var parent:XML in xml.ns::channel) {
				for each ( var node:XML in parent.ns::item) {
					Node.build(node,minzoom,maxzoom,this);
	   			}
			}
		}

		public function markers_parse_kml(xml:XML):void {
			var ns:Namespace = xml.namespace();
			var count:int = 0;
			for each (var node:XML in xml.ns::Placemark) {
				Node.build(node,minzoom,maxzoom,this);
				count = count + 1;
			}
		}

		// load a pile of pretty arc lines between already existing markers
		private function lines_load(dataPath:String):void {
			var dataType:String = "XML";
			var xmlSession:DataLoader = new DataLoader({ dataType: dataType, dataPath: dataPath, app: this, onLoad: this.lines_parse });
			xmlSession.loadData();
		}

		public function lines_parse(xmlData:XML):void {
			for each (var blob:XML in xmlData.line) { 			
				var attributes:XMLList = blob.attributes();
				var type:Number = attributes[0];
				var startNodeID:Number = attributes[1];
				var endNodeID:Number = attributes[2];
				if(Node.nodes.length > startNodeID && Node.nodes.length > endNodeID ) {
					var n1:Node	= Node.nodes[startNodeID];
					var n2:Node = Node.nodes[endNodeID];
					lines_arc(n1.latitude,n1.longitude,n2.latitude,n2.longitude);
				}
			}
		}

		// draw a curved line over the planets surface - TODO deal with wrap around
		public function lines_arc(lat1:Number,lon1:Number,lat2:Number,lon2:Number):void {
			var a:Vertex3D = to_vector(lat1,lon1);
			var b:Vertex3D = to_vector(lat2,lon2);
			var x:Number = (lat1+lat2)/2;
			var y:Number = (lon1+lon2)/2;
			var z:Number = Math.sqrt(x*x+y*y)*3 + surface_radius;
			var c:Vertex3D = to_vector(x,y,z);
			var be:Bezier3D = new Bezier3D(0xccff44,2,10,a,b,c);
			spin_scene.addChild(be._instance);
		}

		public function to_vector(latitude:Number,longitude:Number,elevation:Number = 0):Vertex3D {
			var v:Vertex3D = new Vertex3D();
			latitude = Math.PI * latitude / 180;
			longitude = Math.PI * longitude / 180;
			// rotate into our frame
			longitude += Math.PI/2;
			latitude -= Math.PI/2;
			elevation = elevation ? elevation : surface_radius;
			v.x = elevation * Math.sin(latitude) * Math.cos(longitude);
			v.z = elevation * Math.sin(latitude) * Math.sin(longitude);
			v.y = elevation * Math.cos(latitude);
			return v;
		}

		// ************************************************************************************************************************
		// update
		// ************************************************************************************************************************

		// general update; flash doesn't support vertical beam synchronization... dunno how fast this is.
		public function event_update(e:Event):void {
			// i have no idea
			earthglow.x = stage.stageWidth / 2 ; // width_desired/2;
			earthglow.y = stage.stageHeight / 2 ; // height_desired/2;
			earthglow.visible = true;
			if( manipulator ) {
				spin_camera.my_transform = manipulator.get_transform();
			}
			if( planet ) {
				planet.focus(spin_camera.lat(),spin_camera.lon(),user_zoom);
			}
			spin_renderer.renderScene(spin_scene, spin_camera, spin_viewport);
			sequencing_engine();
		}

		// ************************************************************************************************************************
		// angel
		// ************************************************************************************************************************

		private var sequence_timer:Timer = new Timer(60*1000,99999);
		private var animate_timer:Timer = new Timer(10,99999);

		// http://xangel.makerlab.org:3000/xml?q=%40anselm+near+banff+canada";
		public var angel_url:String = "http://angel.makerlab.org/xml?q=%40anselm+near+banff+canada";
		public var sample_markers_url:String = "assets/kmldata.xml";
		public var sample_lines_url:String  = "assets/connections.xml";

		public function sequencer_start():void {
			sequence_timer.start();
			sequence_timer.addEventListener(TimerEvent.TIMER,angel_timer_handler);
			animate_timer.start();
			animate_timer.addEventListener(TimerEvent.TIMER,animate_timer_handler);
			markers_load_kml(sample_markers_url);
//			lines_load(sample_lines_url);
 //       	markers_load_kml("assets/angel.xml");
 			markers_load_kml(angel_url);
     		event_zoom_in(null);
			manipulator.event_move(  1, 50);
		}

		public function animate_timer_handler(e:TimerEvent):void {
//			 manipulator.event_move(  1, 0);
		}

        public function angel_timer_handler(e:TimerEvent):void {
        	angel_update();
        }

		public function angel_update():void {
//			markers_load_kml(sample_markers_url);
        	markers_load_kml(angel_url);
        }
	}
}
