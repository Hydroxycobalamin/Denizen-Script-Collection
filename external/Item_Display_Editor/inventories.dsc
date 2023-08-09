item_display_editor_gui:
    type: inventory
    debug: false
    inventory: CHEST
    title: Item Display Editor
    size: 36
    gui: true
    definitions:
        display: armor_stand[flag=item_display_editor.type:display;display=<white>ITEM TRANSFORM]
        pivot: map[flag=item_display_editor.type:pivot;display=<white>BILLBOARD]
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
        selector: stick[flag=item_display_editor.config:selector;display=<white>Selector Mode]
        # groups
        groups: candle[flag=item_display_editor.groups;display=<white>Groups]
        # reset_groups
        reset_item: barrier[flag=item_display_editor.reset_item;display=<white>Reset Item Display Editor Item]
    slots:
    - [display] [pivot] [left-x] [right-x] [] [] [] [glowing] [glow_color]
    - [] [] [left-y] [right-y] [] [scale-all] [scale-east-west] [scale-up-down] [scale-north-south]
    - [remove] [] [left-z] [right-z] [reset] [] [x] [y] [z]
    - [size] [blocks] [selector] [] [groups] [reset_item] [] [] []
item_display_editor_gui_handler:
    type: world
    debug: false
    events:
        after player clicks item_flagged:item_display_editor.groups in item_display_editor_gui:
        - inject IDE_open_inventory_group_gui
        after player clicks item_flagged:item_display_editor.reset_item in item_display_editor_gui:
        - if <player.has_flag[item_display_editor.selected_displays]>:
            - foreach <player.flag[item_display_editor.selected_displays]> as:display:
                - if !<[display].has_flag[item_display_editor.glowing]>:
                    - glow <[display]> false for:<player>
            - flag <player> item_display_editor.selected_displays:!
        - inventory flag slot:hand item_display_editor.type:!
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
            - case selector:
                - if <[player_config.selector]> == single:
                    - flag <player> item_display_editor.config.selector:multi
                    - inventory adjust destination:<player.open_inventory> slot:<context.slot> "lore:<&[lore]>Selector Mode<&co> <&[emphasis]>multi"
                - else:
                    - flag <player> item_display_editor.config.selector:single
                    - inventory adjust destination:<player.open_inventory> slot:<context.slot> "lore:<&[lore]>Selector Mode<&co> <&[emphasis]>single"
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
IDE_open_inventory:
    type: task
    debug: false
    script:
    - define config <proc[IDE_get_player_config]>
    - define inventory <inventory[item_display_editor_gui]>
    - inventory adjust slot:28 destination:<[inventory]> "lore:<&[lore]>Size<&co> <[config.size].custom_color[emphasis]>"
    - inventory adjust slot:29 destination:<[inventory]> "lore:<&[lore]>Ignoring Blocks<&co> <[config.blocks].custom_color[emphasis]>"
    - inventory adjust slot:30 destination:<[inventory]> "lore:<&[lore]>Selector Mode<&co> <[config.selector].custom_color[emphasis]>"
    - if <player.has_flag[item_display_editor.selected_display]>:
        - define display_item <player.flag[item_display_editor.selected_display]>
        - define data <[display_item].proc[IDE_get_data]>
        - inventory adjust slot:1 destination:<[inventory]> "lore:<&[lore]>Transformation<&co> <[data.display].custom_color[emphasis]>"
        - inventory adjust slot:2 destination:<[inventory]> "lore:<&[lore]>Billboard<&co> <[data.pivot].custom_color[emphasis]>"
        - inventory adjust slot:3 destination:<[inventory]> "lore:<&[lore]>Rotation XL<&co> <[data.transformation_left_rotation].x.custom_color[emphasis]>"
        - inventory adjust slot:4 destination:<[inventory]> "lore:<&[lore]>Rotation XR<&co> <[data.transformation_right_rotation].x.custom_color[emphasis]>"
        - inventory adjust slot:8 destination:<[inventory]> "lore:<&[lore]>Glowing<&co> <[display_item].has_flag[item_display_editor.glowing].custom_color[emphasis]>"
        - inventory adjust slot:9 destination:<[inventory]> "lore:<&[lore]>Glow color<&co> <&color[<[data.glow_color].if_null[white]>]>COLOR"
        - inventory adjust slot:12 destination:<[inventory]> "lore:<&[lore]>Rotation YL<&co> <[data.transformation_left_rotation].y.custom_color[emphasis]>"
        - inventory adjust slot:13 destination:<[inventory]> "lore:<&[lore]>Rotation YR<&co> <[data.transformation_right_rotation].y.custom_color[emphasis]>"
        - inventory adjust slot:16 destination:<[inventory]> "lore:<&[lore]>Scale EW<&co> <[data.scale].x.custom_color[emphasis]>"
        - inventory adjust slot:17 destination:<[inventory]> "lore:<&[lore]>Scale UD<&co> <[data.scale].y.custom_color[emphasis]>"
        - inventory adjust slot:18 destination:<[inventory]> "lore:<&[lore]>Scale NS<&co> <[data.scale].z.custom_color[emphasis]>"
        - inventory adjust slot:21 destination:<[inventory]> "lore:<&[lore]>Rotation ZL<&co> <[data.transformation_left_rotation].z.custom_color[emphasis]>"
        - inventory adjust slot:22 destination:<[inventory]> "lore:<&[lore]>Rotation ZR<&co> <[data.transformation_right_rotation].z.custom_color[emphasis]>"
        - inventory adjust slot:25 destination:<[inventory]> "lore:<&[lore]>Location X<&co> <[display_item].location.x.round_to[4].custom_color[emphasis]>"
        - inventory adjust slot:26 destination:<[inventory]> "lore:<&[lore]>Location Y<&co> <[display_item].location.y.round_to[4].custom_color[emphasis]>"
        - inventory adjust slot:27 destination:<[inventory]> "lore:<&[lore]>Location Z<&co> <[display_item].location.z.round_to[4].custom_color[emphasis]>"
    - inventory open destination:<[inventory]>
item_display_editor_group_gui:
    type: inventory
    debug: false
    data:
        info_lore:
        - <gold>Left-Click<&co>
        - <&[base]>Selects the group.
        - <gold>Right-Click<&co>
        - <&[base]>Renames the group
        - <gold>Shift-Rightclick<&co>
        - <&[base]>Deletes the group
    inventory: CHEST
    title: Groups
    gui: true
    definitions:
        info: <item[light].with[display=<white>Info;lore=<script.parsed_key[data.info_lore]>]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [info] [] [] [] []
item_display_editor_group_gui_handler:
    type: world
    debug: false
    pager:
    - define pages <context.item.flag[groups]>
    - define max <[pages].size>
    - if <[max]> < <[page]>:
        - stop
    - if <[page]> < 1:
        - stop
    - inventory set origin:<[pages].get[<[page]>].pad_right[45].with[air]> destination:<player.open_inventory>
    - inventory flag slot:<context.slot> page:<[page]> destination:<player.open_inventory>
    - inventory adjust slot:<context.slot> destination:<player.open_inventory> "lore:<&[base]>Current Page - <[page]>/<[max]>"
    events:
        # Pages
        after player left clicks IDE_pager in item_display_editor_group_gui:
        - define page <context.item.flag[page].add[1]>
        - inject <script> path:pager
        after player right clicks IDE_pager in item_display_editor_group_gui:
        - define page <context.item.flag[page].sub[1]>
        - inject <script> path:pager
        after player left clicks item_flagged:group in item_display_editor_group_gui:
        - inventory close
        - define displays <context.item.flag[group]>
        - foreach <[displays]> as:display:
            - if !<[display].is_spawned>:
                - narrate "<&[error]>You can't select this group because its not loaded."
                - stop
            - if <[display].distance[<player.location>]> > 25:
                - narrate "<&[error]>You're to faw away to select this group."
                - stop
        - if <player.has_flag[item_display_editor.selected_displays]>:
            - foreach <player.flag[item_display_editor.selected_displays]> as:display:
                - if !<[display].has_flag[item_display_editor.glowing]>:
                    - glow <[display]> false for:<player>
        - flag <player> item_display_editor.selected_displays:<[displays]>
        - glow <[displays]> true for:<player>
        after player SHIFT_RIGHT clicks item_flagged:group in item_display_editor_group_gui:
        - inventory close
        - define inventory <inventory[item_display_editor_anvil_gui]>
        - inventory set destination:<[inventory]> slot:1 "origin:paper[lore=<&[lore]>Type DELETE to delete the claim;flag=uuid:<context.item.flag[uuid]>;flag=type:delete]"
        - inventory open destination:<[inventory]>
        after player left clicks item_flagged:group in item_display_editor_group_gui:
        - inventory close
        - define inventory <inventory[item_display_editor_anvil_gui]>
        - inventory set destination:<[inventory]> slot:1 "origin:paper[lore=<&[lore]>Type the new name into the field.;flag=uuid:<context.item.flag[uuid]>;flag=type:rename]"
        - inventory open destination:<[inventory]>
IDE_open_inventory_group_gui:
    type: task
    debug: false
    script:
    - define inventory <inventory[item_display_editor_group_gui]>
    - define groups <player.flag[item_display_editor.groups].parse_tag[<[parse_value.candle].if_null[<item[candle]>].with[display=<[parse_value.name].if_null[<white>Group]>].with_flag[group:<[parse_value.displays]>].with_flag[uuid:<[parse_value.uuid]>]>].if_null[air]>
    - define pages <[groups].sub_lists[36]>
    - inventory set slot:44 destination:<[inventory]> origin:<item[IDE_pager].with_flag[groups:<[pages]>]>
    - inventory set slot:1 destination:<[inventory]> origin:<[pages].first>
    - inventory open destination:<[inventory]>
IDE_pager:
    type: item
    debug: false
    material: stone
    display name: <white>Page
    flags:
        page: 1
IDE_selector:
    type: item
    debug: false
    material: gold_block
    display name: <white>Selector
item_display_editor_anvil_gui:
    type: inventory
    inventory: ANVIL
    gui: true
    slots:
    - [] [] []
item_display_editor_anvil_gui_handler:
    type: world
    debug: false
    events:
        on player clicks item in item_display_editor_anvil_gui slot:3:
        - define uuid <context.item.flag[uuid]>
        - define matches <player.flag[item_display_editor.groups].find_all_matches[*<[uuid]>*]>
        - if <[matches].is_empty>:
            - debug error "<&[error]>Could not find any group with this uuid on player '<player.custom_color[emphasis]>'. Even if it should find a group."
            - stop
        - if <context.item.flag[type]> == delete && <player.open_inventory.anvil_rename_text> == DELETE:
            - foreach <[matches]> as:index:
                - flag <player> item_display_editor.groups[<[index]>]:<-
                - narrate "<&[base]>The group was removed."
        - if <context.item.flag[type]> == rename:
            - foreach <[matches]> as:index:
                - define match <player.flag[item_display_editor.groups].get[<[index]>]>
                - flag <player> item_display_editor.groups[<[index]>]:<[match].with[name].as[<player.open_inventory.anvil_rename_text.parse_color>]>
                - narrate "<&[base]>The group was renamed."
        - inventory close