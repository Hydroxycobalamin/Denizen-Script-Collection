flagvisualizer:
    type: command
    debug: false
    name: visualizeflag
    description: Makes flagged locations visible.
    usage: /visualizeflag [show/search/clear/clearall] [flag_name] ({chunk}/location) (material/{bedrock})
    tab completions:
        1: search|clear|show|clearall
        2: <player.flag[flagvisualizer.flagged].deep_keys.parse[before_last[.]].deduplicate.include[<&lt>flag_name<&gt>].if_null[<&lt>flag_name<&gt>]>
        3: chunk|location
        4: <server.material_types.filter[is_block].parse[name.to_lowercase]>
    permission: flagvisualizer
    script:
    - choose <context.args.size>:
        - case 0:
            - narrate "The search for flagged blocks stopped. No more data will be populated." format:flagvisualizer_format
            - flag <player> flagvisualizer.search:!
        - case 1:
            - if <context.args.first> != clearall:
                - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
                - stop
            - narrate "All data was cleared." format:flagvisualizer_format
            - flag <player> flagvisualizer:!
        - case 2:
            - define flag_name <context.args.get[2]>
            - choose <context.args.first>:
                - case show:
                    - if !<player.flag[flagvisualizer.flagged.<[flag_name]>].exists>:
                        - narrate "There's no flag data for <[flag_name].color[gold]> stored. Populate data first with <element[/visualizeflag search flag_name].on_click[/visualizeflag search ].type[SUGGEST_COMMAND].on_hover[<gold>Click to prewrite the command]>" format:flagvisualizer_format
                        - stop
                    - define flagged_locations <player.flag[flagvisualizer.flagged.<[flag_name]>.locations].filter[chunk.is_loaded].if_null[null]>
                    - if <[flagged_locations].is_empty.if_null[true]>:
                        - narrate "Loaded chunks don't contain blocks flagged with <[flag_name].color[gold]>!" format:flagvisualizer_format
                        - stop
                    - foreach <[flagged_locations]> as:location:
                        - if <[loop_index]> >= 32:
                            - foreach stop
                        - clickable flagvisualizer_teleport def:<[location]> for:<player> save:loc_<[loop_index]>
                        - define entry <[flagged_locations].get[<[loop_index]>]>
                        - define "clickables:->:<[entry].simple.on_click[<entry[loc_<[loop_index]>].command>].on_hover[Teleport to: <[entry].simple>]>"
                    - narrate "<[flagged_locations].size.color[gold]> locations found. For the sake of clarity, only the first 32 entries are listed.<n>Locations: <[clickables].separated_by[<element[,].color[gold]> ]>" format:flagvisualizer_format
                    - showfake <player.flag[flagvisualizer.flagged.<[flag_name]>.material]> <[flagged_locations]> duration:1m
                - case clear:
                    - narrate "Data cleared for <[flag_name].color[gold]>" format:flagvisualizer_format
                    - flag <player> flagvisualizer.flagged.<[flag_name]>:!
                - case search:
                    - run flagvisualizer_start_search def:<[flag_name]>|chunk|bedrock
                - default:
                    - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
        - case 3 4:
            - if <context.args.first> != search:
                - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
                - stop
            - define flag_name <context.args.get[2]>
            - define mode <context.args.get[3]>
            - define material <context.args.get[4].if_null[bedrock]>
            - run flagvisualizer_start_search def:<[flag_name]>|<[mode]>|<[material]>
        - default:
            - narrate "Syntax: <gold><script.data_key[usage]>" format:flagvisualizer_format
flagvisualizer_start_search:
    type: task
    debug: false
    definitions: flag_name|mode|material
    data:
        valid_modes:
        - location
        - chunk
    script:
    - if <player.has_flag[flagvisualizer.search]>:
        - narrate "The search for flagged blocks stopped. No more data will be populated." format:flagvisualizer_format
        - flag <player> flagvisualizer.search:!
        - stop
    - if !<material[<[material]>].is_block.if_null[false]>:
        - narrate "<[material]> is not a block. <gold>Default: Bedrock." format:flagvisualizer_format
        - define block bedrock
    - if !<script.data_key[data.valid_modes].contains[<[mode]>]>:
        - narrate "<[mode].color[gold]> is not a valid mode. <gold>Default: chunk" format:flagvisualizer_format
        - define mode chunk
    - definemap search flag:<[flag_name]> mode:<[mode]> material:<[material]>
    - flag <player> flagvisualizer.search:<[search]>
    - flag <player> flagvisualizer.flagged.<[flag_name]>.material:<[material]>
    - narrate "Searching for blocks flagged <[flag_name].color[gold]>! <gold>Mode:<[mode]>" format:flagvisualizer_format
flagvisualizer_search_handler:
    type: world
    debug: false
    events:
        after player steps on block flagged:flagvisualizer.search:
        - ratelimit <player> 1s
        - define flag_name <player.flag[flagvisualizer.search.flag]>
        - define material <player.flag[flagvisualizer.search.material]>
        - if <player.flag[flagvisualizer.search.mode]> == location:
            - define locations <context.location.find_blocks_flagged[<[flag_name]>].within[50]>
        - else:
            - define locations <context.location.chunk.blocks_flagged[<[flag_name]>]>
        - define locations <[locations].exclude[<player.flag[flagvisualizer.flagged.<[flag_name]>.locations].if_null[<list>]>]>
        - if <[locations].is_empty>:
            - stop
        - showfake <[material]> <[locations]>
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