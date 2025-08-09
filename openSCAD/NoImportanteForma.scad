// =======================================================
// Satélite Compacto - Estilo basado en tu código original
// Autor: Víctor Alonso García
// Fecha: 2025-08-09
// =======================================================

// --- Parámetros principales ---
body_radius = 20;          // Radio del cuerpo central
body_height = 40;          // Altura del cuerpo
antenna_length = 35;       // Longitud de la antena
antenna_radius = 1.5;      // Grosor de la antena
panel_width = 35;          // Ancho del panel solar
panel_height = 18;         // Alto del panel solar
panel_thickness = 1.8;     // Grosor del panel solar

// =======================================================
// Módulo principal
// =======================================================
module satellite_compact() {
    union() {
        body();
        antennas();
        solar_panels();
    }
}

// =======================================================
// Cuerpo central
// =======================================================
module body() {
    color("silver")
    cylinder(h = body_height, r = body_radius, center = true);
}

// =======================================================
// Antenas (superior e inferior)
// =======================================================
module antennas() {
    color("gray")
    union() {
        translate([0,0,body_height/2])
            cylinder(h = antenna_length, r = antenna_radius, center = false);

        translate([0,0,-(body_height/2 + antenna_length)])
            cylinder(h = antenna_length, r = antenna_radius, center = false);
    }
}

// =======================================================
// Paneles solares (izquierda y derecha)
// =======================================================
module solar_panels() {
    color("blue")
    union() {
        translate([body_radius + panel_thickness/2, 0, 0])
            cube([panel_thickness, panel_width, panel_height], center = true);

        translate([-body_radius - panel_thickness/2, 0, 0])
            cube([panel_thickness, panel_width, panel_height], center = true);
    }
}

// =======================================================
// Llamada al modelo
// =======================================================
satellite_compact();
