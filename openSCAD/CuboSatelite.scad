module vectorBox(){
    //just a small demonstrator for vector subtraction and addition
    // as things can get complicated with single unit variables the below shows
 //how it can be abstracted and simplified
    //inside side length
    inSize = 10 ;
    //wall thickness
    wallThick = .5;
    //the vectors predefined
    inSizeA = [inSize,inSize,inSize] ;
    inSizeX = [inSize,0,0] ;
    inSizeY = [0,inSize,0] ;
    inSizeZ = [0,0,inSize] ;
    offset = wallThick * 2 ;
    offsetA = [offset,offset,offset] ;
    offsetX = [offset,0,0] ;
    offsetY = [0,offset,0] ;
    offsetZ = [0,0,offset] ;
    offsetZY = offsetZ + offsetY ;
    offsetZX = offsetZ + offsetX ;
    offsetXY = offsetX + offsetY ;
    diffWiggle = .1 ;
    diffWiggleY = [0,diffWiggle,0] ;
    difference() {
        //total volume cube
        cube(inSizeA + offsetA);
        //inside volume cube
        translate((offsetZX)/2 - diffWiggleY/2) 
            cube(inSizeA + offsetY + diffWiggleY);
    }
 }
 vectorBox();