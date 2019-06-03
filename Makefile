SHELL := /bin/bash


XUs := 1 1.25 1.5 1.75 2 2.25 2.75 3 4 6 6.25 7
NAMEs := iso-enter big-ass-enter
BASEs := mx al
PARTs := master-base sculpt-base stem-cavity sprues-only
STLs :=
JPGs :=


.PHONY : stl render
.SECONDARY :


all : # Redefined later



define KEY
scad/z-butt-$(2)-$(1)-master-base.scad :
	echo -e "include <z-butt.scad>\n\n\n$(1)_master_base($(3));\n" > $$@

scad/z-butt-$(2)-$(1)-sculpt-base.scad :
	echo -e "include <z-butt.scad>\n\n\n$(1)_sculpt_base($(3));\n" > $$@

scad/z-butt-$(2)-$(1)-stem-cavity.scad :
	echo -e "include <z-butt.scad>\n\n\nrotate([0, 180, 0]){$(1)_stem_cavity($(3));}\n" > $$@

scad/z-butt-$(2)-$(1)-sprues-only.scad :
	echo -e "include <z-butt.scad>\n\n\n$(1)_sprues_only($(3));\n" > $$@


STLs := $(STLs) \
	stl/z-butt-$(2)-$(1)-master-base.stl \
	stl/z-butt-$(2)-$(1)-sculpt-base.stl \
	stl/z-butt-$(2)-$(1)-stem-cavity.stl \
	stl/z-butt-$(2)-$(1)-sprues-only.stl
endef


$(foreach base,$(BASEs), \
	$(foreach xu,$(XUs),$(eval $(call KEY,$(base),$(xu)u,xu=$(xu)))) \
	$(foreach name,$(NAMEs),$(eval $(call KEY,$(base),$(name),name=\"$(name)\"))) \
)


define RENDER

img/z-butt-$(2)-$(1).jpg : \
	stl/z-butt-$(2)-$(1)-master-base.stl \
	stl/z-butt-$(2)-$(1)-sculpt-base.stl \
	stl/z-butt-$(2)-$(1)-stem-cavity.stl \
	stl/z-butt-$(2)-$(1)-sprues-only.stl

	@mkdir -p img
	blender -b -P render/render.py -- --name=$(2)-$(1) --output=$$@ \
	  --samples=9 --percentage=100 \
	  --distance=$(3) --pan=$(4) --tilt=$(5) --aim-y=$(6)

JPGs := $(JPGs) img/z-butt-$(2)-$(1).jpg
endef

$(eval $(call RENDER,mx,1u,150,-20,-60,-5))
$(eval $(call RENDER,al,1u,150,22,-60,-5))
$(eval $(call RENDER,mx,2u,160,0,-60,-5))
$(eval $(call RENDER,mx,7u,260,15,-60,-15))
$(eval $(call RENDER,mx,iso-enter,200,-18,-75,-5))



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



stl/%.stl : scad/%.scad scad/z-butt.scad
	@mkdir -p stl
	openscad -o /tmp/$*.stl $<
ifneq (, $(shell which meshlabserver))
#	If Meshlab is available, convert STLs to binary.
	meshlabserver -i /tmp/$*.stl -o $@
else
	mv /tmp/$*.stl $@
endif



z-butt-openscad-stl.zip : stl/z-butt-*.stl
	zip -r $@ stl/z-butt-[1-9]*.stl
