# Anti-flood script for public commands in Eggdrop
# Blocks users from spamming public commands (e.g., !help, !quote)

# -----------------------------
# CONFIGURATION
# -----------------------------
# Max allowed commands per time window
set flood-max 3

# Time window in seconds
set flood-time 15

# Timeout for mute (ban or kick, optional)
set flood-punish-time 60

# Kick instead of warn? (1 = yes, 0 = just warn)
set flood-kick 1

# Channels to protect
set flood-channels "#yourchannel"

# -----------------------------
# TRACKING ARRAY
# -----------------------------
array set flood-tracker {}

# -----------------------------
# MAIN HANDLER
# -----------------------------
bind pubm - * pubcmd_flood_check

proc pubcmd_flood_check {nick uhost hand chan text} {
    global flood-max flood-time flood-tracker flood-channels flood-kick flood-punish-time

    if {![string match -nocase "#*" $chan]} { return } ;# not a public channel
    if {[string first "!" $text] != 0} { return } ;# not a command

    set now [clock seconds]
    set key "${chan}:${nick}"

    # Initialize if not seen before
    if {![info exists flood-tracker($key)]} {
        set flood-tracker($key) "$now"
        return
    }

    # Split into timestamps
    set timestamps [split $flood-tracker($key) ","]
    set filtered {}

    # Keep only recent timestamps
    foreach ts $timestamps {
        if {($now - $ts) <= $flood-time} {
            lappend filtered $ts
        }
    }

    lappend filtered $now
    set flood-tracker($key) [join $filtered ","]

    # Check if flood threshold exceeded
    if {[llength $filtered] > $flood-max} {
        if {$flood-kick} {
            putquick "KICK $chan $nick :Flooding public commands (max $flood-max every $flood-time sec)"
        } else {
            putquick "NOTICE $nick :Mos keqperdor komandat publike! Lejohet $flood-max çdo $flood-time sekonda."
        }
        # Reset their tracker
        unset flood-tracker($key)
    }
}
