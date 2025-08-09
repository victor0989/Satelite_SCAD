$fn = 100;

height = 19; // total height to top rim
plugTopD = 42; // diameter of top cover
plugTopH = 2; // 2mm rim height of top cover
plugTopOff = 16.8; // from bottom to top rim

diffWiggle = 0.2;
diffWiggleA = [diffWiggle, diffWiggle, diffWiggle];
diffWiggleX = [diffWiggle, 0, 0];
diffWiggleY = [0, diffWiggle, 0];
diffWiggleZ = [0, 0, diffWiggle];

plugBottomD = 38;
plugBottomH = plugTopOff;
plugSideCutH = 3;
plugSideCutW = 5;

zdiff = [0, 0, -diffWiggle/2];
cutCubeHeight = 8;
cubeXY = plugBottomD - (plugSideCutH + 9);
cubeFloor = 2;
pinR = 9.5; // distance from center for 220v power pins

// ssd1306 variables
ssd1306X = 26.9;
ssd1306Y = 27.9;
ssd1306off = [2, 2, 0];
ssd1306XY = [ssd1306X, ssd1306Y, 0];
ssd1306PCBH = 1.7;
ssd1306PCBZ = [0, 0, ssd1306PCBH];
ssd1306PCBdim = [ssd1306XY[0], ssd1306XY[1], ssd1306PCBZ[2]];
ssd1306mountD = 2;

LCDX = 27.5; // left to right
LCDY = 20;   // topR to bottomR
LCDZ = 2;    // height from PCB
LCDflexW = 13; // flex cable width
LCDflexH = 3;  // flex cable length from LCD to edge
LCDmask = 4;   // how much to cover up at the bottom

LCDdim = [LCDX, LCDY, LCDZ];
FLEXdim = [LCDflexW, LCDflexH, LCDdim[2]];
LCDdimXY = [LCDX, LCDY, 0];

// Module for mounting holes (pegs)
module pegs(XYdimensions, offset, height, diameter) {
    TR = [[+1, 0, 0], [0, +1, 0], [0, 0, 0]];
    TL = [[-1, 0, 0], [0, +1, 0], [0, 0, 0]];
    BR = [[+1, 0, 0], [0, -1, 0], [0, 0, 0]];
    BL = [[-1, 0, 0], [0, -1, 0], [0, 0, 0]];

    // Calculate positions manually because OpenSCAD doesn't support vector * vector
    mPosTR = [ (TR[0][0] * XYdimensions[0]/2) + (offset[0] * BL[0][0]),
               (TR[1][1] * XYdimensions[1]/2) + (offset[1] * BL[1][1]),
               0 ];
    mPosTL = [ (TL[0][0] * XYdimensions[0]/2) + (offset[0] * BR[0][0]),
               (TL[1][1] * XYdimensions[1]/2) + (offset[1] * BR[1][1]),
               0 ];
    mPosBR = [ (BR[0][0] * XYdimensions[0]/2) + (offset[0] * TL[0][0]),
               (BR[1][1] * XYdimensions[1]/2) + (offset[1] * TL[1][1]),
               0 ];
    mPosBL = [ (BL[0][0] * XYdimensions[0]/2) + (offset[0] * TR[0][0]),
               (BL[1][1] * XYdimensions[1]/2) + (offset[1] * TR[1][1]),
               0 ];

    translate(mPosTR) cylinder(h=height, d=diameter, center=true);
    translate(mPosTL) cylinder(h=height, d=diameter, center=true);
    translate(mPosBR) cylinder(h=height, d=diameter, center=true);
    translate(mPosBL) cylinder(h=height, d=diameter, center=true);
}

// Module for SSD1306 device
module ssd1306(PCBdim, LCDdim, FLEXdim, PCBwiggle, LCDwiggle) {
    difference() {
        union() {
            // PCB
            translate([0, 0, PCBdim[2]/2]) color("green") cube([PCBdim[0] + PCBwiggle[0], PCBdim[1] + PCBwiggle[1], PCBdim[2] + PCBwiggle[2]], center=true);
            // LCD
            translate([0, 0, PCBdim[2] + LCDdim[2]/2]) color("black") cube([LCDdim[0] + LCDwiggle[0], LCDdim[1] + LCDwiggle[1], LCDdim[2] + LCDwiggle[2]], center=true);
            // FLEX cable
            translate([0, -LCDdim[1]/2 - FLEXdim[1]/2, PCBdim[2] + FLEXdim[2]/2]) color("brown") cube(FLEXdim, center=true);
        }
        translate([0, 0, PCBdim[2]/2]) pegs(ssd1306XY, ssd1306off, PCBdim[2] + diffWiggle, 2);
    }
}

// Module for PCB (with resizing)
module PCB(resize) {
    difference() {
        cube([ssd1306XY[0] + resize[0], ssd1306XY[1] + resize[1], ssd1306PCBH + resize[2]], center=true);
        pegs(ssd1306XY, ssd1306off, ssd1306PCBH + diffWiggle, ssd1306mountD);
    }
}

// Module for ssd1306 harness
module ssd1306Harness(resize) {
    pegD = 1.7;
    pegH = 5;
    pegZ = [0, 0, pegH];
    difference() {
        PCB(resize);
        cube([22, 22, diffWiggle] + ssd1306PCBZ, center=true);
        translate([0, 12, 0]) cube([15, 3, diffWiggle] + ssd1306PCBZ, center=true);
        translate([0, 0, 0]) cube([25, 6, diffWiggle] + ssd1306PCBZ, center=true);
    }
    translate([0, 0, pegH/2 + ssd1306PCBH/2]) pegs(ssd1306XY, ssd1306off, pegH, pegD);
}

// Module for top cover
module cover() {
    coverThick = 0.5;
    rimH = 1.5;
    viewportThick = 0.5;
    rimThick = 1;
    union() {
        translate([0, 0, coverThick/2]) difference() {
            // top cover cylinder
            cylinder(h=coverThick, d=plugTopD, center=true);
            // LCD assumed centered
            cube([LCDdimXY[0], LCDdimXY[1], coverThick + diffWiggle], center=true);
            // flex cable
            translate([0, -LCDY/2 - LCDflexH/2 + diffWiggle, 0])
                cube([LCDflexW, LCDflexH + diffWiggle, coverThick + diffWiggle], center=true);
            // subtract mounting holes
            pegs(ssd1306XY, ssd1306off, coverThick + diffWiggle, ssd1306mountD + 0.3);
        }
    }
}

// Module for plug
module plug() {
    difference() {
        union() {
            difference() {
                // Plug cylinder
                cylinder(h=plugBottomH, d=plugBottomD, center=true);
                
                // Cut guide left and right
                cutOffTR = [ (plugBottomD/2) - plugSideCutH, plugSideCutW/2, 0];
                cutOffTL = [ ((plugBottomD/2) + plugSideCutH) + plugSideCutH, plugSideCutW/2, 0];
                cutOffBR = [ (plugBottomD/2) - plugSideCutH, -(plugSideCutW/2), cutCubeHeight];
                cutOffBL = [ -((plugBottomD/2) + plugSideCutH) + plugSideCutH, plugSideCutW/2 - cutCubeHeight, 0];
                cutCubeSize = [plugSideCutH, cutCubeHeight, plugBottomH + diffWiggle];
                
                translate(cutOffTR + zdiff) cube(cutCubeSize, center=false);
                translate(cutOffTL + zdiff) cube(cutCubeSize, center=false);
                translate(cutOffBR + zdiff) cube(cutCubeSize, center=false);
                translate(cutOffBL + zdiff) cube(cutCubeSize, center=false);
            }
            // add top rim
            translate([0, 0, plugTopOff]) cylinder(h=plugTopH, d=plugTopD, center=true);
        }
        // cube cutout for inner volume
        translate([0, 0, height/2 + cubeFloor]) cube([cubeXY, cubeXY, height], center=true);
        
        // punch holes for cabling where 220v power pins should be
        translate([pinR, 0, 0]) translate(zdiff) cylinder(h=cubeFloor + diffWiggle, d=6, center=true);
        translate([-pinR, 0, 0]) translate(zdiff) cylinder(h=cubeFloor + diffWiggle, d=6, center=true);
        
        // make room for the PCB
        translate([0, 0, plugTopOff + 1]) PCB([1, 1, 0]);
        translate([0, 0, plugTopOff + 2]) PCB([1, 1, 0]);
    }
    // add in the harness
    translate([0, 0, plugTopOff - 0.7]) ssd1306Harness([-1, -1, 0]);
}

// OUTPUT
plug();
translate([0, 0, 25]) ssd1306(ssd1306PCBdim, LCDdim, FLEXdim, [0, 0, 0], [0, 0, 0]);
translate([0, 0, 33]) cover();






