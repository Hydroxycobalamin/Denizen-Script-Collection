##########################################################################################
#                                                                                        #
#                                     Player exporter                                    #
#   Saves player uuids and player names into a .json file for use in PlayerFileCleaner   #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#   https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Player-Exporter   #
#                                    PlayerFileCleaner                                   #
#                  https://github.com/Hydroxycobalamin/PlayerFileCleaner                 #
##########################################################################################
player_exporter:
    type: task
    debug: false
    script:
    - if <util.has_file[../../player_names.json]>:
        - narrate "<&[error]>A file called player_names.json already exist in the server directory. You must remove it first."
        - stop
    - ~yaml create id:names
    - foreach <server.players> as:__player:
        - ~yaml id:names set <player.uuid>:<player.name>
    - ~log <yaml[names].to_json> type:none file:player_names.json