##########################################################################################
#                                                                                        #
#                                     LoreFormatter                                      #
#                             A procedure which formats lore                             #
#                Version: 1.0.1                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#    https://github.com/Hydroxycobalamin/Denizen-Script-Collection/wiki/LoreFormatter    #
#                                                                                        #
##########################################################################################
format_lore:
    type: procedure
    debug: false
    data:
        # Set a width in pixels when the lore should split.
        width: 150
        # Add more custom tags here.
        parseables:
            [line]: <element[ ].repeat[<script.data_key[data.width].div[4].round_up>].strikethrough>
    definitions: script
    script:
    - define lore <[script].data_key[data.lore].if_null[null]>
    - if <[lore]> == null:
        - debug error "<&[error]> Script <[script].name.custom_color[emphasis]> does not have a data key with the path: <element[data.lore].custom_color[emphasis]>!"
        - determine null
    - define data <script.parsed_key[data]>
    - foreach <[lore]> as:line:
        - if <[line]> in <[data.parseables]>:
            - define lore[<[loop_index]>]:<[data.parseables.<[line]>]>
            - foreach next
        - define lore[<[loop_index]>]:<[line].parsed.split_lines_by_width[<[data.width]>].lines_to_colored_list.separated_by[<n>]>
    - determine <[lore].separated_by[<n>]>