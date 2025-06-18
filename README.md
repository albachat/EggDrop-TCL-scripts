Here’s an Eggdrop TCL script that bans users who send multiline single-character lines in #AlbaChat, even if the bot does not have @ (op) status.

    ✅ Works in #AlbaChat
    ✅ Detects 1-character lines repeated across multiple lines
    ✅ Bot does not require operator status to detect and log
    ✅ But ban/kick will only work if bot has op — this is an IRC limitation
    ✅ You can still log or notify ops if bot has no @
