SHELL := /bin/bash


SIZES := 1 1.25 1.5 1.75 2 2.25 2.75 3 4 6 6.25 7


# If Meshlab is available, clean up STLs and save them as binary.
# Set to `true` or `false`
CONVERT_STL_MESHLAB := true

.PHONY : stl
.SECONDARY :


STL_MX_MASTER_BASE := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-mx-master-base.stl)
STL_MX_SCULPT_BASE := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-mx-sculpt-base.stl)
STL_MX_STEM_CAVITY := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-mx-stem-cavity.stl)
STL_MX_SPRUES_ONLY := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-mx-sprues-only.stl)
STL_AL_MASTER_BASE := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-al-master-base.stl)
STL_AL_SCULPT_BASE := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-al-sculpt-base.stl)
STL_AL_STEM_CAVITY := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-al-stem-cavity.stl)
STL_AL_SPRUES_ONLY := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-al-sprues-only.stl)
STL_CONTAINER := $(foreach xu,$(SIZES),stl/z-butt-$(xu)u-container.stl)

SIZES_COMMA := $(shell echo "$(SIZES)" | sed 's/ /, /g')



all : img stl

clean :
	rm -rf \
	  img/z-butt-1u-family-photo.png \
	  img/z-butt-2u-family-photo.png \
	  img/z-butt-iso-enter-family-photo.png \
	  img/z-butt-all-family-photo.png \
	  stl \
	  scad/z-butt-*.scad \
	  z-butt-openscad-stl.zip

stl : \
	$(STL_MX_MASTER_BASE) \
	$(STL_MX_SCULPT_BASE) \
	$(STL_MX_STEM_CAVITY) \
	$(STL_MX_SPRUES_ONLY) \
	$(STL_AL_MASTER_BASE) \
	$(STL_AL_SCULPT_BASE) \
	$(STL_AL_STEM_CAVITY) \
	$(STL_AL_SPRUES_ONLY) \
	$(STL_CONTAINER)

img : \
	img/z-butt-1u-family-photo.png \
	img/z-butt-2u-family-photo.png \
	img/z-butt-iso-enter-family-photo.png \
	img/z-butt-all-family-photo.png \

release : z-butt-openscad-stl.zip


stl/%.stl : scad/%.scad scad/z-butt.scad
	@mkdir -p stl
	openscad -o /tmp/$*.stl $<
ifneq (, $(shell if $(CONVERT_STL_MESHLAB); then which meshlabserver; fi;))
	meshlabserver -i /tmp/$*.stl -o $@
else
	mv /tmp/$*.stl $@
endif


img/z-butt-1u-family-photo.png : CROP := -crop 870x620+0+160
img/z-butt-2u-family-photo.png : CROP := -crop 870x620+0+160
img/z-butt-iso-enter-family-photo.png : CROP := -crop 870x620+0+160
img/z-butt-all-family-photo.png : CROP := -crop 870x780+0+60
img/%.png : scad/%.scad scad/z-butt.scad
	openscad \
	  --imgsize=3480,3480 \
	  -o /tmp/$*.png $<
ifneq (, $(shell which convert))
	convert -resize 25% $(CROP) /tmp/$*.png $@
else
	mv /tmp/$*.png $@
endif


scad/z-butt-%u-mx-master-base.scad :
	echo -e "include <z-butt.scad>\n\n\nmx_master_base(xu=$*);\n" > $@

scad/z-butt-%u-mx-sculpt-base.scad :
	echo -e "include <z-butt.scad>\n\n\nmx_sculpt_base(xu=$*);\n" > $@

scad/z-butt-%u-mx-stem-cavity.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([180, 0, 0]){mx_stem_cavity(xu=$*);}\n" > $@

scad/z-butt-%u-mx-sprues-only.scad :
	echo -e "include <z-butt.scad>\n\nmx_sprues_only(xu=$*);\n" > $@

scad/z-butt-%u-al-master-base.scad :
	echo -e "include <z-butt.scad>\n\n\nal_master_base(xu=$*);\n" > $@

scad/z-butt-%u-al-sculpt-base.scad :
	echo -e "include <z-butt.scad>\n\n\nal_sculpt_base(xu=$*);\n" > $@

scad/z-butt-%u-al-stem-cavity.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([180, 0, 0]){al_stem_cavity(xu=$*);}\n" > $@

scad/z-butt-%u-al-sprues-only.scad :
	echo -e "include <z-butt.scad>\n\nal_sprues_only(xu=$*);\n" > $@

scad/z-butt-%u-container.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([0, 0, 0]){container(xu=$*);}\n" > $@


scad/z-butt-%u-family-photo.scad :
	echo -e "include <z-butt.scad>\n\n\nfamily_photo([$*]);\n" > $@

scad/z-butt-iso-enter-family-photo.scad :
	echo -e "include <z-butt.scad>\n\n\nfamily_photo(name=\"iso-enter\");\n" > $@

scad/z-butt-all-family-photo.scad :
	echo -e "include <z-butt.scad>\n\n\nfamily_photo([$(SIZES_COMMA)]);\n" > $@


z-butt-openscad-stl.zip : stl/z-butt-*.stl
	zip -r $@ stl/z-butt-[1-9]*.stl
