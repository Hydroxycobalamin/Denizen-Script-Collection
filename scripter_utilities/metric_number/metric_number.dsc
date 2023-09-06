##########################################################################################
#                                                                                        #
#                                      MetricNumber                                      #
#                   A procedure which formats numbers to k, M, G and T                   #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#     https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/MetricNumber    #
#                                                                                        #
##########################################################################################

## <--[procedure]
## @attribute <ElementTag.proc[metric_number]>
## @returns ElementTag
## @description
## Returns a formatted number.
## @Group MetricNumber
## @Script MetricNumber
## @example
## # Returns '250k'.
## - narrate <element[250000].proc[metric_number]>
## -->
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
    - if !<[number].exists>:
        - debug error "<&[error]>No input given. This procedure requires a decimal input."
        - determine null
    - if !<[number].is_decimal>:
        - debug error "<&[error]>Input is not a decimal. Did a tag not parse properly or did you input text? Input was: '<[number].custom_color[emphasis]>'."
        - determine null
    - foreach <script.data_key[data]> key:div as:suffix:
        - if <[number].div[<[div]>].abs> >= 1:
            - determine <[number].div[<[div]>].round_to[2]><[suffix]>
    - determine <[number]>