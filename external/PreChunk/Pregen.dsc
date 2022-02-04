#Script: 1.0.1
#Author: Icecapade
#Date 2020-05-12
PreChunk:
    type: command
    debug: false
    name: prechunk
    description: Pre generate your world!
    usage: /prechunk [size] [world]
    permission: prechunk.gen
    permission message: <&3>You need the permission <&b><permission> <&3>to use that command!
    tab complete:
    - if <context.args.is_empty>:
        - determine <list[16|32|64|128|256].alphanumeric>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[16|32|64|128|256].filter[starts_with[<context.args.first>]]>
    - else if <context.args.size> < 2:
        - determine <server.worlds.parse[name]>
    - else if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.worlds.parse[name].filter[starts_with[<context.args.last>]]>
    script:
    - if <context.args.size> == 2 && <context.args.first.is_integer> && <context.args.first> >= 4 && <server.worlds.parse[name].contains[<context.args.last>]>:
        - narrate "<&3>[PreChunk] Generation started! See console for information."
        - define world <context.args.get[2]>
        - define X <context.args.first.mul[-1]>
        - define Y <context.args.first.mul[-1]>
        - define loops <[X].mul[-2]>
        - repeat <[loops]>:
            - chunkload <chunk[<[X]>,<[Y]>,<[world]>]> duration:1t
            - repeat <[loops]>:
                - chunkload <chunk[<[X]>,<[Y]>,<[world]>]> duration:1t
                #- announce to_console <[X]>/<[Y]>
                - define Y:++
                - waituntil rate:5t <server.recent_tps.first> > 18
                #Change the wait time, if you're receiving much lag. Good waiting period would be 5t or 10t. NEVER set to 0t.
                - wait 5t
            - define X:++
            - define Y <context.args.first.mul[-1]>
            - define a:++
            - announce to_console "<[a]>/<[loops]> rows loaded!"
        - announce to_console "<&3>[PreChunk] Generation finished in <queue.time_ran.formatted>! Have a good day!"
    - else:
        - narrate "<&3>[PreChunk] Usage: <&7>/prechunk [size] [world] <&nl><&3>The size is measured in chunks. A size of 64 would be a map with 128x128 Chunks. (2048x2048 blocks)."