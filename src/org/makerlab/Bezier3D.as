package org.makerlab {

	// line
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.special.LineMaterial;

	public class Bezier3D {

		private var _lines:Array;
		public var _instance:Lines3D;
		private var _material:LineMaterial;

		public function Bezier3D(color:Number, size:Number, segments:int, start:Vertex3D, end:Vertex3D, control:Vertex3D) {
			this._material = new LineMaterial(color,0.5);
			this._instance = new Lines3D(this._material);
			this.size = size;
			this.segments = segments;
			this.start = start;
			this.end = end;
			this.control = control;
			rebuild();
		}

		private var _size:Number = 1;
		public function get size():Number {
			return _size;
		}

		public function set size(value:Number):void {
			if(value == _size) return;
			_size = value;
		}
	   
		private var _segments:int = 10;
		public function get segments():int {
			return _segments;
		}
		public function set segments(value:int):void {
			if(value == _segments) return;
			_segments = Math.max(1, value);
		}
	   
		private var _start:Vertex3D;
		public function get start():Vertex3D {
			return _start;
		}
		public function set start(value:Vertex3D):void {
			if(value === _start) return;
			_start = value;
		}
	   
		private var _end:Vertex3D;
		public function get end():Vertex3D {
			return _end;
		}
		public function set end(value:Vertex3D):void {
			if(value === _end) return;
			_end = value;
		}
	   
		private var _control:Vertex3D;
		public function get control():Vertex3D {
			return _control;
		}
		public function set control(value:Vertex3D):void {
			if(value === _control) return;
			_control = value;
		}
	   
		public function rebuild():void {
			clear();
			build();
		}
	   
		public function clear():void {
			if(_lines && _lines.length) {
				var c_len:int = _lines.length;
				for(var i:int=0; i<c_len; i++) _instance.removeLine(_lines[i]);
			}
			_lines = [];
		}

		private function build():void {
			var c_seg:Number, c_dseg:Number, c_sqdseg:Number, c_dbseg:Number, c_pseg:Number;
			for(var i:int=0; i<_segments; i++) {
				c_seg = i / _segments;
				c_dseg = 1 - c_seg;
				c_sqdseg = c_dseg * c_dseg;
				c_dbseg = 2 * c_seg * c_dseg;
				c_pseg = c_seg * c_seg;
				
				var c_p1:Vertex3D = new Vertex3D();
				c_p1.x = c_sqdseg * _start.x + c_dbseg * _control.x + c_pseg * _end.x;
				c_p1.y = c_sqdseg * _start.y + c_dbseg * _control.y + c_pseg * _end.y;
				c_p1.z = c_sqdseg * _start.z + c_dbseg * _control.z + c_pseg * _end.z;
				
				c_seg = (i+1) / _segments;
				c_dseg = 1 - c_seg;
				c_sqdseg = c_dseg * c_dseg;
				c_dbseg = 2 * c_seg * c_dseg;
				c_pseg = c_seg * c_seg;
				
				var c_p2:Vertex3D = new Vertex3D();
				c_p2.x = c_sqdseg * _start.x + c_dbseg * _control.x + c_pseg * _end.x;
				c_p2.y = c_sqdseg * _start.y + c_dbseg * _control.y + c_pseg * _end.y;
				c_p2.z = c_sqdseg * _start.z + c_dbseg * _control.z + c_pseg * _end.z;
				
				var c_line:Line3D = new Line3D(_instance, _material, _size, c_p1, c_p2);
				_lines.push(c_line);
				_instance.addLine(c_line);
			}
		}
	}
}