#######################################################
#           _ _            _____ _           _   
#     /\   | | |          / ____| |         | |  
#    /  \  | | |__   __ _| |    | |__   __ _| |_ 
#   / /\ \ | | '_ \ / _` | |    | '_ \ / _` | __|
#  / ____ \| | |_) | (_| | |____| | | | (_| | |_ 
# /_/    \_\_|_.__/ \__,_|\_____|_| |_|\__,_|\__|
#
########################################################
# Ban on Multiline Single-Character Lines in #AlbaChat #
# Enable channel events
bind pubm - * check_multiline_char
bind ctcp - "ACTION" check_multiline_char_action

# Set the channel to monitor
set monitored_channel "#AlbaChat"

# Check regular messages
proc check_multiline_char {nick uhost hand chan text} {
    global monitored_channel
    if {![string equal -nocase $chan $monitored_channel]} { return }

    if {[is_multiline_single_char $text 2]} {
        putquick "MODE $chan +b $uhost"
        putquick "KICK $chan $nick :Mos shenoni nga 1 shkronje ose shenje."
    }
}

# Check ACTION messages (/me)
proc check_multiline_char_action {nick uhost hand dest keyword args} {
    global monitored_channel
    if {![string equal -nocase $dest $monitored_channel]} { return }

    set msg [lindex $args 0]
    if {[is_multiline_single_char $msg 2]} {
        putquick "MODE $dest +b $uhost"
        putquick "KICK $dest $nick :Mos shenoni nga 1 shkronje ose shenje."
    }
}

# Core logic to detect multiline single-character messages
proc is_multiline_single_char {msg minlines} {
    set lines [split $msg "\n"]
    set count 0

    foreach line $lines {
        set line [string trim $line]
        if {[string length $line] == 1} {
            incr count
        }
    }

    # Ban if all lines are 1 character and we have at least $minlines
    return [expr {$count >= $minlines && $count == [llength $lines]}]
}
