// OPENSCA Model for enclosure for Tine's table
// Currently 3 devices: Waatuino, 3.3v to 5v level shifter, and ESP Wemos D1 Mini
$fn = 100;
wiggle = 0.01;

// Wemos D1 Mini (26mm x 35mm, height 7mm)
module wemos() {
    difference() {
        union() {
            cube([26, 35, 10]);                       // Main board
            translate([9, 32, 0]) cube([10, 5, 5]);   // USB port area
        }
        // Side slots
        translate([3, 5, -wiggle]) cube([1, 20, 3 + wiggle]);
        translate([21, 5, -wiggle]) cube([1, 20, 3 + wiggle]);
    }
}

// Voltage level shifter (14mm x 16mm, height 7mm)
module v5v3() {
    union() {
        difference() {
            cube([14, 16, 10]);
            translate([3, 3, -wiggle]) cube([8, 10, 3 + wiggle]);  // Inner cutout
        }
        translate([4, 4, 0]) cube([6, 8, 3 + wiggle]);            // Inner block
    }
}

// Blanker module (14mm x 18mm, height 10mm)
module blanker() {
    cube([14, 18, 10]);
}

// Wattuino (Arduino 5V clone 22mm x 32mm, height 7mm)
module wattuino() {
    union() {
        difference() {
            cube([19, 34, 10]);
            translate([2.5, 4, -wiggle]) cube([14, 26, 3 + wiggle]);
        }
        translate([3.5, 5, 0]) cube([12, 24, 3 + wiggle]);
    }
}

// Outer casing (63mm x 37mm x 10mm)
module casing() {
    cube([63, 37, 10]);
}

// Cabling boom (50mm x 8mm x 3mm)
module cabling() {
    cube([50, 8, 3.01]);
}

// Enclosure assembly
module enclosure() {
    difference() {
        casing();
        translate([1, 1, 1]) wemos();
        translate([28, 1, 1]) v5v3();
        translate([43, 1, 1]) wattuino();
        translate([28, 18, 1]) blanker();
        translate([7, 7, 7]) cabling();
    }
}

enclosure();



