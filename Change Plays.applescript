(*
   File: Change Plays.applescript
   Author: eweb
   Copyright eweb, 2015-2015
   Contents:
*)
(*
   Date:          Author:  Comments:
   26th May 2015  eweb     #0008 Change number of plays
*)
tell application "iTunes"
	set sel to selection
	repeat with t in sel
		set trackname to the name of t
		set default_answer to the played count of t
		set dialog_answers to display dialog "Enter a new play count for " & trackname & ":" default answer default_answer
		set newcount to text returned of dialog_answers as integer
		if button returned of dialog_answers is "OK" then
			set played count of t to newcount
		end if
	end repeat
end tell

(* Look in the Library folder in your account's home. There might be an iTunes folder. If there is, see if there's a "Scripts" folder inside it. If there is, save your script there, with a name like "Change Play Count". Choose "script" as the format. It'll show up in a new menu with a little script icon.
*)
