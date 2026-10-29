note
	description: "Observable events of one parse: element starts and ends, with adjacent character data joined."

class
	DR_TRACE

create
	make

feature {NONE} -- Initialization

	make
		do
			create events.make (8)
			create pending_text.make_empty
		end

feature -- Recording

	put_start (name: READABLE_STRING_8)
		do
			flush_text
			events.extend ("start:" + name)
		end

	put_end (name: READABLE_STRING_8)
		do
			flush_text
			events.extend ("end:" + name)
		end

	put_text (text: READABLE_STRING_8)
			-- Character data; the API may divide it at any point, so pieces are joined.
		do
			pending_text.append (text)
		end

	wipe_out
		do
			events.wipe_out
			pending_text.wipe_out
		end

feature -- Output

	line: STRING_8
			-- Events separated by " | "; bytes outside printable ASCII, `\' and `|' as \xNN.
		local
			i: INTEGER
		do
			flush_text
			create Result.make (64)
				-- An index loop: `across ... as' means different things in the two ECF formats.
			from i := 1 until i > events.count loop
				if i > 1 then Result.append (" | ") end
				Result.append (escaped (events [i]))
				i := i + 1
			end
		end

	escaped (s: READABLE_STRING_8): STRING_8
		local
			i, code: INTEGER
		do
			create Result.make (s.count)
			from i := 1 until i > s.count loop
				code := s.item (i).code
				if code >= 32 and code < 127 and s.item (i) /= '\' and s.item (i) /= '|' then
					Result.append_character (s.item (i))
				else
					Result.append ("\x")
					Result.append (code.to_hex_string.substring (7, 8).as_lower)
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	events: ARRAYED_LIST [STRING_8]

	pending_text: STRING_8

	flush_text
		do
			if not pending_text.is_empty then
				events.extend ("text:" + pending_text)
				create pending_text.make_empty
			end
		end

end
