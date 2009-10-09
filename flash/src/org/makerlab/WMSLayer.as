package org.makerlab {

	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.material.TriangleMaterial;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.utils.MaterialsList;

	/*
	 * handle both spherical or flat mapping of a tiled wms layer
	 */

	public class WMSLayer extends TriangleMesh3D {

		public var debug:Boolean = true;
		
		public var latitude:Number = 0;
		public var longitude:Number = 0;

		// area of interest
		public var lat:Number = 0;
		public var lon:Number = 0;
		public var zoom:Number = 0;
	
		// a flat mode - usually i enable this for testing tiling schemes
		public var is_flat:Boolean = false;
	
		// size of sphere or flat rendering area in papervision3d world space units
		public var surface:Number = 800;
	
		// a helpful hint about how big the viewing window is for the user in ordinary pixel space
		public var pw:int = 512;
		public var ph:int = 512;
	
		// rendering style; wms = 0, oneearth = 10, yahoo = 20 ; TODO; better if this was a class
		public var vendor:int = 0;

		// for some vendor styles there is an url to reach the data... TODO; later put in a class renderer
		//public var wmsurl:String = "http://onearth.jpl.nasa.gov/browse.cgi?wms_server=wms.cgi&layers=modis&srs=EPSG:4326&format=image/png&transparent=true";

		// this works... but relies on onearth
		// public var wmsurl:String = "http://maps.civicactions.net/cgi-bin/mapserv?map=/www/sites/maps.civicactions.net/maps/world.map&service=WMS&WMTVER=1.0.0&REQUEST=map&SRS=EPSG:4326&LAYERS=bluemarble,landsat7,lakes,rivers,cities,majorroads,minorroads,tiger_polygon,tiger_landmarks,tiger_lakes,tiger_local_roads,tiger_major_roads,lowboundaries,boundaries,coastlines&FORMAT=image/jpeg&STYLES=&TRANSPARENT=TRUE"

		// this works pretty good
		// public var wmsurl:String = "http://www2.demis.nl/wms/wms.asp?wms=BlueMarble&REQUEST=GetMap&Layers=Earth%20Image,Countries&FORMAT=image/png&SRS=EPSG:4326&VERSION=1.1.1&Styles="

		// local tests - this is awesome
		// public var wmsurl:String = "http://localhost/cgi-bin/mapserv?map=/Users/anselm/packages/mapserver/worldborders.map&&service=WMS&WMTVER=1.0.0&REQUEST=map&SRS=EPSG:4326&LAYERS=worldborders&FORMAT=image/png&STYLES=&TRANSPARENT=TRUE";

		// this circumvents fucking flash drm
		public var wmsurl:String = "http://civicmaps.org/cgi-bin/mapserv?map=/www/sites/maps.civicactions.net/maps/world3.map&service=WMS&WMTVER=1.0.0&REQUEST=map&SRS=EPSG:4326&LAYERS=a1,a2,b1,b2,c1,c2,d1,d2&FORMAT=image/jpeg&STYLES=";

		// this works... not hugely beautiful
		//public var wmsurl:String = "http://openaerialmap.org/wms/?REQUEST=GetMap&Layers=World&FORMAT=image/png&SRS=EPSG:4326&version=1.1.1&styles=";
		
		// nasa and onearth are almost always down
		//public var wmsurl:String = "http://wms.jpl.nasa.gov/wms.cgi?service=WMS&WMTVER=1.0.0&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=modis&FORMAT=image/jpeg&STYLES=&TRANSPARENT=TRUE"

		// for some vender styles there is a fixed tile size - depends on vendor style
		public var tilepw:int = 512;
		public var tileph:int = 512;

		// computed width and height of a tile grid required to hypothetically tesselate entire sphere
		public var tilesx:Number;
		public var tilesy:Number;

		// computed size of each tile in longitude and latitude degrees
		public var tilegw:Number;
		public var tilegh:Number;

		// computed focus tile of a tile grid that is imagined underneath the current longitude and latitude
		public var tilex:Number;
		public var tiley:Number;

		// computed span of tiles in tile grid to render out of the set of all possible tiles in the tile grid
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;

		//
		// set size of sphere
		//
		public function set_surface(_surface:Number):void {
			surface = _surface;
			if( surface < 0.1 ) surface = 0.1;
		}

		//
		// set an internal representation of latitude and longitude and zoom - making sure values are legal
		//
		public function set_lon_and_lat_and_zoom(_longitude:Number,_latitude:Number,_zoom:Number):void {

			lon = _longitude;
			lat = _latitude;
			zoom = _zoom;

			// clean up focal point such that wrap-around cases are not present
			while( lon < -180.0 ) lon += 360.0;
			while( lon > 180.0 ) lon -= 360.0;
			while( lat < -90.0 ) lat += 180.0;
			while( lat > 90.0 ) lat -= 180.0;

			// convert lon and lat into an x y position in a flat planar space in the positive quadrant
			lon = lon + 180.0;
			lat = -lat;
			lat = lat + 90.0;

			// clean up zoom
			zoom = Math.floor(zoom);
			if( zoom < 0 ) zoom = 0;
			if( zoom > 16 ) zoom = 16;
		}

		//
		// prepare for doing a wms based style of render - this is the simplest case
		//
		public function vendor_wms():void {

			// ...
			vendor = 0;

			// how many tiles wide and tall is the world? lets render square tiles
			tilesx = Math.pow(2,zoom) * 2;
			tilesy = Math.pow(2,zoom);

			// the size of each tile in world space is a function of how big the tile grid is
			tilegw = 360.0/tilesx;
			tilegh = 180.0/tilesy;
		}

		//
		// setup for nasa jpl oneearth tiling scheme
		// untested - broken
		// note: this is a pretty moronic format because tile edges do not intersect 0,0 - hard to deal with -
		// the guy who invented this probably worked on the nasa mars climate orbiter.
		//
		// i couldn't find any docs on the format; here is what mikel maron says:
		// 
		// The images start from the northwest corner (-180,-166) and are placed in
		// non-overlapping tiles covering the world. At the lowest zoom level,
		// each tile covers 256 degrees of lat and lon. So the global
		// image is not divided in equal portions, and the tiles contain areas
		// "off the map. The bounding boxes at the lowest zoom are -180,-166,76,90 
		// and 76,-166,332,90
		//
		public function vendor_oneearth():void {

			// ...
			vendor = 10;

			// onearth also uses a power of 2 zoom with square tiles; two tiles side by size at far view
			tilesx = Math.pow(2,zoom) * 2;
			tilesy = Math.pow(2,zoom);
	
			// tiles are a fixed 256 by 256 degrees at zoom = 0 ... for some bizarre reason...
			tilegw = 256 / tilesx * 2; // ( * 2 to stay square )
			tilegh = 256 / tilesy;

			// TODO: for this format to work requires clipping away the unused tile fragment
			//       i guess this could be accomplished with some simple but extra math
		}

		//
		// yahoo blocks their tiles to flash clients... so this is a waste of time.
		//
		public function vendor_yahoo():void {}

		//
		// set the vendor
		//
		public function set_vendor():void {
			// TODO: use subclassing
			if( vendor == 0 ) vendor_wms();
			else if ( vendor == 10 ) vendor_oneearth();
			else if ( vendor == 20 ) vendor_yahoo();
		}

		//
		// set tile extents; deal with overlap elsewhere
		// this occurs after setting the vendor style such as set_vendor_wms() 
		//
		public function set_tile_extents():void {

			// find focal tile where a lon,lat of 0,0 = center tile in tile grid...
			tilex = Math.floor(lon/tilegw);
			tiley = Math.floor(lat/tilegh);

			// rendering a single tile
			left = tilex;
			right = tilex;
			top = tiley;
			bottom = tiley;

			// render up to a 9 tile patch (hardcoded for now) but do not overwrap self due to wraparound
			if( tilesx > 1 ) left -= 1;
			if( right - left < tilesx -1 ) right += 1;
			if( tilesy > 1 ) top -= 1;
			if( bottom - top < tilesy -1 ) bottom += 1;

			// for low resolutions just render everything please to avoid overlapping around the poles
			if(zoom < 2 ) {
				left = 0;
				right = tilesx - 1;
				top = 0;
				bottom = tilesy - 1;
			}

			// debugging
			if(debug) {
				trace("wms: there may be up to " + tilesx + " tiles wide and " + tilesy + " tall at zoom " + zoom );
				trace("wms: each tile is " + tilegw + " degrees wide and " + tilegh + " tall " );
				trace("wms: the center tile is at " + tilex + " and " + tiley );
				trace("wms: and tiles will be printed from left top of " + left + "," + top + " to a right bottom of " + right + "," + bottom );
			}
		}

		//
		// build up a set of vertices for our tiles in a seamless fashion to avoid visual slivers
		// http://math.rice.edu/~pcmi/sphere/drg_txt.html
		//
		public var v:Vertex3D;
		public var vertex_row:Array;
		public var vertex_rows:Array;
		public var vertices:Array;
		public var vertextotal:int = 0;
		public var subtile:Number = 1;
		public function make_vertices():void {

			// optional curvature for tiles by subtiling them

			subtile = (is_flat || tilesx > 16 ) ? 1 : Math.ceil(32/tilesx);
 
			if( debug ) trace("wms: subtiling is going to be " + subtile );

			// make vertices now

			var i:Number, j:Number;
			var x:Number, y:Number, z:Number, t:Number;
			var yradians:Number, xradians:Number;

			vertex_rows = new Array();
			vertices = new Array();
			vertextotal = 0;

			for(j = top*subtile; j <= bottom*subtile + subtile ; j+=1 ) {
				vertex_row = new Array();
				for(i = left*subtile; i <= right*subtile + subtile; i+=1 ) {
					xradians = Math.PI*2*i/(tilesx*subtile);
					yradians = Math.PI*j/(tilesy*subtile);
					x = -surface*Math.sin(yradians)*Math.sin(xradians);
					y = -surface*Math.cos(yradians);
					z = surface*Math.sin(yradians)*Math.cos(xradians);

					if(is_flat) {
						x = i*(surface/tilesx) - surface/2; //surface/360.0*(i/subtile*tilegw-(360.0/2));
						y = j*(surface/tilesy) - surface/2; //surface/180.0*(j/subtile*tilegh-(180.0/2))*tileratio;
						z = 0;
					}

					if( true || debug ) {
						x = Math.floor( x * 100000 ) / 100000;
						y = Math.floor( y * 100000 ) / 100000;
						z = Math.floor( z * 100000 ) / 100000;
						//trace(" vertex ("+j+" "+i+") at " + x + " " + y + " " + z + " *** " + Math.cos(yradians) + " " + yradians);
					}

					//if(is_flat==false && (j==0||j==tiles*subtile) && v!=null) {
					//		// only one vertex at the pole ideally
					//} else
					{
						v = new Vertex3D(x,y,z);
						vertices.push(v);
						vertextotal = vertextotal + 1;
					}
					vertex_row.push(v);
				}
				vertex_rows.push( vertex_row );
			}

			if( debug ) trace("wms: vertex rows is " + vertex_rows.length + " cols is " + vertex_row.length + " total vertices is " + vertextotal );

		}

		//
		// make an idealized uv subdivision of a tile
		// this works on EDGES so that if one had 2 polygons there would be 3 edges wide.
		// this occurs after defining the vertices - basically after the subtiling regime is specified
		//
		// note for schemes like onearth this approach would have to pin uv's
		// based not on an assumption that one tile = exact coverage of that region
		// but rather with some simple fraction of the coverage ratio
		// for example in a farthest view situation the tile is 256 tall although
		// the world is only 180 tall... so the ratio of 256/180 should be used here
		//
		public var uv_rows:Array;
		public function make_uv():void {
			uv_rows = new Array();
			for(var j:int=0;j<=subtile;j++) {
				uv_rows.push(new Array());
				for(var i:int=0;i<=subtile;i++) {
					uv_rows[j].push(new NumberUV(i/subtile,j/subtile));
				}
			}
		}

		//
		// make materials...
		//
		public var mymaterials:MaterialsList;
		public var material_row:Array;
		public var material_rows:Array;
		public var materialtotal:int = 0;
		public var polarcap:TriangleMaterial;
		public function make_materials():void {
			var key:String;
			var i:Number,j:Number;
			mymaterials = new MaterialsList();
			material_rows = new Array();
			materialtotal = 0;
			if( polarcap == null ) {
				polarcap = new ColorMaterial( 0xffffff, 1 );
			}
			for(j=top;j<=bottom;j++) {			// visit vertical major tiles range
				material_row = new Array();
				material_rows.push(material_row);
				for(i=left;i<=right;i++) {		// visit horizontal major tiles range

					// ordinary wms server?
					if(vendor == 0) {

						var x1:Number = i*tilegw-180;
						var y1:Number = j*tilegh-90;
						var x2:Number = i*tilegw+tilegw-180;
						var y2:Number = j*tilegh+tilegh-90;

						// wraparound
						while(x1<-180) { x1+=360;x2+=360;}
						while(y1<-90) { y1+=180;y2+=180; }
						while(x2>180) { x1-=360;x2-=360; }
						while(y2>90) { y1-=180;y2-=180; }

						key = wmsurl
							+ "&WIDTH="+tilepw
							+ "&HEIGHT="+tileph
							+ "&BBOX="
							// bottom left corner ( eg -180, -90 )
							+ x1
							+ ","
							+ y1
							+ ","
							// top right corner ( eg 180, 90 )
							+ x2
							+ ","
							+ y2
							;

						// polar caps; i don't paint there due to convergence of polygons
						if( y2 > 89 && y1 > 65 ) key = null;
						if( y2 < -65 && y1 < -89 ) key = null;

					} else if(vendor == 10) {
						// TBD
					} else if(vendor == 20) {
						// Yahoo
						// for yahoo if textures are out of bounds wrap-around
						// at zoom 17 
						// y = 0 or -1
						// x = 0 or 1
						// at zoom 16
						// y = 1,0,-1,-2
						// x = 0,1,2,3
						// at zoom 15
						// y = 3,2,1,0,-1,-2,-3,-4
						//     0 1 2 3 4 5 6 7
						//		7 6 5 4 3 2 1 0
						var xpos:int = i;
						var ypos:int = j;
						xpos %= tilesx;
						ypos %= tilesy;
						//ypos = tilesx/2 - 1 - ypos;
						ypos = ypos - tilesx/2; // hack; world is painted from bottom...fix?
						key = wmsurl + "&x="+xpos+"&y="+ypos;
					}
					if( debug ) {
						trace("wms: asking for texture " + key);
					}
					var m:TriangleMaterial;
					if( key != null ) {
						var temp:BitmapFileMaterial = new BitmapFileMaterial(key);
						temp.checkPolicyFile = true;
						m = temp;
					} else
					{
						m = polarcap;
					}
					m.doubleSided = false;
					m.smooth = false;
					mymaterials.addMaterial(m,key);
					material_row.push(m);
					materialtotal++;
				}
			}
			if( debug ) trace("wms: total number of materials is " + materialtotal );
		}

		//
		// wire the polygons together as strips overtop of the pre-arranged set of vertices
		// this occurs after make_vertices() and make_uv() and make_materials()
		// TODO: fix: note that there will be a seam in the case of a sphere due to lazy closure on wraparound
		//
		public var myfaces:Array;
		private var facetotal:int = 0;
		public function make_polygons():void {
			var jnum:int = vertex_rows.length-1;
			var v1:Vertex3D;
			var v2:Vertex3D;
			var v3:Vertex3D;
			var v4:Vertex3D;
			var uv1:NumberUV;
			var uv2:NumberUV;
			var uv3:NumberUV;
			var uv4:NumberUV;
			var f1:Triangle3D;
			var f2:Triangle3D;
			var i:Number,j:Number;
			myfaces = new Array();
			facetotal = 0;
			for(j=0;j<jnum;j++) {					// visit vertical range of tiles
				var inum:int = vertex_rows[j].length-1;
				for(i=0;i<inum;i++) {				// visit horizontal range of tiles
					v1 = vertex_rows[j][i];
					v2 = vertex_rows[j][i+1];
					v3 = vertex_rows[j+1][i+1];
					v4 = vertex_rows[j+1][i];
					uv1 = uv_rows[j%subtile+0][i%subtile+0];
					uv2 = uv_rows[j%subtile+0][i%subtile+1];
					uv3 = uv_rows[j%subtile+1][i%subtile+1];
					uv4 = uv_rows[j%subtile+1][i%subtile+0];
					//var m1:ColorMaterial = new ColorMaterial( j*0x200000 + i * 0x20, 0.6 );
					//var m2:ColorMaterial = new ColorMaterial( 0, 0.6 );
					//var m:BitmapFileMaterial = null;
					var m:TriangleMaterial = material_rows[Math.floor(j/subtile)][Math.floor(i/subtile)];
					if(debug) {
						trace("QUAD ("+v1.x+","+v1.y+","+v1.z+") ("+v2.x+","+v2.y+","+v2.z+") ("+v3.x+","+v3.y+","+v3.z+") ("+v4.x+","+v4.y+","+v4.z+")" );
					}
					f1 = new Triangle3D(this,[v1,v2,v3],m,[uv1,uv2,uv3]);
					f2 = new Triangle3D(this,[v3,v4,v1],m,[uv3,uv4,uv1]);
					myfaces.push(f1);
					myfaces.push(f2);
					facetotal++;
				}
			}
			if( debug ) trace("wms: total number of faces " + facetotal );
		}

		//
		// apply the geometry to papervision3d
		//
		public function finalize_geometry():void {
			this.geometry.ready = false;
			this.materials = mymaterials;
			this.geometry.vertices = vertices;
			this.geometry.faces = myfaces;
			this.geometry.ready = true;
		}

		//
		// set a new focus
		//
		public var old_latitude:Number = -1;
		public var old_longitude:Number = -1;
		public var old_zoom:Number = -1;
		public var old_left:Number = 0;
		public var old_right:Number = 0;
		public var old_top:Number = 0;
		public var old_bottom:Number = 0;
		public function focus(latitude:Number,longitude:Number,zoom:Number):void {
			this.zoom = zoom;
			// hack; fix coordinate system later TODO
			latitude = -latitude;
			longitude = -longitude;
			this.latitude = latitude;
			this.longitude = longitude;
			if( (latitude != old_latitude || longitude != old_longitude || zoom != old_zoom) ) {
				// there has been sufficient change to rebuild the sphere state.
				if( debug ) {
					trace("WMSLayer: rebuilding at longitude and latitude " + latitude + " " + longitude + " and zoom " + zoom );
				}
				old_latitude = latitude;
				old_longitude = longitude;
				old_zoom = zoom;
				set_surface(surface);
				set_lon_and_lat_and_zoom(longitude,latitude,zoom);
				set_vendor();
				set_tile_extents();
				if( old_left != left || old_right != right || old_top != top || old_bottom != bottom ) {
					old_left = left;
					old_right = right;
					old_top = top;
					old_bottom = bottom;
					make_vertices();
					make_uv();
					make_materials();
					make_polygons();
					finalize_geometry();
				}
			}
		}
		public function WMSLayer(surface_radius:Number):void {
			this.surface = surface_radius;
			super(null,new Array(),new Array(),null);
		}
	}
}

