<h3>Description of the scripts</h3>

<strong>revert.tcl</strong> - TCL script for Eggdrop that will automatically remove +v (voice), +h (halfop), and +o (op) from any user unless the change was made by one of these trusted users  
<strong>singlecharban.tcl</strong> - Ban on Multiline Single-Character Text or Action Lines in #AlbaChat where BOT is oper  
<strong>multi-host-repeat.tcl</strong> - Advanced multi-host repeat flood detection and protection script.  
<strong>multi-host-nick-flood.tcl</strong> - Protection against nick floods from multihosts  
<strong>autodj.tcl</strong> - AutoDj tcl that plays current songs and has some public commands like !song !next !play and !pause  
<strong>random.tcl</strong> - Randomly sends a public message  to a random user in #AlbaChat 

<h3>Installation</h3>

    Save as random.tcl in your scripts/ directory.

    Add to your Eggdrop config:

source scripts/random.tcl

Restart or .rehash your bot.
