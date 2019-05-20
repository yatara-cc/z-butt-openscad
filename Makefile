SHELL := /bin/bash


SIZES := 1 1.25 1.5 1.75 2 2.25 2.75 3 4 6 6.25 7
STL_MX_BASE := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-mx-base.stl)
STL_MX_STEM_CAVITY := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-mx-stem-cavity.stl)


all : \
	$(STL_MX_BASE) \
	$(STL_MX_STEM_CAVITY) \
	img/z-butt-family-photo.png

clean :
	rm -rf \
	  stl \
	  img/z-butt-family-photo.png

stl/%.stl : %.scad z-butt.scad
	mkdir -p stl
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
