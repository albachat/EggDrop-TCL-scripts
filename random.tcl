#######################################################
#           _ _            _____ _           _   
#     /\   | | |          / ____| |         | |  
#    /  \  | | |__   __ _| |    | |__   __ _| |_ 
#   / /\ \ | | '_ \ / _` | |    | '_ \ / _` | __|
#  / ____ \| | |_) | (_| | |____| | | | (_| | |_ 
# /_/    \_\_|_.__/ \__,_|\_____|_| |_|\__,_|\__|
#
#######################################################

# Randomly sends a public message 
# to a random user in #AlbaChat at regular intervals.

# === Configuration ===

# Channel to send messages in
set randommsg_channel "#AlbaChat"

# Interval between messages (in seconds)
set randommsg_interval 540  ;# 9 minutes

# List of messages in Albanian
set albanian_messages {
    "Si po kalon?"
    "A je mirë sot?"
    "Kujdesu për veten!"
    "Mos harro të buzëqeshësh ??"
    "Të qoftë dita e mbarë!"
    "Gëzuar ditën!"
    "A ke nevojë për ndihmë?"
    "Je i/e mrekullueshëm!"
    "Shijo ditën!"
    "Bëj diçka që të lumturon sot."
    "Mos u dorëzo – çdo ditë është një mundësi e re."
    "Edhe rrugët e gjata fillojnë me një hap të vetëm."
    "Jeta është më e bukur kur ndihmojmë njëri-tjetrin."
    "Qetësia është forca e mendjes së fortë."
    "Fjalët e mira janë dhuratë pa kosto, por me shumë vlerë."
    "Kurrë mos nënvlerëso fuqinë e një buzëqeshjeje."
    "Sot është dita e duhur për të bërë diçka ndryshe."
    "Fillo ditën me mirënjohje dhe do ta përfundosh me buzëqeshje."
    "Humori është ilaç për shpirtin – qesh më shumë!"
    "Mos harro: ti je më i/e fortë se sa mendon."
    "Jeto me zemër të hapur dhe mendje të qetë."
    "Çdo pengesë është një mësim i fshehur."
    "Frymëzo të tjerët duke qenë vetvetja."
    "Një ditë pa të qeshura është një ditë e humbur."
    "Edhe pak durim bën mrekulli."
    "Je këtu për një arsye – mos harro kurrë vlerën tënde!"
}

# === Timer setup ===

# Start the repeating timer on load
utimer 10 start_random_message_loop

# === Functions ===

# Start the loop
proc start_random_message_loop {} {
    global randommsg_interval
    send_random_albanian_message
    utimer $randommsg_interval start_random_message_loop
}

# Send a random message to a random user in the channel
proc send_random_albanian_message {} {
    global randommsg_channel albanian_messages

    # Get the userlist for the channel
    set userlist [chanlist $randommsg_channel]
    if {[llength $userlist] == 0} {
        putlog "RANDOMMSG: No users found in $randommsg_channel."
        return
    }

    # Pick a random user
    set random_user [lindex $userlist [rand [llength $userlist]]]

    # Pick a random message
    set message [lindex $albanian_messages [rand [llength $albanian_messages]]]

    # Send the message
    putquick "PRIVMSG $randommsg_channel :$random_user: $message"
    putlog "RANDOMMSG: Sent to $random_user in $randommsg_channel — \"$message\""
}
