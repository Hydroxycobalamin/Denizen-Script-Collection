##########################################################################################
#                                                                                        #
#                                        PreChunk                                        #
#                       Pregenerates your world in a squared shape.                      #
#                Version: 1.1                           Author: Icecapade                #
#                                                                                        #
#                                     Documentation:                                     #
#       https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/PreChunk      #
#                                                                                        #
#                                                                                        #
##########################################################################################
PreChunk:
    type: command
    debug: false
    name: prechunk
    description: Pre generate your world!
    usage: /prechunk [size] [world]
    permission: prechunk.gen
    tab completions:
        1: 16|32|64|128|256
        2: <server.worlds.parse[name]>
    check_generated:
    - define i:++
    - if <[i].mod[10]> == 0:
        - wait 1t
    - if <chunk[<[X]>,<[Y]>,<[world]>].is_generated>:
        - define Y:++
        - repeat next
    script:
    - if <context.args.size> == 2 && <context.args.first.is_integer> && <context.args.first> >= 4 && <server.worlds.parse[name].contains[<context.args.last>]>:
        - narrate "<&3>[PreChunk] Generation started! See console for information."
        - define world <context.args.get[2]>
        - define X <context.args.first.mul[-1]>
        - define Y <context.args.first.mul[-1]>
        # Generate a square.
        - define rows <[X].mul[-2]>
        - repeat <[rows]>:
            - if !<chunk[<[X]>,<[Y]>,<[world]>].is_generated>:
                - chunkload <chunk[<[X]>,<[Y]>,<[world]>]> duration:1t
            - repeat <[rows]>:
                # Skip if the chunk was already generated before.
                - inject <script> path:check_generated
                - chunkload <chunk[<[X]>,<[Y]>,<[world]>]> duration:1t
                #- announce to_console <[X]>/<[Y]>
                - define Y:++
                - waituntil rate:5t <server.recent_tps.first> > 18
                # Change the wait time, if you're receiving much lag. Good waiting period would be 5t or 10t. NEVER set to 0t.
                - wait 5t
            # Switch to the next row.
            - define X:++
            # Reset Y.
            - define Y <context.args.first.mul[-1]>
            # Count up for statistics.
            - define a:++
            - announce to_console "<[a]>/<[rows]> rows loaded!"
        - announce to_console "<&3>[PreChunk] Generation finished in <queue.time_ran.formatted>! Have a good day!"
    - else:
        - narrate "<&3>[PreChunk] Usage: <&7>/prechunk [size] [world] <n><&3>The size is measured in chunks. A size of 64 would be a map with 128x128 Chunks. (2048x2048 blocks)."