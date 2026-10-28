note
	description: "[
		xpact adapter: one reused XP_NATIVE_PARSER, the incremental parser behind the DLL.
		Chunks go to `parse' unchanged; events come from its handler's event log.
	]"

class
	DR_BACKEND

create
	make

feature {NONE} -- Initialization

	make
		do
			create trace.make
			create last_error.make_empty
			create parser.make
		end

feature -- Parsing

	run (chunks: ARRAYED_LIST [STRING_8]): BOOLEAN
			-- Reset, then feed `chunks'; the last one is final. Stops at the first error.
		local
			i, status: INTEGER
		do
			trace.wipe_out
			last_error.wipe_out
			if attached parser as p then
				if p.reset then
					Result := True
					from i := 1 until not Result or i > chunks.count loop
						status := p.parse (chunks [i], i = chunks.count)
						Result := status = p.Xml_status_ok
						i := i + 1
					end
					if not Result then
						last_error := "status " + status.out + ", code " + p.last_error_code.out + ", call " + (i - 1).out + " of " + chunks.count.out
					end
				else
					last_error := "reset failed"
				end
				record_events (p)
			else
				last_error := "backend closed"
			end
		end

	close
		do
			parser := Void
		end

feature -- Access

	trace: DR_TRACE

	last_error: STRING_8

	gc_policy: STRING_8 = "normal"

feature {NONE} -- Implementation

	parser: detachable XP_NATIVE_PARSER

	record_events (p: XP_NATIVE_PARSER)
			-- "start:name:attribute-count", "end:name" and "text:..." from the handler's log.
		local
			event: STRING_8
			colon: INTEGER
		do
			across p.handler.events as e loop
				event := e.item
				if event.starts_with ("start:") then
					colon := event.last_index_of (':', event.count)
					if colon > 6 then
						trace.put_start (event.substring (7, colon - 1))
					else
						trace.put_start (event.substring (7, event.count))
					end
				elseif event.starts_with ("end:") then
					trace.put_end (event.substring (5, event.count))
				elseif event.starts_with ("text:") then
					trace.put_text (event.substring (6, event.count))
				end
			end
		end

end
