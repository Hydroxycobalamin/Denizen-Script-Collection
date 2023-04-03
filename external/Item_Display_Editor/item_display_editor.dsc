##########################################################################################
#                                                                                        #
#                                   Item Display Editor                                  #
#                         Place and adjust items in your world!                          #
#                Version: 1.0.4                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
# https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Item-Display-Editor #
#                                                                                        #
##########################################################################################
item_display_editor_command:
    type: command
    debug: false
    description: Spawns item displays
    usage: /ide
    name: ide
    tab completions:
        1: spawn|gui|item
    permission: item_display_editor
    script:
    - define argument <context.args.first.if_null[null]>
    - if <[argument]> == spawn:
        - define item <player.item_in_hand>
        - if <[item]> matches *air:
            - stop
        - if <player.gamemode> != creative:
            - take slot:hand
        - define location <player.eye_location.ray_trace[range=5].if_null[null]>
        - if <[location]> == null:
            - narrate "<&[error]>You can't place this block here."
            - stop
        - spawn item_display_editor_entity[item=<[item]>] <[location]> save:entity
        - flag <entry[entity].spawned_entity> owner:<player>
    - else if <[argument]> == gui:
        - inject IDE_open_inventory
    - else if <[argument]> == item:
        - give item_display_editor_item
        - wait 1t
        - if <player.item_in_hand> matches item_display_editor_item:
            - flag <player> item_display_editor.in_selection
        - narrate "<&[base]>Click <&[emphasis]>F(swap items) <&[base]>after you selected an item display."
    - else:
        - narrate "<&[base]>Syntax: <&[emphasis]>/ide [spawn|gui|item]"
item_display_editor_entity:
    type: entity
    debug: false
    entity_type: item_display
    mechanisms:
        item: stone
item_display_editor_gui:
    type: inventory
    debug: false
    inventory: CHEST
    title: Item Display Editor
    size: 36
    gui: true
    definitions:
        item-transform: armor_stand[flag=item_display_editor.type:item-transform;display=<white>ITEM TRANSFORM]
        billboard: map[flag=item_display_editor.type:billboard;display=<white>BILLBOARD]
        left-x: torch[flag=item_display_editor.type:left-x;display=<white>ROTATION LEFT X]
        right-x: soul_torch[flag=item_display_editor.type:right-x;display=<white>ROTATION RIGHT X]
        glowing: glowstone[flag=item_display_editor.type:glowing;display=<white>GLOWING]
        glow_color: glow_berries[flag=item_display_editor.type:glow_color;display=<white>GLOW_COLOR]
        left-y: lantern[flag=item_display_editor.type:left-y;display=<white>ROTATION LEFT Y]
        right-y: soul_lantern[flag=item_display_editor.type:right-y;display=<white>ROTATION RIGHT Y]
        scale-east-west: copper_block[flag=item_display_editor.type:scale-east-west;display=<white>SCALE EAST/WEST]
        scale-up-down: iron_block[flag=item_display_editor.type:scale-up-down;display=<white>SCALE UP/DOWN]
        scale-north-south: gold_block[flag=item_display_editor.type:scale-north-south;display=<white>SCALE NORTH/SOUTH]
        scale-all: gold_block[flag=item_display_editor.type:scale-all;display=<white>SCALE ALL]
        remove: barrier[flag=item_display_editor.type:remove;display=<red>REMOVE]
        left-z: campfire[flag=item_display_editor.type:left-z;display=<white>ROTATION LEFT Z]
        right-z: soul_campfire[flag=item_display_editor.type:right-z;display=<white>ROTATION RIGHT Z]
        reset: light[block_material=light[level=1];flag=item_display_editor.type:reset;display=<aqua>RESET]
        y: iron_ingot[flag=item_display_editor.type:up-down;display=<white>UP/DOWN]
        x: copper_ingot[flag=item_display_editor.type:east-west;display=<white>EAST/WEST]
        z: gold_ingot[flag=item_display_editor.type:north-south;display=<white>NORTH/SOUTH]
        # Player configuration
        size: slime_ball[flag=item_display_editor.config:size;display=<white>Size]
        blocks: glass[flag=item_display_editor.config:blocks;display=<white>Ignore Blocks]
    slots:
    - [item-transform] [billboard] [left-x] [right-x] [] [] [] [glowing] [glow_color]
    - [] [] [left-y] [right-y] [] [scale-all] [scale-east-west] [scale-up-down] [scale-north-south]
    - [remove] [] [left-z] [right-z] [reset] [] [x] [y] [z]
    - [size] [blocks] [] [] [] [] [] [] []
item_display_editor_gui_handler:
    type: world
    debug: false
    events:
        on player left|right clicks item_flagged:item_display_editor.config in item_display_editor_gui:
        - define config <context.item.flag[item_display_editor.config]>
        - define player_config <proc[IDE_get_player_config]>
        - choose <[config]>:
            - case size:
                - define size:|:0.1|0.5|1|2|5
                - if <context.click> == LEFT:
                    - define add 1
                - else:
                    - define add -1
                - define index <[size].find[<[player_config.size]>].add[<[add]>]>
                - if <[index]> == 0:
                    - define index 5
                - if <[index]> == 6:
                    - define index 1
                - define size <[size].get[<[index]>]>
                - flag <player> item_display_editor.config.size:<[size]>
                - inventory adjust destination:<player.open_inventory> slot:<context.slot> "lore:<&[lore]>Size<&co> <[size].custom_color[emphasis]>"
            - case blocks:
                - if <[player_config.blocks]>:
                    - flag <player> item_display_editor.config.blocks:false
                    - inventory adjust destination:<player.open_inventory> slot:<context.slot> "lore:<&[lore]>Ignoring Blocks<&co> <&[emphasis]>false"
                - else:
                    - flag <player> item_display_editor.config.blocks:true
                    - inventory adjust destination:<player.open_inventory> slot:<context.slot> "lore:<&[lore]>Ignoring Blocks<&co> <&[emphasis]>true"
            - default:
                - debug error "<&[error]>Event misfired or flag value did not match. Value was: '<context.item.flag[item_display_editor.config].custom_color[emphasis]>'"
        on player left clicks item_flagged:item_display_editor.type in item_display_editor_gui:
        - define type <context.item.flag[item_display_editor.type]>
        - if <player.item_in_hand> not matches item_display_editor_item:
            - narrate "<&[error]>You must hold the Item Script Editor item in your main hand."
            - stop
        - inventory flag slot:hand item_display_editor.type:<[type]>
        - inventory flag slot:hand item_display_editor.glow_color:!
        on player swaps items offhand:item_display_editor_item:
        - determine passively cancelled
        - inject IDE_open_inventory
        on player clicks block with:item_flagged:item_display_editor.type:
        - determine passively cancelled
        - define item_display <player.flag[item_display_editor.selected_display].if_null[null]>
        - if <[item_display]> == null:
            - narrate "<&[error]>You don't have an item_display selected."
            - stop
        - define data <[item_display].display_entity_data>
        - if <player.is_sneaking>:
            - define value 0.03125
        - else:
            - define value 0.0625
        - define click_type <context.click_type.before[_]>
        - if <[click_type]> == RIGHT:
            - define value <[value].mul[-1]>
        - choose <context.item.flag[item_display_editor.type]>:
            # Move Y
            - case up-down:
                - define vector 0,<[value]>,0
                - inject IDE_set_location
            # Move X
            - case east-west:
                - define vector <[value]>,0,0
                - inject IDE_set_location
            # Move Z
            - case north-south:
                - define vector 0,0,<[value]>
                - inject IDE_set_location
            # Scale Y
            - case scale-up-down:
                - define vector <location[0,<[value]>,0]>
                - inject IDE_set_transformation_scale
            # Scale X
            - case scale-east-west:
                - define vector <location[<[value]>,0,0]>
                - inject IDE_set_transformation_scale
            # Scale Z
            - case scale-north-south:
                - define vector <location[0,0,<[value]>]>
                - inject IDE_set_transformation_scale
            - case scale-all:
                - define vector <location[<[value]>,<[value]>,<[value]>]>
                - inject IDE_set_transformation_scale
            # item_transform
            - case item-transform:
                - if <[click_type]> == LEFT:
                    - define add 1
                - else:
                    - define add -1
                - define ENUM_LIST:|:NONE|THIRDPERSON_LEFTHAND|THIRDPERSON_RIGHTHAND|FIRSTPERSON_LEFTHAND|FIRSTPERSON_RIGHTHAND|HEAD|GUI|GROUND|FIXED
                - define item_transform <[data.item_transform]>
                - define index <[ENUM_LIST].find[<[item_transform]>].add[<[add]>]>
                - if <[index]> == 0:
                    - define index 9
                - if <[index]> == 10:
                    - define index 1
                - define transform <[ENUM_LIST].get[<[index]>]>
                - adjust <[item_display]> display_entity_data:<[data].with[item_transform].as[<[transform]>]>
                - narrate "<&[base]>Transformation set to <[transform].custom_color[emphasis]>."
            - case billboard:
                - if <[click_type]> == LEFT:
                    - define add 1
                - else:
                    - define add -1
                - define ENUM_LIST:|:FIXED|VERTICAL|HORIZONTAL|CENTER
                - define billboard <[data.billboard]>
                - define index <[ENUM_LIST].find[<[billboard]>].add[<[add]>]>
                - if <[index]> == 0:
                    - define index 4
                - if <[index]> == 5:
                    - define index 1
                - define transform <[ENUM_LIST].get[<[index]>]>
                - adjust <[item_display]> display_entity_data:<[data].with[billboard].as[<[transform]>]>
                - narrate "<&[base]>Billboard set to <[transform].custom_color[emphasis]>."
            # remove
            - case remove:
                - if <[item_display].flag[owner].if_null[null]> != <player> && !<player.is_op>:
                    - narrate "<&[error]>This item does not belong to you."
                    - stop
                - give <[item_display].item>
                - remove <[item_display]>
            - case right-x:
                - run IDE_set_transformation_rotation def.item_display:<[item_display]> def.data:<[data]> def.axis:<list[1|0|0]> def.type:transformation_right_rotation def.click_type:<[click_type]>
            - case right-y:
                - run IDE_set_transformation_rotation def.item_display:<[item_display]> def.data:<[data]> def.axis:<list[0|1|0]> def.type:transformation_right_rotation def.click_type:<[click_type]>
            - case right-z:
                - run IDE_set_transformation_rotation def.item_display:<[item_display]> def.data:<[data]> def.axis:<list[0|0|1]> def.type:transformation_right_rotation def.click_type:<[click_type]>
            - case left-x:
                - run IDE_set_transformation_rotation def.item_display:<[item_display]> def.data:<[data]> def.axis:<list[1|0|0]> def.type:transformation_left_rotation def.click_type:<[click_type]>
            - case left-y:
                - run IDE_set_transformation_rotation def.item_display:<[item_display]> def.data:<[data]> def.axis:<list[0|1|0]> def.type:transformation_left_rotation def.click_type:<[click_type]>
            - case left-z:
                - run IDE_set_transformation_rotation def.item_display:<[item_display]> def.data:<[data]> def.axis:<list[0|0|1]> def.type:transformation_left_rotation def.click_type:<[click_type]>
            - case reset:
                - adjust <[item_display]> display_entity_data:<[data].with[transformation_right_rotation].as[0|0|0|1].with[transformation_left_rotation].as[0|0|0|1]>
                - flag <[item_display]> item_display_editor.transformation_left_rotation:!
                - flag <[item_display]> item_display_editor.transformation_right_rotation:!
            - case glowing:
                - if <[item_display].has_flag[item_display_editor.glowing]>:
                    - adjust <[item_display]> glowing:false
                    - flag <[item_display]> item_display_editor.glowing:!
                    - narrate "<&[base]>Display item wont glow anymore."
                - else:
                    - adjust <[item_display]> glowing:true
                    - flag <[item_display]> item_display_editor.glowing
                    - narrate "<&[base]>Display item will glow now."
            - case glow_color:
                - if <player.item_in_hand.has_flag[item_display_editor.glow_color]>:
                    - adjust <[item_display]> display_entity_data:<[data].with[glow_color].as[<player.item_in_hand.flag[item_display_editor.glow_color]>]>
                    - stop
                - flag <player> item_display_editor.chat_input expire:30s
                - narrate "<&[base]>Type a RGB or HEX value in chat for the color. Example: 255,255,255 or #ffff00."
            - default:
                - debug error "<&[error]>Event misfired or flag value did not match. Value was: '<context.item.flag[item_display_editor.type].custom_color[emphasis]>'"
        on player chats flagged:item_display_editor.chat_input ignorecancelled:true priority:-100:
        - determine passively cancelled
        - if <player.item_in_hand> not matches item_display_editor_item:
            - narrate "<&[error]>You must hold the item editor in your hand."
            - flag <player> item_display_editor.chat_input:!
            - stop
        - define color <color[<context.message>].if_null[null]>
        - if <[color]> == null:
            - narrate "<&[error]>This is not a valid color code <context.message.custom_color[emphasis]>."
            - flag <player> item_display_editor.chat_input:!
            - stop
        - flag <player> item_display_editor.chat_input:!
        - inventory flag slot:hand item_display_editor.glow_color:<[color]>
        - narrate "<&[base]>Color code set. Swoosh your stick to apply it!"
        on player walks flagged:item_display_editor.in_selection:
        - ratelimit <player> 2t
        - if <player.item_in_hand> not matches item_display_editor_item:
            - stop
        - define player_config <player.flag[item_display_editor.config]>
        - define item_display <player.eye_location.ray_trace_target[entities=item_display;blocks=<[player_config.blocks]>;range=10;raysize=<[player_config.size]>].if_null[null]>
        # If no display item is in range. Remove the glowing and the flag.
        - define display_item <player.flag[item_display_editor.selected_display].if_null[<player>]>
        - if <[item_display]> == null:
            - if <player.has_flag[item_display_editor.selected_display]>:
                - if !<[display_item].has_flag[item_display_editor.glowing]>:
                    - adjust <[display_item]> glowing:false
                - flag <player> item_display_editor.selected_display:!
            - stop
        # If the player selected item is not equal the new item, remove the glowing from the old one and add it to the new one.
        - if <[display_item]> != <[item_display]> && !<[display_item].has_flag[item_display_editor.glowing]>:
            - adjust <[display_item]> glowing:false
            - flag <player> item_display_editor.selected_display:<[item_display]>
        - flag <player> item_display_editor.selected_display:<[item_display]>
        - adjust <[item_display]> glowing:true
        on player scrolls their hotbar item:item_display_editor_item:
        - flag <player> item_display_editor.in_selection
        on player scrolls their hotbar item:!item_display_editor_item flagged:item_display_editor.in_selection:
        - inject IDE_disable_selection
        on player quits flagged:item_display_editor.in_selection:
        - inject IDE_disable_selection
        after player drops item_display_editor_item:
        - inject IDE_disable_selection
        - remove <context.entity>
item_display_editor_item:
    type: item
    material: blaze_rod
    debug: false
    display name: <white>Item Display Editor
    lore:
    - <gold>Swapping items(F)
    - <&[base]>Opens the editor.
    - <gold>Left click
    - <&[base]>Applies the effect, if any.
    - <gold>Right click
    - <&[base]>Reverses the effect, if any.
    - <gold>Sneak
    - <&[base]>Sneaking while clicking doubles the value.
## Helper methods
IDE_open_inventory:
    type: task
    debug: false
    script:
    - define config <proc[IDE_get_player_config]>
    - define inventory <inventory[item_display_editor_gui]>
    - inventory adjust slot:28 destination:<[inventory]> "lore:<&[lore]>Size<&co> <[config.size].custom_color[emphasis]>"
    - inventory adjust slot:29 destination:<[inventory]> "lore:<&[lore]>Ignoring Blocks<&co> <[config.blocks].custom_color[emphasis]>"
    - if <player.has_flag[item_display_editor.selected_display]>:
        - define display_item <player.flag[item_display_editor.selected_display]>
        - define data <[display_item].display_entity_data>
        - inventory adjust slot:1 destination:<[inventory]> "lore:<&[lore]>Transformation<&co> <[data.item_transform].custom_color[emphasis]>"
        - inventory adjust slot:2 destination:<[inventory]> "lore:<&[lore]>Billboard<&co> <[data.billboard].custom_color[emphasis]>"
        - inventory adjust slot:3 destination:<[inventory]> "lore:<&[lore]>Rotation XL<&co> <[data.transformation_left_rotation].get[1].custom_color[emphasis]>"
        - inventory adjust slot:4 destination:<[inventory]> "lore:<&[lore]>Rotation XR<&co> <[data.transformation_right_rotation].get[1].custom_color[emphasis]>"
        - inventory adjust slot:8 destination:<[inventory]> "lore:<&[lore]>Glowing<&co> <[display_item].has_flag[item_display_editor.glowing].custom_color[emphasis]>"
        - inventory adjust slot:9 destination:<[inventory]> "lore:<&[lore]>Glow color<&co> <&color[<[data.glow_color].if_null[white]>]>COLOR"
        - inventory adjust slot:12 destination:<[inventory]> "lore:<&[lore]>Rotation YL<&co> <[data.transformation_left_rotation].get[2].custom_color[emphasis]>"
        - inventory adjust slot:13 destination:<[inventory]> "lore:<&[lore]>Rotation YR<&co> <[data.transformation_right_rotation].get[2].custom_color[emphasis]>"
        - inventory adjust slot:16 destination:<[inventory]> "lore:<&[lore]>Scale EW<&co> <[data.transformation_scale].x.custom_color[emphasis]>"
        - inventory adjust slot:17 destination:<[inventory]> "lore:<&[lore]>Scale UD<&co> <[data.transformation_scale].y.custom_color[emphasis]>"
        - inventory adjust slot:18 destination:<[inventory]> "lore:<&[lore]>Scale NS<&co> <[data.transformation_scale].z.custom_color[emphasis]>"
        - inventory adjust slot:21 destination:<[inventory]> "lore:<&[lore]>Rotation ZL<&co> <[data.transformation_left_rotation].get[3].custom_color[emphasis]>"
        - inventory adjust slot:22 destination:<[inventory]> "lore:<&[lore]>Rotation ZR<&co> <[data.transformation_right_rotation].get[3].custom_color[emphasis]>"
        - inventory adjust slot:25 destination:<[inventory]> "lore:<&[lore]>Location X<&co> <[display_item].location.x.round_to[4].custom_color[emphasis]>"
        - inventory adjust slot:26 destination:<[inventory]> "lore:<&[lore]>Location Y<&co> <[display_item].location.y.round_to[4].custom_color[emphasis]>"
        - inventory adjust slot:27 destination:<[inventory]> "lore:<&[lore]>Location Z<&co> <[display_item].location.z.round_to[4].custom_color[emphasis]>"
    - inventory open destination:<[inventory]>
IDE_disable_selection:
    type: task
    debug: false
    script:
    - if <player.has_flag[item_display_editor.selected_display]>:
        - if !<player.flag[item_display_editor.selected_display].has_flag[item_display_editor.glowing]>:
            - adjust <player.flag[item_display_editor.selected_display]> glowing:false
    - flag <player> item_display_editor.selected_display:!
    - flag <player> item_display_editor.in_selection:!
IDE_set_transformation_scale:
    type: task
    debug: false
    script:
    - define transformation_scale <[data.transformation_scale]>
    - adjust <[item_display]> display_entity_data:<[data].with[transformation_scale].as[<[transformation_scale].add[<[vector]>]>]>
    - narrate "<&[base]>Transformation scale was set to: <[item_display].display_entity_data.get[transformation_scale].xyz.custom_color[emphasis]>"
IDE_set_transformation_rotation:
    type: task
    debug: false
    definitions: item_display|data|axis|type|click_type
    script:
    - if <[click_type]> == LEFT:
        - flag <[item_display]> item_display_editor.<[type]>.angle:+:5
    - else:
        - flag <[item_display]> item_display_editor.<[type]>.angle:-:5
    - adjust <[item_display]> display_entity_data:<[data].with[<[type]>].as[<[axis].proc[IDE_quaternion].context[<[item_display].flag[item_display_editor.<[type]>.angle]>]>]>
IDE_set_location:
    type: task
    debug: false
    script:
    - teleport <[item_display]> <[item_display].location.add[<[vector]>].round_to_precision[0.03125]>
    - narrate "<&[base]>The location of the item_display was set to <[item_display].location.format[sx sy sz world].custom_color[emphasis]>."
IDE_get_player_config:
    type: procedure
    debug: false
    script:
    - definemap config:
        size: 1
        blocks: true
    - foreach <[config]> key:key as:value:
        - define flag <player.flag[item_display_editor.config.<[key]>].if_null[null]>
        - if <[flag]> != null:
            - define config.<[key]> <[flag]>
    - determine <[config]>
## Quaternion math.
IDE_quaternion:
    type: procedure
    debug: false
    definitions: axis|angle
    script:
    - define angle <[angle].to_radians>
    - define angle_div <[angle].div[2].sin>
    - define x <[axis].get[1].mul[<[angle_div]>]>
    - define y <[axis].get[2].mul[<[angle_div]>]>
    - define z <[axis].get[3].mul[<[angle_div]>]>
    - define w <[angle].div[2].cos>
    - define axis <[x]>|<[y]>|<[z]>|<[w]>
    - determine <[axis]>