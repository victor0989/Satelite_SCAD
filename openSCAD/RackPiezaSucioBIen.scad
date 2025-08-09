// Parámetros rack
NumRackUnits = 42;
unitHeight = 44.45; // 1U estándar en mm (1.75 inch)
RackWidth = 800;
RackDepth = 1200;
RackHeight = NumRackUnits * unitHeight;
RackFrameThickness = 10;

RackColor = [0.6, 0.6, 0.6];
FloatLabelColorTitle = [0,0,0];

floorLevelTitle = "Empty Rack from settings file";
rackTopTitle1 = "Rack A";
rackTopTitle2 = "Rack B";

LabelT = [0,0,0]; // posición label default

// Parámetro animación (variable $t para mostrar estado de animación)
$t = 0; // 0 o 1 según animación

// Define Positions on DC Floor
RowOffset0 = [400, 600, 0];
Rack1 = [RackWidth*0, 0, 0] + RowOffset0;
Rack2 = [RackWidth*1, 0, 0] + RowOffset0;

// invisible rack for optional animation (pop out)
Rack1A = [RackWidth*0, -RackDepth*$t, 0] + RowOffset0;
Rack2A = [RackWidth*1, -RackDepth*$t, 0] + RowOffset0;

// invisible rack for optional animation (pop in)
Rack1B = [RackWidth*0, (RackDepth*($t)) - RackDepth, 0] + RowOffset0;
Rack2B = [RackWidth*1, (RackDepth*($t)) - RackDepth, 0] + RowOffset0;

// Función para texto simple
module floatLabel(text, col, size=20, pos=[0,0,0]) {
    color(col)
    translate(pos)
        linear_extrude(height = 1)
            text(text, size=size, halign="center", valign="center");
}

// Función rack frame (caja hueca)
module rackFrame(width, height, depth, thickness) {
    color(RackColor)
    difference() {
        cube([width, depth, height]);
        translate([thickness, thickness, thickness])
            cube([width - 2*thickness, depth - 2*thickness, height - thickness]);
    }
}

// Posicionar un rack con etiqueta y color
module positionRack(pos, width, height, depth, thickness, color_, title, sidebarInfo) {
    translate(pos)
        rackFrame(width, height, depth, thickness);
    translate([width/2, depth/2, height + 20])
        floatLabel(title, FloatLabelColorTitle, 40, [-width/4, 0, 0]);
    // sidebarInfo se puede usar para añadir más elementos si quieres
}

// Módulo logo vacío para no dar error
module logo() {
    // aquí podrías poner un diseño simple o dejar vacío
    // por ejemplo, un cubo pequeño representando el logo:
    color([0,0,1])
    cube([50,20,2]);
}

// Renderiza todo

translate([0,0,-0.5]) logo();

translate([300, 50, -10]) floatLabel(floorLevelTitle, FloatLabelColorTitle, 60, LabelT);

RackBSidebarInfoON = true;
RackASidebarInfoON = false;

positionRack(Rack1, RackWidth, RackHeight, RackDepth, RackFrameThickness, RackColor, rackTopTitle1, RackASidebarInfoON);
positionRack(Rack2, RackWidth, RackHeight, RackDepth, RackFrameThickness, RackColor, rackTopTitle2, RackBSidebarInfoON);



