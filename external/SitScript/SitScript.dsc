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
        - ratelimit <player> 5t
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
simplesit_format:
    type: format
    debug: false
    format: <gold>[SimpleSit] <[text].custom_color[base]>