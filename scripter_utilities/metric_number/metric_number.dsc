##########################################################################################
#                                                                                        #
#                                      MetricNumber                                      #
#                   A procedure which formats numbers to k, M, G and T                   #
#                Version: 1.0.1                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#     https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/MetricNumber    #
#                                                                                        #
##########################################################################################
metric_number:
    type: procedure
    debug: false
    data:
        1000000000000: T
        1000000000: G
        1000000: M
        1000: k
    definitions: number
    script:
    - define length <[number].abs.log[10].round>
    - foreach <script.data_key[data]> key:div as:suffix:
        - if <[length]> >= <[div].length.sub[1]>:
            - determine <[number].div[<[div]>].round_to[2]><[suffix]>
    - determine <[number].div[1000].round_to[2]>k