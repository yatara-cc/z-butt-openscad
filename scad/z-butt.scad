include <makers-mark.scad>


// Constants

unit_u = 19.05;
unit_lego = 1.6;
unit_lego_stud = 5 * unit_lego;


// User Parameteters


plate_size = 32;
plate_height = 3;
plate_chamfer = 1;
plate_inset = 0;  // Distance to shrink the main plate size.

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
sprue_plate_height = 1;
sprue_plate_width = 1.5;

mx_width = 4.21;
mx_thickness = 1.25;
mx_offset = 0.1;  // Gap between positive and negative models.
mx_cone = 1;
mx_bevel = 0.25;
mx_diameter = 5.6;
mx_height_base = 3;
mx_height_cavity = 5;

al_w1 = 4.95;
al_l1 = 5.95;
al_w2 = 0.95;
al_l2 = 7.85;
al_w0 = 2.25;
al_l0 = 4.5;
al_wd = 2.5;
al_height = 3.9;
al_stem_l1 = 4.45;
al_stem_w1 = 2.2;
al_stem_l0 = 2.55;
al_stem_w0 = 0.9;
al_stem_ch = 0.5;

key_cavity_size = 14.925;
key_cavity_ch_xy = 2;
key_cavity_height = 5;
key_cavity_bevel = 0.25;

key_sculpt_size = 14.925;
key_sculpt_ch_xy = 1.8;
key_sculpt_height = 4.5;
key_sculpt_bevel = 0.93;
key_sculpt_diameter = 5.82;

container_wall = 3;
container_base = 2;
container_overlap = unit_lego_stud / 2;
container_height = 28;  // Internal height
container_inset = 0.1;  // XY Gap between contents and internal container walls.
container_gap_edge = 0.1;  // XY Gap between connecting container edges.
container_clips = true;
container_clip_inset = 0.15;  // Gap between touching clip faces.


// Internal Parameters


overlap = 0.1;  // Offset to avoid coplanar faces in Boolean operations.
container_clip_width = unit_lego_stud / 2;
container_clip_extension = unit_lego_stud - 2 * container_wall;


// Functions


function calc_xu (xu=1, name="") = 
     (name == "iso-enter") ? 1.5 :
     (name == "big-ass-enter") ? 2.25 :
     xu;

function calc_yu (yu=1, name="") = 
     (name == "iso-enter") ? 2 :
     (name == "big-ass-enter") ? 2 :
     yu;


function calc_plate_size (u=1) = unit_lego_stud * round((plate_size + unit_u * (u - 1)) / unit_lego_stud);


function calc_base_size (u=1) = base_size + unit_u * (u - 1);


function calc_key_cavity_size (u=1) = key_cavity_size + unit_u * (u - 1);


function calc_key_sculpt_size (u=1) = key_sculpt_size + unit_u * (u - 1);


// See `https://deskthority.net/wiki/Space_by_keyboard`.
function stabilizers_xy (xu=1, yu=1, name="") = 
     (name == "iso-enter") ? [[0.125, -0.5], [0.125, 0.5]] :
     (name == "big-ass-enter") ? [[0.5, -0.5], [0.5, 0.5]] :
     (xu == 7) ? [[-3, 0], [3, 0]] :
     (xu == 6.25) ? [[-xu / 2 + 0.5, 0], [-xu / 2 + 5.75, 0]] :  // (Cherry)
     (xu == 6) ? [[-2.5, 0], [2.5, 0]] :  // (Cherry)
     (xu == 4) ? [[-1.5, 0], [1.5, 0]] :
     (xu == 3) ? [[-1, 0], [1, 0]] :
     (xu >= 2) ? [[-0.5, 0], [0.5, 0]] :
     [];


// See `https://deskthority.net/wiki/Space_by_keyboard`.
function switches_xy (xu=1, yu=1, name="") = 
     (name == "iso-enter") ? [[0.125, 0]] :
     (name == "big-ass-enter") ? [[0.5, 0], [-0.625, -0.5]] :
     (xu == 7) ? [[0, 0]] :
     (xu == 6.25) ? [[-xu / 2 + 3.75, 0]] :  // (Cherry)
     (xu == 6) ? [[0.5, 0]] :  // (Cherry)
     [[0, 0]];


// Generic Geometry Modules


module rotate_z_copy (angle) {
     children();
     rotate([0, 0, angle]) {
          children();
     }
}


module translate_copy (v, n=2) {
     for (i = [0 : n - 1]) {
          translate([v[0] * i, v[1] * i, v[2] * i]) {
               children();
          }
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



module bevel_corner_square (sx, sy, r, n) {
     // An XY-centered square with a bevel on a single corner.
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
     
     polygon(points=points);
}


// Z-Butt Components


module stem_copy (xu=1, yu=1, name="", switches=true, stabilizers=true) {
     if (switches) {
          for (xy = switches_xy(xu=xu, yu=yu, name=name)) {
               translate([unit_u * xy[0], unit_u * xy[1], 0]) {
                    children();
               }
          }
     }
     if (stabilizers) {
          for (xy = stabilizers_xy(xu=xu, yu=yu, name=name)) {
               translate([unit_u * xy[0], unit_u * xy[1], 0]) {
                    children();
               }
          }
     }
}


module top_plate (xu=1, yu=1) {
     chamfered_cube (
          calc_plate_size(xu) - plate_inset,
          calc_plate_size(yu) - plate_inset,
          key_cavity_height + plate_height - plate_chamfer,
          key_cavity_height, key_cavity_height);
}


module bottom_plate (xu=1, yu=1) {
     rotate([180, 0, 0]) {
          chamfered_cube (
               calc_plate_size(xu) - plate_inset,
               calc_plate_size(yu) - plate_inset,
               plate_height,
               plate_chamfer, plate_chamfer);
     }
}


module registration_cube (xu=1, yu=1, offset=0) {
     size_x = calc_plate_size(xu) - regst_inset;
     size_y = calc_plate_size(yu) - regst_inset;

     translate([0, 0, -regst_height]) {
          linear_extrude(regst_height + overlap) {
               bevel_corner_square(
                    size_x + offset,
                    size_y + offset,
                    regst_radius + offset, 25);
          }
     }
}


module base (xu=1, yu=1, name="") {
     if (name == "iso-enter") {
          union() {
               translate([0, 0.5 * unit_u, 0]) {
                    base(1.5, 1);
               }
               translate([0.125 * unit_u, 0, 0]) {
                    base(1.25, 2);
               }
          }
     } else if (name == "big-ass-enter") {
          union() {
               translate([0.375 * unit_u, 0, 0]) {
                    base(1.5, 2);
               }
               translate([0, -0.5 * unit_u, 0]) {
                    base(2.25, 1);
               }
          }
     } else {
          size_x = calc_base_size(xu);
          size_y = calc_base_size(yu);
     
          scale([size_x, size_y, regst_height + overlap]) {
               translate([-.5, -.5, -1]) {
                    cube([1, 1, 1]);
               }
          }
     }
}


module indent (xu, yu, name="") {
     if (name == "iso-enter") {
          union() {
               translate([0, 0.5 * unit_u, 0]) {
                    indent(1.5, 1);
               }
               translate([0.125 * unit_u, 0, 0]) {
                    indent(1.25, 2);
               }
          }
     } else if (name == "big-ass-enter") {
          union() {
               translate([0.375 * unit_u, 0, 0]) {
                    indent(1.5, 2);
               }
               translate([0, -0.5 * unit_u, 0]) {
                    indent(2.25, 1);
               }
          }
     } else {
          size_x = indent_size + unit_u * (xu - 1);
          size_y = indent_size + unit_u * (yu - 1);
     
          translate([0, 0, overlap]) {
               rotate([180, 0, 0]) {
                    chamfered_cube(size_x, size_y, indent_depth + overlap, indent_depth, indent_depth);
               }
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


module key_sculpt (xu=1, yu=1, name="") {
     if (name == "iso-enter") {
          union() {
               translate([0, 0.5 * unit_u, 0]) {
                    key_sculpt(1.5, 1);
               }
               translate([0.125 * unit_u, 0, 0]) {
                    key_sculpt(1.25, 2);
               }
          }
     } else if (name == "big-ass-enter") {
          union() {
               translate([0.375 * unit_u, 0, 0]) {
                    key_sculpt(1.5, 2);
               }
               translate([0, -0.5 * unit_u, 0]) {
                    key_sculpt(2.25, 1);
               }
          }
     } else {
          inset = 2 * key_sculpt_bevel;
          sx = calc_key_sculpt_size(xu) - inset;
          sy = calc_key_sculpt_size(yu) - inset;

          bevelled_key(sx, sy, key_sculpt_height, key_sculpt_ch_xy, key_sculpt_bevel, $fn=64);
     }
}


module key_cavity (xu=1, yu=1) {
     inset = 2 * key_cavity_bevel;
     sx = calc_key_cavity_size(xu) - inset;
     sy = calc_key_cavity_size(yu) - inset;

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


module sprue_copy (length, include_last=false) {
     n = floor(length / sprue_max_distance);
     x = length / n;
     
     for (i = [0 : n - 1]) {
          translate([x * i, 0, 0]) {
               children();
          }
     }
     if (include_last) {
          translate([x * n, 0, 0]) {
               children();
          }
     }
}


module sprues_base (height, xu=1, yu=1, name="") {
     if (name == "iso-enter") {
          dxa = calc_base_size(1.5);
          dxb = calc_base_size(1.25);
          dya = calc_base_size(2);
          dyb = calc_base_size(1);
          translate([-dxa / 2, dya / 2, 0]) {
               sprue_copy(dxa, sprue_max_distance, include_last=false) {
                    sprue_base(height);
               }
          }
          rotate([0, 0, 90]) {
               translate([-dya / 2, dxb - dxa / 2, 0]) {
                    sprue_copy(dya - dyb, sprue_max_distance) {
                         sprue_base(height);
                    }
               }
               translate([(dya / 2) - dyb, dxa / 2, 0]) {
                    sprue_copy(dyb, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
          }
          rotate([0, 0, 180]) {
               translate([-dxa / 2, dya / 2, 0]) {
                    sprue_copy(dxb, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
          }
          rotate([0, 0, 270]) {
               translate([-dya / 2, dxa / 2, 0]) {
                    sprue_copy(dya, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
          }
     } else if (name == "big-ass-enter") {
          dxa = calc_base_size(2.25);
          dxb = calc_base_size(1.5);
          dya = calc_base_size(2);
          dyb = calc_base_size(1);
          translate([dxa / 2 - dxb, dya / 2, 0]) {
               sprue_copy(dxb, sprue_max_distance, include_last=false) {
                    sprue_base(height);
               }
          }
          translate([-dxa / 2, dyb - (dya / 2), 0]) {
               sprue_copy(dxa - dxb, sprue_max_distance, include_last=false) {
                    sprue_base(height);
               }
          }
          rotate([0, 0, 90]) {
               translate([dyb - (dya / 2), dxb - dxa / 2, 0]) {
                    sprue_copy(dya - dyb, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
               translate([-dya / 2, dxa / 2, 0]) {
                    sprue_copy(dyb, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
          }
          rotate([0, 0, 180]) {
               translate([-dxa / 2, dya / 2, 0]) {
                    sprue_copy(dxa, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
          }
          rotate([0, 0, 270]) {
               translate([-dya / 2, dxa / 2, 0]) {
                    sprue_copy(dya, sprue_max_distance, include_last=false) {
                         sprue_base(height);
                    }
               }
          }
     } else {
          dx = calc_base_size(xu);
          dy = calc_base_size(yu);

          rotate_z_copy(180) {
               translate([-dx / 2, -dy / 2, 0]) {
                    sprue_copy(dx, sprue_max_distance) {
                         sprue_base(height);
                    }
               }
               rotate([0, 0, 90]) {
                    translate([-dy / 2, -dx / 2, 0]) {
                         sprue_copy(dy, sprue_max_distance) {
                              sprue_base(height);
                         }
                    }
               }
          }
     }
}


module mx_sprues_stem (height) {
     d = (mx_diameter - sprue_diameter_stem) / 2;

     for (i = [0 : 3]) {
          rotate([0, 0, 45 + 90 * i]) {
               translate([-d, 0, -height]) {
                    cylinder(h=height + mx_cone, d=sprue_diameter_stem);
               }
          }
     }
}


module al_sprues_stem (height) {
     d = (mx_diameter - sprue_diameter_stem) / 2;

     rotate_z_copy(180) {
          translate([2, 0, -height]) {
               cylinder(h=height + al_stem_ch, d=sprue_diameter_stem);
          }
     }
}


module mx_stem () {
     translate([0, 0, -overlap]) {
          cylinder(h=(key_cavity_height + overlap * 3), d=mx_diameter, $fn=48);
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


module al_outer_2d () {
     union() {
          square([al_l1, al_w1], center=true);
          square([al_l0 + al_w2 * 2, al_w0], center=true);
          translate([0, al_wd / 2]) {
               square([al_l2, al_w2], center=true);
          }
          translate([0, -al_wd / 2]) {
               square([al_l2, al_w2], center=true);
          }
     }
}


module al_inner_2d () {
     square([al_l0, al_w0], center=true);
}


module al_switch_stem (height) {
     linear_extrude(height) {
          difference() {
               al_outer_2d();
               al_inner_2d();
          }
     }
}


module al_stem () {
     height = key_cavity_height + overlap;

     rotate([180, 0, 0]) {
          translate([0, 0, -height]) {
               difference() {
                    chamfered_cube(al_stem_l1, al_stem_w1, height,
                                   al_stem_ch, al_stem_ch);
                    centered_cube([al_stem_l0, al_stem_w0, 100]);
               }
          }
     }
     
}


module master_base (xu=1, yu=1, name="") {
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     union () {
          difference() {
               bottom_plate(xu=nxu, yu=nyu);
               registration_cube(xu=nxu, yu=nyu, offset=regst_offset);
          }
          difference() {
               base(xu=nxu, yu=nyu, name=name);
               indent(xu=nxu, yu=nyu, name=name);
          }
          sprues_base(regst_height + overlap, xu=nxu, yu=nyu, name=name, $fn=48);
     }
}


module mx_master_base (xu=1, yu=1, name="") {
     color("LightSteelBlue") {
          union () {
               master_base(xu=xu, yu=yu, name=name);
               translate([0, 0, -indent_depth - overlap]) {
                    stem_copy(xu=xu, yu=yu, name=name) {
                         mx_cross(mx_height_base + indent_depth + overlap, offset=-mx_offset);
                    }
               }
          }
     }
}


module al_master_base (xu=1, yu=1, name="") {
     color("LightSteelBlue") {
          union () {
               master_base(xu=xu, yu=yu, name=name);
               translate([0, 0, -indent_depth - overlap]) {
                    stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                         al_switch_stem(al_height + indent_depth + overlap);
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         mx_cross(mx_height_base + indent_depth + overlap, offset=-mx_offset);
                    }
               }
          }
     }
}


module sculpt_base (xu=1, yu=1, name="") {
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     union () {
          difference() {
               bottom_plate(xu=nxu, yu=nyu);
               registration_cube(xu=nxu, yu=nyu, offset=regst_offset);
          }
          sprues_base(regst_height + overlap, xu=xu, yu=yu, name=name, $fn=48);
          base(xu=xu, yu=yu, name=name);
          key_sculpt(xu=xu, yu=yu, name=name);
     }
}


module mx_sculpt_base (xu=1, yu=1, name="") {
     color("SteelBlue") {
          difference() {
               sculpt_base(xu=xu, yu=yu, name=name);
               translate([0, 0, key_sculpt_height - key_cavity_height]) {
                    stem_copy(xu=xu, yu=yu, name=name) {
                         cylinder(h=key_cavity_height + overlap, d=key_sculpt_diameter, $fn=48);
                    }
               }
          }
     }
}


module al_sculpt_base (xu=1, yu=1, name="") {
     color("SteelBlue") {
          difference() {
               sculpt_base(xu=xu, yu=yu, name=name);
               translate([0, 0, key_sculpt_height - key_cavity_height]) {
                    stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                         linear_extrude(key_cavity_height + overlap) {
                              al_inner_2d();
                         }
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         cylinder(h=key_cavity_height + overlap, d=key_sculpt_diameter, $fn=48);
                    }
               }
          }
     }
}


module stem_cavity_positive (xu=1, yu=1) {
     union() {
          top_plate(xu=xu, yu=yu);
          registration_cube(xu=xu, yu=yu);
     }
}


module stem_cavity_negative (xu=1, yu=1) {
     union() {
          base(xu=xu, yu=yu);
          key_cavity(xu=xu, yu=yu);
     }
}


module stem_cavity (xu=1, yu=1, name="") {
     if (name == "iso-enter") {
          difference() {
               stem_cavity_positive(xu=1.5, yu=2);
               union() {
                    translate([0, 0.5 * unit_u, 0]) {
                         stem_cavity_negative(xu=1.5);
                    }
                    translate([0.125 * unit_u, 0, 0]) {
                         stem_cavity_negative(xu=1.25, yu=2);
                    }
               }
          }
     } else if (name == "big-ass-enter") {
          difference() {
               stem_cavity_positive(xu=2.25, yu=2);
               union() {
                    translate([0.375 * unit_u, 0, 0]) {
                         stem_cavity_negative(xu=1.5, yu=2);
                    }
                    translate([0, -0.5 * unit_u, 0]) {
                         stem_cavity_negative(xu=2.25, yu=1);
                    }
               }
          }
     } else {
          difference() {
               stem_cavity_positive(xu=xu, yu=yu);
               stem_cavity_negative(xu=xu, yu=yu);
          }
     }
}


module stem_cavity_mm (xu=1, yu=1) {
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


module mx_stem_cavity (xu=1, yu=1, name="") {
     union () {
          color("CornflowerBlue") {
               union() {
                    difference() {
                         union() {
                              stem_cavity(xu=xu, yu=yu, name=name);
                              sprues_base(sprue_height, xu=xu, yu=yu, name=name, $fn=48);
                              stem_copy(xu=xu, name=name, yu=yu) {
                                   mx_stem();
                              }
                         }
                         stem_copy(xu=xu, yu=yu, name=name) {
                              union() {
                                   mx_cross(key_cavity_height);
                                   translate([0, 0, -overlap * 2]) {
                                        cylinder(d1=mx_width, d2=0, h=mx_cone, $fn=32);
                                   }
                              }
                         }
                    }
                    stem_copy(xu=xu, yu=yu, name=name) {
                         mx_sprues_stem(sprue_height, $fn=48);
                    }
               }
          }
          stem_cavity_mm(xu=xu, yu=yu);
     }
}


module al_stem_cavity (xu=1, yu=1, name="") {
     union () {
          color("CornflowerBlue") {
               difference() {
                    union() {
                         stem_cavity(xu=xu, yu=yu, name=name);
                         sprues_base(sprue_height, xu=xu, yu=yu, name=name, $fn=48);
                         stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                              al_sprues_stem(sprue_height, $fn=48);
                         }
                         stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                              al_stem();
                         }
                         stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                              mx_sprues_stem(sprue_height, $fn=48);
                         }
                         stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                              mx_stem();
                         }
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         mx_cross(key_cavity_height);
                    }
               }
          }
          stem_cavity_mm(xu=xu, yu=yu);
     }
}


module sprues_only_base (xu=1, yu=1, name="") {
     plate_x = calc_plate_size(xu);
     plate_y = calc_plate_size(yu);
     base_x = calc_base_size(xu);
     base_y = calc_base_size(yu);

     translate([0, 0, -sprue_height]) {
          linear_extrude(sprue_plate_height) {
               union() {
                    difference() {
                         bevel_corner_square(
                              plate_x, plate_y,
                              regst_radius, 25);
                         bevel_corner_square(
                              plate_x - sprue_plate_width * 2,
                              plate_y - sprue_plate_width * 2,
                              regst_radius - sprue_plate_width, 25);
                    }
               }
               stem_copy(xu=xu, yu=yu, name=name) {
                    circle(d=mx_diameter, $fn=48);
               }
               if (name != "" || yu > xu) {
                    rotate([0, 0, 90]) {
                         translate([-base_y / 2, 0, 0]) {
                              sprue_copy(base_y, include_last=true) {
                                   square([sprue_plate_width, plate_x], center=true);
                              }
                         }
                    }
               } else {
                    translate([-base_x / 2, 0, 0]) {
                         sprue_copy(base_x, include_last=true) {
                              square([sprue_plate_width, plate_y], center=true);
                         }
                    }
               }
          }
     }
}


module mx_sprues_only (xu=1, yu=1, name="") {
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     color("SkyBlue") {
          union () {
               sprues_base(sprue_height, xu=nxu, yu=nyu, name=name, $fn=48);
               stem_copy(xu=xu, yu=yu, name=name) {
                    mx_sprues_stem(sprue_height, $fn=48);
               }
               sprues_only_base(xu=nxu, yu=nyu, name=name);
          }
     }
}


module al_sprues_only (xu=1, yu=1, name="") {
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     color("SkyBlue") {
          union () {
               sprues_base(sprue_height, xu=nxu, yu=nyu, name=name, $fn=48);
               stem_copy(xu=xu, yu=yu, name=name) {
                    al_sprues_stem(sprue_height, $fn=48);
               }
               sprues_only_base(xu=nxu, yu=nyu, name=name);
          }
     }
}


module container (yu=1, name="", yn=2, xs=0) {
     plate_x = calc_plate_size(1);
     plate_y = calc_plate_size(calc_yu(yu=yu, name=name));

     wxy = container_wall;
     wz = container_base;
     gxy = container_gap_edge;
     
     cxy = 0.5; // XY Chamfer
     cz = 1; // Z Chamfer
     
     dy = plate_y + wxy;
     ox = plate_x + wxy * 2;
     oy = dy * yn + wxy;
     oz = container_height + wz;

     module chamfer () {
          polyhedron(
               points=[
                    [0, 0, -cz],
                    [-cxy, 0, 0],
                    [0, cxy, 0],
                    [cxy, 0, 0],
                    [0, -cxy, 0]
              ],
               faces=[
                    [1, 2, 3, 4],
                    [0, 1, 4],
                    [0, 2, 1],
                    [0, 3, 2],
                    [0, 4, 3]
                    ]
               );
     }

     module outer () {
          x = (xs ? unit_lego_stud * (xs + 2) : ox);
          minkowski() {
               translate([0, 0, cz]) {
                    scale([x - 2 * cxy, oy - 2 * cxy, oz - cz]) {
                         translate([-0.5, -0.5, 0]) {
                              cube(1);
                         }
                    }
               }
               chamfer();
          }
     }

     module internal () {
          x = (xs ? unit_lego_stud * (xs + 2) : plate_x + container_inset);
          for (i = [0 : yn - 1]) {
               translate([0, dy * (i - (yn - 1) / 2), wz]) {
                    centered_cube([
                                       x,
                                       plate_y + container_inset,
                                       oz
                                       ]);
               }
          }
     }

     module connection () {
          centered_cube([container_overlap + gxy, dy / 2 + gxy, oz + overlap * 2]);
          hull () {
               centered_cube([container_overlap + gxy, dy / 2 + gxy, overlap + cz + gxy / 2]);
               centered_cube([container_overlap + 2 * cxy + gxy, dy / 2 + 2 * cxy + gxy, overlap]);
          }
     }
          

     module connections () {
          translate([container_overlap / 2 - gxy / 2, 0, -overlap]) {
               scale([ox, oy + overlap * 2, oz + overlap * 2]) {
                    translate([0, -0.5, 0]) {
                         cube(1);
                    }
               }
          }
          for (i = [0 : yn]) {
               translate([0, dy * (i - (yn - 0.5) / 2), -overlap]) {
                    connection();
                    translate([container_overlap, -dy / 2, 0]) {
                         connection();
                    }
               }
          }
     }

     module clip() {
          bevel = 0.25;
          touching_height = 2;
          thin = 0.001;

          width = container_clip_width;
          ey = container_clip_extension;
          eyr = ey - (container_clip_inset + bevel);
          a = 30;
          hi = (container_clip_inset / 2 + bevel) / cos(a);

          yi = -0.5 * ey;
          yo = yi + eyr;
          xo = width + 2 * (yo * sin(a) - hi);
          xi = width + 2 * (yi * sin(a) - hi);

          xm = 1;
          sy = sqrt(pow(ey, 2) + pow((xo - xm) / 2, 2));
          
          minkowski() {
               sphere(r=bevel, $fn=12);
               hull() {
                    translate([0, yo, 0]) {
                         scale([xo, thin, touching_height]) {
                              translate([-0.5, -1, -0.5]) {
                                   cube([1, 1, 1]);
                              }
                         }
                    }
                    translate([0, yi, 0]) {
                         scale([xm, thin, touching_height / 2 + sy]) {
                              translate([-0.5, 0, -1]) {
                                   cube([1, 1, 1]);
                              }
                         }
                    }
                    translate([0, yi, 0]) {
                         scale([xi, thin, touching_height]) {
                              translate([-0.5, 0, -0.5]) {
                                   cube([1, 1, 1]);
                              }
                         }
                    }
               }
          }
     }

     module copy_clip_heights() {
          for (z = [8, 28]) {
               translate([0, 0, z]) {
                    children();
               }
          }
     }

     module clips() {
          width = container_clip_width;
          dx = ox / 2 + container_clip_extension / 2;
          dy = oy / 2 + container_clip_extension / 2;

          copy_clip_heights () {
               if (xs) {
                    for (x = [0 : xs - 1]) {
                         rotate_z_copy(180) {
                              translate([width * (x * 2 - xs + .5), dy, 0]) {
                                   clip();
                              }
                         }
                    }
               } else {
                    qx = ox / (2 * width);
                    qy = oy / (2 * width);
                    nx = floor(qx / 2);
                    ny = 2 * floor(qy / 2);
                    for (x = [0 : nx - 1]) {
                         rotate([0, 0, 180]) {
                              translate([width * (x * 2 + 0.5), dy, 0]) {
                                   clip();
                              }
                         }
                         translate([width * (x * 2 + 0.5 - 2 * nx), dy, 0]) {
                              clip();
                         }
                    }
                    for (y = [0 : ny - 1]) {
                         translate([-dx, width * (y * 2 - ny + 0.5), 0]) {
                              rotate([0, 0, 90]) {
                                   clip();
                              }
                         }
                    }
               }
          }
     }

     color("khaki") {
          difference() {
               outer();
               union () {
                    internal();
                    if (xs) {
                         rotate_z_copy(180) {
                              translate([unit_lego_stud * xs / 2, 0, 0]) {
                                   connections();
                              }
                         }
                    } else {
                         connections();
                    }
               }
          }
          if (container_clips) {
               clips();
          }
     }
}



module container_tesselate (xu=1, yu=1, xn=2, ext=0) {
     xp = calc_plate_size(xu);
     yp = calc_plate_size(yu);
     ey = unit_lego_stud * ext / 2;

     rotate_z_copy(180) {
          translate([0, ey, 0]) {
               container(xu=xu, yu=yu, xn=xn);
          }

          translate([0, ey + yp + container_wall * 2 + container_clip_extension, 0]) {
               rotate([0, 0, 180]) {
                    container(xu=xu, yu=yu, xn=xn);
               }
          }

          translate([xp + yp / 2 + container_wall * 2.5 + container_clip_extension, ey, 0]) {
               rotate([0, 0, 90]) {
                    container(xu=xu, yu=yu, xn=xn);
               }
          }

     }
}


module family_photo (xu_list, name="") {
     module photo (xu=1, yu=1, name="", i=0) {
          cx = (calc_plate_size(xu) + 8) / 2;
          cy = (calc_plate_size(yu) + 8);
          cz = i * -32;

          translate([0, 0, 0]) {
               translate([cx, 0, cz]) {
                    mx_master_base(xu=xu, yu=yu, name=name);
               }
     
               translate([cx, cy, cz]) {
                    mx_sculpt_base(xu=xu, yu=yu, name=name);
               }
     
               translate([-cx, cy, cz]) {
                    translate([0, 0, + sprue_height]) {
                         mx_sprues_only(xu=xu, yu=yu, name=name);
                    }
               }
               
               translate([-cx, 0, cz]) {
                    rotate([0, 180, 0]) {
                         mx_stem_cavity(xu=xu, yu=yu, name=name);
                    }
               }
          }
     
          translate([0, cy * 2, 0]) {
               translate([cx, 0, cz]) {
                    al_master_base(xu=xu, yu=yu, name=name);
               }

               translate([cx, cy, cz]) {
                    al_sculpt_base(xu=xu, yu=yu, name=name);
               }
     
               translate([-cx, cy, cz]) {
                    translate([0, 0, + sprue_height]) {
                         al_sprues_only(xu=xu, yu=yu, name=name);
                    }
               }
               
               translate([-cx, 0, cz]) {
                    rotate([0, 180, 0]) {
                         al_stem_cavity(xu=xu, yu=yu, name=name);
                    }
               }
          }
     
          translate([0, cy * 4, cz]) {
               container(xu=xu, yu=yu, name=name);
          }
     }

     if (name == "iso-enter") {
          photo(xu=1.5, yu=2, name=name);
     } else if (name == "big-ass-enter") {
          photo(xu=2.25, yu=2, name=name);
     } else {
          for (i = [0 : len(xu_list) - 1]) {
               photo(xu=xu_list[i], i=i);
          }
     }
}
