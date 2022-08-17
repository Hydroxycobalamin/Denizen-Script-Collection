##########################################################################################
#                                                                                        #
#                                       ShortNumber                                      #
#                   A procedure which formats numbers to k, M, G and T                   #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#     https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/ShortNumber     #
#                                                                                        #
##########################################################################################
short_number:
    type: procedure
    debug: false
    data:
        1000000000000: T
        1000000000: G
        1000000: M
        1000: k
    definitions: number
    script:
    - define length <[number].length>
    - foreach <script.data_key[data]> key:div as:suffix:
        - if <[length]> >= <[div].length>:
            - determine <[number].div[<[div]>].round_to[2]><[suffix]>