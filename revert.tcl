#######################################################
#           _ _            _____ _           _   
#     /\   | | |          / ____| |         | |  
#    /  \  | | |__   __ _| |    | |__   __ _| |_ 
#   / /\ \ | | '_ \ / _` | |    | '_ \ / _` | __|
#  / ____ \| | |_) | (_| | |____| | | | (_| | |_ 
# /_/    \_\_|_.__/ \__,_|\_____|_| |_|\__,_|\__|
#
#######################################################
# Protects specific user hosts from being banned. 
# Reverses any unauthorized +v, +h, or +o 
# (voice, halfop, op) if not set by authorized users

# Authorized nicks allowed to set +v/+h/+o
set allowed_nicks {ChanServ OperServ}

# Protected hostmasks (no bans allowed)
# Example: *!*@host.com or nick!*@*.isp.net
set protected_hosts {
    *!*@staff.zemra.org
}

# === Reverse Unauthorized +v/+h/+o ===
bind raw - "MODE" reverse_unauthorized_modes

proc reverse_unauthorized_modes {from keyword text} {
    set nick [lindex [split $from "!"] 0]
    set chan [string tolower [lindex $text 0]]

    # Only apply in #AlbaChat
    if {$chan ne "#albachat"} return

    # Skip if nick is allowed
    if {[lsearch -exact $::allowed_nicks $nick] != -1} return

    set modes [lindex $text 1]
    set targets [lrange $text 2 end]

    set rev_modes ""
    set rev_targets ""

    set add 1
    set i 0
    foreach m [split $modes ""] {
        if {$m eq "+"} {
            set add 1
        } elseif {$m eq "-"} {
            set add 0
        } elseif {$m in {v h o}} {
            if {$add == 1} {
                append rev_modes "-$m"
                append rev_targets " [lindex $targets $i]"
            }
            incr i
        } else {
            incr i
        }
    }

    if {[string length $rev_modes] > 0} {
        putserv "MODE $chan $rev_modes$rev_targets"
    }
}

# === Ban Protection ===
bind mode - * protect_from_ban

proc protect_from_ban {nick uhost hand chan mode target} {
    # Only act on #AlbaChat
    if {[string tolower $chan] ne "#albachat"} return

    if {$mode eq "+b"} {
        foreach protected $::protected_hosts {
            if {[matchban $protected $target]} {
                # Remove the ban immediately
                putserv "MODE $chan -b $target"
                putserv "PRIVMSG $chan :Ban on protected user ($target) was reversed."
                return
            }
        }
    }
}


putlog "Channel Mode protection by DeviL loaded.."
