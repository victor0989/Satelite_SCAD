// ===========================================
// Satélite paramétrico: ESA-like y Parker-like (con exposición)
// Autor: Víctor + Copilot
// ===========================================

$fn = 96;
quality = 64;

// ---------------------------
// Parámetros de modo y vistas
// ---------------------------
parker_mode = true;          // true: Parker-like, false: ESA-like
show_source_beams = true;    // dibuja rayos de fuentes
show_sun_beam     = true;    // dibuja rayo del Sol
show_exposure     = true;    // pinta intersección de rayos con geometría (overlay)
exposure_target   = "panels"; // "panels", "bus", "all"

// ---------------------------
// Parámetros comunes (ESA-like)
// ---------------------------
bus_w = 60;  bus_d = 60;  bus_h = 80;
panel_len = 180; panel_w = 50; panel_t = 2; panel_segments = 3; panel_deploy_deg = 90;
dish_diameter = 60; dish_depth = 12; dish_thickness = 1.2; boom_len = 50;
thruster_h = 12; thruster_r1=4; thruster_r2=1.6;
show_reaction_wheel = true; show_radiators = true; show_star_trackers = true; show_legacy_kit = false;

// ---------------------------
// Parámetros Parker
// ---------------------------
p_bus_w = 90; p_bus_d = 90; p_bus_h = 120;

// Escudo térmico (TPS)
shield_d = 220;      // diámetro
shield_thk = 12;     // espesor equivalente
shield_cone = 22;    // conicidad del borde
shield_gap = 28;     // separación bus-escudo (a lo largo de +X)
shield_back_standoff = 10; // distancia del escudo al aro soporte

// Alas pequeñas tipo pala
paddle_len = 85;
paddle_root_w = 44;
paddle_tip_w  = 26;
paddle_t      = 2;
paddle_y_offset = p_bus_d/2 - 8;

// Control de inclinación
auto_paddle_tilt = true; // calcula inclinación según Sol
paddle_tilt_deg  = 22;   // si auto=false, valor manual
tilt_min = 5; tilt_max = 75; tilt_gain = 1.1; tilt_bias = 30;

// Radiadores y refrigeración
radiator_w = 80; radiator_h = 120; radiator_t = 2.2; radiator_back_offset = 46;

// Antenas e instrumentos Parker
back_dish_d = 50; back_dish_depth = 10;
boom_len_back = 140; boom_tip_r = 3.0;
faraday_len = 48; faraday_r = 12;

// FIELDS: whips sobre el plano del escudo
whip_len = 160; whip_r = 0.9;

// ---------------------------
// “Simulación” de fuentes (direcciones e intensidades)
// ---------------------------
// Definición en coordenadas espaciales: azimut (°) alrededor de Z, elevación (°) desde el plano XY.
sun_az_deg = 0;   // 0° = +X
sun_el_deg = 0;   // 0° = en el plano XY
sources = [        // [az_deg, el_deg, intensidad_relativa]
  [  0,   0, 1.0],  // Sol por defecto (alineado con +X)
  [ 45,  10, 0.5],  // fuente secundaria
  [-60, -20, 0.4]   // fuente terciaria
];

// Longitud y radio de los “rayos” de exposición
beam_len = 1200;
sun_beam_r = 18;
src_beam_r = 12;

// ---------------------------
// Utilidades
// ---------------------------
function rad(a) = a * PI / 180;
function deg(a) = a * 180 / PI;
function clamp(x,a,b) = max(a, min(b, x));
function dot(a,b) = a[0]*b[0] + a[1]*b[1] + a[2]*b[2];
function norm(v) = sqrt(dot(v,v));
function unit(v) = v / norm(v + 1e-9);
function vec_from_az_el(az,el) = [cos(rad(el))*cos(rad(az)), cos(rad(el))*sin(rad(az)), sin(rad(el))];

function yaw_deg_from_dir(d)   = deg(atan2(d[1], d[0]));                               // rotación Z
function pitch_deg_from_dir(d) = deg(asin(d[2] / (norm(d)+1e-9)));                     // elevación

module orient_beam(dir=[1,0,0]) {
  // Eje del cilindro base: +X
  y = yaw_deg_from_dir(dir);
  p = pitch_deg_from_dir(dir);
  rotate([0, -p, 0]) rotate([0,0, y]) children();
}

module ring(h=4, r_outer=20, r_inner=16, center=false) {
  difference() { cylinder(h=h, r=r_outer, center=center); cylinder(h=h+0.2, r=r_inner, center=center); }
}

module strut_x(l=30, r=1.6) { rotate([0,90,0]) cylinder(h=l, r=r, center=false); }

// ---------------------------
// Partes comunes (ESA-like)
// ---------------------------
module bus_body(w=bus_w, d=bus_d, h=bus_h) { color("lightgray") cube([w,d,h], center=true); }

module radiator_plate(w=36, h=50, t=1.6) {
  color([0.95,0.95,1.0]) cube([w,t,h], center=true);
}

module star_tracker() {
  color("gray") cylinder(h=8, r=4, center=true);
  color([0.1,0.1,0.1]) translate([0,0,6]) cylinder(h=2, r=3.8, center=true);
  color("silver") rotate([0,90,0]) cylinder(h=12, r=1.2, center=false);
}

module thruster(h=thruster_h, r1=thruster_r1, r2=thruster_r2) { color("silver") cylinder(h=h, r1=r1, r2=r2); }

module solar_segment(seg_len=50, seg_w=panel_w, seg_t=panel_t) {
  color([0.2,0.2,0.25]) cube([seg_len, seg_w, seg_t], center=true);
  translate([0,0,-seg_t/4]) color([0.02,0.1,0.35]) cube([seg_len-3, seg_w-3, seg_t/2], center=true);
}

module solar_wing(total_len=panel_len, segs=panel_segments, seg_w=panel_w, seg_t=panel_t) {
  seg_len = total_len / segs;
  union() {
    for (i=[0:segs-1]) translate([i*(seg_len+1.5) + seg_len/2, 0, 0]) solar_segment(seg_len, seg_w, seg_t);
    color("silver") translate([-2, 0, 0]) rotate([0,90,0]) cylinder(h=4, r=2.5, center=true);
  }
}

module dish_parabola(d=dish_diameter, depth=dish_depth, t=dish_thickness, profile_steps=36) {
  rmax = d/2; a = depth/(rmax*rmax);
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
  color([0.4,0.4,0.45]) translate([0,0,-6]) cylinder(h=6, r=10);
  color([0.4,0.4,0.45]) translate([0,0, 2]) cylinder(h=6, r=10);
  color([0.4,0.4,0.45]) translate([0,0,10]) cylinder(h=6, r=10);
}

module medium_gain_patch(r=8, h=2) {
  color("white") cylinder(h=h, r=r, center=true);
  color("silver") translate([0,0,-h/2-2]) cylinder(h=2, r=r*0.8);
}

// ---------------------------
// Ensamblajes (ESA-like)
// ---------------------------
module solar_array_pair(deploy_deg=panel_deploy_deg) {
  translate([-bus_w/2, 0, 0]) { color("silver") rotate([0,90,0]) cylinder(h=6, r=3, center=true);
    rotate([0, deploy_deg, 0]) translate([-1, 0, 0]) solar_wing(); }
  translate([ bus_w/2, 0, 0]) { color("silver") rotate([0,90,0]) cylinder(h=6, r=3, center=true);
    rotate([0,-deploy_deg, 0]) mirror([1,0,0]) translate([-1, 0, 0]) solar_wing(); }
}

module hga_assembly() {
  translate([bus_w/2, 0, 0]) {
    color("silver") strut_x(l=boom_len, r=1.8);
    translate([boom_len, 0, 0]) { gimbal_hga(d_outer=34); rotate([0, -25, 0]) dish_parabola(); }
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

module esa_satellite() {
  bus_body(); solar_array_pair(panel_deploy_deg);
  hga_assembly();
  if (show_radiators) radiators_assembly();
  if (show_star_trackers) star_trackers_assembly();
  thrusters_assembly();
  if (show_reaction_wheel) reaction_wheel_stack();
}

// ===================================================
// Parker-like: escudo térmico, palas basculantes,
// radiadores antisolares, booms, whips y sensores
// ===================================================

// Escudo térmico por capas (cara blanca, núcleo, trasera negra)
module heat_shield_layered(d=shield_d, th=shield_thk, cone=shield_cone) {
  // Frente (blanco) — cara al Sol
  color([0.98,0.98,0.98])
  hull() { translate([0,0,0]) cylinder(h=0.8, r=d/2);
          translate([0,0,0.8]) cylinder(h=0.8, r=d/2 - cone*0.25); }
  // Núcleo (gris)
  color([0.4,0.4,0.4])
  translate([0,0,1.6])
  hull() { cylinder(h=th-3.2, r=d/2 - cone*0.25);
           translate([0,0,th-3.2]) cylinder(h=0.1, r=d/2 - cone*0.85); }
  // Trasera (negra)
  color([0.05,0.05,0.05])
  translate([0,0,th-1.2])
  hull() { cylinder(h=1.2, r=d/2 - cone*0.85);
           translate([0,0,1.2]) cylinder(h=0.8, r=d/2 - cone); }
}

module tps_rim_sensors(d=shield_d) {
  // Sensores en el borde
  for (a=[0:45:315]) rotate([0,0,a]) translate([d/2 - 6,0,shield_thk+2])
    color([1,0.9,0.2]) sphere(r=2.2);
}

module tps_support_truss() {
  // Aro soporte y ménsulas hacia el bus
  color("silver") translate([0,0,0]) ring(h=3, r_outer=shield_d/2 - 12, r_inner=shield_d/2 - 18, center=false);
  for (a=[0:60:300]) rotate([0,0,a]) translate([shield_d/2 - 18, 0, -shield_back_standoff])
    rotate([0,90,0]) cylinder(h=shield_back_standoff + 4, r=2.6);
}

// Copa de Faraday (SWEAP)
module faraday_cup(len=faraday_len, r=faraday_r) {
  color("silver") union() {
    cylinder(h=len*0.6, r=r*0.6);
    translate([0,0,len*0.6]) cylinder(h=len*0.4, r1=r*0.6, r2=r*0.25);
    translate([0,0,-6]) cylinder(h=6, r=r*0.35); // cuello
  }
}

// Pala trapezoidal con marco
module parker_paddle(len=paddle_len, root_w=paddle_root_w, tip_w=paddle_tip_w, t=paddle_t) {
  color([0.03,0.09,0.30])
  linear_extrude(height=t, center=true)
    polygon(points=[[0,-root_w/2],[0,root_w/2],[len,tip_w/2],[len,-tip_w/2]]);
  color([0.18,0.18,0.22])
  linear_extrude(height=t*0.2, center=true)
    offset(delta=1.2)
      polygon(points=[[0,-root_w/2],[0,root_w/2],[len,tip_w/2],[len,-tip_w/2]]);
  color("silver") rotate([0,90,0]) cylinder(h=4, r=2.2, center=true);
}

// Radiador antisolar
module parker_radiator(w=radiator_w, h=radiator_h, t=radiator_t) {
  color([0.92,0.92,1.0]) cube([w,t,h], center=true);
  for (i=[-3:3]) translate([i*6,0,0]) color([0.85,0.85,0.95]) cube([1.2,t+0.2,h-6], center=true);
}

// Ductos de refrigeración (aprox.)
module cooling_loops() {
  color([0.75,0.75,0.8])
  union() {
    // Colectores desde palas a radiadores
    for (s=[-1,1]) {
      translate([ p_bus_w/2 + shield_gap - 12, s*(p_bus_d/2 - 8),  0])
        rotate([0,90,0]) cylinder(h=20, r=1.2);
      translate([ p_bus_w/2 + 10, s*(p_bus_d/2 - 8),  0])
        rotate([0,0,90]) torus_arc(R=18, r=1.2, ang=90);
      translate([ -p_bus_w/2 - radiator_back_offset + 6, s*(p_bus_d/2 - 8),  0])
        rotate([0,90,0]) cylinder(h= (p_bus_w/2 + radiator_back_offset - 6) + (p_bus_w/2 - 10), r=1.2);
    }
  }
}

// Torus aproximado para codos
module torus_arc(R=10, r=1, ang=90) {
  rotate_extrude(angle=ang, convexity=5)
    translate([R,0,0]) circle(r=r);
}

// Whips de FIELDS, inclinados desde el borde del escudo
module fields_whips() {
  for (a=[-35, 35, 145, -145]) {
    rotate([0,0,a]) translate([shield_d/2 - 10,0,shield_thk])
      rotate([0,-10,0]) color([0.85,0.85,0.9])
        rotate([0,90,0]) cylinder(h=whip_len, r=whip_r);
  }
}

// Antena trasera y boom
module rear_comms_and_boom() {
  // Antena mediana en -X
  translate([ -p_bus_w/2 - 24, 0, 0]) {
    color("silver") rotate([0,90,0]) ring(h=3, r_outer=18, r_inner=14, center=true);
    rotate([0,90,0]) dish_parabola(d=back_dish_d, depth=back_dish_depth, t=1.0);
  }
  // Boom instrumentos hacia -X
  translate([ -p_bus_w/2 - 10, 0, 0]) {
    color("silver") rotate([0,90,0]) cylinder(h=boom_len_back, r=1.8);
    translate([-boom_len_back,0,0]) color([0.8,0.8,0.2]) sphere(r=boom_tip_r);
  }
}

// Propulsores protegidos tras escudo
module parker_thrusters() {
  for (s = [[-1,1],[-1,-1]])  // esquinas traseras
    translate([ -p_bus_w/2, s[1]*p_bus_d/2,  s[0]*p_bus_h/2 ])
      rotate([0,90,0]) thruster(h=10, r1=3.2, r2=1.2);
}

// Cálculo de inclinación automática de palas según Sol
function auto_tilt_from_sun(az,el) =
  let(sdir = unit(vec_from_az_el(az,el)),
      n    = [1,0,0],                             // normal del escudo (apunta a +X)
      ang  = deg(acos(clamp(dot(sdir,n), -1, 1))) // 0..180°
  )
  clamp(tilt_bias + tilt_gain*ang, tilt_min, tilt_max);

// Conjunto Parker
module parker_probe() {
  // Bus principal
  color("lightgray") cube([p_bus_w,p_bus_d,p_bus_h], center=true);

  // Conjunto escudo térmico al frente (+X)
  translate([ p_bus_w/2 + shield_gap, 0, 0]) {
    rotate([0,90,0]) heat_shield_layered();
    tps_support_truss();
    tps_rim_sensors();
    // Copa de Faraday a través del escudo
    translate([ 2 + shield_thk, 0, 0]) rotate([0,90,0]) faraday_cup();
    // Whips FIELDS
    fields_whips();
  }

  // Ménsulas radiales hacia el bus
  translate([ p_bus_w/2, 0, 0]) for (a=[0:60:300])
    rotate([0,0,a]) translate([p_bus_d/2 - 14,0, -shield_back_standoff])
      color("silver") strut_x(l=shield_gap, r=2.4);

  // Palas solares a ±Y cerca del borde del escudo
  tilt_used = (auto_paddle_tilt ? auto_tilt_from_sun(sun_az_deg, sun_el_deg) : paddle_tilt_deg);

  // +Y
  translate([ p_bus_w/2 + shield_gap - 12,  paddle_y_offset,  0])
    rotate([0, tilt_used, 0]) rotate([0,90,90]) parker_paddle();
  // -Y
  translate([ p_bus_w/2 + shield_gap - 12, -paddle_y_offset,  0])
    rotate([0,-tilt_used, 0]) mirror([0,1,0]) rotate([0,90,90]) parker_paddle();

  // Radiadores antisolares y ductos
  translate([-p_bus_w/2 - radiator_back_offset, 0, 0]) {
    translate([0,  p_bus_d/2 - 8,  0]) rotate([0,90,0]) parker_radiator(w=radiator_w, h=radiator_h);
    translate([0, -p_bus_d/2 + 8,  0]) rotate([0,90,0]) parker_radiator(w=radiator_w*0.9, h=radiator_h*0.9);
  }
  cooling_loops();

  // Antena trasera y boom
  rear_comms_and_boom();

  // Propulsores
  parker_thrusters();

  // Ruedas de reacción (decorativo)
  translate([0,0,0]) reaction_wheel_stack();
}

// ==============================
// “Rayos” de exposición
// ==============================
module beam(dir=[1,0,0], L=beam_len, r=10, col=[1,1,0]) {
  color(col, 0.35)
    orient_beam(dir)
      translate([0,0,-r]) // pequeño offset visual
        translate([0,0,0]) // base en el origen
          rotate([0,90,0]) cylinder(h=L, r=r);
}

// Geometría diana simplificada para intersección (Parker)
module parker_target_geometry(target="all") {
  if (target=="bus" || target=="all")
    color([1,0,0,0.4]) cube([p_bus_w,p_bus_d,p_bus_h], center=true);
  if (target=="panels" || target=="all") {
    // Usa mismas transformaciones que palas
    tilt_used = (auto_paddle_tilt ? auto_tilt_from_sun(sun_az_deg, sun_el_deg) : paddle_tilt_deg);
    translate([ p_bus_w/2 + shield_gap - 12,  paddle_y_offset,  0])
      rotate([0, tilt_used, 0]) rotate([0,90,90])
        color([1,0,0,0.4]) linear_extrude(height=paddle_t, center=true)
          polygon(points=[[0,-paddle_root_w/2],[0,paddle_root_w/2],[paddle_len,paddle_tip_w/2],[paddle_len,-paddle_tip_w/2]]);
    translate([ p_bus_w/2 + shield_gap - 12, -paddle_y_offset,  0])
      rotate([0,-tilt_used, 0]) mirror([0,1,0]) rotate([0,90,90])
        color([1,0,0,0.4]) linear_extrude(height=paddle_t, center=true)
          polygon(points=[[0,-paddle_root_w/2],[0,paddle_root_w/2],[paddle_len,paddle_tip_w/2],[paddle_len,-paddle_tip_w/2]]);
  }
  // El escudo sirve de sombra; no lo incluimos como target, pero sí bloquea rayos en la vista normal.
}

// Dibuja rayos y (opcional) intersecciones con la diana
module exposure_overlay() {
  // Vector del Sol desde az/el
  sun_dir = unit(vec_from_az_el(sun_az_deg, sun_el_deg));
  if (show_sun_beam) beam(dir=sun_dir, L=beam_len, r=sun_beam_r, col=[1,0.9,0.1]);

  if (show_source_beams)
    for (s = sources)
      beam(dir=unit(vec_from_az_el(s[0], s[1])), L=beam_len, r=src_beam_r*s[2], col=[1,0,1]);

  if (show_exposure) {
    // Intersección de diana con la unión de haces (aprox.: interseccion con cada uno, sumadas)
    target = exposure_target;
    // Sol
    intersection() {
      parker_target_geometry(target);
      beam(dir=unit(vec_from_az_el(sun_az_deg, sun_el_deg)), L=beam_len, r=sun_beam_r);
    }
    // Fuentes
    for (s = sources) intersection() {
      parker_target_geometry(target);
      beam(dir=unit(vec_from_az_el(s[0], s[1])), L=beam_len, r=src_beam_r*s[2]);
    }
  }
}

// ---------------------------
// Ejecutar
// ---------------------------
if (parker_mode) {
  parker_probe();
  exposure_overlay();
} else {
  esa_satellite();
}

// -----------------------------------------------
// Opcional: preset rápido (comenta/descomenta)
// -----------------------------------------------
// // Perihelio (muy protegido):
// sun_az_deg = 0; sun_el_deg = 0;
// shield_d = 240; shield_cone = 26; auto_paddle_tilt = true;
// radiator_w = 90; radiator_h = 140; radiator_back_offset = 52;
// // Crucero (más abierto):
// // sun_az_deg = 10; sun_el_deg = 5; auto_paddle_tilt = true;
// // shield_d = 200; shield_cone = 18; radiator_w = 70; radiator_h = 110;



