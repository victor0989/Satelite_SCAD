color_def = [0,0.5,0.7];
//----------------------------------
// The modules
module Touchscreen(color=color_def) {
    color(color)
        translate([-50,0,0])
            import("Xadow_1_54_Touhscreen_collapsed.stl");
}
module GSM_BLE(color=color_def) {
    color(color)
        translate([0.65,-0.61,0])
            rotate([0,0,90])
                import("Xadow_GSM_BLE_v1_collapsed.stl");
}
module GSM_Breakout(color=color_def) {
    color(color)
        rotate([0,0,90])
            translate([0,0,0])
                import("Xadow___GSM_Breakout_v1_collapsed.stl");
}
module Audio(color=color_def) {
    color(color)
        rotate([0,0,90])
            translate([-91.42,-45.06,0])
                import("Xadow_Audio_v1.stl");
}
difference(){
    translate([-5,-65,-2]) cube([58,120,2]);
    union(){
        Touchscreen();
        translate ([39.5,-15,0]) GSM_Breakout();
        translate ([9.5,-15,0]) Audio();
        translate ([39,-45,0]) GSM_BLE();
    }
}




