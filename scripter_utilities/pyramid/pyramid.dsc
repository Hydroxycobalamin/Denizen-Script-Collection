##########################################################################################
#                                                                                        #
#                                         Pyramid                                        #
#           A scripter utility which creates a pyramid from the input provided           #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#       https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/Pyramid       #
#                                                                                        #
##########################################################################################
create_pyramid:
    type: task
    debug: false
    description:
    - Creates a pyramid shaped form.
    definitions: size[ElementTag(Integer)]|center[LocationTag]|stair[MaterialTag: must be a stair material]|slab[MaterialTag: must be a slab material]
    sub_script:
        check_definitions:
        - if !<[size].exists>:
            - debug error "<&[error]>No size specified. Did you forgot to pass <&[emphasis]>def.size:<&lt>ElementTag(Integer)<&gt><&[error]>?"
            - stop
        - if !<[size].is_integer>:
            - debug error "<&[error]>size must be an integer. Provided: <&dq><[size].custom_color[emphasis]><&dq>."
            - stop
        - if !<[center].exists>:
            - debug error "<&[error]>No center specified. Did you forgot to pass <&[emphasis]>def.center:<&lt>LocationTag<&gt><&[error]>?"
            - stop
        - if !<[center].as[location].exists>:
            - debug error "<&[error]>center must be a valid LocationTag. Provided: <&dq><[center].custom_color[emphasis]><&dq>."
            - stop
        - if !<[stair].exists>:
            - debug error "<&[error]>No stair specified. Did you forgot to pass <&[emphasis]>def.stair:<&lt>MaterialTag<&gt><&[error]>?"
            - stop
        - if !<[stair].as[material].name.ends_with[stairs].exists>:
            - debug error "<&[error]>stair must be a valid stair block. Provided: <&dq><[stair].custom_color[emphasis]><&dq>."
            - stop
        - if !<[slab].exists>:
            - debug error "<&[error]>No slab specified. Did you forgot to pass <&[emphasis]>def.slab:<&lt>MaterialTag<&gt><&[error]>?"
            - stop
        - if !<[slab].as[material].name.ends_with[slab].exists>:
            - debug error "<&[error]>slab must be a valid slab block. Provided: <&dq><[slab].custom_color[emphasis]><&dq>."
            - stop
    script:
    - inject <script> path:sub_script.check_definitions
    - define slab <[slab].as[material].with[type=bottom]>
    - define stair <[stair].as[material]>
    - define center <[center].round>
    # height = 0.5x - 0.5
    - define height <[size].div[2].sub[0.5].round>
    - define center_to_outline <[size].div[2].round_down>
    - repeat <[height]> as:index:
        - define level <[index].sub[1]>
        - define length <[center_to_outline].sub[<[level]>]>
        - foreach north|south|east|west as:direction:
            - choose <[direction]>:
                - case north:
                    - define main <[center].add[0,<[level]>,<[length]>]>
                    - define row_right <[main].points_between[<[main].add[<[length]>,0,0]>]>
                    - define row_left <[main].points_between[<[main].add[-<[length]>,0,0]>]>
                    - define corners <list>
                - case south:
                    - define main <[center].add[0,<[level]>,-<[length]>]>
                    - define row_right <[main].points_between[<[main].add[<[length]>,0,0]>]>
                    - define row_left <[main].points_between[<[main].add[-<[length]>,0,0]>]>
                    - define corners <list>
                - case east:
                    - define main <[center].add[-<[length]>,<[level]>,0]>
                    - define row_right <[main].points_between[<[main].add[0,0,<[length]>]>]>
                    - define row_left <[main].points_between[<[main].add[0,0,-<[length]>]>]>
                    - definemap corners:
                        1:
                            location: <[main].add[0,0,-<[length]>]>
                            shape: outer_right
                        2:
                            location: <[main].add[0,0,<[length]>]>
                            shape: outer_left
                - case west:
                    - define main <[center].add[<[length]>,<[level]>,0]>
                    - define row_right <[main].points_between[<[main].add[0,0,<[length]>]>]>
                    - define row_left <[main].points_between[<[main].add[0,0,-<[length]>]>]>
                    - definemap corners:
                        1:
                            location: <[main].add[0,0,-<[length]>]>
                            shape: outer_left
                        2:
                            location: <[main].add[0,0,<[length]>]>
                            shape: outer_right
                - default:
                    - foreach next
            - modifyblock <[main]> <[stair].with[direction=<[direction]>]> delayed
            - modifyblock <[row_right]> <[stair].with[direction=<[direction]>]> delayed
            - modifyblock <[row_left]> <[stair].with[direction=<[direction]>]> delayed
            - if !<[corners].is_empty>:
                - modifyblock <[corners.1.location]> <[stair].with[direction=<[direction]>;shape=<[corners.1.shape]>]> delayed
                - modifyblock <[corners.2.location]> <[stair].with[direction=<[direction]>;shape=<[corners.2.shape]>]> delayed
        - modifyblock <[center].add[0,<[height]>,0]> <[slab]> delayed