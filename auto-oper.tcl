# === Replace with your oper credentials ===

# Bind to server connect event
bind evnt - init-server do_oper_on_connect

proc do_oper_on_connect {type} {
    global operuser operpass
    putserv "OPER operuser operpass"
}
