##########################################################################################
#                                                                                        #
#                                       Hammer Time                                      #
#                                    It's Hammer time!                                   #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#     https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Hammer-Time     #
#                                                                                        #
##########################################################################################
hammer_handler:
    type: world
    debug: false
    data:
        #Add a list of materials which will be breakable by the hammer.
        materials:
            - stone
            - andesite
            - diorite
            - granite
            - deepslate
            - cobbled_deepslate
            - tuff
            - netherrack
            - budding_amethyst
            - amethyst_block
            - end_stone
            - calcite
            - dripstone_block
            - *basalt
            - *cobblestone
            - *sandstone
            - *terracotta
    stop_effect:
    # Remove the slow digging effect for hammers.
    - cast remove slow_digging
    - flag <player> hammer.effect.slow_digging:!
    # Reapply the slow digging effect.
    - if <player.has_flag[hammer.effect.preserve]>:
        - define effect <player.flag[hammer.effect.preserve]>
        - cast <[effect.type]> duration:<[effect.duration]> amplifier:<[effect.amplifier].sub[1]>
        - flag <player> hammer.effect.preserve:!
    start_effect:
    # Preserve the current slow digging effect.
    - if <player.has_effect[slow_digging]> && !<player.has_flag[hammer.effect.slow_digging]>:
        - flag <player> hammer.effect.preserve:<player.effects_data.filter[get[type].equals[SLOW_DIGGING]].first>
    # Apply the slow digging effect for hammers.
    - cast slow_digging duration:600s no_ambient no_icon hide_particles
    - flag <player> hammer.effect.slow_digging expire:600s
    events:
        on player breaks block with:*_hammer:
        - ratelimit <player> 1t
        - run <script> path:stop_effect
        - define location <context.location>
        - define vector <player.flag[hammer.vector]>
        - if <[vector]> == 1,0,0 || <[vector]> == -1,0,0:
            - define cuboid <[location].add[0,-1,-1].to_cuboid[<[location].add[0,1,1]>]>
        - else if <[vector]> == 0,1,0 || <[vector]> == 0,-1,0:
            - define cuboid <[location].add[-1,0,-1].to_cuboid[<[location].add[1,0,1]>]>
        - else if <[vector]> == 0,0,1 || <[vector]> == 0,0,-1:
            - define cuboid <[location].add[-1,-1,0].to_cuboid[<[location].add[1,1,0]>]>
        - define blocks <[cuboid].blocks[<script.data_key[data.materials].separated_by[|]>].exclude[<[location]>]>
        - modifyblock <[blocks]> air naturally:<player.item_in_hand> source:<player>
        - run hammer_durability_helper def.item:<player.item_in_hand> def.durability:<[blocks].size>
        on player left clicks !*air with:*_hammer:
        - flag <player> hammer.vector:<context.location.sub[<context.relative>].xyz>
        - run <script> path:start_effect
        after player left clicks block flagged:hammer.effect.slow_digging with:!*_hammer priority:-1:
        - run <script> path:stop_effect
        after player drops *_hammer flagged:hammer.effect.slow_digging:
        - run <script> path:stop_effect
        after player scrolls their hotbar item:!*_hammer:
        - run <script> path:stop_effect
hammer_durability_helper:
    type: task
    debug: false
    definitions: item|durability
    script:
    - if <player.gamemode> == creative:
        - stop
    - if <[item].durability.add[<[durability]>]> >= <[item].max_durability>:
        - inventory set slot:hand o:air
        - playeffect effect:ITEM_CRACK at:<player.location.above[0.5].forward[0.4]> special_data:<[item].material.name> offset:0.2 quantity:15
        - playsound <player.location> sound:ENTITY_ITEM_BREAK
    - else:
        - inventory adjust slot:hand durability:<[item].durability.add[<[durability]>]>
wooden_hammer:
    type: item
    debug: false
    material: wooden_pickaxe
    display name: <white>Wooden Hammer
    lore:
        - <empty>
        - <gray><&translate[item.modifiers.mainhand]>
        - <dark_green> 4 <&translate[attribute.name.generic.attack_damage]>
        - <dark_green> 0.6 <&translate[attribute.name.generic.attack_speed]>
    mechanisms:
        custom_model_data: 101
        hides: ATTRIBUTES
        attribute_modifiers:
            generic_attack_damage:
                1:
                    operation: add_number
                    amount: 3
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
            generic_attack_speed:
                1:
                    operation: add_number
                    amount: -3.2
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
                2:
                    operation: add_scalar
                    amount: -0.25
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
    recipes:
        1:
            type: shaped
            input:
            - *_planks|*_planks|*_planks
            - *_planks|*_planks|*_planks
            - air|stick|air
stone_hammer:
    type: item
    debug: false
    material: stone_pickaxe
    display name: <white>Stone Hammer
    lore:
        - <empty>
        - <gray><&translate[item.modifiers.mainhand]>
        - <dark_green> 5 <&translate[attribute.name.generic.attack_damage]>
        - <dark_green> 0.6 <&translate[attribute.name.generic.attack_speed]>
    mechanisms:
        custom_model_data: 102
        hides: ATTRIBUTES
        attribute_modifiers:
            generic_attack_damage:
                1:
                    operation: add_number
                    amount: 4
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
            generic_attack_speed:
                1:
                    operation: add_number
                    amount: -3.2
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
                2:
                    operation: add_scalar
                    amount: -0.25
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
    recipes:
        1:
            type: shaped
            input:
            - cobblestone/cobbled_deepslate/blackstone|cobblestone/cobbled_deepslate/blackstone|cobblestone/cobbled_deepslate/blackstone
            - cobblestone/cobbled_deepslate/blackstone|cobblestone/cobbled_deepslate/blackstone|cobblestone/cobbled_deepslate/blackstone
            - air|stick|air
iron_hammer:
    type: item
    debug: false
    material: iron_pickaxe
    display name: <white>Iron Hammer
    lore:
        - <empty>
        - <gray><&translate[item.modifiers.mainhand]>
        - <dark_green> 6 <&translate[attribute.name.generic.attack_damage]>
        - <dark_green> 0.675 <&translate[attribute.name.generic.attack_speed]>
    mechanisms:
        custom_model_data: 103
        hides: ATTRIBUTES
        attribute_modifiers:
            generic_attack_damage:
                1:
                    operation: add_number
                    amount: 5
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
            generic_attack_speed:
                1:
                    operation: add_number
                    amount: -3.1
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
                2:
                    operation: add_scalar
                    amount: -0.25
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
    recipes:
        1:
            type: shaped
            input:
            - iron_ingot|iron_ingot|iron_ingot
            - iron_ingot|iron_ingot|iron_ingot
            - air|stick|air
golden_hammer:
    type: item
    debug: false
    material: golden_pickaxe
    display name: <white>Golden Hammer
    lore:
        - <empty>
        - <gray><&translate[item.modifiers.mainhand]>
        - <dark_green> 4 <&translate[attribute.name.generic.attack_damage]>
        - <dark_green> 0.75 <&translate[attribute.name.generic.attack_speed]>
    mechanisms:
        custom_model_data: 104
        hides: ATTRIBUTES
        attribute_modifiers:
            generic_attack_damage:
                1:
                    operation: ADD_NUMBER
                    amount: 3
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
            generic_attack_speed:
                1:
                    operation: add_number
                    amount: -3
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
                2:
                    operation: add_scalar
                    amount: -0.25
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
    recipes:
        1:
            type: shaped
            input:
            - gold_ingot|gold_ingot|gold_ingot
            - gold_ingot|gold_ingot|gold_ingot
            - air|stick|air
diamond_hammer:
    type: item
    debug: false
    material: diamond_pickaxe
    display name: <white>Diamond Hammer
    lore:
        - <empty>
        - <gray><&translate[item.modifiers.mainhand]>
        - <dark_green> 7 <&translate[attribute.name.generic.attack_damage]>
        - <dark_green> 0.75 <&translate[attribute.name.generic.attack_speed]>
    mechanisms:
        custom_model_data: 105
        hides: ATTRIBUTES
        attribute_modifiers:
            generic_attack_damage:
                1:
                    operation: ADD_NUMBER
                    amount: 6
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
            generic_attack_speed:
                1:
                    operation: add_number
                    amount: -3
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
                2:
                    operation: add_scalar
                    amount: -0.25
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
    recipes:
        1:
            type: shaped
            input:
            - diamond|diamond|diamond
            - diamond|diamond|diamond
            - air|stick|air
netherite_hammer:
    type: item
    debug: false
    material: netherite_pickaxe
    display name: <white>Netherite Hammer
    lore:
        - <empty>
        - <gray><&translate[item.modifiers.mainhand]>
        - <dark_green> 8 <&translate[attribute.name.generic.attack_damage]>
        - <dark_green> 0.75 <&translate[attribute.name.generic.attack_speed]>
    mechanisms:
        custom_model_data: 106
        hides: ATTRIBUTES
        attribute_modifiers:
            generic_attack_damage:
                1:
                    operation: ADD_NUMBER
                    amount: 7
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
            generic_attack_speed:
                1:
                    operation: add_number
                    amount: -3
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
                2:
                    operation: add_scalar
                    amount: -0.25
                    slot: hand
                    id: 10000000-1000-1000-1000-100000000000
    recipes:
        1:
            type: smithing
            base: diamond_hammer
            retain: display|enchantments
            upgrade: netherite_ingot