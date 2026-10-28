note
	description: "[
		Functional regression CLI for one implementation: one input file, every chunking, observable events.
		Chunkings: `whole' (one final call), `split@k' (bytes 1..k non-final, the rest final),
		`bytes' (one non-final call per byte, then an empty final call) and `bytes-final'
		(one call per byte, the last byte final; no empty call).
		Output, one line per chunking:  XPACT_TRACE <tab> chunking <tab> ACCEPT|REJECT <tab> events <tab> error
		`--lifecycle' runs fixed sequences on one reused parser:  XPACT_LIFECYCLE <tab> step <tab> verdict <tab> events
	]"

class
	DR_REGRESSION_ROOT

inherit
	XP_BUILD_IDENTITY

	EXCEPTIONS

create
	make

feature {NONE} -- Initialization

	make
		local
			arguments: ARGUMENTS_32
		do
			create arguments
			if arguments.argument_count = 1 and then arguments.argument (1).same_string ("--identity") then
				put_identity
			elseif arguments.argument_count = 1 and then arguments.argument (1).same_string ("--lifecycle") then
				lifecycle
			elseif arguments.argument_count >= 2 and then arguments.argument (1).same_string ("--trace") then
				if arguments.argument_count = 4 and then arguments.argument (3).same_string ("--chunking") then
					trace_file (create {PATH}.make_from_string (arguments.argument (2)), arguments.argument (4).to_string_8)
				elseif arguments.argument_count = 2 then
					trace_file (create {PATH}.make_from_string (arguments.argument (2)), Void)
				else
					usage_error
				end
			else
				usage_error
			end
		end

feature {NONE} -- Commands

	put_identity
		local
			backend: DR_BACKEND
		do
			create backend.make
			io.put_string ("XPACT_REGRESSION_IDENTITY%T" + implementation_id + "%T" + source_revision + "%T" + build_configuration + "%T" + backend.gc_policy + "%N")
			backend.close
		end

	trace_file (path: PATH; a_chunking: detachable STRING_8)
			-- Every chunking of the file's bytes, or only the one named `a_chunking'.
		local
			backend: DR_BACKEND
			k: INTEGER
		do
			if attached raw_file_bytes (path) as bytes then
				create backend.make
				if a_chunking = Void or else a_chunking.same_string ("whole") then
					put_trace (backend, "whole", chunks_of (bytes, 0))
				end
				from k := 1 until k >= bytes.count loop
					if a_chunking = Void or else a_chunking.same_string ("split@" + k.out) then
						put_trace (backend, "split@" + k.out, chunks_of (bytes, k))
					end
					k := k + 1
				end
				if bytes.count > 0 and (a_chunking = Void or else a_chunking.same_string ("bytes")) then
					put_trace (backend, "bytes", chunks_of (bytes, -1))
				end
				if bytes.count > 1 and (a_chunking = Void or else a_chunking.same_string ("bytes-final")) then
					put_trace (backend, "bytes-final", chunks_of (bytes, -2))
				end
				backend.close
			else
				io.error.put_string ("Cannot read input as original bytes%N")
				die (2)
			end
		end

	lifecycle
			-- Reuse of one parser: success, failure and partial input in sequence (plan step 5).
		local
			backend: DR_BACKEND
		do
			create backend.make
			put_step (backend, "1-valid", << "<root>hi</root>" >>)
			put_step (backend, "2-mismatched", << "<root><child></root>" >>)
			put_step (backend, "3-valid-after-failure", << "<root>hi</root>" >>)
			put_step (backend, "4-incomplete", << "<root>" >>)
			put_step (backend, "5-valid-after-incomplete", << "<a x='1'><b/>t</a>" >>)
			put_step (backend, "6-partial-then-final", << "<root>h", "i</root>" >>)
			put_step (backend, "7-bad-utf8", << "<r>%/255/</r>" >>)
			put_step (backend, "8-valid-after-bad-utf8", << "<r>ok</r>" >>)
			put_step (backend, "9-empty", << "" >>)
			put_step (backend, "10-valid-after-empty", << "<root/>" >>)
			backend.close
		end

feature {NONE} -- Implementation

	put_trace (backend: DR_BACKEND; name: STRING_8; chunks: ARRAYED_LIST [STRING_8])
		local
			verdict: STRING_8
		do
			if backend.run (chunks) then verdict := "ACCEPT" else verdict := "REJECT" end
			io.put_string ("XPACT_TRACE%T" + name + "%T" + verdict + "%T" + backend.trace.line + "%T" + backend.trace.escaped (backend.last_error) + "%N")
		end

	put_step (backend: DR_BACKEND; name: STRING_8; parts: ARRAY [STRING_8])
		local
			chunks: ARRAYED_LIST [STRING_8]
			verdict: STRING_8
		do
			create chunks.make_from_array (parts)
			if backend.run (chunks) then verdict := "ACCEPT" else verdict := "REJECT" end
			io.put_string ("XPACT_LIFECYCLE%T" + name + "%T" + verdict + "%T" + backend.trace.line + "%T" + backend.trace.escaped (backend.last_error) + "%N")
		end

	chunks_of (bytes: STRING_8; split: INTEGER): ARRAYED_LIST [STRING_8]
			-- 0: whole; k > 0: [1, k] and the rest; -1: one chunk per byte, then an empty final chunk;
			-- -2: one chunk per byte, the last one final.
		local
			i: INTEGER
		do
			create Result.make (2)
			if split = 0 then
				Result.extend (bytes)
			elseif split > 0 then
				Result.extend (bytes.substring (1, split))
				Result.extend (bytes.substring (split + 1, bytes.count))
			else
				from i := 1 until i > bytes.count loop
					Result.extend (bytes.substring (i, i))
					i := i + 1
				end
				if split = -1 then
					Result.extend ("")
				end
			end
		end

	raw_file_bytes (path: PATH): detachable STRING_8
		local
			file: RAW_FILE
		do
			create file.make_with_path (path)
			if file.exists and then file.is_readable then
				create Result.make (file.count)
				file.open_read
				from until file.end_of_file loop
					file.read_stream (65536)
					Result.append (file.last_string)
				end
				file.close
			end
		end

	usage_error
		do
			io.error.put_string ("Usage: --identity | --lifecycle | --trace FILE [--chunking whole|split@K|bytes]%N")
			die (2)
		end

end
