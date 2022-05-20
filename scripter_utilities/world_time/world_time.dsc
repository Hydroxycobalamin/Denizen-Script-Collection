##########################################################################################
#                                                                                        #
#                                       WorldTime                                        #
#                   A procedure which gets and formats the worlds time                   #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#      https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/WorldTime      #
#                                                                                        #
##########################################################################################
world_time:
    type: procedure
    debug: false
    definitions: world|format|add_period
    script:
    # Get the current world time.
    - define time <[world].time>
    # If add_period is true, save the period in a definition. Default case is false.
    - define add_period <[add_period].if_null[false]>
    - if <[add_period]>:
        - define period <[world].time.period.to_titlecase>
    # Calculate time
    - define hour <[time].div[1000].add[6].mod[24].round_down>
    - define minute <[hour].mod[1].mul[60].round_down>
    # 24 hour format.
    - if <[format]> == 24:
        - define meridiem <empty>
    # 12 hour format.
    - else if <[format]> == 12:
        - define minute <[hour].mod[1].mul[60].round_down>
        - if <[hour]> > 12:
            - define hour <[hour].sub[12]>
        - if <[hour]> < 12:
            - define meridiem AM
        - else:
            - define meridiem PM
    # If no format is given, output an error.
    - else:
        - debug error "<&[error]>No format given. Add 24 or 12 to the format argument."
    - determine "<&[emphasis]><[hour].pad_left[2].with[0]><element[:].custom_color[base]><[minute].pad_left[2].with[0]><[meridiem].custom_color[base]> <[period].if_null[<empty>]>"