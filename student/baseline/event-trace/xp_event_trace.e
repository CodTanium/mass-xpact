note
	description: "[
		Print every parser event for each XML file given on the command line.
		Built with all Eiffel assertions enabled, so a contract violation stops
		the run with an exception trace instead of being silently ignored.
	]"

class
	XP_EVENT_TRACE

create
	make

feature {NONE} -- Initialization

	make
		local
			l_arguments: ARGUMENTS_32
			i: INTEGER
		do
			create l_arguments
			if l_arguments.argument_count = 0 then
				io.put_string ("usage: xpact_event_trace FILE...%N")
			else
				from
					i := 1
				until
					i > l_arguments.argument_count
				loop
					trace_file (l_arguments.argument (i).to_string_8)
					i := i + 1
				end
			end
		end

feature {NONE} -- Tracing

	trace_file (a_path: STRING_8)
			-- Parse `a_path' as one final document and print its events.
		require
			path_not_empty: not a_path.is_empty
		local
			l_handler: XP_TRACE_HANDLER
			l_parser: XP_PARSER
			l_ok: BOOLEAN
			n: INTEGER
		do
			io.put_string ("== " + a_path + "%N")
			if attached file_bytes (a_path) as l_bytes then
				io.put_string ("bytes: " + l_bytes.count.out + "%N")
				create l_handler.make
				create l_parser.make (l_handler)
				l_ok := l_parser.parse (l_bytes)
				across l_handler.events as e loop
					n := n + 1
					io.put_string ("  " + n.out + ". " + e.item + "%N")
				end
				if l_ok then
					io.put_string ("result: ACCEPT (" + n.out + " events)%N")
				else
					io.put_string ("result: REJECT at line " + l_parser.current_line_number.out + ", column " + l_parser.current_column_number.out + ": " + l_parser.last_error + "%N")
					if n > 0 then
						io.put_string ("note: " + n.out + " event(s) were delivered before the error was detected%N")
					end
				end
			else
				io.put_string ("result: cannot read file%N")
			end
			io.put_new_line
		end

	file_bytes (a_path: STRING_8): detachable STRING_8
			-- Exact bytes of `a_path' (binary read, no line-ending translation).
		local
			l_file: RAW_FILE
		do
			create l_file.make_with_name (a_path)
			if l_file.exists and then l_file.is_readable then
				create Result.make (l_file.count)
				l_file.open_read
				from
				until
					l_file.end_of_file
				loop
					l_file.read_stream (8192)
					Result.append (l_file.last_string)
				end
				l_file.close
			end
		end

end
