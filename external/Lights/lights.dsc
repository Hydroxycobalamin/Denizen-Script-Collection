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
        ##Lights add/remove
        after player right clicks *candle|redstone_lamp|sea_lantern|glowstone|jack_o_lantern|shroomlight|end_rod with:street_light_tool:
        - define location <context.location>
        #If the location don't has the flag light, add the location as light.
        - if !<[location].has_flag[light]>:
            - flag <[location].world> light.locations.<[location].material.name>:->:<[location]>
            - flag <[location]> light
            - narrate "Light added." format:street_light_format
        #Else remove the location being a light.
        - else:
            - flag <[location].world> light.locations.<[location].material.name>:<-:<[location]>
            - flag <[location]> light:!
            - narrate "Light removed." format:street_light_format
        ##Prevent the light from being destroyed
        on player breaks block location_flagged:light:
        - determine cancelled
        on block destroyed by explosion location_flagged:light:
        - determine cancelled
        on piston extends:
        - if <context.blocks.filter_tag[<[filter_value].has_flag[light]>].any>:
            - determine cancelled
        on piston retracts:
        - if <context.blocks.filter_tag[<[filter_value].has_flag[light]>].any>:
            - determine cancelled
        ##Prevent misuse of the Light Tool.
        after player drops street_light_tool:
        - remove <context.entity>
        ##Lights on
        after time 18:
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
        #If the material is unswitchable, set the block.
        - if <script[street_lights_data].data_key[lights.unswitchable].contains[<[material]>]>:
            #If <[blocks].get[<[material]>]> is_null set the <[material]> instead.
            - modifyblock <[locations]> <[blocks].get[<[material]>].if_null[<[material]>]>
        #Else, switch the block.
        - else:
            - switch <[locations]> state:<[state]>
        - wait 5t
street_light_format:
    type: format
    debug: false
    format: <yellow>[Light] <&[base]><[text]>