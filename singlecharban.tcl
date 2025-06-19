#####################################################
#           _ _            _____ _           _   
#     /\   | | |          / ____| |         | |  
#    /  \  | | |__   __ _| |    | |__   __ _| |_ 
#   / /\ \ | | '_ \ / _` | |    | '_ \ / _` | __|
#  / ____ \| | |_) | (_| | |____| | | | (_| | |_ 
# /_/    \_\_|_.__/ \__,_|\_____|_| |_|\__,_|\__|
#
#####################################################
# Ban on Multiline Single-Character Text or Action  #
# Action Lines in #AlbaChat where BOT is oper       #

# Bind normal and action messages
bind pubm - * check_multiline_char
bind ctcp - "ACTION" check_multiline_char_action

# Channel to monitor
set monitored_channel "#AlbaChat"

# Threshold for triggering the ban
set line_threshold 2

# Check regular messages
proc check_multiline_char {nick uhost hand chan text} {
    global monitored_channel line_threshold
    if {![string equal -nocase $chan $monitored_channel]} { return }

    if {[is_multiline_single_char $text $line_threshold]} {
        do_oper_ban $chan $nick $uhost "Multiline single-character message"
    }
}

# Check action (/me) messages
proc check_multiline_char_action {nick uhost hand dest keyword args} {
    global monitored_channel line_threshold
    if {![string equal -nocase $dest $monitored_channel]} { return }

    set msg [lindex $args 0]
    if {[is_multiline_single_char $msg $line_threshold]} {
        do_oper_ban $dest $nick $uhost "Multiline single-character action"
    }
}

# Core check: message has at least $minlines lines of 1 character
proc is_multiline_single_char {msg minlines} {
    set lines [split $msg "\n"]
    set count 0

    foreach line $lines {
        set line [string trim $line]
        if {[string length $line] == 1} {
            incr count
        }
    }

    return [expr {$count >= $minlines && $count == [llength $lines]}]
}

# Perform ban using oper privileges
proc do_oper_ban {chan nick uhost reason} {
    # Use full hostmask for oper ban
    set hostmask "*!*[string range $uhost 1 end]"

    # Set ban, then kick
    putquick "MODE $chan +b $hostmask"
    putquick "KICK $chan $nick :$reason"
    
    # Optional: log the action
}
