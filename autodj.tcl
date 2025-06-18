# === Configuration ===
set autodj_channel "#yourchannel"
set autodj_playlist_file "playlist.txt"
set autodj_interval 180           ;# Seconds between songs
set autodj_enabled 1              ;# 1 = on, 0 = off

# Internal vars
set autodj_playlist {}
set autodj_index 0

# === Bind commands ===
bind pub - "!song" autodj_nowplaying
bind pub - "!next" autodj_next_manual
bind pub - "!play" autodj_enable
bind pub - "!pause" autodj_disable

# === Load playlist from file ===
proc autodj_load_playlist {} {
    global autodj_playlist autodj_playlist_file

    set autodj_playlist {}
    if {[file exists $autodj_playlist_file]} {
        set fp [open $autodj_playlist_file r]
        while {[gets $fp line] >= 0} {
            if {[string trim $line] ne ""} {
                lappend autodj_playlist [string trim $line]
            }
        }
        close $fp
    }
}

# === Play next track ===
proc autodj_next_track {} {
    global autodj_playlist autodj_index autodj_channel autodj_enabled autodj_interval

    if {!$autodj_enabled || [llength $autodj_playlist] == 0} {
        return
    }

    if {$autodj_index >= [llength $autodj_playlist]} {
        set autodj_index 0
    }

    set song [lindex $autodj_playlist $autodj_index]
    incr autodj_index

    putserv "PRIVMSG $autodj_channel :Now Playing: $song"

    timer $autodj_interval autodj_next_track
}

# === Start on bot init ===
bind evnt - init-server autodj_start

proc autodj_start {type} {
    global autodj_enabled
    autodj_load_playlist
    if {$autodj_enabled} {
        autodj_next_track
    }
}

# === Command Handlers ===
proc autodj_nowplaying {nick uhost hand chan text} {
    global autodj_playlist autodj_index
    if {[llength $autodj_playlist] == 0} {
        putserv "PRIVMSG $chan :No playlist loaded."
        return
    }

    set idx [expr {$autodj_index - 1}]
    if {$idx < 0} { set idx 0 }
    set song [lindex $autodj_playlist $idx]
    putserv "PRIVMSG $chan :Now Playing: $song"
}

proc autodj_next_manual {nick uhost hand chan text} {
    autodj_next_track
}

proc autodj_enable {nick uhost hand chan text} {
    global autodj_enabled
    set autodj_enabled 1
    putserv "PRIVMSG $chan :AutoDJ enabled."
    autodj_next_track
}

proc autodj_disable {nick uhost hand chan text} {
    global autodj_enabled
    set autodj_enabled 0
    putserv "PRIVMSG $chan :AutoDJ paused."
}
