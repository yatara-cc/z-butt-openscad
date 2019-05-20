include <z-butt.scad>

sizes = [1, 2];

for (i = [0 : len(sizes) - 1]) {
     xu = sizes[i];
     cx = calc_plate_size(xu) / 2 + 4;
     cy = i * 40;
     
     translate([cx, cy, 0]) {
          mx_master_base(xu);
     }
     
     translate([cx, cy, -64]) {
          mx_sculpt_base(xu);
     }
     
     translate([-cx, cy, 0]) {
          rotate([0, 180, 0]) {
               mx_stem_cavity(xu);
          }
     }

     translate([-5, cy + container_height / 2, -64]) {
          rotate([90, 180, 0]) {
               container(xu);
          }
     }
     
}
