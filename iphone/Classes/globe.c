///////////////////////////////////////////////////////////////////////////////
// modified to be a globe by anselm@hook.org from andrew willmotts gltest.cpp
// see http://www.typhoonlabs.com/tutorials/gles/Tutorial3.pdf
////////////////////////////////////////////////////////////////////////////////

#define NDEBUG

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>

#include "earth.h"
#include "globe.h"
#include "arcball.h"

///////////////////////////////////////////////////////////////////////////////////
// get texture 
////////////////////////////////////////////////////////////////////////////////////

GLuint texture[1];
extern GLuint texture_earth[];
void BuildGLTextures() {
    int w = 256;
    int h = 128;
    char* data = (char*)texture_earth;
    glGenTextures(1,&texture[0]);
    glBindTexture(GL_TEXTURE_2D,texture[0]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,w,h,0,GL_RGB,GL_UNSIGNED_BYTE,data);
};

///////////////////////////////////////////////////////////////////////////////////
// draw stuff 
////////////////////////////////////////////////////////////////////////////////////

GLfloat colors[] = {
	1,0,0,1,
	0,1,0,1,
	0,0,1,1,
};

GLfloat glvertices[] = {
	0,0,0,
	0,0,0,
	0,0,0,
	0,0,0
};

GLfloat gltextures[] = {
	0,0,
	0,0,
	0,0,
	0,0,
};

int is_flat=0;
float surface=1;
float zoom=0;
float longitude=0;
float latitude=0;
int pw=512;
int ph=512;
int tilepw=256;
int tileph=128;

void draw_thing() {

	// size of world
	float wwidth = 360.0;
	float wheight = 180.0;

	// what is the world space tile ratio?
	int tileratio = tileph/tilepw;

	// how many tiles would we like to use to tile the world at this zoom?
	int tiles = (int)pow(2,zoom);

	// how big are the tiles in world space?
	float tilegw = wwidth/tiles;
	float tilegh = wheight/tiles;

	// get a positive tile index
	int tilex = (int)round((longitude+(wwidth/2))/tilegw);
	int tiley = (int)round((latitude+(wheight/2))/tilegh);
	
	// pick a patch that defines the visible mesh extent at the chosen point... can wraparound axes.
	int LT = (tilex-(int)round(pw/tilepw/2));
	int RT = (tilex+(int)round(pw/tilepw/2));
	int TP = (tiley-(int)round(ph/tileph/2));
	int BT = (tiley+(int)round(ph/tileph/2));

	// hack: due to wraparound at low zoom just show the whole planet as one tile
	if(zoom < 4) {
		tiles = 1;
		tilex = 0;
		tiley = 0;
		LT = 0;
		RT = 1;
		TP = 0;
		BT = 1;
	}

	// decide on an integer subtiling regimen to provide a nice sense of curvature for the mesh
	int subtile = (is_flat || tiles > 16 ) ? 1 : ((int)ceil(16/tiles));

	// make vertices for the mesh; as a series of horizontal strings of vertices
	//float m = 0;
	int i;
	int j;
	float x;
	float y;
	float z = 0;
	float t;
	float rad1;
	float rad2;
	float *v;
	int vertex_row_length = (RT-LT)*subtile+1;
	int vertex_rows_total = (BT-TP)*subtile+1;
	int vertices_length = vertex_row_length * vertex_rows_total * 3;
	GLfloat vertices[vertices_length];
	//int test = 0;
	//if(test){glBegin(GL_POINTS);}
	for(j=0;j<vertex_rows_total;j++) {							// visit vertical range of subtile EDGES
		if(!is_flat) {
			rad1 = 1.0f*(j+TP)/(tiles*subtile);					// fractional degree along the arc of latitude
			y = -surface*cos(rad1*3.14159265f);					// might as well calculate y now
			t = surface*sin(rad1*3.14159265f);					// convenience
		}
		v = 0;													// reset vertex to deal with poles
		for(i=0;i<vertex_row_length;i++) {						// visit horizontal range of subtile EDGES!
			if(is_flat) {
				x = surface/wwidth*((i+LT)/subtile*tilegw-(wwidth/2));// scale to scale size and center
				y = surface/wheight*((j+TP)/subtile*tilegh-(wheight/2))*tileratio;
			} else {
				rad2 = 2.0f*(i+LT)/(tiles*subtile);				// fractional degree along arc of longitude
				x = -t*sin(rad2*3.14159265f);
				z = t*cos(rad2*3.14159265f);
			}
			// optional optimization
			//if(is_flat==0 && (rad1==0||rad1>=1 && v!=null) {  // only one vertex at pole
			//  TODO should really enable this to prevent seams but it requires tracking vertex_rows...
			//} else
			{
				vertices[(j*vertex_row_length+i)*3+0] = x;
				vertices[(j*vertex_row_length+i)*3+1] = y;
				vertices[(j*vertex_row_length+i)*3+2] = z;
				//if(test){glColor3f(m*2,1.0f,1.0f);glVertex3f(x+m,y+m,z+m); m = m + 0.001; }
			}
		}
	}
	//if(test){glEnd();return;}

	/*
	 // make textures
	 var key:String;
	 var m:BitmapFileMaterial;
	 var materials:MaterialsList = new MaterialsList();
	 var material_row:Array;
	 var material_rows:Array = new Array();
	 for(j=TP;j<BT;j++) {							// visit vertical major tiles range
	 material_row = new Array();
	 material_rows.push(material_row);
	 for(i=LT;i<RT;i++) {							// visit horizontal major tiles range
	 key = wmsurl
	 + "&WIDTH="+tilepw
	 + "&HEIGHT="+tileph
	 + "&BBOX="
	 + (i*tilegw-(wwidth/2))					// degrees right of prime meridian
	 + ","
	 + (j*tilegh-(wheight/2))				// degrees south of north pole
	 + ","
	 + (i*tilegw+tilegw-(wwidth/2))			// width
	 + ","
	 + (j*tilegh+tilegh-(wheight/2))			// height
	 ;
	 m = new BitmapFileMaterial(key);
	 m.doubleSided = 0;
	 m.smooth = 1;
	 materials.addMaterial(m,key);
	 material_row.push(key);
	 }
	 }
	 */
	// make an idealized uv subdivision of a tile
	float uv_rows[(subtile+1)*(subtile+1)*2];
	for(j=0;j<=subtile;j++) {							// visit vertical subrange EDGES
		for(i=0;i<=subtile;i++) {						// visit horizontal subrange EDGES
			uv_rows[(j*subtile+j+i)*2+0]=1.0f*i/subtile;
			uv_rows[(j*subtile+j+i)*2+1]=1.0f*j/subtile;
		}
	}
	
	
	// make polygons
	// TODO: fix: note that there will be a seam in the case of a sphere due to lazy closure on wrap
	/*
	 var v1:Vertex3D;
	 var v2:Vertex3D;
	 var v3:Vertex3D;
	 var v4:Vertex3D;
	 var uv1UV;
	 var uv2UV;
	 var uv3UV;
	 var uv4UV;
	 var f1:Face3D;
	 var f2:Face3D;
	 var faces:Array = new Array();
	 */

	GLuint faces[(vertex_rows_total-1)*(vertex_row_length-1)];

	//glBegin(GL_QUADS);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,texture[0]);

	for(j=0;j<vertex_rows_total-1;j++) {				// visit vertical range of tiles
		for(i=0;i<vertex_row_length-1;i++) {				// visit horizontal range of tiles
			
			/*
			 v1 = vertex_rows[j][i];
			 v2 = vertex_rows[j][i+1];
			 v3 = vertex_rows[j+1][i+1];
			 v4 = vertex_rows[j+1][i];
			 uv1 = uv_rows[j%subtile+0][i%subtile+0];
			 uv2 = uv_rows[j%subtile+0][i%subtile+1];
			 uv3 = uv_rows[j%subtile+1][i%subtile+1];
			 uv4 = uv_rows[j%subtile+1][i%subtile+0];
			 f1 = new Face3D(new Array(v1,v2,v3), null, new Array(uv1,uv2,uv3));
			 f2 = new Face3D(new Array(v3,v4,v1), null, new Array(uv3,uv4,uv1));
			 f1.materialName = material_rows[Math.floor(j/subtile)][Math.floor(i/subtile)];
			 f2.materialName = material_rows[Math.floor(j/subtile)][Math.floor(i/subtile)];
			 faces.push(f1);
			 faces.push(f2);
			 */
			
			x = vertices[(j*vertex_row_length+i)*3+0];
			y = vertices[(j*vertex_row_length+i)*3+1];
			z = vertices[(j*vertex_row_length+i)*3+2];
			glvertices[0*3+0]=x;glvertices[0*3+1]=y;glvertices[0*3+2]=z;
			gltextures[0*2+0]= uv_rows[((j%subtile)*(subtile+1)+(i%subtile))*2+0];
			gltextures[0*2+1]= uv_rows[((j%subtile)*(subtile+1)+(i%subtile))*2+1];
			faces[0]=j*vertex_row_length+i;
			
			x = vertices[(j*vertex_row_length+i+1)*3+0];
			y = vertices[(j*vertex_row_length+i+1)*3+1];
			z = vertices[(j*vertex_row_length+i+1)*3+2];
			glvertices[1*3+0]=x;glvertices[1*3+1]=y;glvertices[1*3+2]=z;
			gltextures[1*2+0]= uv_rows[((j%subtile)*(subtile+1)+(i%subtile+1))*2+0];
			gltextures[1*2+1]= uv_rows[((j%subtile)*(subtile+1)+(i%subtile+1))*2+1];
			faces[1]=j*vertex_row_length+i+1;
			
			x = vertices[(j*vertex_row_length+vertex_row_length+i)*3+0+3];
			y = vertices[(j*vertex_row_length+vertex_row_length+i)*3+1+3];
			z = vertices[(j*vertex_row_length+vertex_row_length+i)*3+2+3];
			glvertices[2*3+0]=x;glvertices[2*3+1]=y;glvertices[2*3+2]=z;
			gltextures[2*2+0]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile+1))*2+0];
			gltextures[2*2+1]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile+1))*2+1];
			faces[2]=j*vertex_row_length+vertex_row_length+i+1;
			
			x = vertices[(j*vertex_row_length+vertex_row_length+i)*3+0];
			y = vertices[(j*vertex_row_length+vertex_row_length+i)*3+1];
			z = vertices[(j*vertex_row_length+vertex_row_length+i)*3+2];
			glvertices[3*3+0]=x;glvertices[3*3+1]=y;glvertices[3*3+2]=z;
			gltextures[3*2+0]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile))*2+0];
			gltextures[3*2+1]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile))*2+1];
			faces[3]=j*vertex_row_length+vertex_row_length+i;
			
			// xxx todo remove - i threw this in because i can't get glDrawElements() below to behave...
			// basically i'm just flipping the vertex pair so i can use a triangle strip
			x = vertices[(j*vertex_row_length+vertex_row_length+i)*3+0];
			y = vertices[(j*vertex_row_length+vertex_row_length+i)*3+1];
			z = vertices[(j*vertex_row_length+vertex_row_length+i)*3+2];
			glvertices[2*3+0]=x;glvertices[2*3+1]=y;glvertices[2*3+2]=z;
			gltextures[2*2+0]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile))*2+0];
			gltextures[2*2+1]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile))*2+1];
			faces[2]=j*vertex_row_length+vertex_row_length+i+1;
			
			x = vertices[(j*vertex_row_length+vertex_row_length+i)*3+0+3];
			y = vertices[(j*vertex_row_length+vertex_row_length+i)*3+1+3];
			z = vertices[(j*vertex_row_length+vertex_row_length+i)*3+2+3];
			glvertices[3*3+0]=x;glvertices[3*3+1]=y;glvertices[3*3+2]=z;
			gltextures[3*2+0]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile+1))*2+0];
			gltextures[3*2+1]= uv_rows[((j%subtile+1)*(subtile+1)+(i%subtile+1))*2+1];
			faces[3]=j*vertex_row_length+vertex_row_length+i;
			
			glTexCoordPointer(2,GL_FLOAT,0,gltextures);
			if(0) {
				// fails???
				glVertexPointer(3,GL_FLOAT,0,vertices);
				glDrawElements(GL_TRIANGLES,1,GL_FIXED,faces);
			} else {
				glVertexPointer(3,GL_FLOAT,0,glvertices);
				glDrawArrays(GL_TRIANGLE_STRIP,0,4);
			}
		}
	}
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	
	/*
	 // apply geometry
	 this.geometry.ready = 0;
	 this.materials = materials;
	 this.geometry.vertices = vertices;
	 this.geometry.faces = faces;
	 this.geometry.ready = 1;
	 */
}

void draw_anything() {
	GLfloat triVertices[] = { 
		0.0f, 1.0f, 0.0f, 
		-1.0f, -1.0f, 0.0f, 
		1.0f, -1.0f, 0.0f 
	}; 
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, triVertices);
	glDrawArrays(GL_TRIANGLES, 0, 3);
}

///////////////////////////////////////////////////////////////////////////////////
//  more boring things
////////////////////////////////////////////////////////////////////////////////////

/*
public function WMSLayer(wmsurl, is_flat:Boolean=0,scale=1000,zoom=0):void {
		this.wmsurl = wmsurl;
		if(!this.wmsurl) {
		//this.wmsurl = "http://civicmaps.org/tom/tilecache-1.4/tilecache.cgi?LAYERS=basic&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&EXCEPTIONS=application%2Fvnd.ogc.se_inimage&SRS=EPSG%3A4326"
		this.wmsurl = "http://civicmaps.org/cgi-bin/mapserv?map=/www/sites/maps.civicactions.net/maps/world.map&service=WMS&WMTVER=1.0.0&REQUEST=map&SRS=EPSG:4326&LAYERS=bluemarble,landsat7,lakes,rivers,cities,majorroads,minorroads,tiger_polygon,tiger_landmarks,tiger_lakes,tiger_local_roads,tiger_major_roads,lowboundaries,boundaries,coastlines&FORMAT=image/jpeg&STYLES=&TRANSPARENT=TRUE"
		}
		this.is_flat = is_flat;
		super( null, new Array(), new Array(), null, null );
		rebuild(is_flat,scale,zoom);
	}
	}
}
*/

static int initialized = 0;

float* globe_event(int event,int x,int y,int w, int h) {

    if(!initialized) {
		BuildGLTextures();
		ArcBall_initialize(w,h);
		initialized = 1;

		glViewport(0, 0, w, h);

		// we're moving the camera; so setup the view based on that philosophy
		// http://www.sjbaker.org/steve/omniv/projection_abuse.html
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrthof(-1, 1, -1, 1, -1, 1);
	}

	float* mat = ArcBall_update(x,y,(event == GLOBE_MOUSEDRAG || event == GLOBE_MOUSEDOWN ) ? 1 : 0);
	
	if(event == GLOBE_UPDATE) {

		glClearColor(0.0f, 0.5f, 0.5f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	

		// move the camera; also move it back 1 unit so we are not inside the globe
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glTranslatef(0,0,1);
		glMultMatrixf(mat);

		draw_thing();

		return mat;
	}

}

