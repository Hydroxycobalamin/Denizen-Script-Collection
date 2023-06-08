##########################################################################################
#                                                                                        #
#                                      Progressbar                                       #
#                        A procedure which displays progressbars                         #
#                Version: 1.0.0                            Author: Icecapade             #
#                                                                                        #
#                                     Documentation:                                     #
#                                https://docs.icecapa.de/                                #
#                                                                                        #
##########################################################################################

## <--[procedure]
## @attribute <MapTag.proc[progressbar]>
## @returns ElementTag
## @description
## Returns a progressbar with the information provided.
## @Group Progressbar
## @Script Progressbar
## @example
## # Creates a new progressbar with 20 | characters. 8 of them will be green, the rest will be gray.
## - definemap progressbar:
##     element: |
##     color: <green>
##     barColor: <gray>
##     size: 20
##     currentValue: 40
##     maxValue: 100
## - narrate <[progressbar].proc[progressbar]>
## -->
progressbar:
    type: procedure
    definitions: progressbar
    script:
    - if <[progressbar.currentValue]> > <[progressbar.maxValue]>:
        - debug error "<&[error]>currentValue may not be larger than maxValue."
        - stop
    - define percentage <[progressbar.currentValue].div[<[progressbar.maxValue]>]>
    - define progressBarProgress <[progressbar.size].mul[<[percentage]>]>
    - define progressBarEmpty <[progressbar.size].sub[<[progressBarProgress]>]>
    - define progressBar <[progressbar.color]><[progressbar.element].repeat[<[progressBarProgress]>]><[progressbar.barColor]><[progressbar.element].repeat[<[progressBarEmpty]>]>
    - determine <[progressBar]>