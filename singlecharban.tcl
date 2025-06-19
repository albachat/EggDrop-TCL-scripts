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
set monitored_channel "#albachat"

# Function to check for multiline single-character messages
proc check_multiline_char {nick uhost hand chan text} {
    global monitored_channel
    if {![string equal $chan $monitored_channel]} { return }

    if {[is_multiline_single_char $text]} {
        putquick "MODE $chan +b $uhost"
        putquick "KICK $chan $nick :Multiline single-character spam is not allowed."
    }
}

# Function to check CTCP /me actions
proc check_multiline_char_action {nick uhost hand dest keyword args} {
    global monitored_channel
    if {![string equal $dest $monitored_channel]} { return }

    set msg [lindex $args 0]
    if {[is_multiline_single_char $msg]} {
        putquick "MODE $dest +b $uhost"
        putquick "KICK $dest $nick :Multiline single-character action messages are not allowed."
    }
}

# Utility to check for single-character lines
proc is_multiline_single_char {msg} {
    set lines [split $msg "\n"]
    set count 0

    foreach line $lines {
        set line [string trim $line]
        if {[string length $line] == 1} {
            incr count
        }
    }

    return [expr {$count >= 4 && $count == [llength $lines]}]
}
