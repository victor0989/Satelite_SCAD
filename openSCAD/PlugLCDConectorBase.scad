$fn=100;

// Variables para PCB y componentes
diffWiggle = 0.2; // pequeña diferencia para restar sobre bordes
PCB1306holeD = 2;
PCB1306holeOff = [2, 2, 0];
PCB1306Z = 1.7;
PCB1306X = 26.9;
PCB1306Y = 27.9;
PCB1306 = [PCB1306X, PCB1306Y, PCB1306Z];

// Componentes superiores LCD
LCDmaskY = 4; // cuánto cubrir en la parte inferior
LCDX = 27.5;
LCDY = 20;
LCDZ = 2;
LCDflexX = 13;
LCDflexY = 3;
LCD = [LCDX, LCDY, LCDZ];
LCDpos = [0, 0, PCB1306[2]];
LCDviewPos = [0, LCDmaskY/2, PCB1306[2]];
LCDmask = [LCD[0], LCDmaskY, LCD[2]];
LCDmaskPos = [0, -LCD[1]/2 + LCDmask[1]/2, LCDpos[2]];
LCDview = [LCD[0], LCD[1] - LCDmask[1], LCD[2]];
LCDflex = [LCDflexX, LCDflexY, LCD[2]];
LCDflexPos = [0, -LCD[1]/2 - LCDflex[1]/2, PCB1306[2]];

// Array de objetos para capas
extrudeFalse = false;
extrudeTrue = true;
object = [
    [PCB1306, [0, 0, 0], "green", extrudeFalse],
    [LCDview, LCDviewPos, "black", extrudeTrue],
    [LCDflex, LCDflexPos, "brown", extrudeTrue],
    [LCDmask, LCDmaskPos, "grey", extrudeTrue]
];

// Módulo para pines de montaje
module pegs(XYZ, offset, holeD) {
    H = XYZ[2];
    XY = [XYZ[0], XYZ[1], 0];
    
    TR = [ [+1, 0, 0], [0, +1, 0], [0, 0, 0] ];
    TL = [ [-1, 0, 0], [0, +1, 0], [0, 0, 0] ];
    BR = [ [+1, 0, 0], [0, -1, 0], [0, 0, 0] ];
    BL = [ [-1, 0, 0], [0, -1, 0], [0, 0, 0] ];
    
    // Calculamos posiciones con vectores y offset
    posTR = [ (TR[0][0]*XY[0]/2 + offset[0]*BL[0][0]), (TR[1][1]*XY[1]/2 + offset[1]*BL[1][1]), 0 ];
    posTL = [ (TL[0][0]*XY[0]/2 + offset[0]*BR[0][0]), (TL[1][1]*XY[1]/2 + offset[1]*BR[1][1]), 0 ];
    posBR = [ (BR[0][0]*XY[0]/2 + offset[0]*TL[0][0]), (BR[1][1]*XY[1]/2 + offset[1]*TL[1][1]), 0 ];
    posBL = [ (BL[0][0]*XY[0]/2 + offset[0]*TR[0][0]), (BL[1][1]*XY[1]/2 + offset[1]*TR[1][1]), 0 ];

    translate(posTR) cylinder(h = H, d = holeD, center = true);
    translate(posTL) cylinder(h = H, d = holeD, center = true);
    translate(posBR) cylinder(h = H, d = holeD, center = true);
    translate(posBL) cylinder(h = H, d = holeD, center = true);
}

// Módulo para capas de ladrillos (cubos con color)
module brickLayer(array) {
    module blocks(list) {
        translate(list[1]) color(list[2]) cube(list[0], center = true);
    }
    for (i = [0 : len(array) - 1]) {
        blocks(array[i]);
    }
}

// Salida
difference(){
    brickLayer(object);
    pegs(PCB1306 + [0, 0, diffWiggle], PCB1306holeOff, PCB1306holeD);
}





