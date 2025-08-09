/*
 Parametric Schuko CEE 7/3 socket
 Copyright 2017 Anders Hammarquist <iko@iko.pp.se>
 Licensed under Creative Commons - Attribution - Share Alike
 Made using a negative "profile punch" that can be extracted
 and used to "punch" a schuko socket into any sufficiently large solid.
*/

// Diameter of cover
coverdiameter = 50; // [50:100]
// Thickness of cover
coverthickness = 4.8; // [2:0.2:15]
// Center screw offset (extreme values disables screw hole)
screwoffset = 0; // [-11:0.5:11]

// This is the socket punch. Includes cut-out for earthing contacts and holes for pins and center screw.
module schuko(screwoffset=0, screwdia=3.5, screwhead=6.5, screwsink=3) {
    module earthing() {
        intersection() {
            union() {
                translate([-22, -2, 3])
                    cube([6, 4, 20]);
                translate([-19, -2, 17.5])
                    rotate([0, -30, 0])
                        cube([15, 4, 4]);
            }
            translate([-22, -3, 3])
                cube([22, 6, 20]);
        }
    }

    difference() {
        union() {
            // Main socket cylinder
            translate([0, 0, -1])
                cylinder(r=39/2, $fn=300, h=18.5);

            // Earthing cutouts
            color([1, 1, 1]) {
                earthing();
                rotate([0, 0, 180]) earthing();
            }

            // Power pins
            translate([0, 10, 0])
                cylinder(r=7/2, $fn=300, h=30);
            translate([0, -10, 0])
                cylinder(r=7/2, $fn=300, h=30);

            // Center screw hole
            if (abs(screwoffset) <= 10) {
                translate([screwoffset, 0, 0])
                    cylinder(r=screwdia/2, $fn=300, h=30);
                translate([screwoffset, 0, 0])
                    cylinder(r=screwhead/2, $fn=300, h=17.5 + screwsink);
            }
        }

        // Side key profile
        translate([5.4/2, 16.9, 3]) cube([7, 3, 20]);
        translate([-5.4/2 - 7, 16.9, 3]) cube([7, 3, 20]);
        translate([5.4/2, -20.4, 3]) cube([7, 3.5, 20]);
        translate([-5.4/2 - 7, -20.4, 3]) cube([7, 3.5, 20]);
    }
}

// Main difference block (housing + socket punch)
difference() {
    // Outer housing
    difference() {
        cylinder(r=39/2, $fn=300, h=17.5);
        translate([-27.3/2, -27.8/2, 0]) cube([27.3, 27.8, 10]);
    }

    // Housing + lip + pin guard
    rotate([0, 0, 0]) {
        difference() {
            union() {
                // Outer lip
                translate([0, 0, 0])
                    cylinder(r=44/2, $fn=300, h=21.5);

                // Lip with polygon extrusion
                rotate_extrude($fn=100) {
                    polygon(points=[
                        [0, 0],
                        [coverdiameter/2, 0],
                        [coverdiameter/2 + 0.2 * coverthickness, coverthickness],
                        [0, coverthickness]
                    ]);
                }

                // Pin guard: 9.5 x 28.5 x 3mm (rounded ends)
                translate([-4.75, -14.25, 21.5]) cube([9.5, 28.5, 3]);

                // Center screw standoffs
                translate([-7.25, -3, 21.5]) cube([2.5, 6, 5.5]);
                translate([4.75, -3, 21.5]) cube([2.5, 6, 5.5]);
            }
            schuko(screwoffset=screwoffset);
        }
    }
}







