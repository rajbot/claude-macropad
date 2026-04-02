// Claude Macropad Case - Auto-generated
// Space-invader shaped top-shell case
// Print: flip upside-down (top plate on build plate)

$fn = 48;

outer = [[17.70, 83.30], [118.30, 83.30], [118.30, 55.30], [138.30, 55.30], [138.30, 30.70], [118.30, 30.70], [118.30, -2.30], [17.70, -2.30], [17.70, 30.70], [-2.30, 30.70], [-2.30, 55.30], [17.70, 55.30]];
inner = [[19.70, 81.30], [116.30, 81.30], [116.30, 53.30], [136.30, 53.30], [136.30, 32.70], [116.30, 32.70], [116.30, -0.30], [19.70, -0.30], [19.70, 32.70], [-0.30, 32.70], [-0.30, 53.30], [19.70, 53.30]];

total_h = 11.1;
top_t = 1.5;
wall = 2.0;

module cross_shape(pts, h) {
    linear_extrude(height=h)
        polygon(points=pts);
}

// Main case shell: outer walls + top plate, hollow inside
module case_shell() {
    difference() {
        // Outer solid
        cross_shape(outer, total_h);

        // Inner cavity (from z=0 up to top plate underside)
        translate([0, 0, -0.1])
            cross_shape(inner, total_h - top_t + 0.1);
    }
}

// Standoffs hanging from top plate underside
module standoffs() {
    standoff_z_bot = total_h - top_t - 5.0;
    standoff_z_top = total_h - top_t;

    translate([25, 76, standoff_z_bot])
        cylinder(h=5.0, d=5.0);

    translate([111, 76, standoff_z_bot])
        cylinder(h=5.0, d=5.0);

    translate([25, 5, standoff_z_bot])
        cylinder(h=5.0, d=5.0);

    translate([111, 5, standoff_z_bot])
        cylinder(h=5.0, d=5.0);

}

// All holes to cut
module all_cutouts() {

    // M2 screw holes - blind, stop before top plate
    // Go from bottom (z=0) through standoff but not through top plate
    screw_depth = total_h - top_t + 0.1;  // up to underside of top plate

    translate([25, 76, -0.1])
        cylinder(h=screw_depth, d=1.7);

    translate([111, 76, -0.1])
        cylinder(h=screw_depth, d=1.7);

    translate([25, 5, -0.1])
        cylinder(h=screw_depth, d=1.7);

    translate([111, 5, -0.1])
        cylinder(h=screw_depth, d=1.7);

    // 1u switch cutout
    translate([61.0, 25.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([36.0, 60.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([80.0, 25.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([86.0, 60.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([61.0, 44.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([3.0, 36.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([91.0, 6.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([119.0, 36.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([42.0, 25.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 1u switch cutout
    translate([31.0, 6.0, total_h - top_t - 0.1])
        cube([14.0, 14.0, top_t + 0.2]);

    // 2u switch cutout (wider for stabilizers)
    translate([51.35, 6.0, total_h - top_t - 0.1])
        cube([33.3, 14.0, top_t + 0.2]);

    // USB-C cutout
    translate([63.0, 81.2, 3.5999999999999996])
        cube([10.0, 2.2, 5.0]);

}

// Space invader legs extending from bottom edge
// 4 legs: outer pair (angled out) + inner pair (big center gap)
// Proportions matched from reference image
module legs() {
    leg_depth = 20;      // how far legs extend down (negative y)
    leg_h = total_h;     // full case height
    y_start = -2.30;     // bottom outer edge of case body

    // All legs within body width (17.7 to 118.3)
    // Pattern: outer, gap, inner, big center gap, inner, gap, outer

    // Left outer leg - flush with body left edge (17.7)
    translate([17.70, y_start - leg_depth, 0])
        cube([11, leg_depth, leg_h]);

    // Left inner leg
    translate([36.5, y_start - leg_depth, 0])
        cube([12, leg_depth, leg_h]);

    // Right inner leg
    translate([86.5, y_start - leg_depth, 0])
        cube([13, leg_depth, leg_h]);

    // Right outer leg - flush with body right edge (118.3)
    translate([118.30 - 11, y_start - leg_depth, 0])
        cube([11, leg_depth, leg_h]);
}

// Bottom plate - flat plate with M2 through-holes, fits inside the walls
// Prints flat, screws onto bottom of standoffs through PCB
bottom_t = 1.5;

module bottom_plate() {
    difference() {
        // Plate matches inner cavity outline so it sits inside the walls
        linear_extrude(height=bottom_t)
            polygon(points=inner);

        // M2 clearance holes (2.4mm for M2 screw to pass through)
        for (pos = [[25, 76], [111, 76], [25, 5], [111, 5]]) {
            translate([pos[0], pos[1], -0.1])
                cylinder(h=bottom_t + 0.2, d=2.4);
        }

        // USB-C clearance notch in the edge
        translate([63.0, 81.30 - 1, -0.1])
            cube([10.0, 3, bottom_t + 0.2]);
    }
}

// Top shell assembly
color("orange")
difference() {
    union() {
        case_shell();
        standoffs();
        legs();
    }
    all_cutouts();
}

// Bottom plate - shown offset for preview, prints as separate piece
color([0.15, 0.15, 0.15])
translate([0, 0, -5])  // offset for visibility in preview
    bottom_plate();
