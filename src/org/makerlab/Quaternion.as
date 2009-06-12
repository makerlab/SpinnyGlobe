package org.makerlab {

	import flash.geom.Matrix;

	import org.papervision3d.core.math.*;

	// http://yamasv.blog92.fc2.com/blog-date-200708.html

	public class Quaternion{

		public var _w:Number;

		public var _x:Number;

		public var _y:Number;

		public var _z:Number;



		public function Quaternion(w:Number=1, v:Number3D=null){

			_w = w;

			if(v != null){

				_x = v.x;

				_y = v.y;

				_z = v.z;

			} else {

				_x = 0;

				_y = 0;

				_z = 0;

			}

		}

		public function reset():void {

			_w = 1;

			_x = 0;

			_y = 0;

			_z = 0;

		}

		/*

		 * 

		 */

		public static function rotateQuaternion(r:Number, v:Number3D):Quaternion{

			var q:Quaternion = new Quaternion();

			var s:Number = Math.sin(r/2.0);

			q._w = Math.cos(r/2.0);

			q._x = v.x * s;

			q._y = v.y * s;

			q._z = v.z * s;

			return q;

		}

		/*

		 * 

		 */

		public function multiplScalar(s:Number):Quaternion{

			var q:Quaternion = new Quaternion();

			q._w = _w * s;

			q._x = _x * s;

			q._y = _y * s;

			q._z = _z * s;

			return q;

		}

		/*

		 * 積を返す

		 */

		public function multiply(o:Quaternion):Quaternion{

			var q:Quaternion = new Quaternion();

			q._w = _w * o._w - _x * o._x - _y * o._y - _z * o._z;

			q._x = _y * o._z - _z * o._y + _w * o._x + _x * o._w;

			q._y = _z * o._x - _x * o._z + _w * o._y + _y * o._w;

			q._z = _x * o._y - _y * o._x + _w * o._z + _z * o._w;

			return q;

		}

		/*

		 * 

		 */

		public function mul(j:Quaternion,o:Quaternion):void{

			_w = j._w * o._w - j._x * o._x - j._y * o._y - j._z * o._z;

			_x = j._y * o._z - j._z * o._y + j._w * o._x + j._x * o._w;

			_y = j._z * o._x - j._x * o._z + j._w * o._y + j._y * o._w;

			_z = j._x * o._y - j._y * o._x + j._w * o._z + j._z * o._w;

		}

		/*

		 * 

		 */

		public function add(rhs:Quaternion):Quaternion{

			var q:Quaternion = new Quaternion();

			q._w = _w + rhs._w;

			q._x = _x + rhs._x;

			q._y = _y + rhs._y;

			q._z = _z + rhs._z;

			return q;

		}

		/*

		 * 共役クォータニオンを返す 

		 */

		public function conjugation():Quaternion{

			var q:Quaternion = new Quaternion();

			q._w = _w ;

			q._x = -_x ;

			q._y = -_y ;

			q._z = -_z ;

			return q;

		}



		public function to_mat():Matrix3D {

			var m:Matrix3D = new Matrix3D();

			// from ggraphic gems iv - ken shoemake's arcball rotation controller

			var nq:Number = _x*_x + _y*_y + _z*_z + _w*_w;

			var  s:Number = (nq>0.0) ? (2.0/nq) : 0.0 ;

			var xs:Number = _x * s ,  ys:Number = _y * s,	zs:Number = _z * s;

			var wx:Number = _w * xs,  wy:Number = _w * ys,	wz:Number = _w * zs;

			var xx:Number = _x * xs,  xy:Number = _x * ys,	xz:Number = _x * zs;

			var yy:Number = _y * ys,  yz:Number = _y * zs,	zz:Number = _z * zs;

			m.n11 = 1.0-(yy+zz);

			m.n12 = xy+wz;

			m.n13 = xz-wy;

			m.n21 = xy-wz;

			m.n22 = 1.0-(xx+zz);

			m.n23 = yz + wx;

			m.n31 = xz + wy;

			m.n32 = yz - wx;

			m.n33 = 1.0-(xx+yy);

			return m;

		}



		public function convert2Matrix3D():Matrix3D{

			var m:Matrix3D = new Matrix3D();

			var sx:Number = _x * _x;

			var sy:Number = _y * _y;

			var sz:Number = _z * _z;

			var cx:Number = _y * _z;

			var cy:Number = _x * _z;

			var cz:Number = _x * _y;

			var wx:Number = _w * _x;

			var wy:Number = _w * _y;

			var wz:Number = _w * _z;

			m.n11 = 1.0 - 2.0 * (sy + sz);

			m.n12 = 2.0 * (cz + wz);

			m.n13 = 2.0 * (cy - wy);

			m.n21 = 2.0 * (cz - wz);

			m.n22 = 1.0 - 2.0 * (sx + sz);

			m.n23 = 2.0 * (cx + wx);

			m.n31 = 2.0 * (cy + wy);

			m.n32 = 2.0 * (cx - wx);

			m.n33 = 1.0 - 2.0 * (sx + sy);

			return m;

		}



		public function get w():Number{

			return _w;

		}



		public function get x():Number{

			return _x;

		}



		public function get y():Number{

			return _y;

		}



		public function get z():Number{

			return _z;

		}



		public function set w(v:Number):void{

			_w = v;

		}



		public function set x(v:Number):void{

			_x = v;

		}



		public function set y(v:Number):void{

			_y = v;

		}



		public function set z(v:Number):void{

			_z = v;

		}

		public function set(v:Quaternion):void{

			_w = v._w;

			_x = v._x;

			_y = v._y;

			_z = v._z;

		}

		public function set2(v:Number,z:Number3D):void{

			_w = v;

			_x = z.x;

			_y = z.y;

			_z = z.z;

		}

	}

}

