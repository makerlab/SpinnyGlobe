package org.makerlab {

	import org.papervision3d.core.*;

	import org.papervision3d.core.proto.*;

	import org.papervision3d.core.geom.*;

	import org.papervision3d.materials.*;

	public class PolyLine extends Mesh3D {

		private function vertices_new_Vertex3D(v:Array,x:Number,y:Number,z:Number):Vertex3D {

			var t:Vertex3D = new Vertex3D(x,y,z);

			v.push(t);

			return t;

		}

		public function PolyLine(x1,y1,z1,x2,y2,z2):void {

/*

			super( null, new Array(), new Array(), null, null );



			var vertex_rows:Array = new Array();

			var vertices:Array = new Array();



x3 = x2-x1

y3 = y2-y1

z3 = z2-z1



x4 = x3 / 10

y4 = y3 / 10

z4 = z3 / 10



x2 = x1

y2 = y1

z2 = z1



loop 10 times



	x2 = x2 + x4;

	y2 = y2 + y4;

	z1 = z2 + z4;



	draw from

		x1,y1,z1 to x2,y2,z2

	end



end

	  

					y = -surface*Math.cos(rad1*Math.PI);		// might as well calculate y now

					t = surface*Math.sin(rad1*Math.PI);			// convenience

					x = surface/wwidth*(i/subtile*tilegw-(wwidth/2));	// scale to scale size and center

					y = surface/wheight*(j/subtile*tilegh-(wheight/2))*tileratio;					v = new Vertex3D(x,y,z);

					vertices.push(v);

			this.geometry.ready = false;

			this.materials = materials;

			this.geometry.vertices = vertices;

			this.geometry.faces = faces;

			this.geometry.ready = true;

 		}

*/

		

	}

}

