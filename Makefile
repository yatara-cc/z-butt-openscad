SHELL := /bin/bash


XUs := 1 1.25 1.5 1.75 2 2.25 2.75 3 4 6 6.25 7
YUs := 1 2
XSs := 0 1 2 4 8
NAMEs := iso-enter big-ass-enter
BASEs := mx al
STLs :=
JPGs :=

RENDER_SAMPLES := 9
RENDER_PERCENTAGE := 100


.PHONY : stl render
.SECONDARY :


all : # Redefined later



define KEY
scad/z-butt-$(2)-$(1)-master-base.scad :
	echo -e "include <z-butt.scad>\n\n\n$(1)_master_base($(3));\n" > $$@

scad/z-butt-$(2)-$(1)-sculpt-base.scad :
	echo -e "include <z-butt.scad>\n\n\n$(1)_sculpt_base($(3));\n" > $$@

scad/z-butt-$(2)-$(1)-stem-cavity-sla.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([0, 180, 0]){$(1)_stem_cavity($(3));}\n" > $$@

scad/z-butt-$(2)-$(1)-stem-cavity-fdm.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([0, 180, 0]){$(1)_stem_cavity($(3), fdm=true);}\n" > $$@

scad/z-butt-$(2)-$(1)-sprues-only.scad :
	echo -e "include <z-butt.scad>\n\n\n$(1)_sprues_only($(3));\n" > $$@


STLs := $(STLs) \
	stl/z-butt-$(2)-$(1)-master-base.stl \
	stl/z-butt-$(2)-$(1)-sculpt-base.stl \
	stl/z-butt-$(2)-$(1)-stem-cavity-fdm.stl \
	stl/z-butt-$(2)-$(1)-stem-cavity-sla.stl \
	stl/z-butt-$(2)-$(1)-sprues-only.stl
endef


define CONTAINER
scad/z-butt-$(1)u-$(2)s-container.scad :
	echo -e "include <z-butt.scad>\n\n\ncontainer(yu=$(1), xs=$(2));\n" > $$@

STLs := $(STLs) \
	stl/z-butt-$(1)u-$(2)s-container.stl
endef


$(foreach base,$(BASEs), \
	$(foreach xu,$(XUs),$(eval $(call KEY,$(base),$(xu)u,xu=$(xu)))) \
	$(foreach name,$(NAMEs),$(eval $(call KEY,$(base),$(name),name=\"$(name)\"))) \
)
$(foreach yu,$(YUs),$(foreach xs,$(XSs),$(eval $(call CONTAINER,$(yu),$(xs)))))


define RENDER_KEY

img/z-butt-$(2)-$(1).jpg : render/render.py \
	stl/z-butt-$(2)-$(1)-master-base.stl \
	stl/z-butt-$(2)-$(1)-sculpt-base.stl \
	stl/z-butt-$(2)-$(1)-stem-cavity-sla.stl \
	stl/z-butt-$(2)-$(1)-sprues-only.stl

	@mkdir -p img
	blender -b -P render/render.py -- --name=$(2)-$(1) --output=$$@ \
	  --samples=$(RENDER_SAMPLES) --percentage=$(RENDER_PERCENTAGE) \
	  --distance=$(3) --pan=$(4) --tilt=$(5) --aim-z=$(6)

JPGs := $(JPGs) img/z-butt-$(2)-$(1).jpg
endef

define RENDER_CONTAINER

img/z-butt-$(1)-container.jpg : render/render.py \
	stl/z-butt-$(1)-0s-container.stl \
	stl/z-butt-$(1)-1s-container.stl

	@mkdir -p img
	blender -b -P render/render.py -- --name=$(1) --output=$$@ \
	  --samples=$(RENDER_SAMPLES) --percentage=$(RENDER_PERCENTAGE) \
	  --distance=$(2) --pan=$(3) --tilt=$(4) --aim-z=$(5)

JPGs := $(JPGs) img/z-butt-$(1)-container.jpg
endef

$(eval $(call RENDER_KEY,mx,1u,160,-20,-60,-15))
$(eval $(call RENDER_KEY,al,1u,160,22,-60,-15))
$(eval $(call RENDER_KEY,mx,2u,160,0,-60,-15))
$(eval $(call RENDER_KEY,mx,7u,290,15,-60,-25))
$(eval $(call RENDER_KEY,mx,iso-enter,210,-18,-70,-15))
$(eval $(call RENDER_CONTAINER,1u,140,25,-32,5))



all : $(JPGs) $(STLs)

clean :
	rm -rf \
	  stl \
	  img \
	  scad/z-butt-*.scad \
	  z-butt-openscad-stl.zip

stl : $(STLs)

jpg : $(JPGs)

release : z-butt-openscad-stl.zip
	git tag -f stable;
	git push -f
	git push -f --tags

rebuild :
	$(MAKE) clean
	$(MAKE) jpg
	$(MAKE) stl -j 8



stl/%.stl : scad/%.scad scad/z-butt.scad
	@mkdir -p stl
	openscad -o /tmp/$*.stl $<
ifneq (, $(shell which meshlabserver))
#	If Meshlab is available, convert STLs to binary.
	meshlabserver -i /tmp/$*.stl -o $@
else
	mv /tmp/$*.stl $@
endif



z-butt-openscad-stl.zip : $(STLs)
	zip -r $@ $(STLs)
