package org.makerlab {
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.*;	
	import flash.utils.Dictionary;
	public class Billboard extends TriangleMesh3D {
		public var myvertices:Array;	
		public function Billboard(xyz:Vertex3D, name:String=null, initObject:Object=null ) {
				super( null, new Array(), new Array(), null );
				this.geometry.ready = true;
				this.myvertices = new Array();
				this.myvertices.push(xyz);
				this.geometry.vertices = new Array();
				this.geometry.vertices.push(new Vertex3D(xyz.x,xyz.y,xyz.z));
		}
	}
}

/*

also see

http://sleepydesign.com/labs/as3/PaperVision3D/GreatWhite/DisplayObject2D/src/DisplayObject2D.as
 
-----------------------------------------------------------------
//Creation of particle
-----------------------------------------------------------------
var myBitmap : BitmapData = new BitmapData(100, 50, false, 0x0000FF);
var pointSpriteMaterial : ParticleMaterial = new
BitmapParticleMaterialSprite(myBitmap);
 
materialsList = new MaterialsList();   
materialsList.addMaterial(pointSpriteMaterial, "pointSprite"); 
 
particles = new Particles();
particles.addParticle(new
Particle(ParticleMaterial(materialsList.getMaterialByName("pointSprite"))));
 
scene.addChild(particles, "particles");
 
-----------------------------------------------------------------
//BitmapParticleMaterialSprite
-----------------------------------------------------------------
package org.papervision3d.materials.special
{
 import flash.display.BitmapData;
 import flash.display.Graphics;
 import flash.geom.Matrix;
 
 import org.papervision3d.core.geom.renderables.Particle;
 import org.papervision3d.core.render.data.RenderSessionData;
 import org.papervision3d.core.render.draw.IParticleDrawer;
 
 public class BitmapParticleMaterialSprite extends ParticleMaterial
implements IParticleDrawer
 {
  
  private var scaleMatrix:Matrix;
  
  public function BitmapParticleMaterialSprite(bitmap:BitmapData)
  {
   super(0,0);
   this.bitmap = bitmap;
   this.scaleMatrix = new Matrix();
  }
  
  override public function drawParticle(particle:Particle,
graphics:Graphics, renderSessionData:RenderSessionData):void
  {
   scaleMatrix.a = particle.renderScale;
   scaleMatrix.d = particle.renderScale; 
   scaleMatrix.tx = particle.vertex3D.vertex3DInstance.x;
   scaleMatrix.ty = particle.vertex3D.vertex3DInstance.y;
   graphics.beginBitmapFill(bitmap, scaleMatrix, false, smooth);
   graphics.drawRect(particle.vertex3D.vertex3DInstance.x,
particle.vertex3D.vertex3DInstance.y,particle.renderScale*bitmap.width,parti
cle.renderScale*bitmap.height);
   graphics.endFill();
   renderSessionData.renderStatistics.particles++;
  }
  
 }
}
 
*/
