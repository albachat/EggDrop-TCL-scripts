

# === Configuration ===

set drone_channel "#albachat"       ;# Change this to your channel
set drone_ban_time 10m              ;# Time to ban drones (or use 0 for perm)
set drone_patterns {
    *!*@*.invalid
    *!*@drone.*
}
set drone_nick_regexps {
    {^[a-z]{1,2}[0-9]{4,}$}      ; nick like ab1234
    {^[0-9]{6,}$}               ; pure digits
    {^[a-z]{1,}\W{1,}[a-z]{1,}$}; nick with special chars in middle
    {^.{1,3}![^@]+@.*$}         ; short ident or junk
}

# === On Join Check for Suspicious Nick ===
bind join - * check_drone_nick

proc check_drone_nick {nick uhost hand chan} {
    global drone_channel drone_nick_regexps drone_patterns drone_ban_time

    if {[string tolower $chan] ne [string tolower $drone_channel]} return

    set lowered_nick [string tolower $nick]

    foreach pattern $drone_nick_regexps {
        if {[regexp -- $pattern $lowered_nick]} {
            putquick "MODE $chan +b *!*$uhost"
            putquick "KICK $chan $nick :Drone protection"
            if {$drone_ban_time ne "0"} {
                timer 1 [list putquick "MODE $chan -b *!*$uhost"]
            }
            return
        }
    }

    # Optional: Check hostname patterns (useful for known botnets)
    foreach hostmask $drone_patterns {
        if {[matchban $hostmask $nick!$uhost]} {
            putquick "MODE $chan +b *!*$uhost"
            putquick "KICK $chan $nick :Bot host detected"
            if {$drone_ban_time ne "0"} {
                timer 1 [list putquick "MODE $chan -b *!*$uhost"]
            }
            return
        }
    }
}
