GP_to_dP_converter:
    type: command
    debug: false
    data:
        ##GriefPrevention Claims will be named: 'GP_<#>'. Change the Prefix if you already using denizen areas with this format.
        prefix: GP_
    name: gptodp
    description: converts GP claims to dP claims
    usage: /gptodp
    permission: gptodp
    script:
    - if !<script[dPrevention_area_creation].exists> || !<script[dPrevention_get_costs].exists>:
        - narrate "dPrevention is not installed. Cancelling conversion."
        - stop
    #Loop through all GriefPrevention claims.
    - foreach <griefprevention.list_claims.if_null[<list>]> as:claim:
        - define id <script.data_key[data.prefix]><[claim].id>
        #Create a noted denizen area.
        - note <[claim].cuboid> as:<[id]>
        - define cuboid <cuboid[<[id]>]>
        #If the claim is an adminclaim, create a dPrevention admin claim.
        - if <[claim].is_adminclaim>:
            - if <[claim].cuboid.world.flag[dPrevention.areas.admin.cuboids].contains[<[id]>].if_null[false]>:
                - announce to_console "An admin claim with the id <[id].custom_color[emphasis]> exists already!"
                - foreach next
            - run dPrevention_area_creation def:<list_single[<[cuboid]>]>
            - flag <[cuboid].world> dPrevention.areas.admin.cuboids:->:<[id]>
            - announce to_console "An admin claim was created, with id: <[id].color[red]>"
        - else:
        #If the claim is not an admin claim, create a dPrevention claim and set the owner.
            - if <[claim].cuboid.world.flag[dPrevention.areas.cuboids].contains[<[id]>].if_null[false]>:
                - announce to_console "A player claim with the id <[id].custom_color[emphasis]> exists already!"
                - foreach next
            - run dPrevention_area_creation def:<list_single[<[cuboid]>].include[<[claim].owner>]>
            - flag <[cuboid].world> dPrevention.areas.cuboids:->:<[id]>
            - flag <[claim].owner> dPrevention.areas.cuboids:->:<[id]>
            - announce to_console "A player claim was created, with id: <[id].color[red]>. Owner: <[claim].owner.name.color[gold]>"
        #If the GriefPrevention claim does have builders listed, whitelist them onto the claim.
        - if !<[claim].builders.is_empty>:
            - define builders <[claim].builders.parse[uuid]>
            - flag <[cuboid]> dPrevention.permissions.block-break:|:<[builders]>
            - flag <[cuboid]> dPrevention.permissions.block-place:|:<[builders]>
            - flag <[cuboid]> dPrevention.permissions.container-access:|:<[builders]>
            - flag <[cuboid]> dPrevention.permissions.use:|:<[builders]>
            - announce to_console "<[claim].builders.parse[name].space_separated.color[yellow]> were added to the claim <[id].color[red]>. Bypassing flags: <list[block-break|block-places|container-access|use].space_separated.color[aqua]>."
        #If the GriefPrevention claim does have containers listed, whitelist them onto the claim.
        - if !<[claim].containers.is_empty>:
            - flag <[cuboid]> dPrevention.permissions.container-access:|:<[claim].containers.parse[uuid]>
            - announce to_console "<[claim].containers.parse[name].space_separated.color[green]> were added to the claim <[id].color[red]>. Bypassing flags: <element[container-access].color[aqua]>."
    #Loop through the players and set their blocks and bonus blocks.
    - foreach <server.players> as:player:
        - flag <[player]> dPrevention.blocks.amount.per_time:<[player].griefprevention.blocks.if_null[0]>
        - flag <[player]> dPrevention.blocks.amount.per_block:<[player].griefprevention.blocks.bonus.if_null[0]>
        - define in_use <[player].flag[dPrevention.areas.cuboids].if_null[<list>].parse_tag[<[parse_value].as_cuboid.proc[dPrevention_get_costs]>].sum>
        - flag <[player]> dPrevention.blocks.amount.in_use:<[in_use]>
        - announce to_console "<[player].name.color[light_purple]> - <element[From play:].color_gradient[from=#009933;to=#00ff55]><[player].griefprevention.blocks.color[green]> <white>- <element[From blocks:].color_gradient[from=#009933;to=#00ff55]><[player].griefprevention.blocks.bonus> <white>- <element[In Use:].color_gradient[from=#ff3399;to=#cc0066]><[in_use]>"
    - wait 1s
    - announce to_console "Saving denizen files."
    - adjust server save