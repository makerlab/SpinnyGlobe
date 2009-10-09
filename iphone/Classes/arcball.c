
#include "math.h"
#include "arcball.h"

// ********************************
// ARCBALL STATE 
// ******************************** 

Vector3fT   StVec;          //Saved click vector
Vector3fT   EnVec;          //Saved drag vector
GLfloat     AdjustWidth;    //Mouse bounds width
GLfloat     AdjustHeight;   //Mouse bounds height

Matrix4fT   Transform   = {  1.0f,  0.0f,  0.0f,  0.0f,
                             0.0f,  1.0f,  0.0f,  0.0f,
                             0.0f,  0.0f,  1.0f,  0.0f,
                             0.0f,  0.0f,  0.0f,  1.0f };

Matrix3fT   LastRot     = {  1.0f,  0.0f,  0.0f,
                             0.0f,  1.0f,  0.0f,
                             0.0f,  0.0f,  1.0f };

Matrix3fT   ThisRot     = {  1.0f,  0.0f,  0.0f,
                             0.0f,  1.0f,  0.0f,
                             0.0f,  0.0f,  1.0f  };

int isDragging = 0;
Point2fT MousePt;

//Arcball sphere constants:
//Diameter is       2.0f
//Radius is         1.0f
//Radius squared is 1.0f

// ********************************
// ARCBALL LOGIC
// ******************************** 

void setBounds(GLfloat NewWidth, GLfloat NewHeight) {
   assert((NewWidth > 1.0f) && (NewHeight > 1.0f));
   AdjustWidth  = 1.0f / ((NewWidth  - 1.0f) * 0.5f);
   AdjustHeight = 1.0f / ((NewHeight - 1.0f) * 0.5f);
}

void ArcBall_mapToSphere(Point2fT* NewPt, Vector3fT* NewVec)  {
    Point2fT TempPt;
    GLfloat length;

    //Copy paramter into temp point
    TempPt = *NewPt;

    //Adjust point coords and scale down to range of [-1 ... 1]
    TempPt.s.X  =        (TempPt.s.X * AdjustWidth)  - 1.0f;
    TempPt.s.Y  = 1.0f - (TempPt.s.Y * AdjustHeight);

    //Compute the square of the length of the vector to the point from the center
    length      = (TempPt.s.X * TempPt.s.X) + (TempPt.s.Y * TempPt.s.Y);

    //If the point is mapped outside of the sphere... (length > radius squared)
    if (length > 1.0f)
    {
        GLfloat norm;

        //Compute a normalizing factor (radius / sqrt(length))
        norm    = 1.0f / MyFuncSqrt(length);

        //Return the "normalized" vector, a point on the sphere
        NewVec->s.X = TempPt.s.X * norm;
        NewVec->s.Y = TempPt.s.Y * norm;
        NewVec->s.Z = 0.0f;
    }
    else    //Else it's on the inside
    {
        //Return a vector to a point mapped inside the sphere sqrt - length)
        NewVec->s.X = TempPt.s.X;
        NewVec->s.Y = TempPt.s.Y;
        NewVec->s.Z = MyFuncSqrt(1.0f - length);
    }
}

//Create/Destroy
void ArcBall_initialize(int NewWidth, int NewHeight) {
    //Clear initial values
    StVec.s.X     =
    StVec.s.Y     = 
    StVec.s.Z     = 
    EnVec.s.X     =
    EnVec.s.Y     = 
    EnVec.s.Z     = 0.0f;

    //Set initial bounds
    setBounds( 1.0f * NewWidth, 1.0f * NewHeight);
}

void ArcBall_click(Point2fT* NewPt)
{
    //Map the point to the sphere
    ArcBall_mapToSphere(NewPt, &StVec);
}

void ArcBall_drag(Point2fT* NewPt, Quat4fT* NewRot)
{
    //Map the point to the sphere
    ArcBall_mapToSphere(NewPt, &EnVec);

    //Return the quaternion equivalent to the rotation
    if (NewRot)
    {
        Vector3fT  Perp;

        //Compute the vector perpendicular to the begin and end vectors
        Vector3fCross(&Perp, &StVec, &EnVec);

        //Compute the length of the perpendicular vector
        if (Vector3fLength(&Perp) > Epsilon)    //if its non-zero
        {
            // return the perpendicular vector as the transform after all
            NewRot->s.X = Perp.s.X;
            NewRot->s.Y = Perp.s.Y;
            NewRot->s.Z = Perp.s.Z;
            // w is cosine (theta / 2), where theta is rotation angle
            NewRot->s.W= Vector3fDot(&StVec, &EnVec);
        }
        else                                    //if its zero
        {
            //begin and end vectors coincide, so return an identity transform
            NewRot->s.X = 
            NewRot->s.Y = 
            NewRot->s.Z = 
            NewRot->s.W = 0.0f;
        }
    }
}

float* ArcBall_update(int x,int y,int down) {
    Quat4fT q;
    MousePt.s.X = x;
    MousePt.s.Y = y;
    if (!down) {
        isDragging = 0;
    }
    else if(!isDragging) {
        isDragging = 1;
        LastRot = ThisRot;
        ArcBall_click(&MousePt);
    }
    else {
        ArcBall_drag(&MousePt,&q);
        Matrix3fSetRotationFromQuat4f(&ThisRot, &q);
        Matrix3fMulMatrix3f(&ThisRot, &LastRot);
        Matrix4fSetRotationFromMatrix3f(&Transform, &ThisRot);
    }
    return (float*)&Transform;
}

