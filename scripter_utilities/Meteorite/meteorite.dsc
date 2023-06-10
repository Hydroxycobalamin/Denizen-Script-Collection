##########################################################################################
#                                                                                        #
#                                        Meteorite                                       #
#                             Fires a meteorite into a world                             #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#      https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Meteorite      #
#                                                                                        #
##########################################################################################

## <--[task]
## @name fire_meteorite
## @description
## Spawns a meteorite that falls down near the linked player.
## @Usage
## Use to spawn a meteorite on a random player.
## - run fire_meteorite player:<server.players.random>
## @Script Meteorite
## -->
fire_meteorite:
    type: task
    description: This task fires a meteorite that crashes down on the world. Can be injected. Requires a linked player.
    debug: false
    script:
    - define entry <player.location.random_offset[50,0,50].with_y[<player.world.max_height>]>
    - define player_area <player.location.random_offset[125,0,125].proc[meteorite_get_location]>
    # Use sub_lists to speed up the smoke of the meteorite when particles play.
    - define points <[entry].points_between[<[player_area]>].sub_lists[3]>
    - define id <util.random_uuid>
    - shoot meteorite_fire_ball origin:<[points].first.first> destination:<[points].last.last> speed:3.15 save:meteorite
    - mount meteorite|<entry[meteorite].shot_entity> save:mount
    - flag <entry[meteorite].shot_entity> id:<[id]>
    - define velocity <entry[meteorite].shot_entity.velocity>
    - foreach <[points]> as:point:
        - playeffect effect:campfire_cosy_smoke at:<[point]> offset:1,1,1 quantity:25 visibility:300
        - if <entry[meteorite].shot_entity.is_spawned>:
            # Reapply initial velocity to have a constant speed of the fireball.
            - adjust <entry[meteorite].shot_entity> velocity:<[velocity]>
        - else:
            # If the fireball explodes early explode the meteorite.
            - run meteorite_explode def.location:<[entry].world.flag[meteorite.<[id]>]>
            - foreach stop
        - if <[points].size.sub[4]> == <[loop_index]>:
            - run meteorite_explode def.location:<[player_area]>
            - foreach stop
        - wait 1t
    - remove <entry[mount].mounted_entities.first>
meteorite_explode:
    type: task
    debug: false
    description: This task explodes the meteorite and spawns it as real blocks.
    definitions: location[LocationTag]
    script:
    - explode power:4 <[location]> fire breakblocks
    - wait 1t
    - schematic paste name:meteorite <[location].proc[meteorite_get_location]> noair
meteorite_get_location:
    type: procedure
    debug: false
    description: This procedure adjusts the end location of the meteorite. Can be underwater.
    definitions: location[LocationTag]
    script:
    - if !<[location].material.is_solid>:
        - define blocks <[location].to_cuboid[<[location].with_y[<[location].world.min_height>]>].blocks>
        - determine <[blocks].filter[material.is_solid].last>
    - determine <[location]>
meteorite:
    type: entity
    debug: false
    entity_type: block_display
    mechanisms:
        material: obsidian
        display_entity_data:
            # This increases the size of the obsidian block.
            transformation_scale: 3,3,3
            # These are default values, but required.
            transformation_left_rotation: 0|0|0|1
            transformation_right_rotation: 0|0|0|1
            # This moves the block_display into the fireball so it's centered.
            transformation_translation: -1.5,-1.5,-1.5
            # The view range players can see the block_display.
            view_range: 300
meteorite_fire_ball:
    type: entity
    debug: false
    entity_type: fireball
meteorite_handler:
    type: world
    debug: false
    events:
        on meteorite_fire_ball explodes:
        - flag <context.location.world> meteorite.<context.entity.flag[id]>:<context.location.add[<context.entity.velocity>]> expire:1s
        after meteorite_fire_ball spawns:
        - while <context.entity.is_spawned>:
            - playeffect effect:flame at:<context.entity.location.to_ellipsoid[3,3,3].shell> visibility:300
            - wait 1t
        after scripts loaded:
        - if !<util.has_file[/schematics/METEORITE.schem]>:
            - debug error "<&[error]>Schematic for METEORITE couldn't be found. Did you move the '<&[emphasis]>METEORITE.schem<&[error]>' file into '<&[emphasis]>/plugins/Denizen/schematics'<&[error]>?"
            - stop
        - if !<schematic[METEORITE].exists>:
            - ~schematic load name:METEORITE