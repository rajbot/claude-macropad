// Claude Macropad - Bottom Plate
// Prints flat. Screws onto standoffs through PCB mounting holes.

$fn = 48;

inner = [[19.70, 81.30], [116.30, 81.30], [116.30, 53.30], [136.30, 53.30], [136.30, 32.70], [116.30, 32.70], [116.30, -0.30], [19.70, -0.30], [19.70, 32.70], [-0.30, 32.70], [-0.30, 53.30], [19.70, 53.30]];

bottom_t = 1.5;

color([0.15, 0.15, 0.15])
difference() {
    linear_extrude(height=bottom_t)
        polygon(points=inner);

    // M2 clearance holes (2.4mm)
    for (pos = [[25, 76], [111, 76], [25, 5], [111, 5]]) {
        translate([pos[0], pos[1], -0.1])
            cylinder(h=bottom_t + 0.2, d=2.4);
    }

    // USB-C clearance notch
    translate([63.0, 81.30 - 1, -0.1])
        cube([10.0, 3, bottom_t + 0.2]);
}
