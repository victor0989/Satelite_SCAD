// This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
// Dario Pellegrini, Padova (IT) 2019/8
// <pellegrini.dario@gmail.com>

include <PolyGearBasics.scad>

////////////////////////////////////////
// DEMO MODULE
module PGDemo(t=0) {
    // Usamos el parámetro t en lugar de $t para evitar conflictos
    bevel_pair(w=5, n1=17, n2=13, only=0, axis_angle=60, helix_angle = zerol(40));

    Rz(360*t/17)
    Tz(-10)
        spur_gear(n=17, pressure_angle=20, z=10, chamfer=30, 
                  helix_angle = [ for (x = linspace(-1, 1, 11)) exp(-abs(x))*50*sign(x) ]);

    Tz(-10)
    Rz(-360/17*2)
    Ty((13+17)/2)
    Mx()
    Rz(360*t/13)
        spur_gear(n=13, pressure_angle=20, z=10, chamfer=30, 
                  helix_angle = [ for (x = linspace(-1, 1, 11)) exp(-abs(x))*50*sign(x) ]);

    Rz(360*t/17)
    Mz()
        Cy(h=10, r=3, C=0, $fn=17);
}

PGDemo();

////////////////////////////////////////
// HELIX PROFILES
function constant(helix=45, $fn=9) = lst_repeat(helix, $fn);
function zerol(helix=30, $fn=9)    = linspace(-helix, helix, $fn);
function spiral(helix=30, $fn=9)   = linspace(-helix, 0, $fn);
function herringbone(helix=30, $fn=9) =
    let(n=floor($fn/2)) concat(lst_repeat(-helix, n), [0], lst_repeat(helix, n));

////////////////////////////////////////
// SPUR GEAR
module spur_gear(
    n = 16,
    m = 1,
    z = 1,
    pressure_angle = 20,
    helix_angle    = 0,
    backlash       = 0.1,
    w  = undef,
    a0 = undef,
    b0 = undef,
    tol= undef,
    chamfer       = 0,
    chamfer_shift = 0,
    add = 0,
    ded = 0,
    x   = 0,
    type= 1,
    $fn=5
) {
    z = is_undef(w) ? z : w;
    pressure_angle = is_undef(a0) ? pressure_angle : a0;
    helix_angle    = let(hlx = is_undef(b0) ? helix_angle : b0) is_list(hlx) ? hlx : [hlx, hlx];
    backlash       = is_undef(tol) ? backlash : tol;

    fz = len(helix_angle);
    pts = flatten([for (i=[0:fz-1]) let(zi= z*i/(fz-1) - z/2)
        gear_section(n=n, m=m, z=zi, pressure_angle=pressure_angle, helix_angle=helix_angle[i], backlash=backlash, add=add, ded=ded, x=x, type=type, $fn=$fn)
    ]);

    Nlay = len(pts)/fz;
    side = make_side_faces(Nlay, fz);
    caps = make_cap_faces(Nlay, fz, n);

    if (chamfer == 0) {
        polyhedron(points=pts, faces=concat(side, caps));
    } else {
        render(10) {
            polyhedron(points=pts, faces=concat(side, caps));
            MKz()
                let(t = chamfer, rc = m*n/2 + m*chamfer_shift)
                Cy(r1=z/2/tan(t)+rc, r2=0, h=rc*tan(t)+z/2, C=0, $fn=n);
        }
    }
}

////////////////////////////////////////
// BEVEL GEAR
module bevel_gear(
    n = 16,
    m = 1,
    w = 1,
    cone_angle     = 45,
    pressure_angle = 20,
    helix_angle    = 0,
    backlash       = 0.1,
    z  = undef,
    a0 = undef,
    b0 = undef,
    tol= undef,
    add = 0,
    ded = 0,
    x   = 0,
    type= 1,
    $fn=5
) {
    z = is_undef(z) ? w*cos(cone_angle) : z;
    pressure_angle = is_undef(a0) ? pressure_angle : a0;
    helix_angle    = let(hlx = is_undef(b0) ? helix_angle : b0) is_list(hlx) ? hlx : [hlx/2, hlx/2];
    backlash       = is_undef(tol) ? backlash : tol;

    fz = len(helix_angle);
    r0 = m*n/2;
    H0 = r0/tan(cone_angle);

    pts = flatten([
        for (i=[0:fz-1]) let(wi=i*w/fz, zi=i*z/(fz-1), H=H0-zi, R=H/cos(cone_angle))
            Tzpts(fold_on_sphere(
                Tzpts(gear_section(n=n, m=m*H/H0, z=wi-w/2, pressure_angle=pressure_angle, helix_angle=helix_angle[i], backlash=backlash, add=add, ded=ded, x=x, type=type, $fn=$fn), -wi+w/2),
                R, [0,0,H]), zi)
    ]);

    Nlay = len(pts)/fz;
    side = make_side_faces(Nlay, fz);
    caps = make_cap_faces(Nlay, fz, n);

    polyhedron(points=pts, faces=concat(side, caps));
}

////////////////////////////////////////
// BEVEL PAIR
module bevel_pair(
    n1 = 16,
    n2 = 16,
    m = 1,
    w = 1,
    axis_angle     = 90,
    pressure_angle = 0,
    helix_angle    = 0,
    backlash       = 0.1,
    only           = 0,
    a0 = undef,
    b0 = undef,
    tol= undef,
    add = 0,
    ded = 0,
    x   = 0,
    type= 1,
    $fn=5
){
    a = axis_angle;
    b = 90-a;
    r1 = m*n1/2;
    r2 = m*n2/2;

    c1 = (b==0) ? atan(r1/r2) : let(xx = r1 + r2/sin(b), yy = xx*tan(b)) assert(yy>0, "Internal crown not implemented") atan(r1/yy);
    c2 = a - c1;

    gear2x = r1 + r2*cos(a);
    gear2z = r2*sin(a);

    pressure_angle = is_undef(a0) ? pressure_angle : a0;
    helix_angle    = is_undef(b0) ? helix_angle : b0;
    backlash       = is_undef(tol) ? backlash : tol;

    if (only != 2) {
        Rz(360*0/n1)
            bevel_gear(n=n1, m=m, w=w, cone_angle=c1, pressure_angle=pressure_angle, helix_angle=helix_angle, backlash=backlash, add=add, ded=ded, x=x, type=type, $fn=$fn);
    }

    if (only != 1) {
        move = only==2 ? 0 : 1;
        T(-gear2x*move, 0, gear2z*move)
        Ry(a*move)
        Rz(360/n2/2*move)
        Mx()
        Rz(360*0/n2)
            bevel_gear(n=n2, m=m, w=w, cone_angle=c2, pressure_angle=pressure_angle, helix_angle=helix_angle, backlash=backlash, add=add, ded=ded, x=-x, type=type, $fn=$fn);
    }
}








