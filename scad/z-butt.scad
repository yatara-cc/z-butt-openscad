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

indent_depth = 1;

sprue_diameter_base = 3.1;
sprue_diameter_tip = 1.5;
sprue_diameter_stem = 1.4;
sprue_height = 12;
sprue_height_tip = 2;
sprue_max_distance = 8;
sprue_plate_height = 1;
sprue_plate_width = 1.5;

mx_crux_pos = [
     "horiz_length", 4.0,
     "horiz_thick", 1.3,
     "vert_length", 3.9,
     "vert_thick", 1.1
     ];
mx_crux_neg = [
     "horiz_length", 4.38,
     "horiz_thick", 1.26,
     "vert_length", 4.38,
     "vert_thick", 1.15
     ];
mx_bevel = 0.25;
mx_diameter_pos = 5.6;
mx_diameter_neg = 5.8;
mx_stem_bevel = false;
mx_height_pos = 3;
mx_height_neg = 5;

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

lp_depth = 1.6;
lp_stem = [
     "distance_x", 5.75,
     "extension_z", 1.8,
     "size_x", 1.27,
     "size_y", 2.95,
     "bevel", 0.25,
     ];

mx_al_key = [
     "base_sx", 18.5,
     "base_sy", 18.5,
     "cavity_sx", 14.925,
     "cavity_sy", 14.925,
     "cavity_sz", 5,
     "cavity_ch_xy", 2,
     "indent_inset", 3
     ];
lp_key = [
     "base_sx", 17.65,
     "base_sy", 16.5,
     "cavity_sx", 16.1,
     "cavity_sy", 14.9,
     "cavity_sz", 1.6,
     "cavity_ch_xy", 1.6,
     "indent_inset", 1.5
     ];
cavity_bevel = 0.25;
     
key_sculpt_size = 14.925;
key_sculpt_inset_z = 0.5;
key_sculpt_bevel = 0.93;

key_wall = 1.5;  // Thickness of the key wall.
base_inset = 0.25;  // Distance that key overhangs the base.

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


function attr(p, k) = p[search([k], [for(i = [0 : 2: len(p) - 2]) p[i]])[0] * 2 + 1];


function calc_xu (xu=1, name="") = 
     (name == "iso-enter") ? 1.5 :
     (name == "big-ass-enter") ? 2.25 :
     xu;

function calc_yu (yu=1, name="") = 
     (name == "iso-enter") ? 2 :
     (name == "big-ass-enter") ? 2 :
     yu;


function calc_plate_size (u=1) = unit_lego_stud * round((plate_size + unit_u * (u - 1)) / unit_lego_stud);


function calc_base_size (size, u=1) = size + unit_u * (u - 1) - base_inset * 2;


function calc_cavity_size (size, u=1) = size + unit_u * (u - 1);


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


module mirror_copy (v) {
     children();
     mirror(v) {
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



module fdm_corners (sx, sy, sz, fz) {
     // Corner pillars for a bottom-chamfered cube
     // with overhangs not exceeding 45 degrees.
     // 
     // `fz` height of non-chamfered edge in Z.

     xy = fz;
     dz = sz - fz;
     dxy = dz / 2;

     mirror_copy([1, 0, 0]) {
          mirror_copy([0, 1, 0]) {
               hull() {
                    translate([-sx / 2, -sy / 2, 0]) {
                         scale([xy, xy, fz]) {
                              cube(1);
                         }
                    }
                    translate([-sx / 2 + dz, -sy / 2 + dz, sz - fz]) {
                         scale([xy, xy, fz]) {
                              cube(1);
                         }
                    }
                    translate([-sx / 2 + dxy, -sy / 2 + dxy, sz - fz]) {
                         scale([xy, xy, fz]) {
                              cube(1);
                         }
                    }
               }
          }
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


module top_plate (key, xu=1, yu=1, fdm=false) {
     sx = calc_plate_size(xu) - plate_inset;
     sy = calc_plate_size(yu) - plate_inset;
     fz = plate_height - plate_chamfer;
     if (fdm) {
          chamfered_cube(
               sx,
               sy,
               attr(key, "cavity_sz") + fz,
               attr(key, "cavity_sz"), attr(key, "cavity_sz"));
          if (attr(key, "cavity_sz") > plate_height) {
               fdm_corners(sx, sy, attr(key, "cavity_sz") + fz, fz);
          }
     } else {
          chamfered_cube(
               sx, sy,
               plate_height,
               plate_chamfer, plate_chamfer);
          translate([0, 0, fz]) {
               bevelled_key (
                    calc_base_size(attr(key, "base_sx"), xu),
                    calc_base_size(attr(key, "base_sy"), yu),
                    attr(key, "cavity_sz"),
                    attr(key, "cavity_ch_xy"), key_sculpt_bevel, $fn=16);
          }
     }
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


module base (key, xu=1, yu=1, name="") {
     if (name == "iso-enter") {
          union() {
               translate([0, 0.5 * unit_u, 0]) {
                    base(key, 1.5, 1);
               }
               translate([0.125 * unit_u, 0, 0]) {
                    base(key, 1.25, 2);
               }
          }
     } else if (name == "big-ass-enter") {
          union() {
               translate([0.375 * unit_u, 0, 0]) {
                    base(key, 1.5, 2);
               }
               translate([0, -0.5 * unit_u, 0]) {
                    base(key, 2.25, 1);
               }
          }
     } else {
          size_x = calc_base_size(attr(key, "base_sx"), xu);
          size_y = calc_base_size(attr(key, "base_sy"), yu);
     
          scale([size_x, size_y, regst_height + overlap]) {
               translate([-.5, -.5, -1]) {
                    cube([1, 1, 1]);
               }
          }
     }
}


module indent (key, xu, yu, name="") {
     if (name == "iso-enter") {
          union() {
               translate([0, 0.5 * unit_u, 0]) {
                    indent(key, 1.5, 1);
               }
               translate([0.125 * unit_u, 0, 0]) {
                    indent(key, 1.25, 2);
               }
          }
     } else if (name == "big-ass-enter") {
          union() {
               translate([0.375 * unit_u, 0, 0]) {
                    indent(key, 1.5, 2);
               }
               translate([0, -0.5 * unit_u, 0]) {
                    indent(key, 2.25, 1);
               }
          }
     } else {
          sx = calc_base_size(attr(key, "base_sx"), xu) - 2 * attr(key, "indent_inset");
          sy = calc_base_size(attr(key, "base_sy"), yu) - 2 * attr(key, "indent_inset");
          translate([0, 0, overlap]) {
               rotate([180, 0, 0]) {
                    chamfered_cube(sx, sy, indent_depth + overlap, indent_depth, indent_depth);
               }
          }
     }
}


module bevelled_key (sx, sy, sz, ch_xy, bevel) {
     translate([0, 0, -overlap]) {
          minkowski() {
               chamfered_cube(sx, sy, sz + overlap, ch_xy, sz);
               scale([1, 1, 0]) {
                    sphere(bevel);
               }
          }
     }
}


module key_sculpt (key, xu=1, yu=1, name="") {
     if (name == "iso-enter") {
          union() {
               translate([0, 0.5 * unit_u, 0]) {
                    key_sculpt(key, 1.5, 1);
               }
               translate([0.125 * unit_u, 0, 0]) {
                    key_sculpt(key, 1.25, 2);
               }
          }
     } else if (name == "big-ass-enter") {
          union() {
               translate([0.375 * unit_u, 0, 0]) {
                    key_sculpt(key, 1.5, 2);
               }
               translate([0, -0.5 * unit_u, 0]) {
                    key_sculpt(key, 2.25, 1);
               }
          }
     } else {
          inset = 2 * key_sculpt_bevel;
          sx = calc_key_sculpt_size(xu) - inset;
          sy = calc_key_sculpt_size(yu) - inset;

          bevelled_key(
               sx, sy,
               attr(key, "cavity_sz") - key_sculpt_inset_z,
               attr(key, "cavity_ch_xy"),
               key_sculpt_bevel, $fn=24);
     }
}


module key_cavity (key, xu=1, yu=1) {
     inset = 2 * cavity_bevel;
     sx = calc_cavity_size(attr(key, "cavity_sx"), xu) - inset;
     sy = calc_cavity_size(attr(key, "cavity_sy"), yu) - inset;

     bevelled_key(sx, sy, attr(key, "cavity_sz"),
                  attr(key, "cavity_ch_xy"), cavity_bevel, $fn=24);
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
     end = n - (include_last ? 0 : 1);

     if (n > 0) {
          for (i = [0 : end]) {
               translate([x * i, 0, 0]) {
                    children();
               }
          }
     }
}


module sprues_base (key, height, xu=1, yu=1, name="") {
     $fn = 24;
     if (name == "iso-enter") {
          dxa = calc_base_size(attr(key, "base_sx"), 1.5);
          dxb = calc_base_size(attr(key, "base_sx"), 1.25);
          dya = calc_base_size(attr(key, "base_sy"), 2);
          dyb = calc_base_size(attr(key, "base_sy"), 1);
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
          dxa = calc_base_size(attr(key, "base_sx"), 2.25);
          dxb = calc_base_size(attr(key, "base_sx"), 1.5);
          dya = calc_base_size(attr(key, "base_sy"), 2);
          dyb = calc_base_size(attr(key, "base_sy"), 1);
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
          dx = calc_base_size(attr(key, "base_sx"), xu);
          dy = calc_base_size(attr(key, "base_sy"), yu);

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
     d = (mx_diameter_pos - sprue_diameter_stem) / 2;     
     for (i = [0 : 3]) {
          rotate([0, 0, 45 + 90 * i]) {
               translate([-d, 0, -height]) {
                    cylinder(h=height + overlap, d=sprue_diameter_stem, $fn = 16);
               }
          }
     }
}


module al_sprues_stem (height) {
     d = (mx_diameter_pos - sprue_diameter_stem) / 2;
     rotate_z_copy(180) {
          translate([2, 0, -height]) {
               cylinder(h=height + al_stem_ch, d=sprue_diameter_stem, $fn = 16);
          }
     }
}


module lp_sprues_stem (height) {
     ext_z = attr(lp_stem, "extension_z");
     sx = attr(lp_stem, "size_x");
     sy = attr(lp_stem, "size_y");

     h = height - ext_z + overlap;
     lp_copy() {
          translate([0, 0, -height]) {
               cylinder(h=h, d=sprue_diameter_stem, $fn = 16);
          }
     }
}


module mx_stem (height) {
     $fn = 32;
     translate([0, 0, -overlap]) {
          linear_extrude(height + overlap * 3) {
               if (mx_stem_bevel) {
                    minkowski() {
                         scale(mx_diameter_pos - 2 * mx_stem_bevel) {
                              translate([-0.5, -0.5]) {
                                   square(1);
                              }
                         }
                         circle(r=mx_stem_bevel);
                    }
               } else {
                    circle(d=mx_diameter_pos);
               }
          }
     }
}


module mx_cross (dimensions, height) {
     inset = 2 * mx_bevel;
     h = height - mx_bevel;

     minkowski() {
          linear_extrude(h) {
               union() {
                    scale([
                               attr(dimensions, "horiz_length") - inset,
                               attr(dimensions, "horiz_thick") - inset,
                               ]) {
                         translate([-0.5, -0.5]) {
                              square(1);
                         }
                    }
                    scale([
                               attr(dimensions, "vert_thick") - inset,
                               attr(dimensions, "vert_length") - inset,
                               ]) {
                         translate([-0.5, -0.5]) {
                              square(1);
                         }
                    }
               }
          }
          sphere(mx_bevel, $fn=16);
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


module al_stem (height) {
     h = height + overlap;

     rotate([180, 0, 0]) {
          translate([0, 0, -h]) {
               difference() {
                    chamfered_cube(al_stem_l1, al_stem_w1, h,
                                   al_stem_ch, al_stem_ch);
                    centered_cube([al_stem_l0, al_stem_w0, 100]);
               }
          }
     }
     
}


module lp_copy () {
     dx = attr(lp_stem, "distance_x");
     translate([-dx / 2, 0]) {
          children();
     }
     translate([dx / 2, 0]) {
          children();
     }
}


module lp_switch_neg_2d () {
     sx_neg = 1.25;
     sy_neg = 3;

     lp_copy() {
          scale([sx_neg, sy_neg]) {
               translate([-0.5, -0.5]) {
                    square(1);
               }
          }
     }
}

module lp_switch_stem_pos (height) {
     sx_pos = 10.25;
     sy_pos = 4.45;
     linear_extrude(height) {
          scale([sx_pos, sy_pos]) {
               translate([-0.5, -0.5]) {
                    square(1);
               }
          }
     }
}


module lp_switch_stem_neg () {
     h = attr(lp_stem, "extension_z") + 0.25;
     sx_pos = 10.25;
     sy_pos = 4.45;
     translate([0, 0, -h]) {
          linear_extrude(h + overlap) {
               lp_switch_neg_2d ();
          }
     }
}


module lp_stem (cavity_height) {
     $fn = 32;
     ext_z = attr(lp_stem, "extension_z");
     sx = attr(lp_stem, "size_x");
     sy = attr(lp_stem, "size_y");
     bevel = attr(lp_stem, "bevel");

     translate([0, 0, -ext_z]) {
          linear_extrude(cavity_height + ext_z + overlap) {
               lp_copy() {
                    rotate_z_copy(180) {
                         translate([0, sy / 2 - bevel]) {
                              minkowski() {
                                   scale([sx - bevel * 2, sy * 2 / 5 - bevel * 2]) {
                                        translate([-0.5, -1]) {
                                             square(1);
                                        }
                                   }
                                   circle(r=bevel, $fn=8);
                              }
                         }
                    }
                    scale([sx - bevel, sy - bevel * 2]) {
                         translate([-0.5, -0.5]) {
                              square(1);
                         }
                    }
               }
          }
     }
}


module master_base (key, xu=1, yu=1, name="") {
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     union () {
          difference() {
               bottom_plate(key, xu=nxu, yu=nyu);
               registration_cube(xu=nxu, yu=nyu, offset=regst_offset);
          }
          difference() {
               base(key, xu=nxu, yu=nyu, name=name);
               indent(key, xu=nxu, yu=nyu, name=name);
          }
          sprues_base(key, regst_height + overlap, xu=nxu, yu=nyu, name=name, $fn=48);
     }
}


module mx_master_base (xu=1, yu=1, name="") {
     color("LightSteelBlue") {
          union () {
          master_base(mx_al_key, xu=xu, yu=yu, name=name);
          translate([0, 0, -indent_depth - overlap]) {
               stem_copy(xu=xu, yu=yu, name=name) {
                    mx_cross(mx_crux_pos, mx_height_pos + indent_depth + overlap);
               }
               }
          }
     }
}


module al_master_base (xu=1, yu=1, name="") {
     color("LightSteelBlue") {
          union () {
               master_base(mx_al_key, xu=xu, yu=yu, name=name);
               translate([0, 0, -indent_depth - overlap]) {
                    stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                         al_switch_stem(al_height + indent_depth + overlap);
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         mx_cross(mx_crux_pos, mx_height_pos + indent_depth + overlap);
                    }
               }
          }
     }
}


module lp_master_base (xu=1, yu=1, name="") {
     color("LightSteelBlue") {
          difference() {
               union () {
                    master_base(lp_key, xu=xu, yu=yu, name=name);
                    translate([0, 0, -indent_depth - overlap]) {
                         stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                              lp_switch_stem_pos(indent_depth + overlap);
                         }
                         stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                              mx_cross(mx_crux_pos, indent_depth + overlap);
                         }
                    }
               }
               stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                    lp_switch_stem_neg();
               }
          }
     }
}


module sculpt_base (key, xu=1, yu=1, name="") {
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     union () {
          difference() {
               bottom_plate(xu=nxu, yu=nyu);
               registration_cube(xu=nxu, yu=nyu, offset=regst_offset);
          }
          sprues_base(key, regst_height + overlap, xu=xu, yu=yu, name=name, $fn=48);
          base(key, xu=xu, yu=yu, name=name);
          key_sculpt(key, xu=xu, yu=yu, name=name);
     }
}


module mx_sculpt_base (xu=1, yu=1, name="") {
     key = mx_al_key;
     color("SteelBlue") {
          difference() {
               sculpt_base(key, xu=xu, yu=yu, name=name);
               translate([0, 0, -key_sculpt_inset_z]) {
                    stem_copy(xu=xu, yu=yu, name=name) {
                         cylinder(h=attr(key, "cavity_sz") + overlap, d=mx_diameter_neg, $fn=48);
                    }
               }
          }
     }
}


module al_sculpt_base (xu=1, yu=1, name="") {
     key = mx_al_key;
     color("SteelBlue") {
          difference() {
               sculpt_base(key, xu=xu, yu=yu, name=name);
               translate([0, 0, -key_sculpt_inset_z]) {
                    stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                         linear_extrude(attr(key, "cavity_sz") + overlap) {
                              al_inner_2d();
                         }
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         cylinder(h=attr(key, "cavity_sz") + overlap, d=mx_diameter_neg, $fn=48);
                    }
               }
          }
     }
}


module lp_sculpt_base (xu=1, yu=1, name="") {
     key = lp_key;
     color("SteelBlue") {
          difference() {
               sculpt_base(key, xu=xu, yu=yu, name=name);
               translate([0, 0, -key_sculpt_inset_z]) {
                    stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                         linear_extrude(attr(key, "cavity_sz") + overlap) {
                              lp_switch_neg_2d();
                         }
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         cylinder(h=attr(key, "cavity_sz") + overlap, d=mx_diameter_neg, $fn=48);
                    }
               }
          }
     }
}


module stem_cavity_positive (key, xu=1, yu=1, fdm=false) {
     union() {
          top_plate(key, xu=xu, yu=yu, fdm=fdm);
          registration_cube(xu=xu, yu=yu);
     }
}


module stem_cavity_negative (key, xu=1, yu=1) {
     union() {
          base(key, xu=xu, yu=yu);
          key_cavity(key, xu=xu, yu=yu);
     }
}


module stem_cavity (key, xu=1, yu=1, name="", fdm=false) {
     if (name == "iso-enter") {
          difference() {
               stem_cavity_positive(key, xu=1.5, yu=2, fdm=fdm);
               union() {
                    translate([0, 0.5 * unit_u, 0]) {
                         stem_cavity_negative(key, xu=1.5);
                    }
                    translate([0.125 * unit_u, 0, 0]) {
                         stem_cavity_negative(key, xu=1.25, yu=2);
                    }
               }
          }
     } else if (name == "big-ass-enter") {
          difference() {
               stem_cavity_positive(key, xu=2.25, yu=2, fdm=fdm);
               union() {
                    translate([0.375 * unit_u, 0, 0]) {
                         stem_cavity_negative(key, xu=1.5, yu=2);
                    }
                    translate([0, -0.5 * unit_u, 0]) {
                         stem_cavity_negative(key, xu=2.25, yu=1);
                    }
               }
          }
     } else {
          difference() {
               stem_cavity_positive(key, xu=xu, yu=yu, fdm=fdm);
               stem_cavity_negative(key, xu=xu, yu=yu);
          }
     }
}


module mx_stem_cavity (xu=1, yu=1, name="", fdm=false) {
     key = mx_al_key;
     union () {
          color("CornflowerBlue") {
               union() {
                    difference() {
                         union() {
                              stem_cavity(key, xu=xu, yu=yu, name=name, fdm=fdm);
                              sprues_base(key, sprue_height, xu=xu, yu=yu, name=name, $fn=48);
                              stem_copy(xu=xu, name=name, yu=yu) {
                                   mx_stem(attr(key, "cavity_sz"));
                              }
                         }
                         stem_copy(xu=xu, yu=yu, name=name) {
                              mx_cross(mx_crux_neg, attr(key, "cavity_sz"));
                         }
                    }
                    stem_copy(xu=xu, yu=yu, name=name) {
                         mx_sprues_stem(sprue_height);
                    }
               }
          }
     }
}


module al_stem_cavity (xu=1, yu=1, name="", fdm=false) {
     key = mx_al_key;
     color("CornflowerBlue") {
          difference() {
               union() {
                    stem_cavity(key, xu=xu, yu=yu, name=name, fdm=fdm);
                    sprues_base(key, sprue_height, xu=xu, yu=yu, name=name, $fn=48);
                    stem_copy(xu=xu, yu=yu, name=name, stabilizers=false) {
                         al_sprues_stem(sprue_height);
                         al_stem(attr(key, "cavity_sz"));
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         mx_sprues_stem(sprue_height);
                         mx_stem(attr(key, "cavity_sz"));
                    }
               }
               stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                    mx_cross(mx_crux_neg, attr(key, "cavity_sz"));
               }
          }
     }
}


module lp_stem_cavity (xu=1, yu=1, name="", fdm=false) {
     key = lp_key;
     color("CornflowerBlue") {
          difference() {
               union() {
                    stem_cavity(key, xu=xu, yu=yu, name=name, fdm=fdm);
                    sprues_base(key, sprue_height, xu=xu, yu=yu, name=name, $fn=48);
                    stem_copy(xu=xu, name=name, yu=yu, stabilizers=false) {
                         lp_stem(attr(key, "cavity_sz"));
                         lp_sprues_stem(sprue_height);
                    }
                    stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                         mx_sprues_stem(sprue_height);
                         mx_stem(attr(key, "cavity_sz"));
                    }
               }
               stem_copy(xu=xu, yu=yu, name=name, switches=false) {
                    mx_cross(mx_crux_neg, attr(key, "cavity_sz"));
               }
          }
     }
}


module sprues_only_base (key, xu=1, yu=1, name="") {
     plate_x = calc_plate_size(xu);
     plate_y = calc_plate_size(yu);
     base_x = calc_base_size(attr(key, "base_sx"), xu);
     base_y = calc_base_size(attr(key, "base_sy"), yu);

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
                    circle(d=mx_diameter_pos, $fn=48);
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
     key = mx_al_key;
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     
     color("SkyBlue") {
          union() {
               sprues_base(key, sprue_height, xu=nxu, yu=nyu, name=name, $fn=48);
               stem_copy(xu=xu, yu=yu, name=name) {
                    mx_sprues_stem(sprue_height);
               }
               sprues_only_base(key, xu=nxu, yu=nyu, name=name);
          }
     }
}


module al_sprues_only (xu=1, yu=1, name="") {
     key = mx_al_key;
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     
     color("SkyBlue") {
          union() {
               sprues_base(key, sprue_height, xu=nxu, yu=nyu, name=name, $fn=48);
               stem_copy(xu=xu, yu=yu, name=name) {
                    al_sprues_stem(sprue_height, $fn=48);
               }
               sprues_only_base(key, xu=nxu, yu=nyu, name=name);
          }
     }
}


module lp_sprues_only (xu=1, yu=1, name="") {
     key = lp_key;
     nxu = calc_xu(xu, name);
     nyu = calc_yu(yu, name);
     
     color("SkyBlue") {
          union() {
               sprues_base(key, sprue_height, xu=nxu, yu=nyu, name=name, $fn=48);
               stem_copy(xu=xu, yu=yu, name=name) {
                    lp_sprues_stem(sprue_height, $fn=48);
               }
               sprues_only_base(key, xu=nxu, yu=nyu, name=name);
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
