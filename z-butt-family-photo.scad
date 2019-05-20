include <z-butt.scad>

sizes = [1, 1.25, 1.5, 1.75, 2, 2.25, 2.75, 3, 4, 6, 6.25, 7];

for (i = [0 : len(sizes) - 1]) {
     xu = sizes[i];
     cx = calc_plate_size(xu) / 2 + 4;
     cy = i * 40;
     translate([cx, cy, 0]) {
          mx_base(xu);
     }
     
     translate([-cx, cy, 0]) {
          rotate([0, 180, 0]) {
               mx_stem_cavity(xu);
          }
     }
}
