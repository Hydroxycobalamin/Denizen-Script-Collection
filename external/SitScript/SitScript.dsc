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
        ##Sit
        after player right clicks *_stairs with:air:
        - ratelimit <player> 10t
        - define location <context.location>
        #Check if the player is currently sitting or the stair the player clicked can't be sit on.
        - if <player.has_flag[simplesit]> || <[location].material.half> == TOP || <[location].above.material.is_solid>:
            - narrate "This stair is occupied, upside down or you already sitting." format:simplesit_format
            - stop
        #Prevent the player from stand up immediately.
        - if <player.is_sneaking>:
            - narrate "You can't sit while sneaking." format:simplesit_format
            - stop
        #Check the config options.
        - define config <script.data_key[data.config]>
        - if !<[config.sit-on-corners]>:
            - if <[location].material.shape> != STRAIGHT:
                - narrate "You can't sit on corners!" format:simplesit_format
                - stop
        - if !<[config.players-reach-any-block]>:
            - if <[location].y.sub[<player.location.y>]> > 1 || !<player.is_on_ground> && <[location].y.sub[<player.location.y>]> > 0:
                - narrate "You can't reach the block!" format:simplesit_format
                - stop
        #Define the proper location of the armor stand to make the player sit in the correct direction.
        - choose <[location].material.direction>:
            - case NORTH:
                - define spawn_location <[location].add[0.5,-1.2,0.6].with_yaw[0].with_pitch[0]>
            - case SOUTH:
                - define spawn_location <[location].add[0.5,-1.2,0.4].with_yaw[180].with_pitch[0]>
            - case WEST:
                - define spawn_location <[location].add[0.6,-1.2,0.5].with_yaw[-90].with_pitch[0]>
            - case EAST:
                - define spawn_location <[location].add[0.4,-1.2,0.5].with_yaw[90].with_pitch[0]>
        #Spawn the armor stand, make the player sit on it.
        - spawn <[spawn_location]> armor_stand[visible=false;collidable=false;gravity=false] save:chair
        - mount <player>|<entry[chair].spawned_entity>
        - flag <player> simplesit.armorstand.entity:<entry[chair].spawned_entity>
        - flag <player> simplesit.armorstand.location:<[location]>
        ##Cancel Sit
        after player exits vehicle flagged:simplesit:
        #Stop the queue if the player went offline. Workaround since the event fires when they player went offline.
        - if !<player.is_online>:
            - stop
        #Remove the armor stand.
        - define location <context.entity.location.add[0,2.2,0]>
        - inject <script> path:simplesit_cancel
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