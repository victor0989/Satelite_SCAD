// ========================================================
// Parker Solar Probe-like con simulación de exposición solar
// Autor: Víctor + Copilot
// ========================================================

$fn = 96;
quality = 64;

// ---------------------------
// Modo y simulación
// ---------------------------
show_sun_beam   = true;     // Haz del Sol
show_exposure   = true;     // Pinta partes iluminadas
exposure_target = "panels"; // "panels","bus","all"

// Ángulo del Sol
sun_az_deg = 0;   // 0° = Sol de frente (+X)
sun_el_deg = 0;   // 0° en plano horizontal

// ---------------------------
// Parámetros Parker
// ---------------------------
p_bus_w = 90; p_bus_d = 90; p_bus_h = 120;

// Escudo térmico
shield_d = 220; shield_thk = 12; shield_cone = 22;
shield_gap = 28; shield_back_standoff = 10;

// Palas solares
paddle_len = 85; paddle_root_w = 44; paddle_tip_w = 26; paddle_t = 2;
paddle_y_offset = p_bus_d/2 - 8;
auto_paddle_tilt = true;
paddle_tilt_deg = 22; tilt_min = 5; tilt_max = 75; tilt_gain = 1.1; tilt_bias = 30;

// Radiadores
radiator_w = 80; radiator_h = 120; radiator_t = 2.2; radiator_back_offset = 46;

// Instrumentos
back_dish_d = 50; back_dish_depth = 10;
boom_len_back = 140; boom_tip_r = 3.0;
faraday_len = 48; faraday_r = 12;
whip_len = 160; whip_r = 0.9;

// ---------------------------
// Utilidades y helpers
// ---------------------------
function rad(a) = a*PI/180;
function clamp(x,a,b) = max(a,min(b,x));
function vec_from_az_el(az,el) = [cos(rad(el))*cos(rad(az)), cos(rad(el))*sin(rad(az)), sin(rad(el))];
function deg(a) = a*180/PI;
function yaw_deg_from_dir(d) = deg(atan2(d[1],d[0]));
function pitch_deg_from_dir(d) = deg(asin(d[2]/(sqrt(d[0]*d[0]+d[1]*d[1]+d[2]*d[2])+1e-9)));
function auto_tilt_from_sun(az,el) =
  let(sdir = vec_from_az_el(az,el),
      n=[1,0,0],
      ang=deg(acos(clamp(sdir[0]*n[0]+sdir[1]*n[1]+sdir[2]*n[2],-1,1))))
  clamp(tilt_bias+tilt_gain*ang, tilt_min, tilt_max);

// ---------------------------
// Módulos de piezas
// ---------------------------
module ring(h=4, r_outer=20, r_inner=16) {
  difference(){ cylinder(h=h, r=r_outer); cylinder(h=h+0.2, r=r_inner); }
}

module strut_x(l=30, r=1.6){ rotate([0,90,0]) cylinder(h=l, r=r); }

module heat_shield_layered(d=shield_d, th=shield_thk, cone=shield_cone){
  // Frente
  color([0.98,0.98,0.98])
    hull(){ cylinder(h=0.8, r=d/2); translate([0,0,0.8]) cylinder(h=0.8, r=d/2 - cone*0.25); }
  // Núcleo
  color([0.4,0.4,0.4]) translate([0,0,1.6])
    hull(){ cylinder(h=th-3.2, r=d/2 - cone*0.25); translate([0,0,th-3.2]) cylinder(h=0.1, r=d/2 - cone*0.85); }
  // Trasera
  color([0.05,0.05,0.05]) translate([0,0,th-1.2])
    hull(){ cylinder(h=1.2, r=d/2 - cone*0.85); translate([0,0,1.2]) cylinder(h=0.8, r=d/2 - cone); }
}

module tps_rim_sensors(d=shield_d){
  for(a=[0:45:315]) rotate([0,0,a]) translate([d/2 - 6,0,shield_thk+2]) color([1,0.9,0.2]) sphere(r=2.2);
}

module tps_support_truss(){
  color("silver") ring(h=3, r_outer=shield_d/2 - 12, r_inner=shield_d/2 - 18);
  for(a=[0:60:300]) rotate([0,0,a]) translate([shield_d/2 - 18,0,-shield_back_standoff])
    rotate([0,90,0]) cylinder(h=shield_back_standoff + 4, r=2.6);
}

module faraday_cup(len=faraday_len, r=faraday_r){
  color("silver") union(){
    cylinder(h=len*0.6, r=r*0.6);
    translate([0,0,len*0.6]) cylinder(h=len*0.4, r1=r*0.6, r2=r*0.25);
    translate([0,0,-6]) cylinder(h=6, r=r*0.35);
  }
}

module parker_paddle(len=paddle_len, root_w=paddle_root_w, tip_w=paddle_tip_w, t=paddle_t){
  color([0.03,0.09,0.30]) linear_extrude(height=t, center=true)
    polygon(points=[[0,-root_w/2],[0,root_w/2],[len,tip_w/2],[len,-tip_w/2]]);
  color([0.18,0.18,0.22]) linear_extrude(height=t*0.2, center=true)
    offset(delta=1.2)
      polygon(points=[[0,-root_w/2],[0,root_w/2],[len,tip_w/2],[len,-tip_w/2]]);
  color("silver") rotate([0,90,0]) cylinder(h=4, r=2.2, center=true);
}

module parker_radiator(w=radiator_w, h=radiator_h, t=radiator_t){
  color([0.92,0.92,1.0]) cube([w,t,h], center=true);
  for(i=[-3:3]) translate([i*6,0,0]) color([0.85,0.85,0.95]) cube([1.2,t+0.2,h-6], center=true);
}

module torus_arc(R=10, r=1, ang=90){
  rotate_extrude(angle=ang) translate([R,0,0]) circle(r=r);
}

module cooling_loops(){
  color([0.75,0.75,0.8])
  for(s=[-1,1]){
    translate([ p_bus_w/2 + shield_gap - 12, s*(p_bus_d/2 - 8), 0]) rotate([0,90,0]) cylinder(h=20, r=1.2);
    translate([ p_bus_w/2 + 10, s*(p_bus_d/2 - 8), 0]) rotate([0,0,90]) torus_arc(R=18, r=1.2, ang=90);
    translate([ -p_bus_w/2 - radiator_back_offset + 6, s*(p_bus_d/2 - 8), 0])
      rotate([0,90,0]) cylinder(h=(p_bus_w/2 + radiator_back_offset - 6)+(p_bus_w/2 - 10), r=1.2);
  }
}

module fields_whips(){
  for(a=[-35,35,145,-145])
    rotate([0,0,a]) translate([shield_d/2 - 10,0,shield_thk])
      rotate([0,-10,0]) color([0.85,0.85,0.9]) rotate([0,90,0]) cylinder(h=whip_len, r=whip_r);
}

module dish_parabola(d=dish_diameter, depth=dish_depth, t=dish_thickness, profile_steps=36)

module rear_comms_and_boom(){
  translate([ -p_bus_w/2 - 24, 0, 0]){
    color("silver") rotate([0,90,0])
      ring(h=3, r_outer=18, r_inner=14);
    // Antena parabólica trasera
    rotate([0,90,0])
      dish_parabola(d=back_dish_d, depth=back_dish_depth, t=1.0);
  }
  // Boom instrumentos hacia -X
  translate([ -p_bus_w/2 - 10, 0, 0]){
    color("silver") rotate([0,90,0]) cylinder(h=boom_len_back, r=1.8);
    translate([-boom_len_back,0,0])
      color([0.8,0.8,0.2]) sphere(r=boom_tip_r);
  }
}




