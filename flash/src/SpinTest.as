package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.utils.*;
	import flash.display.BitmapData;
	import flash.events.Event;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

/*
	public class SpinTest extends BasicView {
		protected var world:Sphere;
		protected var worldBitmapData:BitmapData;
		protected var worldMaterial:BitmapMaterial;
		public function SpinTest() {
			super(1, 1, true, false);
			opaqueBackground = 0;
			initScene();
			startRendering();
		}
		protected function initScene():void {
			worldBitmapData = new BitmapData(512,256,false,0);
			worldBitmapData.perlinNoise(512,256,4, 123456, true,false);
			worldMaterial = new BitmapMaterial(worldBitmapData);
			world = new Sphere(worldMaterial,300, 10,10);
			scene.addChild(world);
		}
		override protected function onRenderTick(event:Event=null):void {
			world.yaw(1);
			super.onRenderTick(event);
		}
	}

*/

public class SpinTest extends Sprite {

public function SpinTest() {
this.x = 10;
this.y = 10;

this.graphics.beginFill(0x00FF00);
this.graphics.drawRect( -13, -13, 26, 26);
this.graphics.endFill();

this.graphics.beginFill(0x00FF00);
this.graphics.drawCircle(0, 0, 15);
this.graphics.endFill();

this.setTime(5);
}

public function setTime(time:Number):void {
var intervalId:uint = setInterval(step, time);
}

public function step():void {
this.rotation += 3;
}

}


}
