(* INSTRUCTIONS
Mail includes the ability to execute an AppleScript script as the action for a Mail rule.  To use, replace the example code with your processing routines, and save as a compiled script. Then create a Mail rule, and assign the script to be the action for the Mail rule.
*)

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

using terms from application "Mail"
	
	(*
	set the file_name to "A file with a date time 23:34:09"
	set the file_name to replace_chars(file_name, ":", "-")
	display alert file_name
	*)
	
	on perform mail action with messages these_messages for rule this_rule
		try
			tell application "Mail"
				set the message_count to the count of these_messages
				repeat with i from 1 to the message_count
					try
						set this_message to item i of these_messages
						
						set this_source to (source of this_message) as string
						
						set the target_folder to "users:eweb:accounts:drop:" as string
						set the file_name to ((subject of this_message) as string) & " - " & ((date sent of this_message) as string)
						set the file_name to my replace_chars(file_name, ":", "-")
						(*
						set the file_name to replace_chars(file_name, "\"", "")
						*)
						set the target_file to target_folder & file_name & ".eml"
						try
							(* display alert "About to write file " & target_file *)
							set the open_target_file to Â
								open for access file target_file with write permission
							write this_source to the open_target_file starting at 0
							close access the open_target_file
							(* TODO process the order *)
						on error error_message
							display alert "error writing file " & error_message
							try
								close access file target_file
							end try
						end try
					on error error_message
						display alert "error " & target_file & " - " & error_message
					end try
				end repeat
			end tell
		on error
			display alert "error " & error_message
		end try
	end perform mail action with messages
end using terms from
