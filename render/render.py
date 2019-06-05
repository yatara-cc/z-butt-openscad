import os
import sys
import math
import argparse

import bpy

SPACING = 10



def render(path, x=1024, y=512, percentage=100):
    scene = bpy.data.scenes["Scene"]

    scene.render.resolution_x = x
    scene.render.resolution_y = y
    scene.render.resolution_percentage = percentage

    bpy.context.scene.render.image_settings.file_format = "JPEG"
    bpy.context.scene.render.filepath = path

    bpy.ops.render.render(write_still=True)



def create_material_plastic(color, roughness, name):

    material = bpy.data.materials.new(name=name)
    material.use_nodes = True
    [material.node_tree.nodes.remove(v) for v in material.node_tree.nodes]

    noise = material.node_tree.nodes.new('ShaderNodeTexNoise')
    noise.inputs["Scale"].default_value = 75
    noise.inputs["Detail"].default_value = 2

    bump = material.node_tree.nodes.new('ShaderNodeBump')
    bump.inputs["Distance"].default_value = 0.015
    material.node_tree.links.new(
        noise.outputs["Color"], bump.inputs["Height"])

    principled = material.node_tree.nodes.new('ShaderNodeBsdfPrincipled')
    principled.inputs["Base Color"].default_value = tuple(list(color) + [1.0])
    principled.inputs["Roughness"].default_value = roughness
    material.node_tree.links.new(
        bump.outputs["Normal"], principled.inputs["Normal"])

    output = material.node_tree.nodes.new('ShaderNodeOutputMaterial')
    material.node_tree.links.new(
        principled.outputs["BSDF"], output.inputs["Surface"])

    return material



def create_material_glass():
    material = bpy.data.materials.new(name="Glass")
    material.use_nodes = True
    [material.node_tree.nodes.remove(v) for v in material.node_tree.nodes]

    glossy = material.node_tree.nodes.new('ShaderNodeBsdfGlossy')
    glossy.inputs["Roughness"].default_value = 0.01

    output = material.node_tree.nodes.new('ShaderNodeOutputMaterial')
    material.node_tree.links.new(glossy.outputs["BSDF"], output.inputs["Surface"])

    return material



def create_area_lamp(name="Area", location=(0, 0, 0),
                     size=1, strength=100, color=(1, 1, 1, 1)):

    distance = math.sqrt(
        pow(location[0], 2) +
        pow(location[1], 2) +
        pow(location[2], 2)
    )

    bpy.ops.object.lamp_add(type='AREA')
    area = bpy.data.objects["Area"]
    area.name = name
    area.location = location
    area.data.size = size
    emission = area.data.node_tree.nodes["Emission"]
    emission.inputs["Strength"].default_value = strength * distance
    emission.inputs["Color"].default_value = color
    return area



def load_obj(path, name, color):
    bpy.ops.import_mesh.stl(
        filepath=path,
        axis_forward='Y',
        axis_up='Z',
        filter_glob="*.stl"
    )
    obj = bpy.context.active_object
    obj.name = name

    # Put base of object on XY-plane:
    obj.location.z = -obj.bound_box[0][2]

    obj.data.materials.append(create_material_plastic(
        color, roughness=0.1, name=f"plastic-{name}"))
    return obj



def arrange_objects(objects):
    max_width = max([v.dimensions.x for v in objects])
    max_depth = max([v.dimensions.y for v in objects])

    assert len(objects) == 4

    if max_width > max_depth * 2:
        objects[0].location.x = -objects[0].dimensions.x
        total_depth = sum([v.dimensions.y for v in objects]) + SPACING * len(objects)

        y = total_depth / 2
        for obj in objects:
            depth = obj.dimensions.y + SPACING
            y -= depth / 2
            obj.location.x = -obj.bound_box[0][0] - obj.dimensions.x / 2
            obj.location.y = y
            y -= depth / 2
    else:
        objects[0].location.x = -objects[0].bound_box[0][0] + SPACING / 2
        objects[1].location.x = -objects[1].bound_box[0][0] + SPACING / 2
        objects[2].location.x = -objects[2].bound_box[6][0] - SPACING / 2
        objects[3].location.x = -objects[3].bound_box[6][0] - SPACING / 2
        objects[0].location.y = -objects[0].bound_box[0][1] + SPACING / 2
        objects[2].location.y = -objects[2].bound_box[0][1] + SPACING / 2
        objects[1].location.y = -objects[1].bound_box[6][1] - SPACING / 2
        objects[3].location.y = -objects[3].bound_box[6][1] - SPACING / 2



def load_objects(name):
    if name[-3:] in ("-mx", "-al"):
        objects = [
            load_obj(
                f"stl/z-butt-{name}-sculpt-base.stl",
                name="Sculpt Base",
                color=(1.0, 0.5, 1.0)
            ),
            load_obj(
                f"stl/z-butt-{name}-master-base.stl",
                name="Master Base",
                color=(1.0, 0.75, 0.5)
            ),
            load_obj(
                f"stl/z-butt-{name}-sprues-only.stl",
                name="Sprues Only",
                color=(0.5, 0.75, 1.0)
            ),
            load_obj(
                f"stl/z-butt-{name}-stem-cavity.stl",
                name="Stem Cavity",
                color=(0.75, 1.0, 0.5)
            ),
        ]

        arrange_objects(objects)
    else:
        back = load_obj(
            f"stl/z-butt-{name}-container.stl",
            name="Sculpt Base",
            color=(0.75, 0.125, 0.125)
        )
        back.location.y += SPACING

        front = load_obj(
            f"stl/z-butt-{name}-container.stl",
            name="Sculpt Base",
            color=(0.75, 0.125, 0.125)
        )
        front.location.y -= SPACING
        front.rotation_euler.z = math.radians(180)


def main():
    while sys.argv:
        v = sys.argv.pop(0)
        if v == "--":
            sys.argv.insert(0, __file__)
            break

    parser = argparse.ArgumentParser(
        description="Render objects as JPG.")

    parser.add_argument(
        "--samples", "-s",
        type=int, default=6,
        help="Number of render samples.")
    parser.add_argument(
        "--percentage", "-p",
        type=float, default=100,
        help="Render size percentage.")
    parser.add_argument(
        "--pan", "-P",
        type=float, default=12.5,
        help="Camera pan.")
    parser.add_argument(
        "--tilt", "-T",
        type=float, default=-60,
        help="Camera tilt.")
    parser.add_argument(
        "--distance", "-D",
        type=float, default=100,
        help="Camera distance.")
    parser.add_argument(
        "--aim-z", "-z",
        type=float, default=0,
        help="Camera aim Z.")

    parser.add_argument(
        "--name", "-n",
        help="STL model name.")
    parser.add_argument(
        "--output", "-o",
        help="Path to JPG output file.")

    args = parser.parse_args()


    scene = bpy.data.scenes["Scene"]
    scene.render.engine = 'CYCLES'
    bpy.context.scene.cycles.use_square_samples = True
    bpy.context.scene.cycles.samples = args.samples
    bpy.context.scene.render.layers[0].cycles.use_denoising = True


    world = bpy.data.worlds["World"]
    world.use_nodes = True
    if os.path.exists("render/environment.jpg"):
        environment = world.node_tree.nodes.new('ShaderNodeTexEnvironment')
        image = bpy.data.images.load(filepath="render/environment.jpg")
        environment.image = image
        world.node_tree.links.new(
            environment.outputs["Color"],
            world.node_tree.nodes["Background"].inputs["Color"]
        )
    else:
        background_luminosity = 0.3
        world.node_tree.nodes["Background"].inputs["Color"].default_value = \
            tuple([background_luminosity] * 3 + [1.0])

    # Delete default objects:
    bpy.ops.object.select_all(action="SELECT")
    bpy.data.objects['Camera'].select = False
    bpy.ops.object.delete()

    load_objects(args.name);

    create_area_lamp(
        name="Area Key", location=(250, -100, 300),
        size=100, strength=3000, color=(1, 1, 1.2, 1))
    create_area_lamp(
        name="Area Fill", location=(-200, 0, 80),
        size=200, strength=750, color=(1, 1, 1.1, 1))
    create_area_lamp(
        name="Area Rim", location=(-300, 300, 80),
        size=10, strength=2000, color=(1.1, 1.1, 1, 1))

    bpy.ops.mesh.primitive_plane_add(
        radius=1000,
        location=(0, 0, 0),
        rotation=(0, 0, 0)
    )
    plane = bpy.data.objects["Plane"]

    glass = create_material_plastic(
        (1, 1, 1), roughness=0.0, name="plastic-plane")
    glass.node_tree.nodes["Principled BSDF"] \
        .inputs["Specular"].default_value = 0.0
    plane.data.materials.append(glass)

    bpy.context.scene.camera.data.clip_end = 500

    field_of_view = 50.0

    tz = args.aim_z - math.sin(math.radians(args.tilt)) * args.distance
    out = math.cos(math.radians(args.tilt)) * args.distance

    tx = math.sin(math.radians(args.pan)) * out
    ty = -math.cos(math.radians(args.pan)) * out

    scene.camera.data.angle = math.radians(field_of_view)
    scene.camera.rotation_mode = 'XYZ'
    scene.camera.rotation_euler = (
        math.radians(90 + args.tilt),
        0,
        math.radians(args.pan)
    )
    scene.camera.location = (tx, ty, tz)


    render(args.output, x=870, y=620, percentage=args.percentage)
    if os.path.exists("/tmp"):
        bpy.ops.wm.save_as_mainfile(filepath=f"/tmp/z-butt-{args.name}.blend")



main()
