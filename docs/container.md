# Containers

All Z-Butt models have sizes compatible with Lego bricks, so that they can sit in a rectangular tower of bricks to make silicone molds. However, there are also container models available which may provide a more efficient workflow for making silicone molds.

Z-Butts, like keycaps, are measured in units, abbreviated `u` which correspond to the key spacing on standard keyboards. 1u is 0.75 inches or 19.05mm. These units are used for width and depth measurements (depth here refers to the dimension parallel to the keyboard, as opposed to height which refers to the dimensions perpendicular to the keyboard). In the OpenSCAD source code width is the X dimension, depth is the Y dimension and height is the Z dimension.

Most keys have a depth of 1u. Only the ISO Enter key and “Big Ass Enter” key have a depth of 2u and require a 2u deep container. 1u deep containers have two compartments by default so two molds can be made at the same time; 2u containers have a single compartment.

Containers are built from two end pieces and an optional number of center sections. The following table can be used to determine which container pieces are required to house Z-Butt pieces for specific keys.

```
+-------+-------+------------+--------------------+---------------------------+
| Width | Depth | Example    | Z-Butt size        | Containers required       |
+-------+-------+------------+--------------------+---------------------------+
| 1u    | 1u    | Alpha      | 32x32mm, 4x4 studs | 2 1u-0s                   |
| 1.25u | 1u    | Shift      | 40x32mm, 5x4 studs | 2 1u-0s, 1 1u-1s          |
| 1.5u  | 1u    | Tab        | 40x32mm, 5x4 studs | 2 1u-0s, 1 1u-1s          |
| 1.75u | 1u    | Caps Lock  | 48x32mm, 6x4 studs | 2 1u-0s, 1 1u-2s          |
| 2u    | 1u    | Backspace  | 48x32mm, 6x4 studs | 2 1u-0s, 1 1u-2s          |
| 2.25u | 1u    | ANSI Enter | 56x32mm, 7x4 studs | 2 1u-0s, 1 1u-2s, 1 1u-1s |
| 2.5u  | 1u    |            | 64x32mm, 8x4 studs | 2 1u-0s, 2 1u-2s          |
| 2.75u | 1u    | Shift      | 64x32mm, 8x4 studs | 2 1u-0s, 2 1u-2s          |
+-------+-------+------------+--------------------+---------------------------+
| 1.5u  | 2u    | ISO Enter  | 40x48mm, 5x6 studs | 2 2u-0s, 1 2u-1s          |
| 2.25u | 2u    | BAE        | 56x48mm, 7x6 studs | 2 2u-0s, 1 2u-1s, 1 2u-1s |
+-------+-------+------------+--------------------+---------------------------+
```

```
+-------+-------+------------+--------------------+---------------------------+
| Width | Depth | Example    | Z-Butt size        | Containers required       |
+-------+-------+------------+--------------------+---------------------------+
| 1u    | 1u    | Alpha      | 32x32mm, 4x4 studs | 2 1u-0s                   |
| 1.25u | 1u    | Shift      | 40x32mm, 5x4 studs | 2 1u-0s, 1 1u-1s          |
| 1.5u  | 1u    | Tab        | 40x32mm, 5x4 studs | 2 1u-0s, 1 1u-1s          |
| 1.75u | 1u    | Caps Lock  | 48x32mm, 6x4 studs | 2 1u-0s, 1 1u-2s          |
| 2u    | 1u    | Backspace  | 48x32mm, 6x4 studs | 2 1u-0s, 1 1u-2s          |
| 2.25u | 1u    | ANSI Enter | 56x32mm, 7x4 studs | 2 1u-0s, 1 1u-2s, 1 1u-1s |
| 2.5u  | 1u    |            | 64x32mm, 8x4 studs | 2 1u-0s, 2 1u-2s          |
| 2.75u | 1u    | Shift      | 64x32mm, 8x4 studs | 2 1u-0s, 2 1u-2s          |
+-------+-------+------------+--------------------+---------------------------+
| 1.5u  | 2u    | ISO Enter  | 40x48mm, 5x6 studs | 2 2u-0s, 1 2u-1s          |
| 2.25u | 2u    | BAE        | 56x48mm, 7x6 studs | 2 2u-0s, 1 2u-1s, 1 2u-1s |
+-------+-------+------------+--------------------+---------------------------+
```
