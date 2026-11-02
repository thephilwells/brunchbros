on run argv
	set actionName to item 1 of argv
	if actionName is "open" then
		tell application "SameBoy"
			open POSIX file (item 2 of argv)
			activate
		end tell
	else if actionName is "activate" then
		tell application "SameBoy" to activate
	else if actionName is "raise" then
		tell application "System Events" to tell process "SameBoy" to perform action "AXRaise" of window (item 2 of argv)
	else if actionName is "windows" then
		tell application "System Events" to tell process "SameBoy" to get name of every window
	else if actionName is "key" then
		tell application "System Events" to tell process "SameBoy" to key code (item 2 of argv as integer)
	else if actionName is "reset" then
		tell application "System Events" to tell process "SameBoy" to key code 15 using command down
	end if
end run
