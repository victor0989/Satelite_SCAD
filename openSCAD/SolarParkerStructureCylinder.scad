$fn=120;

// =====================
// MÓDULOS PRINCIPALES
// =====================

// Core del satélite
module satelliteCore(h=120, d=40) {
    color("silver")
    cylinder(h=h, d=d);
}

// Escudo térmico
module heatShield(d=80, thickness=5) {
    color("lightgray")
    difference() {
        cylinder(h=thickness, d=d);
        translate([0,0,-0.1]) cylinder(h=thickness+0.2, d=d-8);
    }
}

// Panel solar modular
module solarPanel(width=40, height=2, length=80) {
    color("blue")
    cube([length, width, height], center=true);
}

// Brazo para instrumentos
module instrumentArm(length=30, d=4) {
    color("gray")
    rotate([90,0,0])
    cylinder(h=length, d=d);
}

// Propulsor iónico
module ionThruster(d=12, h=20) {
    color("darkgray")
    union() {
        cylinder(h=h, d=d);
        translate([0,0,h]) cylinder(h=5, d1=d, d2=d/2);
    }
}

// =====================
// ENSAMBLADO DEL SATÉLITE
// =====================
module satellite() {
    // Core
    satelliteCore();

    // Heat Shield (frontal)
    translate([0,0,120]) heatShield();

    // Paneles solares (4 direcciones)
    for (angle=[0:90:270]) {
        rotate([0,0,angle])
        translate([40,0,60]) solarPanel();
    }

    // Brazos para instrumentos
    for (angle=[45:90:360]) {
        rotate([0,0,angle])
        translate([25,0,80]) instrumentArm();
    }

    // Propulsores iónicos en la base
    for (angle=[0:120:360]) {
        rotate([0,0,angle])
        translate([20,0,0]) ionThruster();
    }
}

satellite();



