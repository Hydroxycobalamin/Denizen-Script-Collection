##########################################################################################
#                                                                                        #
#                                      Street-Lights                                     #
#                                  Turn your lights on!                                  #
#                Version: 1.1.1                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#    https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Street-Lights    #
#                                                                                        #
##########################################################################################
street_lights_data:
    type: data
    debug: false
    lights:
        unswitchable:
            #Light on: Light off structure of the unswitchable blocks.
            #You can add more materials to this list to allow more lights.
            #Format:
            #<material>: <material>
            ##You must add a material matcher of the first material to the event which handles adds lights.
            ##Each material must be unique!
            sea_lantern: white_stained_glass
            glowstone: yellow_stained_glass
            jack_o_lantern: pumpkin
            shroomlight: mushroom_stem
            end_rod: glass_pane
            ochre_froglight: yellow_stained_glass
            verdant_froglight: lime_stained_glass
            perlescent_froglight: purple_stained_glass
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
            #Else, give them the Light Tool.
            - give street_light_tool
            - narrate "You received the <item[street_light_tool].display.on_hover[<item[street_light_tool]>].type[SHOW_ITEM]>!" format:street_light_format
        - case 1:
            - choose <context.args.first>:
                - case on:
                    - narrate "You've turned the lights <&[emphasis]>on <&[base]>in world <player.world.name.custom_color[emphasis]>!" format:street_light_format
                    - run street_light_toggle def.state:on def.world:<player.world>
                - case off:
                    - narrate "You've turned the lights <&[emphasis]>off <&[base]>in world <player.world.name.custom_color[emphasis]>!" format:street_light_format
                    - run street_light_toggle def.state:off def.world:<player.world>
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
    - <gold>[Rightclick to Use]
    - <gray>Turn your lights on!
    enchantments:
    - vanishing_curse:1
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
            - flag <[location]> light.on:<[location].material>
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
        - run street_light_toggle def.state:on def.world:<context.world>
        ##Lights off
        after time 6:
        - run street_light_toggle def.state:off def.world:<context.world>
street_light_toggle:
    type: task
    debug: false
    definitions: state|world
    script:
    - foreach <[world].flag[light.locations].if_null[<list>]> key:material as:locations:
        #If the material is unswitchable, set the block manually.
        - if <script[street_lights_data].data_key[lights.unswitchable].contains[<[material]>]>:
            - foreach <[locations]> as:location:
                - if <[state]> == on:
                    #Load the chunk to read the location flag which contains material properties.
                    - chunkload <[location].chunk> duration:1t
                    #Turn the light on.
                    - modifyblock <[location]> <[location].flag[light.<[state]>].if_null[<[material]>]> no_physics
                    #Update location flags if previous version(1.0.0) of Street-Lights was used.
                    - if !<[location].has_flag[light.<[state]>]>:
                        - flag <[location]> light.<[state]>:<[location].material>
                    - wait 1t
                    - foreach next
                #Turn the light off.
                - modifyblock <[location]> <script[street_lights_data].data_key[lights.unswitchable.<[material]>]> no_physics
        #Else, switch the block.
        - else:
            - switch <[locations]> state:<[state]> no_physics
        - wait 5t
street_light_format:
    type: format
    debug: false
    format: <yellow>[Light] <&[base]><[text]>