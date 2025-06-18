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

# === Configuration ===
set spam_channel "#AlbaChat"
set ban_duration 300 ;# in seconds (5 minutes). Set 0 for permanent ban.
set spam_line_threshold 2 ;# Number of lines that must be single-char to trigger

# === Bind public messages ===
bind pubm - * check_multiline_singlechar

proc check_multiline_singlechar {nick uhost hand chan text} {
    global spam_channel ban_duration spam_line_threshold

    # Only process for target channel
    if {[string tolower $chan] ne [string tolower $spam_channel]} {
        return
    }

    # Split message by newlines
    set lines [split $text "\n"]
    set singlechar_lines 0

    foreach line $lines {
        set trimmed [string trim $line]
        if {[string length $trimmed] == 1} {
            incr singlechar_lines
        }
    }

    # Check if the number of single-char lines exceeds threshold
    if {$singlechar_lines >= $spam_line_threshold} {
        if {![chanop $chan [botnick]]} {
            return ;# Bot must have op to act
        }

        # Ban the user
        putquick "MODE $chan +b $uhost"
        putquick "KICK $chan $nick :Stop spamming single-character lines"

        # Schedule unban if duration is set
        if {$ban_duration > 0} {
            utimer $ban_duration [list putquick "MODE $chan -b $uhost"]
        }
    }
}
