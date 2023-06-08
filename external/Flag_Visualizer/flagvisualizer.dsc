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
## To visualize location flags, data gathering is required. Newly gathered blocks will be automatically displayed as the specified material (default: bedrock) for 10 seconds.
## You can gather data by flying around and using one of the following commands to start:
##
## # Gathers data for all blocks flagged with my.cool.sub.flag.path within a range of 50 blocks from the player's location. Flagged blocks will be shown as red_wool.
## /visualizeflag search my.cool.sub.flag.path location red_wool
##
## # Gathers data for all blocks flagged with my.cool.sub.flag.path in the chunk the player is currently in. Flagged blocks will be shown as red_wool.
## /visualizeflag search my.cool.sub.flag.path chunk red_wool
##
## # Gathers data for all blocks flagged with my_flag in the chunk the player is currently in. Flagged blocks will be shown as bedrock.
## /visualizeflag search my_flag
##
## Once you have finished gathering data, use /visualizeflag again to stop gathering.
##
## Data Visualization
## To display all the location flags you have gathered, use:
##
## # Shows all location flags gathered to the player for 1 minute (ignores unloaded chunks).
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
    usage: /visualizeflag [show/search/clear/clearall] [flag_name] ({chunk}/location) (color/{white})
    tab completions:
        1: search|clear|show|clearall
        2: <context.args.first.equals[clearall].if_true[<empty>].if_false[<player.flag[flagvisualizer.flagged].keys.if_null[<&lt>flag_name<&gt>]>]>
        3: <context.args.first.equals[search].if_true[chunk|location].if_false[<empty>]>
        4: <context.args.first.equals[search].if_true[<&lt>&#ffffff<&gt>].if_false[<empty>]>
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
                    # Don't show anything if no data was gathered.
                    - if !<player.has_flag[flagvisualizer.flagged.<[flag_name]>]>:
                        - narrate "There's no flag data for <[flag_name].color[gold]> stored. Populate data first with <element[/visualizeflag search flag_name].on_click[/visualizeflag search ].type[SUGGEST_COMMAND].on_hover[<gold>Click to prewrite the command]>" format:flagvisualizer_format
                        - stop
                    # Define flagged locations to show in loaded chunks.
                    - define flagged_locations <player.flag[flagvisualizer.flagged.<[flag_name]>.locations].filter[chunk.is_loaded].if_null[<list>]>
                    - if <[flagged_locations].is_empty>:
                        - narrate "Loaded chunks don't contain blocks flagged with <[flag_name].color[gold]>!" format:flagvisualizer_format
                        - stop
                    # Create clickables to teleport to flagged locations.
                    - foreach <[flagged_locations]> as:location:
                        - if <[loop_index]> >= 32:
                            - foreach stop
                        - clickable flagvisualizer_teleport def.location:<[location]> for:<player> save:loc_<[loop_index]>
                        - define entry <[flagged_locations].get[<[loop_index]>]>
                        - define "clickables:->:<[entry].simple.on_click[<entry[loc_<[loop_index]>].command>].on_hover[Teleport to: <[entry].simple>]>"
                    - narrate "<[flagged_locations].size.color[gold]> locations found. For the sake of clarity, only the first 32 entries are listed.<n>Locations: <[clickables].separated_by[<element[,].color[gold]> ]>" format:flagvisualizer_format
                    # Display debugblocks. Dont show the green cube if more than 60 cubes would be displayed to save client fps.
                    - if <[flagged_locations].size> > 60:
                        - debugblock <[flagged_locations]> color:<color[255,255,255,0]> name:<player.flag[flagvisualizer.flagged.<[flag_name]>.color]><[flag_name]> duration:1m
                    - else:
                        - debugblock <[flagged_locations]> color:<color[255,255,255,128]> name:<player.flag[flagvisualizer.flagged.<[flag_name]>.color]><[flag_name]> duration:1m
                # Clear data for a specific flag.
                - case clear:
                    - narrate "Data cleared for <[flag_name].color[gold]>" format:flagvisualizer_format
                    - flag <player> flagvisualizer.flagged.<[flag_name]>:!
                # Gather data of a specific flag.
                - case search:
                    - run flagvisualizer_start_search def.flag_name:<[flag_name]> def.mode:chunk def.color:white
                - default:
                    - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
        - case 3 4:
            - if <context.args.first> != search:
                - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
                - stop
            - run flagvisualizer_start_search def.flag_name:<context.args.get[2]> def.mode:<context.args.get[3]> def.color:<context.args.get[4].if_null[white]>
        - default:
            - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
flagvisualizer_start_search:
    type: task
    debug: false
    definitions: flag_name|mode|color
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
    # Define a color.
    - define color <&color[<[color]>].if_null[<&color[white]>]>
    # Default to mode: chunk if an invalid mode was specified.
    - if !<script.data_key[data.valid_modes].contains[<[mode]>]>:
        - narrate "<[mode].color[gold]> is not a valid mode. <gold>Default: chunk" format:flagvisualizer_format
        - define mode chunk
    # Start the search.
    - definemap search flag:<[flag_name]> mode:<[mode]> color:<[color]>
    - flag <player> flagvisualizer.search:<[search]>
    - flag <player> flagvisualizer.flagged.<[flag_name]>.color:<[color]>
    - narrate "Searching for blocks flagged <[flag_name].color[gold]>! <gold>Mode:<[mode]>" format:flagvisualizer_format
flagvisualizer_search_handler:
    type: world
    debug: false
    events:
        after player steps on block flagged:flagvisualizer.search:
        - ratelimit <player> 1s
        - define flag_name <player.flag[flagvisualizer.search.flag]>
        - define color <player.flag[flagvisualizer.search.color]>
        # If mode is location, search for flagged blocks within 50, else search for flagged blocks in the current chunk.
        - if <player.flag[flagvisualizer.search.mode]> == location:
            - define locations <context.location.find_blocks_flagged[<[flag_name]>].within[50]>
        - else:
            - define locations <context.location.chunk.blocks_flagged[<[flag_name]>]>
        - define locations <[locations].exclude[<player.flag[flagvisualizer.flagged.<[flag_name]>.locations].if_null[<list>]>]>
        - if <[locations].is_empty>:
            - stop
        # Display debugblocks. Dont show the green cube if more than 60 cubes would be displayed to save client fps.
        - if <[locations].size> > 60:
            - debugblock <[locations]> color:<color[255,255,255,0]> name:<player.flag[flagvisualizer.flagged.<[flag_name]>.color]><[flag_name]> duration:1m
        - else:
            - debugblock <[locations]> color:<color[255,255,255,128]> name:<player.flag[flagvisualizer.flagged.<[flag_name]>.color]><[flag_name]> duration:1m
        - narrate "<[locations].size.color[gold]> new blocks flagged with <[flag_name].color[gold]> found!" format:flagvisualizer_format
        - narrate "<element[Click to show all locations].on_click[/visualizeflag show <[flag_name]>].on_hover[<gold>Click]>" format:flagvisualizer_format
        - flag <player> flagvisualizer.flagged.<[flag_name]>.locations:|:<[locations]>
flagvisualizer_teleport:
    type: task
    debug: false
    definitions: location
    script:
    - teleport <[location]>
    - narrate "You've been teleported to <[location].simple.color[gold]>!" format:flagvisualizer_format
flagvisualizer_format:
    type: format
    debug: false
    format: <yellow>[Flag Visualizer] <gray><[text]>