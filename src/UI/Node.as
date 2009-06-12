package UI {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	import org.makerlab.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
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

	public class Node extends Sprite {

		// use particles to anchor this for now.
		public static var marker_particles:Particles = null;

		// track all of our own nodes
		public static var nodes:Array = new Array();
		public static var nodeID:int = 0;

		// properties
		public var zdepth:int = 0;
		public var nodeID:int;
		public var id:uint;
		public var title:String = "";
		public var link:String;
		public var type:Number;
		public var geoPosition:String;
		public var description:String;
		public var latitude:Number;
		public var longitude:Number;
		public var elevation:Number;
		public var contentPath:String;

		// visible depth
		public var minzoom:int = 0;
		public var maxzoom:int = 999;

		// display
		private var colorCode:uint;
		public var banner:TextField;
		public var parentscope:SpinnyGlobe = null;

		// some marker colors

		private static var colors:Array = new Array(	0x000000,
														0xe06117,
														0x7fdd34,
														0xd0c32e,
														0xffffff,
														0xffffff,
														0xffffff,
														0xffffff,
														0xffffff,
														0xffffff,
														0xffffff
												);

		// ************************************************************************************************************************
		// startup
		// ************************************************************************************************************************

		// NODE CONSTRUCTOR ////////////////////////////////////
		public function Node(blob:XML,_minzoom:Number,_maxzoom:Number, p:SpinnyGlobe = null):void {

			// we are unfortunately somewhat bound to features of spinnyglobe
			parentscope = p;

			// add to spinnyglobe and remember its depth for text later
			parentscope.addChild(this);
			zdepth = parentscope.getChildIndex(this);

			// track it
			this.nodeID = Node.nodeID;
			Node.nodes.push(this);
			Node.nodeID++;

			// zoom level to show this node at
			this.minzoom = _minzoom;
			this.maxzoom = _maxzoom;

			// decipher this xml blob
			init_xml(blob);

			// for now a particle effects utility helps us find our x,y screen coordinates
			if( Node.marker_particles == null) {
				Node.marker_particles = new Particles();
				p.spin_scene.addChild(Node.marker_particles);		
			}
			var pm:ParticleMaterial = new ParticleMaterial(0xff00ff,0,1);
			var v:Vertex3D = p.to_vector(this.latitude,this.longitude);
			var particle:Particle = new Particle(pm,0,v.x,v.y,v.z);
			Node.marker_particles.addParticle(particle);

			// attach event handling to this subject
			addEventListener(Event.ENTER_FRAME, update);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

		}

		// Pull content in from a kml xml blob or a georss xml blob
		private function init_xml(blob:XML):void {

		 	var ns:Namespace = blob.namespace();
		  	default xml namespace = ns;

			// get id and type
			id = blob.@id.toString();
		    type = int( blob.@type.toString() );
			colorCode = colors[type < colors.length ? int(type) : 0 ]

			// get the title from anywhere - georss is slightly different - try different places
			title = blob.name.toString();
			if( title.length < 1 ) {
				title = blob.title.toString();
			}
			link = blob.link.toString();
		 	contentPath = blob.description.toString();

			// get other stuff
			var geoPos:Array;
			if( blob.Point != null && type > 0 ) { // xxx HACK for georss
			  	geoPosition = blob.Point.coordinates.toString();
				geoPos = geoPosition.split(",", 3);
				latitude  = geoPos[0];
				longitude = geoPos[1];
				elevation = 0; // (available at geoPos[2])
			}
			else if( blob.point != null ) {
				// <georss:point featurename="reed college, portland, oregon">45.479641 -122.629990</georss:point>
				var georss:Namespace = new Namespace("http://www.georss.org/georss");
				default xml namespace = georss;
				geoPos = blob.point.toString().split(" ",2);
				default xml namespace = ns;
				latitude = geoPos[0];
				longitude = geoPos[1];
	 			elevation = 0;
				type = 1; // hack
			}

			// reset namespace to null
			// (this is necessary to avoid: "VerifyError: Error #1025: An invalid register 3 was accessed" )
			default xml namespace = null;
		}

		// TRANSFORMATIONS /////////////////////////////////////
		/*
		private function colorTransform(colorCode:uint):void {
			// change color to type
			var colorInfo:ColorTransform = this.transform.colorTransform;
			colorInfo.color = colorCode;
			this.transform.colorTransform = colorInfo;

			// apply the drop shadow
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.distance = 7;
			shadow.angle 	= 35;
			this.filters = [shadow];
		}
		*/

		// UPDATE /////////////////////////////////////////////////////////////////////
		// RENDER (position node in 3D space) ////////////////////////////////////////
		// this routine dynamically updates the nodes every frame
		// TODO instead of using particles we probably could just brute force compute this
		// http://www.everydayflash.com/blog/index.php/2008/07/07/pixel-precision-in-papervision3d/
		// - xxx would be nice to do a shadow that migrates with respect to the surface of the planet in a nice way... or alpha.
		// - xxx can bitmapparticalmaterial present the same node and same data without interleaving? no...
		// adjust alpha transparency for z dimension (optional)
		// alpha = (1 - (tempPos.z + app.radius * 2) / (app.radius * 2)) * 0.3 + 0.7;
		// adjust alpha transparency for z dimension on just the shadow (optional)
		// node.shadowpoint.alpha = (1 - (tempPos.z + app.radius * 2) / (app.radius * 2)) * 0.3 + 0.7;
		public function update(event:Event):void {
			var v:Boolean = false;
			var x:Number = 0;
			var y:Number = 0;
			if( parentscope.user_zoom < minzoom || parentscope.user_zoom > maxzoom ) {
			} else {
				v = marker_particles.geometry.vertices[nodeID].vertex3DInstance.z < parentscope.camera_distance;
				x = marker_particles.geometry.vertices[nodeID].vertex3DInstance.x + parentscope.spin_viewport.viewportWidth / 2;
				y = marker_particles.geometry.vertices[nodeID].vertex3DInstance.y + parentscope.spin_viewport.viewportHeight / 2;
			}
			marker_update(x,y,v);
		}

		// EVENT HANDLERS ///////////////////////////////////////////////////////////////
		public function clickHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();
			if(this.type ==2 ) {
				parentscope.event_focus_appropriately_on(this.latitude,this.longitude);
				return;
			}
			navigateToURL(new URLRequest(link));
			return;
			/*
			if (app.winOpen == true) {
				closeWindow();
				app.winOpen = false;
				if( app.winNodeID == nodeID ) {
					// clicking same node again leaves it closed or closes it.
					return;
				}
			}
			if (app.winOpen == false) {
				openWindow();
				addPointer();
				app.winNodeID = nodeID;
			}
			*/
		}

		public function mouseOverHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();
			if( this.visible == true) {
				marker_selected(true);
			}
		}

		public function mouseOutHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();
			marker_selected(false);
		}

		// OPEN WINDOW ////////////////////////////////////////////////////////////////////////
		public function openWindow():void {
			var winMode:String = type.toString();
			var win:WinDisplay = new WinDisplay({
								winMode		:winMode,
								title		:title,
								contentPath	:contentPath,
								colorCode   :colorCode,
								appNode		:this,
								app			:parentscope
								});
			win.name = "window";
			parentscope.addChild(win);
//			parentscope.winOpen = true;
		}

		// CLOSE WINDOW ////////////////////////////////////////////////////////////////////////
		public function closeWindow():void {
			// remove window
			var rWin:DisplayObject = parentscope.getChildByName("window"); 	
			parentscope.removeChild(rWin);
//			parentscope.winOpen = false;
		}

		// ************************************************************************************************************************
		// update the marker
		// ************************************************************************************************************************

		private static var popup:Sprite = null;
		public static var selected:Node = null;
		private var drawn:Boolean = false;

		public function marker_selected(state:Boolean):void {
			selected = state ? this : null;
		}

		public function marker_update(x:Number,y:Number,state:Boolean):void {
			this.visible = state;
			if(state) {
				this.x = x;
				this.y = y;
			}
			if(!drawn) {
				drawn = true;
				graphics.lineStyle(3, 0xFFFFFF, 0.5);
				graphics.beginFill( selected == this ? 0xff0000 : 0x00ff00, 0.5 );
				graphics.drawCircle( 0, 0, 10 );
				this.alpha = 0.5;
				graphics.endFill();
			}
			banner_update();
			popup_update();
		}

		private function popup_update():void {
			if(!popup) {
				var text:TextField = new TextField();
				var textformat:TextFormat = new TextFormat();
				popup = new Sprite();
				popup.x = -999;
				popup.y = -999;
				popup.graphics.lineStyle(3, 0xFFFFFF, 0.5);
				popup.graphics.beginFill(0xFFFFFF, 1);
				popup.graphics.drawCircle(0, 0, 20);
				popup.alpha = 0.5;
				/*
				text.selectable = false;
				text.text = "";
				textformat.font = "Courier";
				textformat.color = 0xaaaaaa;
				textformat.size = 10;
				textformat.align = "left";
				text.defaultTextFormat = textformat;	
				popup.addChild(text);
				*/
				if( nodes.length > 0 ) { // ugly hijinx to get this not pickable
					parentscope.addChildAt(popup,Node.nodes[0].zdepth);
				}
			}
			if(selected) {
				popup.visible = selected.visible;
				popup.x = selected.x;
				popup.y = selected.y;
			} else {
				popup.visible = false;
			}
		}

		private function banner_update():void {
			if(!this.banner) {
				var format:TextFormat = new TextFormat();
				format.font = "Helvetica"; 
				format.color = 0xFFFFFF;
				format.size = 12;
				format.align = "left";
				banner = new TextField();
				banner.autoSize = "left";
				banner.selectable = false;
				banner.defaultTextFormat = format;
				banner.text = title;
				banner.mouseEnabled = false;
				if( nodes.length > 0 ) { // ugly hijinx to get this not pickable
					parentscope.addChildAt(banner,Node.nodes[0].zdepth);
				}
			}
			banner.visible = this.visible;
			this.banner.x = this.x + 4;
			this.banner.y = this.y;
		}
	}
}

