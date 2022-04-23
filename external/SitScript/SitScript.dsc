##########################################################################################
#                                                                                        #
#                                       SimpleSit                                        #
#                             Let your players sit on stairs                             #
#                Version: 1.4.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#      https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/SimpleSit      #
#                                                                                        #
##########################################################################################
simplesit:
    type: world
    debug: false
    data:
        config:
            #If false, players can not sit on corner stairs
            sit-on-corners: true
            #If true, players can sit on any stair even if they can not reach the location
            players-reach-any-block: false
    simplesit_cancel:
        - define properties <player.flag[simplesit.armorstand]>
        #Remove the armor_stand and the players flag so he can sit again.
        - remove <[properties.entity]>
        - flag <player> simplesit:!
    events:
        after player right clicks *_stairs with:air:
        - define location <context.location>
        - if <player.has_flag[simplesit]> || <player.is_sneaking> || <[location].material.half> == TOP || <[location].above.material.is_solid>:
            - stop
        #Check the config options.
        - define config <script.data_key[data.config]>
        - if !<[config.sit-on-corners]>:
            - if <[location].material.shape> != STRAIGHT:
                - stop
        - if !<[config.players-reach-any-block]>:
            - if <[location].y.sub[<player.location.y>]> > 1 || !<player.is_on_ground> && <[location].y.sub[<player.location.y>]> > 0:
                - stop
        - choose <[location].material.direction>:
            - case NORTH:
                - spawn <[location].add[0.5,-1.2,0.6].with_yaw[0].with_pitch[0]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
            - case SOUTH:
                - spawn <[location].add[0.5,-1.2,0.4].with_yaw[180].with_pitch[0]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
            - case WEST:
                - spawn <[location].add[0.6,-1.2,0.5].with_yaw[-90].with_pitch[0]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
            - case EAST:
                - spawn <[location].add[0.4,-1.2,0.5].with_yaw[90].with_pitch[0]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
        - mount <player>|<entry[armor].spawned_entity>
        - definemap map entity:<entry[armor].spawned_entity> location:<[location]>
        - flag server simplesit.sitters:->:<player>
        - flag <player> simplesit.armorstand:<[map]>
        after player exits vehicle flagged:simplesit:
        - define location <context.entity.location.add[0,2.2,0]>
        - inject simplesitcancel
        - teleport <[location]>
        on player quits flagged:simplesit:
        - inject simplesitcancel
simplesitcancel:
    type: task
    debug: false
    script:
    - define map <player.flag[simplesit.armorstand]>
    - define chunk <[map].get[location].chunk>
    - if !<[chunk].is_loaded>:
        - chunkload <[chunk]> duration:1s
    - remove <[map].get[entity]>
    - flag <player> simplesit:!
    - flag server simplesit.sitters:<-:<player>
simplesitcommand:
    type: command
    debug: false
    name: simplesit
    description: only used for debug purposes and error handling
    usage: /simplesit [kick/list] (player)
    permission: simplesit.admin
    tab completions:
        1: kick|list
        2: <context.args.first.equals[kick].if_true[<server.flag[simplesit.sitters].parse[name]>].if_false[<empty>]>
    script:
    - choose <context.args.size>:
        - case 1:
            - if <context.args.first> != list:
                - narrate <script[simplesitdata].parsed_key[help].separated_by[<n>]> format:simplesitformat
                - stop
            - if <server.flag[simplesit.sitters].is_empty.if_null[true]>:
                - narrate "Nobody sits." format:simplesitformat
                - stop
            - define player_list <server.flag[simplesit.sitters]>
            - foreach <[player_list]> as:player:
                - clickable simplesitteleport def:<[player]> for:<player> save:teleport_<[player]>
            - narrate "<yellow>Players sitting:" format:simplesitformat
            - narrate "<[player_list].parse_tag[<dark_aqua><&n><[parse_value].name.on_click[<entry[teleport_<[parse_value]>].command>].on_hover[Teleport to <[parse_value].name>'s sit location]><gray>].comma_separated>"
        - case 2:
            - if <context.args.first> != kick:
                - narrate <script[simplesitdata].parsed_key[help].separated_by[<n>]> format:simplesitformat
                - stop
            - define player <server.match_offline_player[<context.args.get[2]>].if_null[null]>
            - if <[player]> == null:
                - narrate "The player is not valid!" format:simplesitformat
                - stop
            - if !<[player].has_flag[simplesit]>:
                - narrate "The player does not sit." format:simplesitformat
                - stop
            - announce "[SimpleSit] <player.name> has removed ARMOR_STAND[<[player].flag[simplesit.armorstand].get[entity]>] at location <player.flag[simplesit.armorstand].get[location]>" to_console
            - run simplesitcancel player:<[player]>
            - narrate "<yellow><[player].name> <white>is able to sit again. Lookup your console for possible errors." format:simplesitformat
        - default:
            - narrate <script[simplesitdata].parsed_key[help].separated_by[<n>]> format:simplesitformat
simplesitteleport:
    type: task
    debug: false
    definitions: player
    script:
    - teleport <[player].flag[simplesit.armorstand].get[location]>
    - narrate "You've been teleported to <yellow><[player].name><white>'s sit location." format:simplesitformat
simplesitformat:
    type: format
    debug: false
    format: <gold>[SimpleSit] <white><[text]>
simplesitdata:
    type: data
    debug: false
    help:
    - Syntax<&co>
    - <yellow>/simplesit list <white>- list all sitting players
    - <yellow>/simplesit kick [player] <white>- removes the armorstand from the player and clears the data