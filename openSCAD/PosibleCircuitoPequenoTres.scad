$fn=100;

module xadow_pin(){
    union(){
        translate([0,0,0]) cylinder(h=1,r1=1,r2=1);
        translate([0,0,1]) cylinder(h=3,r1=1,r2=0.5);
    }
}

module xadow_gsm(){
    difference(){
        union(){
            // Xadow module approx dimensions 25.4mm x 20.3mm x 0.75mm
            cube([25.4,20.3,0.75]);
            translate([3,1.5,0]) xadow_pin();
            translate([21.4,1.5,0]) xadow_pin();
            translate([3,18.5,0]) xadow_pin();
            translate([21.4,18.5,0]) xadow_pin();
        }
        translate([25.4,20.3,0]) cylinder(h=1,r1=1,r2=1);
    }
}

xadow_gsm();




