##########################################################################################
#                                                                                        #
#                                     Flag Visualizer                                    #
#               A debug tool that makes flagged locations visible for you!               #
#                Version: 1.1.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#   https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Flag-Visualizer   #
#                                                                                        #
##########################################################################################

## <--[information]
## @name Flag Visualizer Commands
## @group Flag Visualizer
## @description
## Data Gathering
## To visualize location flags, data gathering is required. Newly gathered blocks will be automatically displayed as the specified material (default: lime_stained_glass) for 1 minute. The color and material argument can be provided in any order.
## You can gather data by flying around and using one of the following commands to start:
##
## # Gathers data for all blocks flagged with my.cool.sub.flag.path within a range of 50 blocks from the player's location. Flagged blocks will be shown as lime_stained_glass with blue text.
## /visualizeflag search my.cool.sub.flag.path location blue
##
## # Gathers data for all blocks flagged with my.cool.sub.flag.path in the chunk the player is currently in. Flagged blocks will be shown as red_stained_glass with white text.
## /visualizeflag search my.cool.sub.flag.path chunk red_stained_glass
##
## # Gathers data for all blocks flagged with my_flag in the chunk the player is currently in. Flagged blocks will be shown as lime_stained_glass with white text.
## /visualizeflag search my_flag
##
## Once you have finished gathering data, use /visualizeflag again to stop gathering.
##
## Data Visualization
## To display all the location flags you have gathered, use:
##
## # Shows all location flags gathered to the player for 1 minute (ignores unloaded chunks). If the command is ran again, it will cancel for the specific flag.
## /visualizeflag show my_flag
##
## Clearing Data
## To clear your data, you can use the following commands:
##
## # Clears the data of the my_flag flag for the player.
## /visualizeflag clear my_flag
##
## # Clears all data and resets everything for the player.
## /visualizeflag clearall
##
## -->

flagvisualizer:
    type: command
    debug: false
    name: visualizeflag
    description: Makes flagged locations visible.
    usage: /visualizeflag [show/search/clear/clearall] [flag_name] ({chunk}/location) (color/{white}) (stained_glass/{lime_stained_glass})
    tab completions:
        1: search|clear|show|clearall
        2: <context.args.first.equals[clearall].if_true[<empty>].if_false[<player.flag[flagvisualizer.flagged].keys.if_null[<&lt>flag_name<&gt>]>]>
        3: <context.args.first.equals[search].if_true[chunk|location].if_false[<empty>]>
        4: <context.args.first.equals[search].if_true[&#ffffff].if_false[<empty>]>
        5: <context.args.first.equals[search].if_true[black_stained_glass|blue_stained_glass|brown_stained_glass|cyan_stained_glass|gray_stained_glass|green_stained_glass|light_blue_stained_glass|light_gray_stained_glass|lime_stained_glass|magenta_stained_glass|orange_stained_glass|pink_stained_glass|purple_stained_glass|red_stained_glass|white_stained_glass|yellow_stained_glass].if_false[<empty>]>
    permission: flagvisualizer
    script:
    - choose <context.args.size>:
        - case 0:
            - narrate "The search for flagged blocks stopped. No more data will be populated." format:flagvisualizer_format
            - flag <player> flagvisualizer.search:!
        - case 1:
            # Clear all data.
            - if <context.args.first> != clearall:
                - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
                - stop
            - narrate "All data was cleared." format:flagvisualizer_format
            - flag <player> flagvisualizer:!
        - case 2:
            - define flag_name <context.args.get[2]>
            - choose <context.args.first>:
                - case show:
                    # Stop show flags if they are already showing.
                    - define faked_entities <player.fake_entities.filter[has_flag[flagvisualizer.<[flag_name]>]]>
                    - if <[faked_entities].any>:
                        - foreach <[faked_entities]> as:faked_entity:
                            - fakespawn <[faked_entity]> cancel
                        - narrate "Showing entities <[flag_name].color[gold]> was cancelled!" format:flagvisualizer_format
                        - stop
                    # Don't show anything if no data was gathered.
                    - define flag_data <player.flag[flagvisualizer.flagged.<[flag_name]>].if_null[null]>
                    - if <[flag_data]> == null:
                        - narrate "There's no flag data for <[flag_name].color[gold]> stored. Populate data first with <element[/visualizeflag search flag_name].on_click[/visualizeflag search ].type[SUGGEST_COMMAND].on_hover[<gold>Click to prewrite the command]>" format:flagvisualizer_format
                        - stop
                    # Define flagged locations to show in loaded chunks.
                    - define locations <[flag_data.locations].filter[chunk.is_loaded].if_null[<list>]>
                    - if <[locations].is_empty>:
                        - narrate "Loaded chunks don't contain blocks flagged with <[flag_name].color[gold]>!" format:flagvisualizer_format
                        - stop
                    # Create clickables to teleport to flagged locations.
                    - foreach <[locations]> as:location:
                        - if <[loop_index]> >= 32:
                            - foreach stop
                        - clickable flagvisualizer_teleport def.location:<[location]> for:<player> save:loc_<[loop_index]>
                        - define entry <[locations].get[<[loop_index]>]>
                        - define "clickables:->:<[entry].simple.on_click[<entry[loc_<[loop_index]>].command>].on_hover[Teleport to: <[entry].simple>]>"
                    - narrate "<[locations].size.color[gold]> locations found. For the sake of clarity, only the first 32 entries are listed.<n>Locations: <[clickables].separated_by[<element[,].color[gold]> ]>" format:flagvisualizer_format
                    # Display debugblocks.
                    - run flagvisualizer_show_blocks def.locations:<[locations]> def.flag_name:<[flag_name]> def.color:<[flag_data.color]> def.material:<[flag_data.material]>
                # Clear data for a specific flag.
                - case clear:
                    - narrate "Data cleared for <[flag_name].color[gold]>" format:flagvisualizer_format
                    - flag <player> flagvisualizer.flagged.<[flag_name]>:!
                # Gather data of a specific flag.
                - case search:
                    - run flagvisualizer_start_search def.flag_name:<[flag_name]> def.mode:chunk
                - default:
                    - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
        - case 3 4 5:
            - if <context.args.first> != search:
                - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
                - stop
            - run flagvisualizer_start_search def.flag_name:<context.args.get[2]> def.mode:<context.args.get[3]> def.color:<context.args.get[4].if_null[null]> def.material:<context.args.get[5].if_null[null]>
        - default:
            - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
flagvisualizer_start_search:
    type: task
    debug: false
    definitions: flag_name|mode|color|material
    data:
        valid_modes:
        - location
        - chunk
    script:
    # Stop the search if the same command was used.
    - if <player.has_flag[flagvisualizer.search]>:
        - narrate "The search for flagged blocks stopped. No more data will be populated." format:flagvisualizer_format
        - flag <player> flagvisualizer.search:!
        - stop
    # Define a color
    - define valid_color <&color[<[color].if_null[null]>].if_null[<&color[<[material].if_null[null]>].if_null[<white>]>]>
    # Define a material.
    - define valid_material <[material].as[MaterialTag].if_null[<[color].as[MaterialTag].if_null[lime_stained_glass]>]>
    # Default to mode: chunk if an invalid mode was specified.
    - if !<script.data_key[data.valid_modes].contains[<[mode]>]>:
        - narrate "<[mode].color[gold]> is not a valid mode. <gold>Default: chunk" format:flagvisualizer_format
        - define mode chunk
    # Start the search.
    - definemap search flag:<[flag_name]> mode:<[mode]> color:<[valid_color]> material:<[valid_material]>
    - flag <player> flagvisualizer.search:<[search]>
    - flag <player> flagvisualizer.flagged.<[flag_name]>.color:<[valid_color]>
    - flag <player> flagvisualizer.flagged.<[flag_name]>.material:<[valid_material]>
    - narrate "Searching for blocks flagged <[flag_name].color[gold]>! <gold>Mode:<[mode]>" format:flagvisualizer_format
flagvisualizer_search_handler:
    type: world
    debug: false
    events:
        after player steps on block flagged:flagvisualizer.search:
        - ratelimit <player> 1s
        - define search <player.flag[flagvisualizer.search]>
        # If mode is location, search for flagged blocks within 50, else search for flagged blocks in the current chunk.
        - if <player.flag[flagvisualizer.search.mode]> == location:
            - define locations <context.location.find_blocks_flagged[<[search.flag]>].within[50].parse[round_down]>
        - else:
            - define locations <context.location.chunk.blocks_flagged[<[search.flag]>]>
        - define locations <[locations].exclude[<player.flag[flagvisualizer.flagged.<[search.flag]>.locations].if_null[<list>]>]>
        - if <[locations].is_empty>:
            - stop
        # Display debugblocks.
        - run flagvisualizer_show_blocks def.locations:<[locations]> def.flag_name:<[search.flag]> def.color:<[search.color]> def.material:<[search.material]>
        - narrate "<[locations].size.color[gold]> new blocks flagged with <[search.flag].color[gold]> found!" format:flagvisualizer_format
        - narrate <element[Click to show all locations].on_click[/visualizeflag show <[search.flag]>].on_hover[<gold>Click]> format:flagvisualizer_format
        - flag <player> flagvisualizer.flagged.<[search.flag]>.locations:|:<[locations]>
flagvisualizer_teleport:
    type: task
    debug: false
    definitions: location
    script:
    - teleport <[location]>
    - narrate "You've been teleported to <[location].simple.color[gold]>!" format:flagvisualizer_format
flagvisualizer_show_blocks:
    type: task
    debug: false
    definitions: locations|flag_name|material|color
    script:
    - foreach <[locations]> as:location:
        - fakespawn flagvisualizer_debugblock_text[text=<[color]><[flag_name]>] <[location].center.add[0,0.6,0]> duration:1m save:text_display
        - fakespawn flagvisualizer_debugblock_block[material=<[material]>] <[location]> duration:1m save:block_display
        - flag <entry[text_display].faked_entity> flagvisualizer.<[flag_name]>
        - flag <entry[block_display].faked_entity> flagvisualizer.<[flag_name]>
flagvisualizer_format:
    type: format
    debug: false
    format: <yellow>[Flag Visualizer] <gray><[text]>
flagvisualizer_debugblock_text:
    type: entity
    debug: false
    entity_type: text_display
    mechanisms:
        see_through: true
        pivot: center
flagvisualizer_debugblock_block:
    type: entity
    debug: false
    entity_type: block_display
