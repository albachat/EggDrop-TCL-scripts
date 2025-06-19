# List of trusted nicks
set trusted_mode_users {
    "RadioZemra"
    "ChanServ"
    "OperServ"
    "DeviL"
}

# Channel to protect
set protected_channel "#AlbaChat"

# Bind to all mode changes
bind mode - * protect_modes

# Function to reverse unauthorized +v/+h/+o changes
proc protect_modes {nick uhost hand chan mode args} {
    global trusted_mode_users protected_channel

    if {![string equal -nocase $chan $protected_channel]} {
        return
    }

    # Check if user is trusted
    set is_trusted 0
    foreach allowed $trusted_mode_users {
        if {[string equal -nocase $nick $allowed]} {
            set is_trusted 1
            break
        }
    }

    if {$is_trusted} {
        return
    }

    set modes [split $mode ""]
    set i 0
    set reversed_modes ""
    set reversed_args ""

    # Loop through mode characters
    foreach m $modes {
        if {$m eq "+" || $m eq "-"} {
            continue
        }

        # Get corresponding argument (target nick)
        set arg [lindex $args $i]

        # If unauthorized user set +v, +h, or +o
        if {[lindex $modes [expr {$i}] - 1] eq "+" && ($m eq "v" || $m eq "h" || $m eq "o")} {
            append reversed_modes "-$m "
            append reversed_args "$arg "
        }

        incr i
    }

    # If any unauthorized modes found, reverse them
    if {$reversed_modes ne ""} {
        putquick "MODE $chan $reversed_modes $reversed_args"
        putquick "PRIVMSG $chan :Unauthorized mode change by $nick. Reversing."
        putlog "MODE PROTECTION: $nick tried unauthorized $mode $args in $chan — reversed"
    }
}
