currency_parser:
    type: procedure
    debug: false
    data:
        currency:
            copper: <&chr[Eff1].font[economy-icons]>
            iron: <&chr[Eff2].font[economy-icons]>
            gold: <&chr[Eff3].font[economy-icons]>
            diamond: <&chr[Eff4].font[economy-icons]>
            emerald: <&chr[Eff5].font[economy-icons]>
    definitions: amount
    script:
    #Define the list, to prevent VSCode errors.
    - define currencies <list>
    - foreach <script.parsed_key[data.currency]> key:currency as:icon:
        #Do the math. Do only show the icon if the highest currency isn't 0.
        - if <[amount].mod[1].mul[100]> == 0 && !<[currencies].is_empty>:
            - define amount <[amount].round_down.div[100]>
            - foreach next
        #If the it's the last item, don't divide it anymore.
        - if <[currency]> == emerald:
            - define currencies:->:<[icon]><[amount].mul[100]>
            - foreach next
        #Add .round to prevent decimals in the copper value.
        - define currencies:->:<[icon]><[amount].mod[1].mul[100].round>
        - define amount <[amount].round_down.div[100]>
    - determine <[currencies].space_separated>