currency_parser:
    type: procedure
    debug: true
    data:
        currency:
            copper: <&chr[Eff1].font[economy-icons]>
            iron: <&chr[Eff2].font[economy-icons]>
            gold: <&chr[Eff3].font[economy-icons]>
            diamond: <&chr[Eff4].font[economy-icons]>
            emerald: <&chr[Eff5].font[economy-icons]>
    definitions: amount
    script:
    - foreach <script.parsed_key[data.currency]> key:currency as:icon:
        #Do the math. Do not show icons if there's nothing to parse.
        - if <[amount]> == 0:
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