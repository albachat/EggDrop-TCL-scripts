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
set ban_duration 300              ;# Duration of ban in seconds (0 = permanent)
set spam_line_threshold 3         ;# Minimum number of 1-character lines to trigger action

# === Bind to public messages ===
bind pubm - * detect_multiline_spam

proc detect_multiline_spam {nick uhost hand chan text} {
    global spam_channel ban_duration spam_line_threshold

    # Only apply in #AlbaChat (case-insensitive)
    if {[string tolower $chan] ne [string tolower $spam_channel]} {
        return
    }

    # Count lines that are single characters (after trimming)
    set lines [split $text "\n"]
    set onechar_count 0

    foreach line $lines {
        set clean [string trim $line]
        if {[string length $clean] == 1} {
            incr onechar_count
        }
    }

    # If threshold is met, take action
    if {$onechar_count >= $spam_line_threshold} {

        # IRCop can set +b and kick even without @
        putquick "MODE $chan +b $uhost"
        putquick "KICK $chan $nick :Spamming single-character lines"

        if {$ban_duration > 0} {
            # Schedule unban if temporary
            utimer $ban_duration [list putquick "MODE $chan -b $uhost"]
        }
    }
}
