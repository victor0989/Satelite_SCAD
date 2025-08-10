// ===========================================
// Satélite paramétrico (ESA / Parker)
// Versión professional limpia - Autor: Víctor + Copilot (mejorado)
// ===========================================

$fn = 96;
quality = 64; // usado en algunos módulos para número de caras

// ---------------------------
// DISPLAY FLAGS
// ---------------------------
parker_mode = true;       // true -> Parker-like probe, false -> ESA-like satellite
show_axes = false;
show_bbox = false;

// ---------------------------
// GLOBAL PARAMETERS (ajustables)
// ---------------------------
/* Bus general (ESA) */
bus_w = 60; bus_d = 60; bus_h = 80;

/* Solar panels */
panel_len = 180;
panel_w   = 50;
panel_t   = 2;
panel_segments = 3;
panel_deploy_deg = 90;

/* HGA */
dish_diameter = 60;
dish_depth    = 12;
dish_thickness= 1.2;
boom_len = 50;

/* Thrusters */
thruster_h = 12;
thruster_r1 = 4;
thruster_r2 = 1.6;

/* Optional sets */
show_reaction_wheel = true;
show_radiators      = true;
show_star_trackers  = true;
show_legacy_kit     = true;

/* Parker-specific */
p_bus_w = 90; p_bus_d = 90; p_bus_h = 120;
shield_d     = 220;    // diámetro escudo
shield_thk   = 10;     // espesor (solo concepto)
shield_cone  = 18;     // conicidad
shield_gap   = 25;     // separación bus-escudo
paddle_len   = 80;
paddle_root_w= 42;
paddle_tip_w = 26;
paddle_t     = 2;
paddle_tilt_deg = 22;
paddle_y_offset = p_bus_d/2 - 6;
radiator_w   = 70;
radiator_h   = 110;
radiator_t   = 2.2;
radiator_back_offset = 40;
back_dish_d  = 50;
back_dish_depth = 10;
boom_len_back = 140;
boom_tip_r    = 3.0;
faraday_len   = 45;
faraday_r     = 12;

// ---------------------------
// UTILITIES
// ---------------------------
module axes(len=200, thick=0.6) {
  if (show_axes) {
    color("red") translate([0,0,0]) cylinder(r=thick, h=len, center=false);
    color("green") rotate([0,0,90]) translate([0,0,0]) cylinder(r=thick, h=len, center=false);
    color("blue") rotate([0,90,0]) translate([0,0,0]) cylinder(r=thick, h=len, center=false);
  }
}

module bbox(w,d,h) {
  if (show_bbox) color([1,0.5,0.2,0.15]) translate([-w/2,-d/2,-h/2]) cube([w,d,h], center=false);
}

// small ring helper (hollow disc)
module ring(h=4, r_outer=20, r_inner=16, center=false) {
  difference() {
    cylinder(h=h, r=r_outer, center=center);
    cylinder(h=h+0.2, r=r_inner, center=center);
  }
}

// simple torus helper (fallback)
module torus(r1=1, r2=0.2) {
  // rotate_extrude of a circle
  rotate_extrude(convexity=10, $fn=quality)
    translate([r1, 0, 0])
      circle(r=r2, $fn=max(12, $fn/2));
}

// ---------------------------
// PRIMITIVES & SUBMODULES
// ---------------------------
module bus_body(w, d, h, color_rgb=[0.9,0.9,0.95]) {
  color(color_rgb) translate([-w/2, -d/2, -h/2]) cube([w,d,h], center=false);
}

module radiator_plate(w=36, h=50, t=1.6) {
  color([0.95,0.95,1.0]) translate([-w/2, -t/2, -h/2]) cube([w,t,h], center=false);
}

module star_tracker() {
  color("gray") cylinder(h=8, r=4, center=true);
  color([0.1,0.1,0.1]) translate([0,0,6]) cylinder(h=2, r=3.8, center=true);
  color("silver") rotate([0,90,0]) cylinder(h=12, r=1.2, center=false);
}

module thruster(h=thruster_h, r1=thruster_r1, r2=thruster_r2) {
  color("silver") cylinder(h=h, r1=r1, r2=r2, center=false);
}

module solar_segment(seg_len=50, seg_w=panel_w, seg_t=panel_t) {
  // panel solar panelado con cara superior oscura
  color([0.2,0.2,0.25]) translate([-seg_len/2, -seg_w/2, -seg_t/2]) cube([seg_len, seg_w, seg_t]);
  translate([- (seg_len-3)/2, -(seg_w-3)/2, -seg_t/2 + seg_t/8])
    color([0.02,0.1,0.35]) cube([seg_len-3, seg_w-3, seg_t/2]);
}

module solar_wing(total_len=panel_len, segs=panel_segments, seg_w=panel_w, seg_t=panel_t) {
  seg_len = total_len / segs;
  union() {
    for (i=[0:segs-1]) translate([i*(seg_len+1.5) + seg_len/2, 0, 0])
      solar_segment(seg_len, seg_w, seg_t);
    // hinge rod
    color("silver") translate([-2, 0, 0]) rotate([0,90,0]) cylinder(h=4, r=2.5, center=true);
  }
}

module dish_parabola(d=dish_diameter, depth=dish_depth, t=dish_thickness, profile_steps=48) {
  rmax = d/2;
  a = depth/(rmax*rmax);
  color("white")
    rotate_extrude(convexity=10, $fn=quality)
      polygon(concat(
        [[0,0]],
        [for (i=[0:profile_steps]) let(r = rmax*i/profile_steps) [r, a*r*r]],
        [[rmax, a*rmax*rmax + t], [0,t]]
      ));
}

module gimbal_hga(d_outer=30, t=2.5) {
  color("silver") ring(h=3, r_outer=d_outer/2, r_inner=d_outer/2 - t, center=true);
  rotate([90,0,0]) color("silver") ring(h=3, r_outer=(d_outer-6)/2, r_inner=(d_outer-6)/2 - t, center=true);
}

module reaction_wheel_stack() {
  color([0.4,0.4,0.45]) translate([0,0,-6]) cylinder(h=6, r=10, center=false);
  color([0.4,0.4,0.45]) translate([0,0, 2]) cylinder(h=6, r=10, center=false);
  color([0.4,0.4,0.45]) translate([0,0,10]) cylinder(h=6, r=10, center=false);
}

module medium_gain_patch(r=8, h=2) {
  color("white") cylinder(h=h, r=r, center=true);
  color("silver") translate([0,0,-h/2-2]) cylinder(h=2, r=r*0.8, center=false);
}

// legacy motor (cosmetic)
module moteurMoche() {
  difference() {
    cylinder(h=5, r1=5, r2=6, center=false);
    translate([0,0,1]) scale([0.95,0.95,1.2]) cylinder(h=5, r1=5, r2=6, center=false);
  }
}

module RotateStuff(radius=20, number=5) {
  for (azimut = [0:360/number:359])
    rotate([0,0,azimut]) translate([radius, 0, 0]) children();
}

module legacy_details(busH=bus_h) {
  translate([0,0,-busH/2 - 6]) RotateStuff(radius=22, number=6)
    rotate([90,0,0]) scale([0.7,0.7,1]) moteurMoche();
}

// ---------------------------
// ASSEMBLIES - ESA style
// ---------------------------
module solar_array_pair(deploy_deg=panel_deploy_deg) {
  // Left wing
  translate([-bus_w/2, 0, 0]) {
    color("silver") rotate([0,90,0]) cylinder(h=6, r=3, center=true);
    rotate([0, deploy_deg, 0]) translate([-1, 0, 0]) solar_wing();
  }
  // Right wing (mirrored)
  translate([ bus_w/2, 0, 0]) {
    color("silver") rotate([0,90,0]) cylinder(h=6, r=3, center=true);
    rotate([0, -deploy_deg, 0]) mirror([1,0,0]) translate([-1, 0, 0]) solar_wing();
  }
}

module hga_assembly() {
  translate([bus_w/2, 0, 0]) {
    color("silver") rotate([0,90,0]) cylinder(h=boom_len, r=1.8, center=false); // boom along +X
    translate([boom_len, 0, 0]) {
      gimbal_hga(d_outer=34);
      rotate([0, -25, 0]) dish_parabola();
    }
  }
}

module star_trackers_assembly() {
  base_z = bus_h/2;
  rotate([0,0,45])  translate([0, bus_d/2 + 6, base_z-10]) rotate([90,0,0]) star_tracker();
  rotate([0,0,-45]) translate([0,-bus_d/2 - 6, base_z-10]) rotate([90,0,0]) star_tracker();
}

module radiators_assembly() {
  translate([0, bus_d/2 + 1, 10]) radiator_plate();
  translate([0,-bus_d/2 - 1, -10]) rotate([0,0,180]) radiator_plate();
}

module thrusters_assembly() {
  corner = [[1,1],[1,-1],[-1,1],[-1,-1]];
  for (c = corner) {
    translate([c[0]*bus_w/2, c[1]*bus_d/2,  bus_h/2]) rotate([90,0,0]) thruster();
    translate([c[0]*bus_w/2, c[1]*bus_d/2, -bus_h/2]) rotate([-90,0,0]) thruster();
  }
}

module reaction_wheels_assembly() {
  if (show_reaction_wheel) translate([0,0,0]) reaction_wheel_stack();
}

// Main ESA satellite
module esa_satellite() {
  // Body
  bus_body(bus_w, bus_d, bus_h);
  bbox(bus_w,bus_d,bus_h);
  // Solar arrays
  solar_array_pair(panel_deploy_deg);
  // HGA
  hga_assembly();
  // Radiators
  if (show_radiators) radiators_assembly();
  // Star trackers
  if (show_star_trackers) star_trackers_assembly();
  // Thrusters
  thrusters_assembly();
  // Reaction wheels
  reaction_wheels_assembly();
  // Legacy details
  if (show_legacy_kit) legacy_details();
}

// ---------------------------
// PARKER probe style
// ---------------------------
// heat shield (approx conical hull)
module heat_shield(d=shield_d, th=shield_thk, cone=shield_cone) {
  color([0.05,0.05,0.05])
  hull() {
    translate([0,0,0])  cylinder(h=1, r=d/2, center=false);
    translate([0,0,th]) cylinder(h=1, r=d/2 - cone, center=false);
  }
}

// faraday cup
module faraday_cup(len=faraday_len, r=faraday_r) {
  color("silver") union() {
    cylinder(h=len*0.6, r=r*0.6, center=false);
    translate([0,0,len*0.6]) cylinder(h=len*0.4, r1=r*0.6, r2=r*0.25, center=false);
    translate([0,0,-6]) cylinder(h=6, r=r*0.35, center=false);
  }
}

module parker_paddle(len=paddle_len, root_w=paddle_root_w, tip_w=paddle_tip_w, t=paddle_t) {
  color([0.03,0.09,0.30])
  linear_extrude(height=t, center=true)
    polygon(points=[
      [0, -root_w/2], [0, root_w/2],
      [len, tip_w/2], [len, -tip_w/2]
    ]);
  // thin frame
  color([0.18,0.18,0.22])
  linear_extrude(height=t*0.2, center=true)
    offset(delta=1.2)
      polygon(points=[
        [0, -root_w/2], [0, root_w/2],
        [len, tip_w/2], [len, -tip_w/2]
      ]);
  // hinge
  color("silver") translate([0,0,0]) rotate([0,90,0]) cylinder(h=4, r=2.2, center=true);
}

module parker_radiator(w=radiator_w, h=radiator_h, t=radiator_t) {
  color([0.92,0.92,1.0]) translate([-w/2,-t/2,-h/2]) cube([w,t,h]);
  // fins
  for (i=[-3:3]) translate([i*6,0,0]) color([0.85,0.85,0.95]) translate([-0.6,-(t+0.2)/2,-(h-6)/2]) cube([1.2,t+0.2,h-6]);
}

module instrument_boom(len=boom_len_back, tip_r=boom_tip_r) {
  color("silver") rotate([0,90,0]) cylinder(h=len, r=1.8, center=false);
  translate([-len,0,0]) color([0.8,0.8,0.2]) sphere(r=tip_r);
}

module parker_probe() {
  // Bus
  color("lightgray") translate([-p_bus_w/2, -p_bus_d/2, -p_bus_h/2]) cube([p_bus_w,p_bus_d,p_bus_h], center=false);
  bbox(p_bus_w,p_bus_d,p_bus_h);

  // heat shield facing +X (sun)
  translate([ p_bus_w/2 + shield_gap, 0, 0]) rotate([0,90,0]) heat_shield();

  // struts between bus and shield
  translate([ p_bus_w/2, 0, 0])
    radial(n=4, r= p_bus_d/2 - 12, start=45)
      color("silver") rotate([0,90,0]) cylinder(h=shield_gap, r=2.4, center=false);

  // Faraday cup in front
  translate([ p_bus_w/2 + shield_gap + shield_thk + 2, 0, 0]) rotate([0,90,0]) faraday_cup();

  // paddles (solar) near Y edges, tilted
  translate([ p_bus_w/2 + shield_gap - 12,  paddle_y_offset,  0])
    rotate([0, paddle_tilt_deg, 0])  rotate([0,90,90]) parker_paddle();
  translate([ p_bus_w/2 + shield_gap - 12, -paddle_y_offset,  0])
    rotate([0, -paddle_tilt_deg, 0]) mirror([0,1,0]) rotate([0,90,90]) parker_paddle();

  // radiators antisolar
  translate([ -p_bus_w/2 - radiator_back_offset,  0,  0]) {
    translate([0,  p_bus_d/2 - 8,  0]) rotate([0,90,0]) parker_radiator();
    translate([0, -p_bus_d/2 + 8,  0]) rotate([0,90,0]) parker_radiator(w=radiator_w*0.9, h=radiator_h*0.9);
  }

  // medium-back dish
  translate([ -p_bus_w/2 - 20, 0, 0]) {
    color("silver") rotate([0,90,0]) ring(h=3, r_outer=18, r_inner=14, center=true);
    rotate([0,90,0]) dish_parabola(d=back_dish_d, depth=back_dish_depth, t=1.0);
  }

  // instrument boom
  translate([ -p_bus_w/2 - 10, 0, 0]) instrument_boom();

  // rear thrusters (protected)
  for (s = [[-1,1],[ -1,-1 ]])
    translate([ -p_bus_w/2, s[1]*p_bus_d/2,  s[0]*p_bus_h/2 ]) rotate([0,90,0]) thruster(h=10, r1=3.2, r2=1.2);

  // medium gain patches on rear
  translate([ -p_bus_w/2 - 6,  18,  18]) rotate([0,90,0]) medium_gain_patch(r=7,h=2);
  translate([ -p_bus_w/2 - 6, -18, -18]) rotate([0,90,0]) medium_gain_patch(r=6,h=2);

  // reaction wheel inside
  translate([0,0,0]) reaction_wheel_stack();

  // optional legacy details underneath
  if (show_legacy_kit)
    translate([0,0,0]) legacy_details(busH=p_bus_h);
}

// ---------------------------
// RUN
// ---------------------------
translate([0,0,0]) {
  if (parker_mode) parker_probe(); else esa_satellite();
  axes();
}
