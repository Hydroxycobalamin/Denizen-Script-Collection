
#Script: 1.1.0
#Author: Icecapade
#Date 2020-06-28
crates_config:
    type: data
    debug: false
    #Show Tripwires (does not affect existing crates)
    show_tripwire: true
    chests:
        light_chest_name: <green>Light
        medium_chest_name: <yellow>Medium
        heavy_chest_name: <red>Heavy
        #Any section requires a chance: and item: key. Specifying the quantity: is optional.
        #In the light_chest_items section; diamonds has a chance of 2%, iron_ingots 8%, dirt 30% and stone has a chance of 60% to drop. It will always have a result.
        #In the medium_chest_items section; beacon has a chance of 1% and iron_ingot of 25%. There is a 74% chance of dropping nothing.
        ##The sum of chances in a section must not exceed 100%
        #Format:
        #<chest>:
        #   <id>:
        #       chance: <#.#>
        #       item: <item>
        #       quantity: <quantity>
        light_chest_items:
            1:
                chance: 2
                item: diamond
            2:
                chance: 8
                item: iron_ingot
            3:
                chance: 30
                item: dirt
            4:
                chance: 60
                item: stone
        medium_chest_items:
            1:
                chance: 1.5
                item: beacon
                quantity: 2
            2:
                chance: 25
                item: iron_ingot
                quantity: 8
        heavy_chest_items:
            1:
                chance: 0.01
                item: diamond_block
                quantity: 64
crates_command:
    type: command
    data:
        types:
        - light
        - medium
        - heavy
    debug: false
    name: crates
    description: Creates Crates
    usage: /crates [Light/Medium/Heavy] (key) <&lt>#<&gt>
    aliases:
    - crate
    permission: crates.create
    tab completions:
        1: light|medium|heavy
        2: key
        3: 8|16|32|64|128
    script:
    - choose <context.args.size>:
        - case 1:
            - define type <context.args.first.to_lowercase>
            - if !<script.data_key[data.types].contains[<[type]>]>:
                - narrate "Syntax: <aqua><script.data_key[usage]>" format:crates_format
                - stop
            - give crates_chest_<[type]>
            - narrate "<dark_aqua>You received a <aqua><[type]> crate." format:crates_format
        - case 2 3:
            - define type <context.args.first.to_lowercase>
            - if !<script.data_key[data.types].contains[<[type]>]> || <context.args.get[2]> != key:
                - narrate "Syntax: <script.data_key[usage]>" format:crates_format
                - stop
            - define quantity <context.args.get[3].if_null[1]>
            - if !<[quantity].is_integer>:
                - narrate "Quantity must be an integer" format:crates_format
                - stop
            - give crates_key_<[type]> quantity:<[quantity].if_null[1]>
            - narrate "<dark_aqua>You received <aqua><[quantity]>x <[type]> keys."
        - default:
            - narrate "Syntax: <script.data_key[usage]>" format:crates_format
crates_handler:
    type: world
    debug: false
    events:
        on player right clicks entity_flagged:crates with:crates_key_*:
        - determine passively cancelled
        - ratelimit <player> 1t
        - define type <context.entity.flag[crates.type]>
        - if <context.item.flag[crates.type]> != <[type]>:
            - narrate "Your key doesn't match the crate." format:crates_format
            - stop
        - run crates_gamble_task def:<context.entity.flag[crates.type]>|<context.entity.location.find_blocks_flagged[crates].within[3].filter[flag[crates.uuid].equals[<context.entity.flag[crates.uuid]>]].first>
        on player right clicks ender_chest location_flagged:crates with:crates_key_*:
        - determine passively cancelled
        - define type <context.location.flag[crates.type]>
        - if <context.item.flag[crates.type]> != <[type]>:
            - narrate "Your key doesn't match the crate." format:crates_format
            - stop
        - run crates_gamble_task def:<context.location.flag[crates.type]>|<context.location>
        after player breaks ender_chest permission:crates.create:
        - define entities <context.location.find_entities[entity_flagged:crates].within[3].filter[flag[crates.uuid].equals[<context.location.flag[crates.uuid]>]]>
        - remove <[entities]>
        - flag <context.location> crates:!
        on player places crates_chest_* permission:crates.create:
        - define type <context.item_in_hand.flag[crates.type]>
        - spawn armor_stand[gravity=false;visible=false;armor_pose=head|0,0,0] <context.location.add[0.5,-0.7,0.5].with_yaw[<player.location.direction[<context.location>].yaw.round_to_precision[90]>].forward_flat[0.25]> save:<[type]>
        - spawn armor_stand[gravity=false;visible=false;custom_name=<script[crates_config].parsed_key[chests.<[type]>_chest_name]>;custom_name_visible=true] <context.location.add[0.5,-0.5,0.5]> save:name
        - wait 1t
        - if <script[crates_config].data_key[show_tripwire].if_null[true]>:
            - equip <entry[<[type]>].spawned_entity> head:<item[tripwire_hook].with[enchantments=durability,1]>
        - define uuid <util.random.uuid>
        - definemap properties type:<[type]> uuid:<[uuid]>
        - flag <entry[<[type]>].spawned_entity>|<entry[name].spawned_entity> crates:<[properties]>
        - flag <context.location> crates:<[properties]>
crates_gamble_task:
    type: task
    debug: false
    definitions: type|chest
    validate_config:
    - define item_chance <[properties].get[chance].if_null[null]>
    - if !<[item_chance].is_decimal>:
        - announce to_console "[Crates] <red>chests.<[type]>_chest_items.<[id]>.chance is invalid! (not a decimal or missing) Skipping."
        - foreach next
    - define item <item[<[properties].get[item]>].if_null[null]>
    - if <[item]> == null:
        - announce to_console "[Crates] <red>chests.<[type]>_chest_items.<[id]>.item is invalid! (not a valid item or missing) Skipping."
        - foreach next
    - define quantity <[properties].get[quantity].if_null[1]>
    - if !<[quantity].is_integer>:
        - announce to_console "[Crates] <red>chests.<[type]>_chest_items.<[id]>.quantity is invalid! (not an integer) Skipping."
        - foreach next
    script:
    - wait 1t
    - take iteminhand
    - define sum <script[crates_config].data_key[chests.light_chest_items].parse_value_tag[<[parse_value].get[chance]>].values.sum>
    - if <[sum]> > 100:
        - announce to_console "[Crates] <red>The sum of chances in chests.<[type]>_chest_items exceeds 100. Some items will be ignored."
    - define chance <util.random.decimal[0].to[100]>
    - foreach <script[crates_config].parsed_key[chests.<[type]>_chest_items]> key:id as:properties:
        - inject <script> path:validate_config
        - define number:+:<[item_chance]>
        - if <[chance]> > <[number]>:
            - foreach next
        - repeat 3:
            - firework <player.location.find.surface_blocks.within[4].random> random primary:<list[green|blue|yellow|aqua|white|orange].random[2]> fade:<list[green|blue|yellow|aqua|white|orange].random[2]> power:1
        - define item <item[<[properties].get[item]>]>
        - define quantity <[properties].get[quantity].if_null[1]>
        - animatechest <[chest]> sound:false
        - playsound <player.location> sound:ENTITY_PLAYER_LEVELUP
        - give <[item]> quantity:<[quantity]>
        - narrate "<green>Congrats! <white>You won <gold><[quantity]>x <[item].display.if_null[<[item].material.translated_name.color[blue]>]>" format:crates_format
        - wait 1s
        - animatechest <[chest]> close sound:false
        - stop
    - narrate "<red>No Result" format:crates_format
crates_format:
    type: format
    debug: false
    format: <gold>[Crates] <white><text>
crates_chest_light:
    type: item
    debug: false
    material: ender_chest
    display name: <green>Light Crate
    lore:
    - <&r>Place it to create a <green>Light Crate.
    flags:
        crates:
            type: light
crates_chest_medium:
    type: item
    debug: false
    material: ender_chest
    display name: <yellow>Medium Crate
    lore:
    - <&r>Place it to create a <yellow>Medium Crate.
    flags:
        crates:
            type: medium
crates_chest_heavy:
    type: item
    debug: false
    material: ender_chest
    display name: <red>Heavy Crate
    lore:
    - <&r>Place it to create a <red>Heavy Crate.
    flags:
        crates:
            type: heavy
crates_key_light:
    type: item
    debug: false
    material: tripwire_hook
    display name: <green>Light Key
    lore:
    - <&r>You can open a <green>Light Crate<&r> with it.
    enchantments:
    - durability:1
    mechanisms:
        hides:
        - ENCHANTS
    flags:
        crates:
            type: light
crates_key_medium:
    type: item
    debug: false
    material: tripwire_hook
    display name: <yellow>Medium Key
    lore:
    - <&r>You can open a <yellow>Medium Crate<&r> with it.
    enchantments:
    - durability:1
    mechanisms:
        hides:
        - ENCHANTS
    flags:
        crates:
            type: medium
crates_key_heavy:
    type: item
    debug: false
    material: tripwire_hook
    display name: <red>Heavy Key
    lore:
    - <&r>You can open a <red>Heavy Crate<&r> with it.
    enchantments:
    - durability:1
    mechanisms:
        hides:
        - ENCHANTS
    flags:
        crates:
            type: heavy