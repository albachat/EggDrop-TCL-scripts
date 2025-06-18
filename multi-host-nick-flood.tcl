# multi-host-nick-flood.tcl v1.6.1 (1Mar2016) by SpiKe^^, closely based on
# repeat.tcl v1.1 (9Apr1999) by slennox <slenny@ozemail.com.au>
# Special Thanks go out to speechles & caesar

## NEW ADDED: This version adds three new settings  (see below) ##


# Nick flood, kick-ban on repeats:seconds #
set mhnk(flood) 3:10

# Nick flood kick-ban reason #
set mhnk(reasn) "Nick Flood!"

# Max number of bans to stack in one mode command #
set mhnk(maxb) 6

# Max number of kicks to stack in one kick command #          <- NEW SETTING <-
# NOTE: many networks allow more than one nick to be kicked per command. #
#       set this at or below the max for your network.
set mhnk(maxk) 3

# Length of time in minutes to ban Nick flooders #
# - set 0 to disable this script removing bans (ex. set mhnk(btime) 0) #
set mhnk(btime) 1

# After a valid Nick flood, script will continue to #
# kick-ban offenders for an additional 'x' seconds #
set mhnk(xpire) 10

# Set the type of ban masks to use #                          <- NEW SETTING <-
#  1 = use host/ip specific bans (ex. *!*@some.host.com) #
#  2 = use wide masked host/ip bans (ex. *!*@*.host.com) #
#      note: setting 2 requires eggdrop 1.6.20 or newer. #
set mhnk(btype) 2

# Set protected host(s) that should not be wide masked #      <- NEW SETTING <-
# - Example:  set mhnk(phost) "*.undernet.org"
#  Note: this setting only applies to ban type 2 above! #
#  Note: set empty to not protect any hosts (ex. set mhnk(phost) "") #
#  Note: space separated if listing more than one protected host #
set mhnk(phost) ""

# Set channel mode(s) on flood detected. #
# - set empty to disable setting channel modes (ex. set mhnk(mode) "") #
set mhnk(mode) "imN"

# Remove these channel modes after how many seconds? #
set mhnk(mrem) 20

# END OF SETTINGS # Don't edit below unless you know what you're doing #

bind nick - * nk_bindnick

proc nk_bindnick {oldnick uhost hand chan nick} {
  global mhnk mhnc mhnq
  set uhost [string tolower $nick!$uhost]
  set chan [string tolower $chan]
  if {[isbotnick $nick]} { return 0 }
  if {[matchattr $hand f|f $chan]} { return 0 }
  set utnow [unixtime]
  set target [lindex $mhnk(flood) 0]
  if {[info exists mhnc($chan)]} {
    set uhlist [lassign $mhnc($chan) cnt ut]
    set utend [expr {$ut + [lindex $mhnk(flood) 1]}]
    set expire [expr {$utend + $mhnk(xpire)}]
    if {$cnt < $target} {
      if {$utnow > $utend} { unset mhnc($chan) }
    } elseif {$utnow > $expire} { unset mhnc($chan) }
  }
  if {![info exists mhnc($chan)]} {
    set mhnc($chan) [list 1 $utnow $uhost]
    return 0
  }
  incr cnt
  if {$cnt <= $target} {
    if {[lsearch $uhlist $uhost] == -1} { lappend uhlist $uhost }
    if {$cnt < $target} {
      set mhnc($chan) [linsert $uhlist 0 $cnt $ut]
    } else {
      set mhnc($chan) [list $cnt $ut]
      if {$mhnk(mode) ne "" && [string is digit -strict $mhnk(mrem)]} {
        putquick "MODE $chan +$mhnk(mode)"
        utimer $mhnk(mrem) [list putquick "MODE $chan -$mhnk(mode)"]
      }
      nk_dobans $chan $uhlist
    }
    return 0
  }
  if {![info exists mhnq($chan)]} {
    utimer 1 [list nk_bque $chan]
    set mhnq($chan) [list $uhost]
  } elseif {[lsearch $mhnq($chan) $uhost] == -1} {
    lappend mhnq($chan) $uhost
  }

  if {[llength $mhnq($chan)] >= $mhnk(maxb)} {
    nk_dobans $chan $mhnq($chan)
    set mhnq($chan) ""
  }

  return 0
}

proc nk_dobans {chan uhlist} {
  global mhnk
  if {![botisop $chan]} return
  set banList ""
  set nickList ""
  foreach ele $uhlist {
    scan $ele {%[^!]!%[^@]@%s} nick user host

    if {$mhnk(btype) == 2} {
      set type 4
      foreach ph $mhnk(phost) {
        if {[string match -nocase $ph $host]} {
          set type 2  ;  break
        }
      }
      set bmask [maskhost $ele $type]
    } else {  set bmask "*!*@$host"  }

    if {[lsearch $banList $bmask] == -1} { lappend banList $bmask }
    if {[lsearch $nickList $nick] == -1} { lappend nickList $nick }
  }
  stack_bans $chan $mhnk(maxb) $banList

  foreach nk $nickList { 
    if {[onchan $nk $chan]} {  lappend nkls $nk  } else { continue }
    if {[llength $nkls] == $mhnk(maxk)} {
      putquick "KICK $chan [join $nkls ,] :$mhnk(reasn)"
      unset nkls
    }
  } 
  if {[info exists nkls]} {
    putquick "KICK $chan [join $nkls ,] :$mhnk(reasn)"
  } 

  if {$mhnk(btime) > 0} {
    set expire [expr {[unixtime] + $mhnk(btime)}]
    lappend mhnk(rmls) [list $expire $chan $banList]
  }
}

proc stack_bans {chan max banlist {opt +} } {
  set len [llength $banlist]
  while {$len > 0} {
    if {$len > $max} {
      set mode [string repeat "b" $max]
      set masks [join [lrange $banlist 0 [expr {$max - 1}]]]
      set banlist [lrange $banlist $max end]
      incr len -$max
    } else {
      set mode [string repeat "b" $len]
      set masks [join $banlist]
      set len 0
    }
    putquick "MODE $chan ${opt}$mode $masks"
  }
}

proc nk_bque {chan} {
  global mhnq
  if {![info exists mhnq($chan)]} { return }
  if {$mhnq($chan) eq ""} { unset mhnq($chan) ; return }
  nk_dobans $chan $mhnq($chan)
  unset mhnq($chan)
}

proc nk_breset {} {
  global mhnc mhnk
  set utnow [unixtime]
  set target [lindex $mhnk(flood) 0]
  foreach {key val} [array get mhnc] {
    lassign $val cnt ut
    set utend [expr {$ut + [lindex $mhnk(flood) 1]}]
    set expire [expr {$utend + $mhnk(xpire)}]
    if {$cnt < $target} {
      if {$utnow > $utend} { unset mhnc($key) }
    } elseif {$utnow > $expire} { unset mhnc($key) }
  }
  if {[info exists mhnk(rmls)]} {
    while {[llength $mhnk(rmls)]} {
      set next [lindex $mhnk(rmls) 0]
      lassign $next expire chan banList
      if {$expire > $utnow} {  break  }
      set mhnk(rmls) [lreplace $mhnk(rmls) 0 0]
      if {![info exists rmAra($chan)]} {  set rmAra($chan) $banList
      } else {  set rmAra($chan) [concat $rmAra($chan) $banList]  }
    }
    foreach {key val} [array get rmAra] {
      set banList ""
      foreach mask $val {
        if {![ischanban $mask $key]} {  continue  }
        lappend banList $mask
      }
      if {$banList eq ""} {  continue  }
      if {![botisop $key]} {
        set mhnk(rmls) [linsert $mhnk(rmls) 0 [list $utnow $key $banList]]
      } else {  stack_bans $key $mhnk(maxb) $banList -  }
    }
    if {![llength $mhnk(rmls)]} {  unset mhnk(rmls)  }
  }
  utimer 30 [list nk_breset]
}

if {![info exists nk_running]} {
  utimer 10 [list nk_breset]
  set nk_running 1
}

set mhnk(flood) [split $mhnk(flood) :]
set mhnk(btime) [expr {$mhnk(btime) * 60}]
set mhnk(phost) [split [string trim $mhnk(phost)]]
if {$mhnk(btime)==0 && [info exists mhnk(rmls)]} {  unset mhnk(rmls)  }

putlog "Loaded multi-host-nick-flood.tcl v1.6.1 by SpiKe^^"

