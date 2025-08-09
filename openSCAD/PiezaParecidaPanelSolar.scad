/* [Base] */
//type = 1; //[1:"Hexagon Grid",2:"Skeleton"]

/* [Hidden] */
$fn = 32;
zero_x = 64;
zero_y = 29;
zero_z = 1.5;
mounts_z = 8.5;
mounts_radius = 2.1;
screwholes = 2.6;
screwholes_radius = 1.5;
screwholes_depth = 10.7;

base_x = zero_x - 2 * 3.0;
base_y = zero_y - 2 * 3.0;
base_z = zero_z;
mount_x = zero_x / 2 - screwholes;
mount_y = zero_y / 2 - screwholes;
mount_z = zero_z + mounts_z;
screwhole_base_z = mount_z - screwholes_depth;

// Base principal
module baseplate() {
    translate([-zero_x / 2 + 3, -zero_y / 2 + 3, 0])
        minkowski() {
            cube([base_x, base_y, base_z / 2]);
            cylinder(r = 3.0, h = base_z / 2);
        }
}

// Monturas
module mounts() {
    translate([0, 0, 0]) cylinder(r = 3.0, h = mount_z);
    translate([-mount_x, -mount_y, 0]) cylinder(r = mounts_radius, h = mount_z);
    translate([-mount_x, +mount_y, 0]) cylinder(r = mounts_radius, h = mount_z);
    translate([+mount_x, -mount_y, 0]) cylinder(r = mounts_radius, h = mount_z);
    translate([+mount_x, +mount_y, 0]) cylinder(r = mounts_radius, h = mount_z);
}

// Hexágonos
module hexagon(radius = 8, latticeWidth = 8, latticeLength = 16, spacing = 1, height = 2) {
    linear_extrude(height) {
        for (j = [0 : latticeWidth - 1]) {
            translate([
                ((sqrt(3) * radius) + spacing) / 2 * (j % 2),
                sqrt(pow((sqrt(3) * radius) + spacing, 2) - pow(((sqrt(3) * radius) + spacing) / 2, 2)) * j,
                0
            ]) {
                for (i = [0 : latticeLength - 1]) {
                    translate([(sqrt(3) * radius * i) + spacing * i, 0, 0]) {
                        rotate([0, 0, 30]) circle(radius, $fn = 6);
                    }
                }
            }
        }
    }
}

// Contorno hexagonal
module hex_border() {
    difference() {
        baseplate();
        holes();
        translate([0, 0, -0.01]) scale([0.9, 0.8, 1.02]) baseplate();
    }
}

// Agujeros de montaje
module holes() {
    translate([0, 0, screwhole_base_z + 0.4]) {
        translate([0, 0, 0]) cylinder(r = screwholes_radius * 1.5, h = screwholes_depth);
        translate([-mount_x, -mount_y, 0]) cylinder(r = screwholes_radius, h = screwholes_depth);
        translate([-mount_x, +mount_y, 0]) cylinder(r = screwholes_radius, h = screwholes_depth);
        translate([+mount_x, -mount_y, 0]) cylinder(r = screwholes_radius, h = screwholes_depth);
        translate([+mount_x, +mount_y, 0]) cylinder(r = screwholes_radius, h = screwholes_depth);
    }
}

// Resultado principal
module result() {
    difference() {
        translate([-2.5, -base_y / 2, 0]) cube([5, base_y, base_z]);
        translate([0, 10, -3]) cylinder(d = 1.5, h = 10);
        translate([0, -10, -3]) cylinder(d = 1.5, h = 10);
        holes();
    }
    translate([0, 0, 0]) hex_border();
    difference() {
        translate([0, 0, 0]) cylinder(r = 3.0, h = mount_z);
        holes();
    }
    difference() {
        mounts();
        holes();
    }
    difference() {
        baseplate();
        holes();
        translate([-zero_x / 2 - 5, -zero_y / 2 + 1.5, -0.1]) hexagon();
    }
}

// Cuerpo final
difference() {
    result();
    translate([0, 10, -3]) cylinder(d = 1.5, h = 10);
    translate([0, -10, -3]) cylinder(d = 1.5, h = 10);
}
