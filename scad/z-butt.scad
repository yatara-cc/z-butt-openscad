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

container_thickness = 2;
container_overlap = 2;
container_height = 28;  // Internal height
container_bevel = 1;
container_inset = 0;  // XY Gap between contents and internal container walls.


// Internal Parameters


overlap = 0.1;  // Offset to avoid coplanar faces in Boolean operations.


// Functions


function calc_plate_size (u=1) = unit_lego_stud * round((plate_size + unit_u * (u - 1)) / unit_lego_stud);


function calc_base_size (u=1) = base_size + unit_u * (u - 1);


function calc_key_cavity_size (u=1) = key_cavity_size + unit_u * (u - 1);


function calc_key_sculpt_size (u=1) = key_sculpt_size + unit_u * (u - 1);


// See `https://deskthority.net/wiki/Space_by_keyboard`.
function stabilizers_xu (xu) = 
     (xu == 7) ? [0.5, 6.5] :
     (xu == 6.25) ? [0.5, 5.75] :  // (Cherry)
     (xu == 6) ? [0.5, 5.5] :  // (Cherry)
     (xu == 4) ? [xu / 2 - 1.5, xu / 2 + 1.5] :
     (xu == 3) ? [xu / 2 - 1, xu / 2 + 1] :
     (xu >= 2) ? [xu / 2 - .5, xu / 2 + .5] :
     [];


// See `https://deskthority.net/wiki/Space_by_keyboard`.
function switches_xu (xu) = 
     (xu == 7) ? [3.5] :
     (xu == 6.25) ? [3.75] :  // (Cherry)
     (xu == 6) ? [3.5] :  // (Cherry)
     [xu / 2];


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


module stem_copy (xu, switches=true, stabilizers=true) {
     cx = -xu / 2;
     if (switches) {
          for (x = switches_xu(xu)) {
               translate([unit_u * (cx + x), 0, 0]) {
                    children();
               }
          }
     }
     if (stabilizers) {
          for (x = stabilizers_xu(xu)) {
               translate([unit_u * (cx + x), 0, 0]) {
                    children();
               }
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
          linear_extrude(regst_height + overlap) {
               bevel_corner_square(
                    size_x + offset, size_y + offset,
                    regst_radius + offset, 25);
          }
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


module sprues_base (height, xu) {
     dx = calc_base_size(xu);
     dy = calc_base_size();

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


module master_base (xu=1) {
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
     }
}


module mx_master_base (xu=1) {
     color("LightSteelBlue") {
          union () {
               master_base(xu=xu);
               translate([0, 0, -indent_depth - overlap]) {
                    stem_copy(xu) {
                         mx_cross(mx_height_base + indent_depth + overlap, offset=-mx_offset);
                    }
               }
          }
     }
}


module al_master_base (xu=1) {
     color("LightSteelBlue") {
          union () {
               master_base(xu=xu);
               translate([0, 0, -indent_depth - overlap]) {
                    stem_copy(xu, stabilizers=false) {
                         al_switch_stem(al_height + indent_depth + overlap);
                    }
                    stem_copy(xu, switches=false) {
                         mx_cross(mx_height_base + indent_depth + overlap, offset=-mx_offset);
                    }
               }
          }
     }
}


module sculpt_base (xu=1) {
     union () {
          difference() {
               bottom_plate(xu);
               registration_cube(xu, regst_offset);
          }
          sprues_base(regst_height + overlap, xu, $fn=48);
          base(xu);
          key_sculpt(xu);
     }
}


module mx_sculpt_base (xu=1) {
     color("SteelBlue") {
          difference() {
               sculpt_base(xu=xu);
               translate([0, 0, key_sculpt_height - key_cavity_height]) {
                    stem_copy(xu) {
                         cylinder(h=key_cavity_height + overlap, d=key_sculpt_diameter, $fn=48);
                    }
               }
          }
     }
}


module al_sculpt_base (xu=1) {
     color("SteelBlue") {
          difference() {
               sculpt_base(xu=xu);
               translate([0, 0, key_sculpt_height - key_cavity_height]) {
                    stem_copy(xu, stabilizers=false) {
                         linear_extrude(key_cavity_height + overlap) {
                              al_inner_2d();
                         }
                    }
                    stem_copy(xu, switches=false) {
                         cylinder(h=key_cavity_height + overlap, d=key_sculpt_diameter, $fn=48);
                    }
               }
          }
     }
}


module stem_cavity (xu=1) {
     difference() {
          union() {
               top_plate(xu);
               registration_cube(xu);
          }
          union() {
               base(xu);
               key_cavity(xu);
          }
     }
}


module stem_cavity_mm (xu=1) {
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


module mx_stem_cavity (xu=1) {
     union () {
          color("CornflowerBlue") {
               union() {
                    difference() {
                         union() {
                              stem_cavity(xu=xu);
                              sprues_base(sprue_height, xu, $fn=48);
                              stem_copy(xu) {
                                   mx_stem();
                              }
                         }
                         stem_copy(xu) {
                              union() {
                                   mx_cross(key_cavity_height);
                                   translate([0, 0, -overlap * 2]) {
                                        cylinder(d1=mx_width, d2=0, h=mx_cone, $fn=32);
                                   }
                              }
                         }
                    }
                    stem_copy(xu) {
                         mx_sprues_stem(sprue_height, $fn=48);
                    }
               }
          }
          stem_cavity_mm(xu=xu);
     }
}


module al_stem_cavity (xu=1) {
     union () {
          color("CornflowerBlue") {
               difference() {
                    union() {
                         stem_cavity(xu=xu);
                         sprues_base(sprue_height, xu, $fn=48);
                         stem_copy(xu, stabilizers=false) {
                              al_sprues_stem(sprue_height, $fn=48);
                         }
                         stem_copy(xu, stabilizers=false) {
                              al_stem();
                         }
                         stem_copy(xu, switches=false) {
                              mx_sprues_stem(sprue_height, $fn=48);
                         }
                         stem_copy(xu, switches=false) {
                              mx_stem();
                         }
                    }
                    stem_copy(xu, switches=false) {
                         mx_cross(key_cavity_height);
                    }
               }
          }
          stem_cavity_mm(xu=xu);
     }
}


module sprues_only_base (xu=1) {
     plate_x = calc_plate_size(xu);
     plate_y = calc_plate_size();
     base_x = calc_base_size(xu);

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
               stem_copy(xu) {
                    circle(d=mx_diameter, $fn=48);
               }
               translate([-base_x / 2, 0, 0]) {
                    sprue_copy(base_x, include_last=true) {
                         square([sprue_plate_width, plate_y], center=true);
                    }
               }
          }
     }
}


module mx_sprues_only (xu=1) {
     color("SkyBlue") {
          union () {
               sprues_base(sprue_height, xu, $fn=48);
               stem_copy(xu) {
                    mx_sprues_stem(sprue_height, $fn=48);
               }
               sprues_only_base(xu=xu);
          }
     }
}


module al_sprues_only (xu=1) {
     color("SkyBlue") {
          union () {
               sprues_base(sprue_height, xu, $fn=48);
               stem_copy(xu) {
                    al_sprues_stem(sprue_height, $fn=48);
               }
               sprues_only_base(xu=xu);
          }
     }
}


module container (xu=1, xn=2) {
     plate_x = calc_plate_size(xu);
     plate_y = calc_plate_size();

     dx = (plate_x + container_thickness);
     dy = container_overlap / 2;
     ch = container_overlap - (container_thickness / 2);
     height = container_height + container_overlap;

     module positive () {
          difference () {
               translate([0, -dy, 0]) {
                    minkowski () {
                         scale([
                                    dx * xn + container_thickness - container_bevel * 2,
                                    plate_y / 2 + container_thickness + dy - container_bevel,
                                    height
                                    ]) {
                              translate([-0.5, 0, 0]) {
                                   cube([1, 1, 1]);
                              }
                         }
                         scale([1, 1, 0]) {
                              sphere(container_bevel, $fn=32);
                         }
                    }
               }
               translate([0, -dy, -overlap]) {
                    scale([
                               dx * xn + container_thickness + overlap * 2,
                               container_bevel + overlap,
                               height + overlap * 2
                               ]) {
                         translate([-0.5, -1, 0]) {
                              cube([1, 1, 1]);
                         }
                    }
               }
          }
     }

     module negative_internal () {
          translate([
                         container_thickness / 2 - container_inset,
                         -dy - overlap,
                         container_overlap]) {
               cube([
                         plate_x + container_inset * 2,
                         (plate_y + container_overlap) / 2 + container_inset + overlap,
                         height + overlap * 2
                         ]) {
               }
          }
     }

     module negative_connection () {
          translate([-dx / 2, -dy - overlap, -overlap]) {
               cube([
                         dx / 2,
                         container_overlap,
                         height + overlap * 2
                         ]) {
               }
          }
          hull() {
               translate([-dx / 2, -dy - overlap, 0]) {
                    cube([
                              dx / 2,
                              container_overlap,
                              ch
                              ]) {
                    }
               }
               translate([-dx / 2 - ch, -dy - overlap, -overlap]) {
                    cube([
                              dx / 2 + ch,
                              container_overlap + ch,
                              overlap
                              ]) {
                    }
               }
          }
          hull() {
               translate([container_thickness / 2, -dy - overlap, -overlap]) {
                    cube([plate_x, overlap, ch]);
                    cube([plate_x, ch, overlap]);
               }
          }
     }

     color("khaki") {
          difference () {
               positive();
               translate([dx * xn * -0.5, 0, 0]) {
                    translate_copy([dx, 0, 0], xn) {
                         negative_internal();
                    }
                    translate_copy([dx, 0, 0], xn + 1) {
                         negative_connection();
                    }
               }
          }
     }
}


module family_photo (sizes) {
     for (i = [0 : len(sizes) - 1]) {
          xu = sizes[i];
          cx = (calc_plate_size(xu) + 8) / 2;
          cy = calc_plate_size() + 8;
          cz = i * -32;

          translate([0, 0, 0]) {
               translate([cx, 0, cz]) {
                    mx_master_base(xu);
               }
     
               translate([cx, cy, cz]) {
                    mx_sculpt_base(xu);
               }
     
               translate([-cx, cy, cz]) {
                    translate([0, 0, + sprue_height]) {
                         mx_sprues_only(xu);
                    }
               }
               
               translate([-cx, 0, cz]) {
                    rotate([0, 180, 0]) {
                         mx_stem_cavity(xu);
                    }
               }
          }
     
          translate([0, cy * 2, 0]) {
               translate([cx, 0, cz]) {
                    al_master_base(xu);
               }

               translate([cx, cy, cz]) {
                    al_sculpt_base(xu);
               }
     
               translate([-cx, cy, cz]) {
                    translate([0, 0, + sprue_height]) {
                         al_sprues_only(xu);
                    }
               }
               
               translate([-cx, 0, cz]) {
                    rotate([0, 180, 0]) {
                         al_stem_cavity(xu);
                    }
               }
          }
     
          translate([0, cy * 4, cz]) {
               container(xu=xu, xn=(xu < 2 ? 2 : 1));
          }
     }
}
