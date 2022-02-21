#Author: Icecapade
#Date: 2021-03-15
#Version: 1.0.3
WGConverter:
    type: command
    data:
        syntax: Syntax<&co> /wgtodenizen [all|world|region] (<&lt>world<&gt>) (<&lt>region<&gt>)
    debug: false
    name: wgtodenizen
    description: converts worldguard regions to useable notables
    usage: /wgtodenizen [all|world|region] (<&lt>world<&gt>) (<&lt>region<&gt>)
    permission: wgconverter.admin
    tab completions:
        1: all|world|region
        2: <list[world|region].contains[<context.args.first>].if_true[<server.worlds.parse[name]>].if_false[<empty>]>
        3: <context.args.first.equals[region].if_true[<world[<context.args.get[2]>].list_regions.parse[id].if_null[<empty>]>].if_false[<empty>]>
    script:
    - choose <context.args.size>:
        - case 1:
            - if <context.args.first> != all:
                - narrate <script.parsed_key[data.syntax]> format:WGConverter_format
                - stop
            - narrate "Converting all WorldGuard-regions in useable Denizen notables.." format:WGConverter_format
            - foreach <server.worlds> as:world:
                - narrate "Current World: <[world].name.color[gold]>" format:WGConverter_format
                - foreach <[world].list_regions> as:region:
                    - if <[region].area.if_null[null]> == null:
                        - narrate "The region <gold><[region].id.color[gold]> is not convertable. Skipping." format:WGConverter_format
                        - foreach next
                    - note <[region].area> as:WG_<[region].id>
                    - narrate "The region <gold><[region].id> <gray>was sucessfully converted to a notable called <gold>WG_<[region].id>" format:WGConverter_format
                - wait 1t
        - case 2:
            - if <context.args.first> != world:
                - narrate <script.parsed_key[data.syntax]> format:WGConverter_format
                - stop
            - define world <world[<context.args.get[2]>].if_null[null]>
            - if <[world]> == null:
                - narrate "This world does not exist or is not loaded." format:WGConverter_format
                - stop
            - foreach <[world].list_regions> as:region:
                - if <[region].area.if_null[null]> == null:
                    - narrate "The region <[region].id.color[gold]> is not convertable. Skipping." format:WGConverter_format
                    - foreach next
                - note <[region].area> as:WG_<[region].id>
                - narrate "The region <[region].id.color[gold]> was sucessfully converted to a notable called <gold>WG_<[region].id>" format:WGConverter_format
                - wait 1t
        - case 3:
            - define first_argument <context.args.first>
            - if <context.args.first> != region:
                - narrate <script.parsed_key[data.syntax]> format:WGConverter_format
                - stop
            - define world_name <context.args.get[2]>
            - define world <world[<[world_name]>].if_null[null]>
            - if <world[<[world]>].if_null[null]> == null:
                - narrate "This world <[world_name].color[gold]> does not exist or is not loaded." format:WGConverter_format
                - stop
            - define id <context.args.last>
            - if !<[world].has_region[<[id]>]>:
                - narrate "This world does not have a region called <[id].color[gold]>!" format:WGConverter_format
                - stop
            - define area <region[<[id]>,<[world_name]>].area.if_null[null]>
            - if <[area]> == null:
                - narrate "The region is not convertable." format:WGConverter_format
                - stop
            - narrate "The region <[id].color[gold]> was sucessfully converted to a notable called <gold>WG_<[id]>" format:WGConverter_format
            - note <[area]> as:WG_<[id]>
WGConverter_format:
    type: format
    debug: false
    format: <yellow>[WGConverter] <gray><[text]>