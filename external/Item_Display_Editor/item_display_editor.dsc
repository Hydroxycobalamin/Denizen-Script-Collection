##########################################################################################
#                                                                                        #
#                                   Item Display Editor                                  #
#                         Place and adjust items in your world!                          #
#                Version: 1.2.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
# https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Item-Display-Editor #
#                                                                                        #
##########################################################################################

## <--[information]
## @name Item Display Editor Commands
## @group Item Display Editor
## @description
## Obtaining the Item and Modifying Display Entities
## To obtain the Item Display Editor item, you need to use the command '/ide item'.
## Pressing 'F' (swap item key) opens the Item Display Editor GUI, where you can select specific attributes to modify.
##
## Three config entries exist:
## Size: This defines the size of the raytrace used to select display entities.
## Ignore Blocks: Enabling this option causes the raytrace to ignore blocks.
## Selector Mode: In 'multi' mode, grouping and saving groups is allowed. 'Single' mode only allows adjustment of individual Display Entities.
##
## Save and Select Groups
## To save a group, you need to first select the relevant Display Entities in multi mode. Once done, you can save the group using the 'save_group' parameter.
## The material of a group can be any candle material, allowing sorting by color.
##
## # Save a group with default options.
## /ide save_group
##
## # Save a group with a name and default material.
## /ide save_group your_name
##
## # Save a group with a name and cyan_candle as the material.
## /ide save_group your_name cyan_candle
##
## Delete Groups
## To delete a group, you can either select it via the Group GUI, then SHIFT_RIGHT click the group to confirm deletion, or delete all Display Entities that are part of the group.
##
## Rename Groups
## To rename a group, right click a group via the Group GUI, type the new name into the field, and confirm.
##
## -->
item_display_editor_command:
    type: command
    debug: false
    description: Spawns item displays
    usage: /ide
    name: ide
    tab completions:
        1: spawn|gui|item|save_group
        2: <context.args.first.equals[save_group].if_true[enter_name_here].if_false[<empty>]>
        3: <context.args.first.equals[save_group].if_true[<server.material_types.filter[advanced_matches[*candle]].parse[name]>].if_false[<empty>]>
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
        - spawn item_display_editor_entity[item=<[item].with[quantity=1]>] <[location]> save:entity
        - flag <entry[entity].spawned_entity> owner:<player>
    - else if <[argument]> == gui:
        - inject IDE_open_inventory
    - else if <[argument]> == item:
        - give item_display_editor_item
        - wait 1t
        - if <player.item_in_hand> matches item_display_editor_item:
            - flag <player> item_display_editor.in_selection
        - narrate "<&[base]>Click <&[emphasis]>F(swap items) <&[base]>after you selected an item display."
    - else if <[argument]> == save_group:
        - choose <context.args.size>:
            - case 2:
                - definemap group:
                    name: <context.args.get[2].escaped>
                    displays: <player.flag[item_display_editor.selected_displays]>
                    uuid: <util.random_uuid>
            - case 3:
                - define candles <server.material_types.filter[advanced_matches[*candle]].parse[name]>
                - if <[candles]> not contains <context.args.get[3]>:
                    - narrate "<&[error]>'<context.args.get[3].custom_color[emphasis]>' is not a valid candle. Did you mean '<[candles].closest_to[<context.args.get[3]>].custom_color[emphasis]>'?"
                    - stop
                - definemap group:
                    candle: <item[<context.args.get[3]>]>
                    name: <context.args.get[2].escaped>
                    displays: <player.flag[item_display_editor.selected_displays]>
                    uuid: <util.random_uuid>
            - default:
                - definemap group:
                    displays: <player.flag[item_display_editor.selected_displays]>
                    uuid: <util.random_uuid>
        - flag <player> item_display_editor.groups:->:<[group]>
        - narrate "<&[base]>Group was sucessfully saved."
    - else:
        - narrate "<&[base]>Syntax: <&[emphasis]>/ide [spawn|gui|item]"
item_display_editor_entity:
    type: entity
    debug: false
    entity_type: item_display
    mechanisms:
        item: stone
item_display_editor_selector:
    type: world
    debug: false
    events:
        on player clicks block with:item_flagged:item_display_editor.type:
        - determine passively cancelled
        - foreach <player.flag[item_display_editor.selected_displays].if_null[<player.flag[item_display_editor.selected_display]>].if_null[null]> as:item_display:
            - if <[item_display]> == null:
                - narrate "<&[error]>You don't have an item_display selected."
                - stop
            - define data <[item_display].proc[IDE_get_data]>
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
                - case display:
                    - if <[click_type]> == LEFT:
                        - define add 1
                    - else:
                        - define add -1
                    - define ENUM_LIST:|:NONE|THIRDPERSON_LEFTHAND|THIRDPERSON_RIGHTHAND|FIRSTPERSON_LEFTHAND|FIRSTPERSON_RIGHTHAND|HEAD|GUI|GROUND|FIXED
                    - define item_transform <[data.display]>
                    - define index <[ENUM_LIST].find[<[item_transform]>].add[<[add]>]>
                    - if <[index]> == 0:
                        - define index 9
                    - if <[index]> == 10:
                        - define index 1
                    - define transform <[ENUM_LIST].get[<[index]>]>
                    - adjust <[item_display]> display:<[transform]>
                    - narrate "<&[base]>Transformation set to <[transform].custom_color[emphasis]>."
                - case pivot:
                    - if <[click_type]> == LEFT:
                        - define add 1
                    - else:
                        - define add -1
                    - define ENUM_LIST:|:FIXED|VERTICAL|HORIZONTAL|CENTER
                    - define pivot <[data.pivot]>
                    - define index <[ENUM_LIST].find[<[pivot]>].add[<[add]>]>
                    - if <[index]> == 0:
                        - define index 4
                    - if <[index]> == 5:
                        - define index 1
                    - define transform <[ENUM_LIST].get[<[index]>]>
                    - adjust <[item_display]> pivot:<[transform]>
                    - narrate "<&[base]>Billboard set to <[transform].custom_color[emphasis]>."
                # remove
                - case remove:
                    - if <[item_display].flag[owner].if_null[null]> != <player> && !<player.is_op>:
                        - narrate "<&[error]>This item does not belong to you."
                        - stop
                    - give <[item_display].item.with[quantity=1]>
                    - define groups <[item_display].flag[owner].if_null[<player>].flag[item_display_editor.groups]>
                    - define matches <[groups].find_all_matches[*<[item_display]>*]>
                    - foreach <[matches]> as:index:
                        - define group <[groups].get[<[index]>]>
                        - flag <player> item_display_editor.groups[<[index]>]:<[group].with[displays].as[<[group.displays].exclude[<[item_display]>]>]>
                        - if <player.flag[item_display_editor.groups].get[<[index]>].get[displays].is_empty>:
                            - flag <player> item_display_editor.groups[<[index]>]:<-
                            - narrate "<&[base]>Group '<player.flag[item_display_editor.groups].get[index].get[name].custom_color[emphasis]>' got removed because it does not contain display entities anymore."
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
                    - adjust <[item_display]> left_rotation:0,0,0,1
                    - adjust <[item_display]> right_rotation:0,0,0,1
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
                        - adjust <[item_display]> glow_color:<player.item_in_hand.flag[item_display_editor.glow_color]>
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
        after player walks flagged:item_display_editor.in_selection:
        - ratelimit <player> 2t
        - if <player.item_in_hand> not matches item_display_editor_item:
            - stop
        - define player_config <proc[IDE_get_player_config]>
        - define item_display <player.eye_location.ray_trace_target[entities=item_display;blocks=<[player_config.blocks]>;range=10;raysize=<[player_config.size]>].if_null[null]>
        # If no display item is in range. Remove the glowing and the flag.
        - define display_item <player.flag[item_display_editor.selected_display].if_null[<player>]>
        - if <[item_display]> == null:
            - if <player.has_flag[item_display_editor.selected_display]>:
                - if !<[display_item].has_flag[item_display_editor.glowing]> && <player.flag[item_display_editor.selected_displays].if_null[<list>]> not contains <[display_item]>:
                    - glow <[display_item]> false for:<player>
                - flag <player> item_display_editor.selected_display:!
            - stop
        # If the player selected item is not equal the new item, remove the glowing from the old one and add it to the new one.
        - if <[display_item]> != <[item_display]> && !<[display_item].has_flag[item_display_editor.glowing]> && <player.flag[item_display_editor.selected_displays].if_null[<list>]> not contains <[display_item]>:
            - glow <[display_item]> false for:<player>
            - flag <player> item_display_editor.selected_display:<[item_display]>
        - flag <player> item_display_editor.selected_display:<[item_display]>
        - if <player.flag[item_display_editor.selected_displays].if_null[<list>]> not contains <[display_item]>:
            - glow <[display_item]> false for:<player>
        - glow <[item_display]> true for:<player>
        on player clicks block with:item_display_editor_item:
        - if <context.item.has_flag[item_display_editor.type]>:
            - stop
        - define item_display <player.flag[item_display_editor.selected_display].if_null[null]>
        - if <[item_display]> == null:
            - narrate "<&[error]>You don't have an item_display selected."
            - stop
        - define player_config <proc[IDE_get_player_config]>
        - if <[player_config.selector]> == multi:
            - if <context.click_type.before[_]> == LEFT:
                - flag <player> item_display_editor.selected_displays:->:<[item_display]>
                - narrate "<&[base]>You've added a display to the group."
                - glow <[item_display]> true for:<player>
            - else:
                - flag <player> item_display_editor.selected_displays:<-:<[item_display]>
                - narrate "<&[base]>You've removed a display from the group."
                - if !<[item_display].has_flag[item_display_editor.glowing]>:
                    - glow <[item_display]> false for:<player>
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
    - define transformation_scale <[data.scale]>
    - adjust <[item_display]> scale:<[transformation_scale].add[<[vector]>]>
    - narrate "<&[base]>Transformation scale was set to: <[item_display].scale.xyz.custom_color[emphasis]>"
IDE_set_transformation_rotation:
    type: task
    debug: false
    definitions: item_display|data|axis|type|click_type
    script:
    - if <[click_type]> == LEFT:
        - flag <[item_display]> item_display_editor.<[type]>.angle:+:5
    - else:
        - flag <[item_display]> item_display_editor.<[type]>.angle:-:5
    - narrate <[type]>
    - if <[type]> == transformation_left_rotation:
        - adjust <[item_display]> left_rotation:<[axis].proc[IDE_quaternion].context[<[item_display].flag[item_display_editor.<[type]>.angle]>]>
    - else:
        - adjust <[item_display]> right_rotation:<[axis].proc[IDE_quaternion].context[<[item_display].flag[item_display_editor.<[type]>.angle]>]>
IDE_set_location:
    type: task
    debug: false
    script:
    - foreach <[item_display]> as:display:
        - teleport <[display]> <[display].location.add[<[vector]>].round_to_precision[0.03125]>
        - narrate "<&[base]>The location of the item_display was set to <[display].location.format[sx sy sz world].custom_color[emphasis]>."
IDE_get_player_config:
    type: procedure
    debug: false
    script:
    - definemap config:
        size: 1
        blocks: true
        selector: single
    - foreach <[config]> key:key as:value:
        - define flag <player.flag[item_display_editor.config.<[key]>].if_null[null]>
        - if <[flag]> != null:
            - define config.<[key]> <[flag]>
    - determine <[config]>
IDE_get_data:
    type: procedure
    debug: false
    definitions: entity
    data:
        display: <[entity].display>
        pivot: <[entity].pivot>
        scale: <[entity].scale>
        glow_color: <[entity].glow_color.if_null[WHITE]>
        transformation_left_rotation: <[entity].left_rotation>
        transformation_right_rotation: <[entity].right_rotation>
    script:
    - determine <script.parsed_key[data]>
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
    - define axis <[x]>,<[y]>,<[z]>,<[w]>
    - determine <[axis]>
