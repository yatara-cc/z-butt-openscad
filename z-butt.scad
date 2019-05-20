include <makers-mark.scad>


// Constants

unit_u = 19.05;
unit_lego = 1.6;
unit_lego_stud = 5 * unit_lego;


// User Parameteters


plate_size = 32;
plate_height = 3;

regst_inset = 4;  // Distance between plate and registration block.
regst_height = 2;
regst_radius = 4;
regst_offset = 0.1;  // Gap between positive and negative models.

base_size = 18;

indent_size = 12;
indent_depth = 1;

sprue_diameter_base = 3.1;
sprue_diameter_tip = 1.5;
sprue_diameter_stem = 1.4;
sprue_height = 12;
sprue_height_tip = 2;
sprue_max_distance = base_size / 2;

mx_width = 3.9;
mx_thickness = 1.25;
mx_offset = 0.1;  // Gap between positive and negative models.
mx_bevel = 0.25;
mx_diameter = 5.8;
mx_height_base = 3;
mx_height_cavity = 5;

key_cavity_size = 14.925;
key_cavity_ch_xy = 2;
key_cavity_height = 5;
key_cavity_bevel = 0.25;

key_sculpt_size = 14.925;
key_sculpt_ch_xy = 1.8;
key_sculpt_height = 4.5;
key_sculpt_bevel = 0.93;
key_sculpt_diameter = 5.82;


// Internal Parameters


overlap = 0.1;  // Offset to avoid coplanar faces in Boolean operations.


// Functions


function calc_plate_size (u=1) = unit_lego_stud * round((plate_size + unit_u * (u - 1)) / unit_lego_stud);


function calc_base_size (u=1) = base_size + unit_u * (u - 1);


function calc_key_cavity_size (u=1) = key_cavity_size + unit_u * (u - 1);


function calc_key_sculpt_size (u=1) = key_sculpt_size + unit_u * (u - 1);


// See `https://deskthority.net/wiki/Space_by_keyboard`.
function stabs_xu (xu) = 
     (xu == 7) ? [.5, 3.5, 6.5] :
     (xu == 6.25) ? [.5, 3.75, 5.75] :  // (Cherry)
     (xu == 6) ? [.5, 3.5, 5.5] :  // (Cherry)
     (xu == 4) ? [xu / 2 - 1.5, xu / 2, xu / 2 + 1.5] :
     (xu == 3) ? [xu / 2 - 1, xu / 2, xu / 2 + 1] :
     (xu >= 2) ? [xu / 2 - .5, xu / 2, xu / 2 + .5] :
     [xu / 2];


// Generic Geometry Modules


module rotate_z_copy (angle) {
     children();
     rotate([0, 0, angle]) {
          children();
     }
}


module centered_cube (size) {
     // A cube with equal sides in XY and centered in XY.
     translate([-size[0] / 2, -size[1] / 2, 0]) {
          cube(size);
     }
}


module chamfered_cube (sx, sy, sz, ch_xy, ch_z) {
     // An XY-centered cube with chamfered top edges.
     //
     // `ch_xy` = XY chamfer indent
     // `ch_z` = Z chamfer indent

     hull() {
          centered_cube([sx, sy, sz - ch_z]);
          centered_cube([sx - 2 * ch_xy, sy - 2 * ch_xy, sz]);
     }
}


module bevel_corner_cube (sx, sy, sz, r, n) {
     // An XY-centered cube with a bevel on a single corner.
     //
     // `r` = corner radius.
     // `n` = corner segments.

     dx = sx / 2;
     dy = sy / 2;
     cx = dx - r;
     cy = dy - r;
     a = 90 / n;

     points = concat(
          [[-dx, dy]],
          [for (t = [0 : n]) [cx + r * sin(a * t), cy + r * cos(a * t)]],
          [[dx, -dy], [-dx, -dy]]
          );
     
     linear_extrude(sz) {
          polygon(points=points);
     }
}


// Z-Butt Components


module stabs_copy (xu) {
     cx = -xu / 2;
     for (x = stabs_xu(xu)) {
          translate([unit_u * (cx + x), 0, 0]) {
               children();
          }
     }
}


module top_plate (xu) {
     size_x = calc_plate_size(xu);
     size_y = calc_plate_size();

     chamfered_cube (size_x, size_y, key_cavity_height + 2,
                     key_cavity_height + 1, key_cavity_height + 1);
}


module bottom_plate (xu) {
     size_x = calc_plate_size(xu);
     size_y = calc_plate_size();

     rotate([180, 0, 0]) {
          chamfered_cube (size_x, size_y, plate_height, 1, 1);
     }
}


module registration_cube (xu, offset=0) {
     size_x = calc_plate_size(xu) - regst_inset;
     size_y = calc_plate_size() - regst_inset;
     
     translate([0, 0, -regst_height]) {
          bevel_corner_cube(
               size_x + offset, size_y + offset, regst_height + overlap,
               regst_radius + offset, 25);
     }
}


module base (xu) {
     size_x = calc_base_size(xu);
     
     scale([size_x, base_size, regst_height + overlap]) {
          translate([-.5, -.5, -1]) {
               cube([1, 1, 1]);
          }
     }
}


module indent (xu) {
     size_x = indent_size + unit_u * (xu - 1);
     
     translate([0, 0, overlap]) {
          rotate([180, 0, 0]) {
               chamfered_cube(size_x, indent_size, indent_depth + overlap, indent_depth, indent_depth);
          }
     }
}


module bevelled_key (sx, sy, sz, ch_xy, bevel) {
     // `overlap` is added to key base to avoid coplanar intersection.
     
     translate([0, 0, -overlap]) {
          minkowski() {
               chamfered_cube(sx, sy , sz + overlap, ch_xy, sz);
               scale([1, 1, 0]) {
                    sphere(bevel);
               }
          }
     }
}


module key_sculpt (xu) {
     inset = 2 * key_sculpt_bevel;
     sx = calc_key_sculpt_size(xu) - inset;
     sy = calc_key_sculpt_size() - inset;

     bevelled_key(sx, sy, key_sculpt_height, key_sculpt_ch_xy, key_sculpt_bevel, $fn=64);
}


module key_cavity (xu) {
     inset = 2 * key_cavity_bevel;
     sx = calc_key_cavity_size(xu) - inset;
     sy = calc_key_cavity_size() - inset;

     bevelled_key(sx, sy, key_cavity_height, key_cavity_ch_xy, key_cavity_bevel, $fn=32);
}


module sprue_base (height) {
     r = sprue_diameter_base / 2;
     
     rotate_extrude() {
          polygon(points=[
                       [0, 0],
                       [sprue_diameter_tip / 2, 0],
                       [r, -sprue_height_tip],
                       [r, -height],
                       [0, -height],
                       ]);
     }
}


module sprues_base (height, xu) {
     dx = calc_base_size(xu);
     dy = calc_base_size();
     cx = -dx / 2;
     cy = -dy / 2;
     nx = floor(dx / sprue_max_distance);
     ny = floor(dy / sprue_max_distance);
     sx = dx / nx;
     sy = dy / ny;

     rotate_z_copy(180) {
          for (x = [0 : nx - 1]) {
               translate([cx + sx * x, cy, 0]) {
                    sprue_base(height);
               }
          }
          for (y = [0 : ny - 1]) {
               translate([-cx, cy + sy * y, 0]) {
                    sprue_base(height);
               }
          }
     }
}


module sprues_stem (height) {
     d = (mx_diameter - sprue_diameter_stem) / 2;

     for (i = [0 : 3]) {
          rotate([0, 0, 45 + 90 * i]) {
               translate([-d, 0, -height]) {
                    cylinder(h=height, d=sprue_diameter_stem);
               }
          }
     }
}


module mx_cavity () {
     translate([0, 0, -overlap]) {
          cylinder(h=(key_cavity_height + overlap), d=mx_diameter, $fn=48);
     }
}


module mx_cross (height, offset=0) {
     inset = 2 * mx_bevel;
     w = mx_width + offset - inset;
     t = mx_thickness + offset - inset;
     h = height - mx_bevel;

     rotate_z_copy(90) {
          minkowski() {
               translate([-w / 2, -t / 2, 0]) {
                    cube([w, t, h]);
               }
               sphere(mx_bevel, $fn=16);
          }
     }
}


module mx_master_base (xu=1) {
     color("LightSteelBlue") {
          union () {
               difference() {
                    bottom_plate(xu);
                    registration_cube(xu, regst_offset);
               }
               difference() {
                    base(xu);
                    indent(xu);
               }
               sprues_base(regst_height + overlap, xu, $fn=48);
               translate([0, 0, -regst_height]) {
                    stabs_copy(xu) {
                         mx_cross(mx_height_base + regst_height + overlap, offset=-mx_offset);
                    }
               }
          }
     }
}


module mx_sculpt_base (xu=1) {
     color("SteelBlue") {
          difference() {
               union () {
                    difference() {
                         bottom_plate(xu);
                         registration_cube(xu, regst_offset);
                    }
                    sprues_base(regst_height + overlap, xu, $fn=48);
                    base(xu);
                    key_sculpt(xu);
               }
               translate([0, 0, key_sculpt_height - key_cavity_height]) {
                    stabs_copy(xu) {
                         cylinder(h=key_cavity_height + overlap, d=key_sculpt_diameter, $fn=48);
                    }
               }
          }
     }
}


module mx_stem_cavity (xu=1) {
     union () {
          color("CornflowerBlue") {
               difference() {
                    union() {
                         top_plate(xu);
                         registration_cube(xu);
                    }
                    union() {
                         base(xu);
                         difference() {
                              key_cavity(xu);
                              stabs_copy(xu) {
                                   mx_cavity();
                              }
                         }
                    }
                    stabs_copy(xu) {
                         mx_cross(key_cavity_height);
                    }
               }
               sprues_base(sprue_height, xu, $fn=48);
               stabs_copy(xu) {
                    sprues_stem(sprue_height, $fn=48);
               }
          }
          
          color("Yellow") {
               translate([0, key_cavity_size / 2, 0]) {
                    rotate([-atan(key_cavity_height / key_cavity_ch_xy), 180, 180]) {
                         translate([0, 2, 0]) {
                              makers_mark(3);
                         }
                    }
               }
          }
     }
}
