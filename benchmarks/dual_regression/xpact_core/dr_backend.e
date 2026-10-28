note
	description: "[
		Pinned Xpact-core adapter: one reused raw parser. Each chunk is copied into its own codec,
		as the W3C lane does with whole documents; core detects the encoding itself.
		The caller's GC state is restored after every run (core switches GC off while parsing).
	]"

class
	DR_BACKEND

inherit
	XT_PARSE_CONSTANTS
	XT_PARSE_ERROR_CONSTANTS

create
	make

feature {NONE} -- Initialization

	make
		local
			data: XT_PARSER_DATA
			p: DR_CORE_PARSER
		do
			create memory
			create trace.make
			create last_error.make_empty
			create codecs.make (4)
			create data.make_default
			create p.make (data)
			p.set_trace (trace)
			parser := p
		end

feature -- Parsing

	run (chunks: ARRAYED_LIST [STRING_8]): BOOLEAN
			-- Reset, then feed `chunks'; the last one is final. Stops at the first error.
		local
			was_collecting: BOOLEAN
			i, status: INTEGER
			codec: XT_UTF_8_CODEC
		do
			was_collecting := memory.collecting
			trace.wipe_out
			last_error.wipe_out
				-- Codecs stay referenced until the run ends: core shares their areas.
			codecs.wipe_out
			if attached parser as p then
				p.reset
				Result := True
				from i := 1 until not Result or i > chunks.count loop
					create codec.make_from_string (chunks [i])
					codecs.extend (codec)
					status := p.parse (codec, i = chunks.count)
					Result := status = Status_ok and p.error_code = Error_none
					i := i + 1
				end
				if not Result then
					last_error := "status " + status.out + ", code " + p.error_code.out + ", call " + (i - 1).out + " of " + chunks.count.out + ": " + p.error_description
				end
			else
				last_error := "backend closed"
			end
			restore_gc (was_collecting)
		rescue
			restore_gc (was_collecting)
		end

	close
		do
			parser := Void
			codecs.wipe_out
		end

feature -- Access

	trace: DR_TRACE

	last_error: STRING_8

	gc_policy: STRING_8 = "core-managed-off-full-collect"

feature {NONE} -- Implementation

	parser: detachable DR_CORE_PARSER

	codecs: ARRAYED_LIST [XT_UTF_8_CODEC]

	memory: MEMORY

	restore_gc (collecting: BOOLEAN)
		do
			if memory.collecting /= collecting then
				if collecting then memory.collection_on else memory.collection_off end
			end
		end

end
