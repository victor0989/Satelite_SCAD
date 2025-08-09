boardThick = 2;
boardWidth = 107;
boardDepth = 55;
holeRad = 2;

// =================== HDMI BOARD ===================
module hdmiBoard(ext) {
    Extrude = ext; // Extrude the ports or set to 0 for real board
    difference() {
        $fn = 100;
        union() {
            // Main board
            color([0, .5, 0]) cube([boardWidth, boardDepth, boardThick]);
            
            // Power port
            color([.2, .2, .2]) translate([6, boardDepth-15, boardThick])
                cube([9, 15+Extrude, 11]);

            // Audio port
            color([0, 0, 0.6]) translate([7, boardDepth-15, boardThick])
                cube([7, 15+Extrude, 10]);

            // VGA port
            color([0, 0, 0.6]) translate([29, boardDepth-9, boardThick])
                cube([31, 15+Extrude, 13]);

            // HDMI port
            color([.9, .9, .9]) translate([74, boardDepth-9.5, boardThick])
                cube([15, 11+Extrude, 6]);

            // Display cable (30 pin)
            color([.9, .9, .9]) translate([62, 0-Extrude, boardThick])
                cube([20, 7+Extrude, 2]);
        }

        // Mounting holes
        translate([2+holeRad, 5+holeRad, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
        translate([2+holeRad, boardDepth-2.5-holeRad, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
        translate([boardWidth-holeRad-2, boardDepth-holeRad-2, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
        translate([boardWidth-holeRad-3, 11+holeRad, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
    }
}

// =================== PILLAR ===================
module pillar(height, inRad, outRad) {
    $fn = 100;
    difference() {
        cylinder(h=height, r=outRad);
        translate([0, 0, -0.05]) cylinder(h=height+0.1, r=inRad);
    }
}

// =================== HOUSING ===================
module housing(width, depth, height, wallThick, floorThick, inRad, pillarThick, off) {
    boxWidth = width;
    boxDepth = depth;
    boxFloorHeight = floorThick;
    boxWallThick = wallThick;
    boxWallHeight = height;
    screwHoleRad = inRad;
    screwPillarRad = inRad + pillarThick;
    screwEdgeOff = off;

    union() {
        // Base plate
        cube([boxWidth, boxDepth, boxFloorHeight]);
        echo("Dimensions floor plate", boxWidth, boxDepth, boxFloorHeight);

        // Corner pillars
        translate([screwEdgeOff, screwEdgeOff, 0]) pillar(boxWallHeight, screwHoleRad, screwPillarRad);
        translate([boxWidth-screwEdgeOff, screwEdgeOff, 0]) pillar(boxWallHeight, screwHoleRad, screwPillarRad);
        translate([screwEdgeOff, boxDepth-screwEdgeOff, 0]) pillar(boxWallHeight, screwHoleRad, screwPillarRad);
        translate([boxWidth-screwEdgeOff, boxDepth-screwEdgeOff, 0]) pillar(boxWallHeight, screwHoleRad, screwPillarRad);
    }

    // Left wall
    translate([0, boxWallThick, boxFloorHeight]) cube([boxWallThick, boxDepth-boxWallThick, boxWallHeight-boxFloorHeight]);

    // Front wall
    translate([0, 0, boxFloorHeight]) cube([boxWidth, boxWallThick, boxWallHeight-boxFloorHeight]);

    // Right wall
    translate([boxWidth-boxWallThick, 0, boxFloorHeight]) cube([boxWallThick, boxDepth-boxWallThick, boxWallHeight-boxFloorHeight]);

    // Rear wall
    translate([0, boxDepth-boxWallThick, boxFloorHeight]) cube([boxWidth, boxWallThick, boxWallHeight-boxFloorHeight]);
}

// =================== PILLARS (HOLES) ===================
module pillars() {
    $fn = 100;
    translate([2+holeRad, 5+holeRad, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
    translate([2+holeRad, boardDepth-2.5-holeRad, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
    translate([boardWidth-holeRad-2, boardDepth-holeRad-2, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
    translate([boardWidth-holeRad-3, 11+holeRad, -0.01]) cylinder(h=boardThick+0.1, r=holeRad);
}

// =================== BLANKING PLATE ===================
module plate(width, depth, height, inRad, Off) {
    plateWidth = width;
    plateDepth = depth;
    plateHeight = height;
    screwHoleRad = inRad;
    screwEdgeOff = Off;

    difference() {
        cube([plateWidth, plateDepth, plateHeight]);

        // Screw holes
        $fn = 100;
        translate([screwEdgeOff, screwEdgeOff, -0.5]) cylinder(h=plateHeight+1, r=screwHoleRad);
        translate([plateWidth-screwEdgeOff, screwEdgeOff, -0.5]) cylinder(h=plateHeight+1, r=screwHoleRad);
        translate([screwEdgeOff, plateDepth-screwEdgeOff, -0.5]) cylinder(h=plateHeight+1, r=screwHoleRad);
        translate([plateWidth-screwEdgeOff, plateDepth-screwEdgeOff, -0.5]) cylinder(h=plateHeight+1, r=screwHoleRad);
    }
}

// =================== ASSEMBLY ===================
difference() {
    housing(122, 61, 25, 2, 2, 1.5, 1.5, 4);  // Enclosure
    translate([7, 3, 5]) hdmiBoard(20);       // HDMI board cutout
}

translate([7, 4, 2]) pillars();              // Pillars
//translate([7, 4, 5]) hdmiBoard(0);        // Uncomment for visual reference
//translate([0, 0, 70]) plate(122, 61, 2, 1.5, 4);  // Uncomment for top plate



