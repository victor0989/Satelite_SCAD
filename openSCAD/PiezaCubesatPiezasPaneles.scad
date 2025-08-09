$fn = 100;

caseRim = 3;
kbD = 82;
kbW = 210;
kbH = 7;
odH = 10;
odW = 156;
odD = 73;
odJSH = 6;

// Odroid cutout dimensions
odJSW = 28 - 13;
odJSR = odJSW / 2;
odJSoffX = 13;
odJSoffY = 11;
odBRW = 118 - 38;
odBRD = 12 - 5;
odBRoffX = 38;
odBRoffY = 5;
odCRW = 28 - 7;
odCRD = 58 - 37;
odCRoffX = 7;
odCRoffY = 37;
odTBW = 152 - 120;
odTBD = 61 - 27;
odTBoffX = 120;
odTBoffY = 27;
odTLoffX = 23;
odTLoffY = odD;
odTLW = 33 - 23;
odTLD = 2;
odTH = 20;
odTRoffX = 123;
odTRoffY = odD;
odTRW = odTLW;
odTRD = odTLD;
odDPW = odBRW;
odDPD = 67 - 14;
odDPoffY = 14;
odDPoffX = odBRoffX;

// Crea una caja abierta sin tapa
module containerOpenLid(width, depth, height, wall, floor, nibDir, tol) {
    difference() {
        // Caja externa
        cube([width + wall * 2, depth + wall * 2, height + floor]);
        // Hueco interior
        translate([wall, wall, floor])
            cube([width, depth, height + 1]);
    }
}

// Ranura vertical para periféricos
module containerVertSlot(width, depth, height, wall, floor, nibDir, tol) {
    cube([width, depth, height]);
}

// Caja principal con recortes
difference() {
    translate([caseRim / 2, caseRim / 2, odJSH])
        containerOpenLid(odW, odD, odH, caseRim, odJSH - caseRim, "nibY", 0.6);

    offset = 0.01;
    translate([1.5, .75, -offset / 2]) union() {
        translate([odW - odJSR * 2 - odJSoffX, odJSoffY, 0] + [odJSR, odJSR, 0])
            cylinder(h = odJSH + offset, r = odJSR);
        translate([odW - odBRW - odBRoffX, odBRoffY, 0])
            cube([odBRW, odBRD, odJSH + offset]);
        translate([odW - odCRW - odCRoffX, odCRoffY, 0])
            cube([odCRW, odCRW, odJSH + offset]);
        translate([odW - odTBW - odTBoffX, odTBoffY, 0])
            cube([odTBW, odTBW, odJSH + offset]);
        translate([odW - odTLW - odTLoffX, odTLoffY, odJSH - .1])
            cube([odTLW, odTLD, odTH + offset]);
        translate([odW - odTRW - odTRoffX, odTRoffY, odJSH - .1])
            cube([odTRW, odTRD, odTH + offset]);
        translate([odW - odDPW - odDPoffX, odDPoffY, 0])
            cube([odDPW, odDPD, odJSH + offset]);
    }
}

// Slots para periféricos
floorDepth = 0;
// Microuter slot
translate([caseRim / 2 + caseRim + odW, caseRim / 2, floorDepth])
    containerVertSlot(12, odD, odH + odJSH, caseRim, floorDepth - caseRim, "nibY", .6);

// Micro USB 3 Port Hub
translate([caseRim / 2 + 2 * caseRim + odW + 12, caseRim / 2, floorDepth])
    containerVertSlot(19.5, odD, odH + odJSH, caseRim, floorDepth - caseRim, "nibY", .6);

