## <--[procedure]
## @attribute <ElementTag.proc[currency_parser]>
## @returns ElementTag
## @description
## Returns a number formatted in a currency.
## @Group CurrencyParser
## @Script CurrencyParser
## @example
## # Use to return the formatted currency with help of an economy script.
## economy_script_name:
##     type: economy
##     priority: normal
##     name single: scripto
##     name plural: scriptos
##     digits: 2
##     format: <white><[amount].proc[currency_parser]><&[base]>
##     balance: <player.flag[money].if_null[0]>
##     has: <player.flag[money].is[or_more].than[<[amount]>]>
##     withdraw:
##     - flag <player> money:-:<[amount]>
##     deposit:
##     - flag <player> money:+:<[amount]>
##
## # Use to tell the player how much money they received.
## - narrate "You have received <server.economy.format[60]>!"
##
## # Use to tell the player how much money they have.
## - narrate "You have <server.economy.format[<player.money>]>!"
##
## # Basic usage
## - narrate <element[5928419264].proc[currency_parser]>
##
## -->
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
        # Do the math. Do not show icons if there's nothing to parse.
        - if <[amount]> == 0:
            - define amount <[amount].round_down.div[100]>
            - foreach next
        # If the it's the last item, don't divide it anymore.
        - if <[currency]> == emerald:
            - define currencies:->:<[icon]><[amount].mul[100]>
            - foreach next
        # Add .round to prevent decimals in the copper value.
        - define currencies:->:<[icon]><[amount].mod[1].mul[100].round>
        - define amount <[amount].round_down.div[100]>
    - determine <[currencies].space_separated>
