#!/usr/bin/env python3
"""Generate an OpenSCAD file and render it to STL for the Claude Macropad case.

Design: Top-shell case (open bottom) matching the space-invader PCB outline.
- Top plate with Cherry MX switch cutouts (1.5mm thick for clip-in)
- Walls extending downward
- M2 standoffs hanging from top plate
- USB-C cutout in the top wall

Print tip: flip upside-down in slicer (top plate on build plate) for smooth keys.
"""

import subprocess
import os

# ============================================================
# PCB geometry (local coords: x = x_kicad - 32, y = 111 - y_kicad)
# ============================================================

pcb_pts = [
    (20, 81), (116, 81), (116, 53), (136, 53),
    (136, 33), (116, 33), (116, 0), (20, 0),
    (20, 33), (0, 33), (0, 53), (20, 53),
]

mounts = [(25, 76), (111, 76), (25, 5), (111, 5)]

switches_1u = [
    (68, 32), (43, 67), (87, 32), (93, 67),
    (68, 51), (10, 43), (98, 13), (126, 43),
    (49, 32), (38, 13),
]
switch_2u = (68, 13)

usb_center_x = 68

# ============================================================
# Case parameters
# ============================================================

cl = 0.3
wall = 2.0
top_t = 1.5
plate_to_pcb = 5.0
pcb_t = 1.6
below_pcb = 3.0
total_h = below_pcb + pcb_t + plate_to_pcb + top_t  # 11.1

standoff_h = plate_to_pcb
standoff_od = 5.0
m2_hole_d = 1.7

mx_1u = 14.0
mx_2u_w = 33.3
mx_2u_h = 14.0

usb_w = 10.0
usb_h = 5.0
usb_z_center = below_pcb + pcb_t + 1.5

# Fillet radius for outer edges
fillet_r = 1.0


def offset_cross(pts, off):
    return [
        (pts[0][0] - off,  pts[0][1] + off),
        (pts[1][0] + off,  pts[1][1] + off),
        (pts[2][0] + off,  pts[2][1] + off),
        (pts[3][0] + off,  pts[3][1] + off),
        (pts[4][0] + off,  pts[4][1] - off),
        (pts[5][0] + off,  pts[5][1] - off),
        (pts[6][0] + off,  pts[6][1] - off),
        (pts[7][0] - off,  pts[7][1] - off),
        (pts[8][0] - off,  pts[8][1] - off),
        (pts[9][0] - off,  pts[9][1] - off),
        (pts[10][0] - off, pts[10][1] + off),
        (pts[11][0] - off, pts[11][1] + off),
    ]


def pts_to_scad(pts):
    """Format polygon points for OpenSCAD."""
    return "[" + ", ".join(f"[{x:.2f}, {y:.2f}]" for x, y in pts) + "]"


# ============================================================
# Generate OpenSCAD
# ============================================================

outer_pts = offset_cross(pcb_pts, cl + wall)
inner_pts = offset_cross(pcb_pts, cl)

scad = f"""// Claude Macropad Case - Auto-generated
// Space-invader shaped top-shell case
// Print: flip upside-down (top plate on build plate)

$fn = 48;

outer = {pts_to_scad(outer_pts)};
inner = {pts_to_scad(inner_pts)};

total_h = {total_h};
top_t = {top_t};
wall = {wall};

module cross_shape(pts, h) {{
    linear_extrude(height=h)
        polygon(points=pts);
}}

// Main case shell: outer walls + top plate, hollow inside
module case_shell() {{
    difference() {{
        // Outer solid
        cross_shape(outer, total_h);

        // Inner cavity (from z=0 up to top plate underside)
        translate([0, 0, -0.1])
            cross_shape(inner, total_h - top_t + 0.1);
    }}
}}

// Standoffs hanging from top plate underside
module standoffs() {{
    standoff_z_bot = total_h - top_t - {standoff_h};
    standoff_z_top = total_h - top_t;
"""

for mx, my in mounts:
    scad += f"""
    translate([{mx}, {my}, standoff_z_bot])
        cylinder(h={standoff_h}, d={standoff_od});
"""

scad += """
}

// All holes to cut
module all_cutouts() {
"""

# M2 screw holes (through standoffs + top plate)
for mx, my in mounts:
    scad += f"""
    // M2 screw hole
    translate([{mx}, {my}, -0.1])
        cylinder(h=total_h + 0.2, d={m2_hole_d});
"""

# 1u switch cutouts in top plate
for sx, sy in switches_1u:
    scad += f"""
    // 1u switch cutout
    translate([{sx - mx_1u/2}, {sy - mx_1u/2}, total_h - top_t - 0.1])
        cube([{mx_1u}, {mx_1u}, top_t + 0.2]);
"""

# 2u switch cutout
sx, sy = switch_2u
scad += f"""
    // 2u switch cutout (wider for stabilizers)
    translate([{sx - mx_2u_w/2}, {sy - mx_2u_h/2}, total_h - top_t - 0.1])
        cube([{mx_2u_w}, {mx_2u_h}, top_t + 0.2]);
"""

# USB-C cutout through top wall
usb_y_inner = pcb_pts[0][1] + cl
scad += f"""
    // USB-C cutout
    translate([{usb_center_x - usb_w/2}, {usb_y_inner - 0.1}, {usb_z_center - usb_h/2}])
        cube([{usb_w}, {wall + 0.2}, {usb_h}]);
"""

scad += """
}

// Final assembly
difference() {
    union() {
        case_shell();
        standoffs();
    }
    all_cutouts();
}
"""

# ============================================================
# Write OpenSCAD file and render to STL
# ============================================================

base_dir = "/Users/rajkumar/dev/claude-macropad"
scad_path = os.path.join(base_dir, "case.scad")
stl_path = os.path.join(base_dir, "case.stl")

with open(scad_path, "w") as f:
    f.write(scad)
print(f"Wrote OpenSCAD: {scad_path}")

# Render to STL
print("Rendering STL (this may take a moment)...")
result = subprocess.run(
    ["openscad", "-o", stl_path, scad_path],
    capture_output=True, text=True, timeout=120
)

if result.returncode == 0:
    size_kb = os.path.getsize(stl_path) / 1024
    width = outer_pts[3][0] - outer_pts[9][0]
    depth = outer_pts[0][1] - outer_pts[6][1]
    print(f"Exported: {stl_path} ({size_kb:.0f} KB)")
    print(f"Case size: {width:.1f} x {depth:.1f} x {total_h:.1f} mm")
    print(f"Switch cutouts: {len(switches_1u)} x 1u + 1 x 2u")
    print(f"Mounting holes: {len(mounts)} x M2 (self-tapping {m2_hole_d}mm)")
    print(f"Print: flip upside-down, top plate on build plate, orange PLA")
else:
    print(f"OpenSCAD error:\n{result.stderr}")
