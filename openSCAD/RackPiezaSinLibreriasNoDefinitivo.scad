// Parámetros básicos
rackWidth = 80;   // Ancho del rack (cm o mm según escala)
rackDepth = 120;  // Profundidad
rackHeight = 200; // Altura total (e.g. 42U * altura unidad)
unitHeight = 4.445; // Altura estándar de 1U en mm (~1.75 pulgadas = 44.45mm, aquí escala reducida)

rackWallThickness = 2;

// Colores
rackColor = [0.6, 0.6, 0.6];
deviceColor = [0.2, 0.2, 0.8];
cableGuideColor = [0.8, 0.5, 0.2];
patchPanelColor = [0.1, 0.7, 0.1];
shelfColor = [0.5, 0.3, 0.7];

// Módulo: rack base
module rack() {
    color(rackColor)
    difference() {
        // Caja del rack exterior
        cube([rackWidth, rackDepth, rackHeight]);
        // Hueco interior (paredes)
        translate([rackWallThickness, rackWallThickness, rackWallThickness])
            cube([rackWidth - 2*rackWallThickness, rackDepth - 2*rackWallThickness, rackHeight]);
    }
}

// Módulo: dispositivo (posición en U, altura en U, profundidad)
module device(u_pos, u_height=1, depth=100, col=deviceColor) {
    color(col)
    translate([rackWallThickness, rackWallThickness, u_pos * unitHeight])
        cube([rackWidth - 2*rackWallThickness, depth, u_height * unitHeight - 0.5]);
}

// Módulo: cable guide
module cable_guide(u_pos) {
    device(u_pos, 1, rackDepth - 10, cableGuideColor);
}

// Módulo: patch panel
module patch_panel(u_pos) {
    device(u_pos, 1, rackDepth - 30, patchPanelColor);
}

// Módulo: shelf
module shelf(u_pos, thickness=4) {
    color(shelfColor)
    translate([rackWallThickness, rackWallThickness, u_pos * unitHeight])
        cube([rackWidth - 2*rackWallThickness, rackDepth - 10, thickness]);
}

// Ensamblaje rack con dispositivos
rack();

// Dispositivos rack 1
device(0, 1);
device(1, 1);
device(2, 7);
device(9, 2);
device(11, 1);
device(12, 1);
device(13, 1);
shelf(14);
device(15, 1);
device(16, 1);
device(17, 1);
device(19, 1);
device(20, 1);
device(21, 1);
device(23, 1);
device(24, 1);
device(37, 1);
patch_panel(38);
patch_panel(39);
cable_guide(40);
cable_guide(41);

// Puedes añadir otro rack desplazando en X o Y

translate([rackWidth + 20, 0, 0]) {
    rack();

    // Dispositivos rack 2
    device(0, 1);
    device(1, 1);
    device(2, 7);
    device(9, 2);
    device(11, 1);
    device(15, 1);
    device(19, 1);
    device(20, 1);
    device(23, 1);
    device(37, 1);
    patch_panel(38);
    patch_panel(39);
    cable_guide(40);
    cable_guide(41);
}



