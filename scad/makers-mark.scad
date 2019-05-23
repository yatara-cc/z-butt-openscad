/* module example_mm (size) { */
/*      bevel = size * 0.05; */
/*      minkowski() { */
/*           square([size, size], center=true); */
/*           circle(bevel, $fn=32); */
/*      } */
/* } */


module makers_mark(size) {
     thickness = 0.1;
     
     translate([0, 0, -thickness]) {
          linear_extrude(thickness * 2) {
               // Add Maker's Mark code here.
               // It should create a 2-D polygon of size `size` in XY.
               
               /* example_mm(size); */
          }
     }
}


