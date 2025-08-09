// Modding the shaft to fit the joysticks
// Load the shaft as reference
#translate([0,0,35]) import("shaft.stl");
$fn=100;

// Points for placing test cylinders
points = [
    [0,0,0],
    [20,0,0],
    [0,0,26],
    [20,0,26]
];

module draw_object() {
    rotate([90,0,0]) cylinder(h=8,d=1.5);  // Replace with your desired object
}

// Place test cylinders at points
translate([-8.5,-6,22.9]) for (p = points)
    translate(p) draw_object();

translate([-9.5,-6,21.8]) rotate([90,0,0]) cube([22,28,1]);

// =============================
// 2020 Extrusion Profiles
// =============================

// Creates a 2D 2020 Extrusion Profile
module extrusion_profile(slot = "t", fillet=0.5, square_size=20, inner_circle_radius=2.5, inner_circle_opening=11, outer_circle_opening=6.2, channel_depth=6.1, lip_depth=1.8, left_open=false, right_open=false, upper_open=false, lower_open=false, outer_square_base=true) {
    if (outer_square_base) {
        difference() {
            outer_square_with_fillet(fillet, square_size);
            extrusion_cuts(slot, fillet, square_size, inner_circle_radius, inner_circle_opening, outer_circle_opening, channel_depth, lip_depth, left_open, right_open, upper_open, lower_open);
        }
    } else {
        extrusion_cuts(slot, fillet, square_size, inner_circle_radius, inner_circle_opening, outer_circle_opening, channel_depth, lip_depth, left_open, right_open, upper_open, lower_open);
    }
}

module outer_square_with_fillet(fillet, square_size) {
    hull() {
        translate([-square_size/2+fillet, -square_size/2+fillet]) circle(fillet);
        translate([ square_size/2-fillet, -square_size/2+fillet]) circle(fillet);
        translate([ square_size/2-fillet,  square_size/2-fillet]) circle(fillet);
        translate([-square_size/2+fillet,  square_size/2-fillet]) circle(fillet);
    }
}

module extrusion_cuts(slot, fillet, square_size, inner_circle_radius, inner_circle_opening, outer_circle_opening, channel_depth, lip_depth, left_open=false, right_open=false, upper_open=false, lower_open=false) {
    inner_circle_opening_fn(inner_circle_radius);

    rotate([0,0,0])   slot_opening(slot, fillet, channel_depth, square_size, outer_circle_opening, inner_circle_opening, lip_depth, upper_open);
    rotate([0,0,90])  slot_opening(slot, fillet, channel_depth, square_size, outer_circle_opening, inner_circle_opening, lip_depth, left_open);
    rotate([0,0,180]) slot_opening(slot, fillet, channel_depth, square_size, outer_circle_opening, inner_circle_opening, lip_depth, lower_open);
    rotate([0,0,270]) slot_opening(slot, fillet, channel_depth, square_size, outer_circle_opening, inner_circle_opening, lip_depth, right_open);
}

module inner_circle_opening_fn(inner_circle_radius) {
    translate([0,0]) circle(inner_circle_radius);
}

module slot_opening(slot, fillet, channel_depth, square_size, outer_channel_opening, inner_channel_opening, lip_depth, open=false) {
    hull() {
        translate([-outer_channel_opening/2+fillet, square_size/2]) circle(fillet);
        translate([ outer_channel_opening/2-fillet, square_size/2]) circle(fillet);
        translate([-outer_channel_opening/2+fillet, square_size/2-channel_depth]) circle(fillet);
        translate([ outer_channel_opening/2-fillet, square_size/2-channel_depth]) circle(fillet);
    }

    if (open) {
        hull() {
            translate([-inner_channel_opening/2-lip_depth, square_size/2-lip_depth]) circle(fillet);
            translate([ inner_channel_opening/2+lip_depth, square_size/2-lip_depth]) circle(fillet);
        }
    }

    if (slot == "t") {
        hull() {
            translate([-outer_channel_opening/2+fillet, square_size/2+square_size/25]) square(square_size/7.5, center=true);
            translate([ outer_channel_opening/2-fillet, square_size/2+square_size/25]) square(square_size/7.5, center=true);
        }
    } else if (slot == "v") {
        translate([-lip_depth-square_size/20, square_size/2]) rotate(45) square(lip_depth*2, center=true);
        translate([ lip_depth+square_size/20, square_size/2]) rotate(45) square(lip_depth*2, center=true);
    }
}

// Example usage:
translate([0,0,0]) extrusion_profile(slot="t");








