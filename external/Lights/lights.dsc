street_lights_data:
    type: data
    debug: false
    lights:
        unswitchable:
            sea_lantern: white_stained_glass
            glowstone: yellow_stained_glass
            jack_o_lantern: pumpkin
            shroomlight: mushroom_stem
            end_rod: glass_pane
street_lights_cmd:
    type: command
    debug: false
    name: lights
    description: lights command
    usage: /lights (show/on/off)
    tab completions:
        1: show|on|off
    permission: lights.admin
    script:
    - choose <context.args.size>:
        - case 0:
            #If the player inventory can't fit the Light Tool, stop the script.
            - if !<player.inventory.can_fit[street_light_tool]>:
                - narrate "You don't have enough space in your inventory!" format:street_light_format
                - stop
            #Else, give him the Light Tool.
            - give street_light_tool
            - narrate "You received the <item[street_light_tool].display.on_hover[<item[street_light_tool]>].type[SHOW_ITEM]>!" format:street_light_format
        - case 1:
            - choose <context.args.first>:
                - case on:
                    - narrate "You've turned the lights <&[emphasis]>on <&[base]>in world <player.world.name.custom_color[emphasis]>!" format:street_light_format
                    - run street_light_toggle def.state:on def.blocks:<script[street_lights_data].data_key[lights.unswitchable].invert> def.world:<player.world>
                - case off:
                    - narrate "You've turned the lights <&[emphasis]>off <&[base]>in world <player.world.name.custom_color[emphasis]>!" format:street_light_format
                    - run street_light_toggle def.state:off def.blocks:<script[street_lights_data].data_key[lights.unswitchable]> def.world:<player.world>
                - case show:
                    #If the world doesn't has any lights yet, stop the script.
                    - if !<player.world.has_flag[light.locations]>:
                        - narrate "The world doesn't has lights yet." format:street_light_format
                        - stop
                    #Construct the Output.
                    - foreach <player.world.flag[light.locations]> key:material as:locations:
                        - define "output:->:<[material].color[aqua]> <[locations].parse[simple].space_separated.color[yellow]>"
                    - narrate "<&[emphasis]>List of Lights"
                    - narrate <[output].separated_by[<n>]>
                - default:
                    - narrate "Syntax: <script.data_key[usage].custom_color[emphasis]>" format:street_light_format
        - default:
            - narrate "Syntax: <script.data_key[usage].custom_color[emphasis]>" format:street_light_format
street_light_tool:
    type: item
    debug: false
    material: stick
    display name: <yellow>Light Tool
    lore:
    - <gray>Turn the lights on!
    enchantments:
    - durability:1
    mechanisms:
        hides: ALL
street_light_handler:
    type: world
    debug: false
    events:
        ##Add Lights
        after player right clicks *campfire|*candle|redstone_lamp|sea_lantern|glowstone|jack_o_lantern|shroomlight|end_rod with:street_light_tool permission:lights.admin:
        - define location <context.location>
        #If the location doesn't have the flag light, add the location as light.
        - if !<[location].has_flag[light]>:
            - flag <[location].world> light.locations.<[location].material.name>:->:<[location]>
            - flag <[location]> light:<[location].material.property_map>
            - narrate "Light added." format:street_light_format
        ##Remove lights
        after player right clicks block location_flagged:light with:street_light_tool permission:lights.admin:
        - define location <context.location>
        - flag <[location].world> light.locations.<[location].material.name>:<-:<[location]>
        - flag <[location]> light:!
        - narrate "Light removed." format:street_light_format
        ##Prevent the light from being destroyed
        on player breaks block location_flagged:light:
        - determine cancelled passively
        - ratelimit <player> 1s
        - narrate "You can't destroy this light. Remove it first with the <item[street_light_tool].display.on_hover[<item[street_light_tool]>].type[SHOW_ITEM]>!" format:street_light_format
        on block destroyed by explosion location_flagged:light:
        - determine cancelled
        on piston extends:
        - if <context.blocks.filter_tag[<[filter_value].has_flag[light]>].any>:
            - determine cancelled
        on piston retracts:
        - if <context.blocks.filter_tag[<[filter_value].has_flag[light]>].any>:
            - determine cancelled
        on entity changes block location_flagged:light:
        - determine cancelled
        ##Remove the tool on drop.
        after player drops street_light_tool:
        - remove <context.entity>
        ##Lights on
        after time 19:
        - run street_light_toggle def.state:on def.blocks:<script[street_lights_data].data_key[lights.unswitchable].invert> def.world:<context.world>
        ##Lights off
        after time 6:
        - run street_light_toggle def.state:off def.blocks:<script[street_lights_data].data_key[lights.unswitchable]> def.world:<context.world>
street_light_toggle:
    type: task
    debug: false
    definitions: state|blocks|world
    script:
    - foreach <[world].flag[light.locations].if_null[<list>]> key:material as:locations:
        #Special case workaround for redstone_lamps, to prevent them from going out again immediately.
        - if <[material]> == redstone_lamp:
            - modifyblock <[locations]> redstone_lamp[switched=<[state].equals[on].if_true[true].if_false[false]>]
            - wait 5t
            - foreach next
        #If the material is unswitchable, set the block manually.
        - if <script[street_lights_data].data_key[lights.unswitchable].contains[<[material]>]>:
            - foreach <[locations]> as:location:
                - if <[state]> == on:
                    #Load the chunk to read the location flag which contains material properties.
                    - chunkload <[location].chunk> duration:1t
                    #Fallback if previous version(1.0.0) of Street-Lights was used.
                    - define properties <[location].flag[light].if_true[<map>].if_false[]>
                    #Turn the light on.
                    - modifyblock <[location]> <material[<[material]>].with_map[<[properties]>]>
                    - foreach next
                #Turn the light off.
                - modifyblock <[location]> <[blocks].get[<[material]>]>
        #Else, switch the block.
        - else:
            - switch <[locations]> state:<[state]>
        - wait 5t
street_light_format:
    type: format
    debug: false
    format: <yellow>[Light] <&[base]><[text]>