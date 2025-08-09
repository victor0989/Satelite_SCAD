cam_width = 23.7;
cam_depth = 23.1;
cam_height = 23.1 + 0.3;
corner_radius = 2;
lip_width = 5.1; // metal radiator & separator
shell_thickness = 1;
screw_cylinder_diameter = 8;
lens_width_height = 19;

lens_corner_radius = 5;
ridge_from_lens = 3.7 + 0.5;
ridge_thickness = 1 - 0.2;

// OpenScad examples
button_width = 14.6 + 1;
button_depth = 4.8;
button_height = shell_thickness + 1; // false, just for the hole
button_from_lens = 11.3 - 4.5 + 0.1;

sd_depth = 3.1;
sd_height = 18.9;
sd_width = 12;
sd_from_lens = 10.75;

screw_from_lens = 23;

battery_length = 65 + 10 + 5;
spring_diameter = 8;
battery_height = battery_length + screw_cylinder_diameter;

screw_cylinder_inner_length = cam_width - shell_thickness * 2;

bay = battery_height;
sil = screw_cylinder_inner_length;

cx = cam_width;   // SD & USB
cy = cam_depth + bay; // lens & screw
cz = cam_height;  // buttons

cr = corner_radius;
lw = lip_width;
st = shell_thickness;
sc = screw_cylinder_diameter;

ix = cx - st * 2;
iy = cy - st * 2;
iz = cz - st * 2;

lxy = lens_width_height;
lc = lens_corner_radius;

ry = ridge_from_lens + 0.1;
rt = ridge_thickness;

bx = button_width;
by = button_depth;
bz = button_height;
bl = button_from_lens;

sd = sd_depth;
sh = sd_height;
sl = sd_from_lens;
sw = sd_width;
sfl = screw_from_lens;
spd = spring_diameter;

$fn = 30;

// Módulos:

module hull_from_cube(x, y, z, r) {
    hull() {
        translate([r, r, r]) sphere(r = r);
        translate([x - r, r, r]) sphere(r = r);
        translate([r, y - r, r]) sphere(r = r);
        translate([x - r, y - r, r]) sphere(r = r);
        translate([r, r, z - r]) sphere(r = r);
        translate([x - r, r, z - r]) sphere(r = r);
        translate([r, y - r, z - r]) sphere(r = r);
        translate([x - r, y - r, z - r]) sphere(r = r);
    }
}

module sensor_hull() {
    hull() {
        translate([0, st, 0]) {
            translate([lc, 0, lc]) sphere(r = lc);
            translate([lxy - lc, 0, lc]) sphere(r = lc);
            translate([lxy - lc, 0, lxy - lc]) sphere(r = lc);
            translate([lc, 0, lxy - lc]) sphere(r = lc);
        }
    }
}

module button_hole() {
    difference() {
        cube([bx, by, bz], center = true);
        difference() {
            cube([bx + 1, by - st, bz + 1], center = true);
            cube([lw + 1, by - st + 1, bz + 2], center = true);
        }
    }
}

module sd_hole() {
    union() {
        difference() {
            cube([st * 2, sd, sh]);
            translate([-0.5, -0.5, sh - sw + 0.01])
                cube([st * 2 + 1, sd + 1, sw + 1]);
        }
        translate([0, 0.5, sh - sw])
            cube([st * 2, sd + 1, sw]);
    }
}

module ridge() {
    translate([0, ry, 0])
        difference() {
            translate([st, 0, st])
                cube([sil, rt, cz - st * 2]);
            translate([(cx - lw) / 2, -ry, 0])
                cube([lw, ry * 2, cz]);
            translate([-1, -1, cr])
                cube([cx + 2, rt + 2, cz - cr * 2]);
        }
}

module full_screw_hole() {
    translate([0, 0, cx])
        rotate([0, 180, 0])
            screwhole(cx / 2);
    rotate([0, 0, 30])
        translate([0, 0, cx / 2 + 2])
            rotate([0, 180, 0])
                nuthole(cx / 2);
}

module screwhole(wz) {
    cylinder(d = 3.2, h = wz + 1);
    translate([0, 0, -0.01])
        cylinder(d = 6, h = 3.5);
}

module nuthole(wz) {
    union() {
        translate([0, 0, -0.5])
            cylinder(d = 3.2, h = wz + 1);
        nd = 5.5 + 0.15;
        nh = 2.4 + 3;
        translate([0, 0, wz - nh + 0.1 + 3])
            cylinder(d = nd + 0.9, h = nh, $fn = 6);
    }
}

// Parte principal

rotate([0, 180, 0]) // <------------------ se puede comentar si quieres rotar la pieza
intersection() {
    translate([0, 0, cx / 2]) // <------------ se puede comentar si quieres mover la pieza
        cube([cz, cy * 2, cx / 2]);

    translate([cz, 0, 0])
        rotate([0, -90, 0]) {
            difference() {
                hull_from_cube(cx, cy, cz, cr);
                translate([st, st, st])
                    hull_from_cube(ix, iy, iz, cr);
                translate([(cx - lw) / 2, 0, 0])
                    cube([lw, cy - bay, cz]); // middle cut 
                translate([cx / 2,  bl + by / 2, cz - st / 2 - 0.01])
                    button_hole();
                translate([-st / 2, sl, (cz - sh) / 2])
                    sd_hole();
                translate([0, sfl, sc / 2 + st])
                    rotate([0, 90, 0])
                        full_screw_hole();
                translate([0, sfl, cz - (sc / 2 + st)])
                    rotate([0, 90, 0])
                        full_screw_hole();
                translate([0, cy - (sc / 2 + st), sc / 2 + st])
                    rotate([0, 90, 0])
                        full_screw_hole();
                translate([0, cy - (sc / 2 + st), cz - (sc / 2 + st)])
                    rotate([0, 90, 0])
                        full_screw_hole();
                ridge();
                translate([0, sfl + sc / 2 + 1, 0])
                    difference() {
                        translate([st, 0, st])
                            cube([sil, rt, cz - st * 2]);
                        translate([st + (sil) / 2, st, st + (cz - st * 2) / 2])
                            rotate([90, 0, 0])
                                cylinder(d = spd, h = rt * 2);
                        translate([st, -rt / 2, (sil - 2) / 2])
                            cube([cz - st * 2, rt * 2, 4]);
                    }
                translate([0, cy - (sc + st + rt + 1), 0])
                    difference() {
                        translate([st, 0, st])
                            cube([sil, rt, cz - st * 2]);
                        translate([st + (sil) / 2, st, st + (cz - st * 2) / 2])
                            rotate([90, 0, 0])
                                cylinder(d = spd, h = rt * 2);
                        translate([st, -rt / 2, (sil - 2) / 2])
                            cube([cz - st * 2, rt * 2, 4]);
                    }
            }
        }
}
