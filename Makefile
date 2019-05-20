SHELL := /bin/bash


SIZES := 1 1.25 1.5 1.75 2
STL_MX_BASE := $(foreach xu,$(SIZES),z-butt-$(xu)u-mx-base.stl)
STL_MX_STEM_CAVITY := $(foreach xu,$(SIZES),z-butt-$(xu)u-mx-stem-cavity.stl)


all : \
	$(STL_MX_BASE) \
	$(STL_MX_STEM_CAVITY) \
	img/z-butt-family-photo.png

clean :
	rm -f \
	  z-butt-*u-mx-base.* \
	  z-butt-*u-mx-stem-cavity.* \
	  img/z-butt-family-photo.png

%.stl : %.scad z-butt.scad
	openscad -o /tmp/$*.stl $<
	mv /tmp/$*.stl $@

img/%.png : %.scad z-butt.scad
	openscad \
	  --imgsize=870,870 \
	  -o /tmp/$*.png $<
	mv /tmp/$*.png $@

z-butt-%u-mx-base.scad :
	echo -e "include <z-butt.scad>\n\n\nmx_base(xu=$*);\n" > /tmp/$*.scad
	mv /tmp/$*.scad $@

z-butt-%u-mx-stem-cavity.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([180, 0, 0]){mx_stem_cavity(xu=$*);}\n" > /tmp/$*.scad
	mv /tmp/$*.scad $@
