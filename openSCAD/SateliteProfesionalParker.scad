// ===========================================
// ESA-like Satellite (Paramétrico y limpio)
// Autor: Víctor + Copilot
// ===========================================

$fn = 96;
quality = 64;

// ---------------------------
// Parámetros globales
// ---------------------------
scale_model = 1;        // Escala general
bus_w = 60;             // Ancho bus (X)
bus_d = 60;             // Fondo bus (Y)
bus_h = 80;             // Alto bus (Z)

panel_len = 180;        // Longitud ala solar
panel_w   = 50;         // Anchura ala solar
panel_t   = 2;          // Espesor ala solar
panel_segments = 3;     // Nº de segmentos por ala
panel_deploy_deg = 90;  // Ángulo de despliegue (0 plegado, 90 desplegado)

dish_diameter = 60;     // Antena de alta ganancia (HGA)
dish_depth    = 12;
dish_thickness= 1.2;

boom_len = 50;          // Longitud del mástil de la HGA

thruster_h = 12;        // Propulsores
thruster_r1= 4;
thruster_r2= 1.6;

show_reaction_wheel = true;
show_radiators      = true;
show_star_trackers  = true;
show_legacy_kit     = true;  // Activa elementos decorativos heredados (limpios)

// ---------------------------
// Utilidades
// ---------------------------
module radial(n=4, r=20, start=0) {
  for (k = [0:n-1])
    rotate([0,0,start + k*360/n])
      translate([r,0,0])
        children();
}

module ring(h=4, r_outer=20, r_inner=16, center=false) {
  difference() {
    cylinder(h=h, r=r_outer, center=center);
    cylinder(h=h+0.2, r=r_inner, center=center);
  }
}

module strut_x(l=30, r=1.6) { // Viga a lo largo de X
  rotate([0,90,0]) cylinder(h=l, r=r, center=false);
}

// ---------------------------
// Partes principales
// ---------------------------
module bus_body(w=bus_w, d=bus_d, h=bus_h) {
  color("lightgray")
    cube([w,d,h], center=true);
}

module radiator_plate(w=36, h=50, t=1.6) {
  color([0.95,0.95,1.0])
    cube([w,t,h], center=true);
}

module star_tracker() {
  // pequeña cámara + boom
  color("gray") translate([0,0,0]) cylinder(h=8, r=4, center=true);
  color([0.1,0.1,0.1]) translate([0,0,6]) cylinder(h=2, r=3.8, center=true);
  color("silver") rotate([0,90,0]) cylinder(h=12, r=1.2, center=false);
}

module thruster(h=thruster_h, r1=thruster_r1, r2=thruster_r2) {
  color("silver")
    cylinder(h=h, r1=r1, r2=r2, center=false);
}

module solar_segment(seg_len=50, seg_w=panel_w, seg_t=panel_t) {
  // Marco
  color([0.2,0.2,0.25])
    cube([seg_len, seg_w, seg_t], center=true);
  // Superficie célula (ligeramente hundida)
  translate([0,0,-seg_t/4])
    color([0.02,0.1,0.35])
      cube([seg_len-3, seg_w-3, seg_t/2], center=true);
}

module solar_wing(total_len=panel_len, segs=panel_segments, seg_w=panel_w, seg_t=panel_t) {
  seg_len = total_len / segs;
  union() {
    for (i=[0:segs-1])
      translate([i*(seg_len+1.5) + seg_len/2, 0, 0])
        solar_segment(seg_len, seg_w, seg_t);
    // bisagra base
    color("silver")
      translate([-2, 0, 0])
        rotate([0,90,0]) cylinder(h=4, r=2.5, center=true);
  }
}

module dish_parabola(d=dish_diameter, depth=dish_depth, t=dish_thickness, profile_steps=36) {
  // Perfil parabólico y revolución
  rmax = d/2;
  a = depth/(rmax*rmax);
  color("white")
    rotate_extrude(convexity=10, $fn=quality)
      polygon(concat(
        [[0,0]],
        [for (i=[0:profile_steps]) 
          let(r = rmax*i/profile_steps) [r, a*r*r]],
        [[rmax, a*rmax*rmax + t], [0,t]]
      ));
}

module gimbal_hga(d_outer=30, t=2.5) {
  // Cardán doble (two-axis)
  color("silver") ring(h=3, r_outer=d_outer/2, r_inner=d_outer/2 - t, center=true);
  rotate([90,0,0])
    color("silver") ring(h=3, r_outer=(d_outer-6)/2, r_inner=(d_outer-6)/2 - t, center=true);
}

module reaction_wheel_stack() {
  // Decorativo: tres ruedas de reacción apiladas
  color([0.4,0.4,0.45]) translate([0,0,-6]) cylinder(h=6, r=10, center=false);
  color([0.4,0.4,0.45]) translate([0,0, 2]) cylinder(h=6, r=10, center=false);
  color([0.4,0.4,0.45]) translate([0,0,10]) cylinder(h=6, r=10, center=false);
}

module medium_gain_patch(r=8, h=2) {
  color("white") cylinder(h=h, r=r, center=true);
  color("silver") translate([0,0,-h/2-2]) cylinder(h=2, r=r*0.8, center=false);
}

// ---------------------------
// Ensamblajes
// ---------------------------
module solar_array_pair(deploy_deg=panel_deploy_deg) {
  // Ala izquierda
  translate([-bus_w/2, 0, 0]) {
    // bisagra al bus
    color("silver") rotate([0,90,0]) cylinder(h=6, r=3, center=true);
    rotate([0, deploy_deg, 0])
      translate([-1, 0, 0])
        solar_wing();
  }
  // Ala derecha
  translate([ bus_w/2, 0, 0]) {
    color("silver") rotate([0,90,0]) cylinder(h=6, r=3, center=true);
    rotate([0, -deploy_deg, 0])
      mirror([1,0,0])
        translate([-1, 0, 0])
          solar_wing();
  }
}

module hga_assembly() {
  // Mástil hacia +X desde el bus y cardán + plato
  translate([bus_w/2, 0, 0]) {
    color("silver") strut_x(l=boom_len, r=1.8);
    translate([boom_len, 0, 0]) {
      gimbal_hga(d_outer=34);
      // offset del plato respecto al cardán
      translate([0, 0, 0])
        rotate([0, -25, 0])  // apuntamiento
          translate([0, 0, 0])
            dish_parabola();
    }
  }
}

module star_trackers_assembly() {
  // Dos cámaras de estrella en brazos a 45º sobre cara +Z
  base_z =  bus_h/2;
  offset =  18;
  rotate([0,0,45]) translate([0, bus_d/2 + 6, base_z-10]) rotate([90,0,0]) star_tracker();
  rotate([0,0,-45]) translate([0,-bus_d/2 - 6, base_z-10]) rotate([90,0,0]) star_tracker();
}

module radiators_assembly() {
  // Radiadores en caras +Y y -Y
  translate([0, bus_d/2 + 1, 10]) radiator_plate();
  translate([0,-bus_d/2 - 1, -10]) rotate([0,0,180]) radiator_plate();
}

module thrusters_assembly() {
  // Ocho propulsores en las esquinas superiores e inferiores
  corner = [[1,1],[1,-1],[-1,1],[-1,-1]]; // signos para X,Y
  for (c = corner) {
    // superior
    translate([c[0]*bus_w/2, c[1]*bus_d/2,  bus_h/2])
      rotate([90,0,0]) thruster();
    // inferior
    translate([c[0]*bus_w/2, c[1]*bus_d/2, -bus_h/2])
      rotate([-90,0,0]) thruster();
  }
}

module medium_gain_antennas() {
  // Dos parches en cara -X
  translate([-bus_w/2 - 3,  15, 10]) rotate([0,90,0]) medium_gain_patch();
  translate([-bus_w/2 - 3, -15, -8]) rotate([0,90,0]) medium_gain_patch(r=6,h=2);
}

module reaction_wheels_assembly() {
  if (show_reaction_wheel)
    translate([0,0,0]) reaction_wheel_stack();
}

// ---------------------------
// Kit legado (limpiado)
// ---------------------------

// Reutilizamos tus módulos ajustados para detalles opcionales
module RotateStuff(radius=20, number=5) {
  for (azimut = [0:360/number:359])
    rotate([0,0,azimut])
      translate([radius, 0, 0])
        children();
}

module moteurMoche() {
  difference() {
    cylinder(h=5, r1=5, r2=6, center=false);
    translate([0,0,1]) scale([0.95,0.95,1.2])
      cylinder(h=5, r1=5, r2=6, center=false);
  }
}

module legacy_details() {
  // Corona de boquillas como adorno
  translate([0,0,-bus_h/2 - 6])
    RotateStuff(radius=22, number=6)
      rotate([90,0,0]) scale([0.7,0.7,1]) moteurMoche();
}

// ---------------------------
// Ensamblaje principal
// ---------------------------
module esa_satellite() {
  scale(scale_model) {
    // Cuerpo
    bus_body();

    // Alas solares
    solar_array_pair(panel_deploy_deg);

    // Antenas
    hga_assembly();
    medium_gain_antennas();

    // Radiadores
    if (show_radiators) radiators_assembly();

    // Cámaras de estrella
    if (show_star_trackers) star_trackers_assembly();

    // Propulsores
    thrusters_assembly();

    // Ruedas de reacción (decorativo interior)
    reaction_wheels_assembly();

    // Detalles heredados
    if (show_legacy_kit) legacy_details();
  }
}

// ---------------------------
// Ejecutar
// ---------------------------
esa_satellite();

