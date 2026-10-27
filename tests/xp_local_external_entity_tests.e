note
	description: "Local resource confinement, declaring-resource bases and parser reuse sequences."

class
	XP_LOCAL_EXTERNAL_ENTITY_TESTS

create
	make

feature {NONE} -- Initialization

	make
		do
			create files.make (16)
			create directories.make (8)
		end

feature -- Tests

	run: BOOLEAN
		local
			seed: RAW_FILE
			root, sub1, sub2, sibling, document, body: PATH
			loader, nonlocal_loader: XP_LOCAL_EXTERNAL_ENTITY_RESOLVER
			parser: XP_PARSER
			handler: XP_COLLECTING_HANDLER
			accepted: BOOLEAN
			input, raw: STRING_8
		do
			create seed.make_open_temporary_with_prefix ("xpact-local-entities-")
			create root.make_from_string (seed.path.canonical_path.name + ".suite")
			create sibling.make_from_string (seed.path.canonical_path.name + ".suite-sibling")
			seed.close
			seed.delete
			create_directory (root)
			create_directory (sibling)
			sub1 := root.extended ("sub1")
			sub2 := root.extended ("sub2")
			create_directory (sub1)
			create_directory (sub2)
			document := root.extended ("document.xml")
			body := root.extended ("body.ent")
			write_file (document, "<root/>")
			write_file (sub1.extended ("document.xml"), "<root/>")
			write_file (body, "root-correct")
			write_file (sub1.extended ("body.ent"), "sub1-wrong")
			write_file (sub2.extended ("body.ent"), "sub2-wrong")
			write_file (sub1.extended ("pe.dtd"), "<!ENTITY %% extpe SYSTEM '../sub2/extpe.ent'><!ENTITY %% later '%%extpe;'>")
			write_file (sub2.extended ("extpe.ent"), "<!ENTITY ent SYSTEM 'body.ent'>")
			write_file (sibling.extended ("outside.ent"), "must never be loaded")
			if {PLATFORM}.is_windows then
				create nonlocal_loader.make (create {PATH}.make_from_string ("\\invalid-local-resolver-test.invalid\share"))
				verify ("UNC root is rejected without any resolution request", not nonlocal_loader.last_error.is_empty and nonlocal_loader.resolution_count = 0)
			end
			create loader.make (root)
			create handler.make
			create parser.make (handler)
			parser.set_external_entity_policy (parser.All_external_entities)
			parser.set_external_entity_resolver (loader)
			parser.set_external_entity_base (utf8_path (document))
			input := "<!DOCTYPE root [<!ENTITY %% pe SYSTEM 'sub1/pe.dtd'>%%pe;%%later;]><root>&ent;</root>"
			accepted := parser.parse (input)
			verify ("E18 nested load and later internal PE succeed", accepted and loader.last_error.is_empty)
			verify ("E18 declaration uses external resource containing its markup", has_event (handler, "text:root-correct"))
			remove_file (body)
			loader.reset
			accepted := parser.parse (input)
			verify ("missing resource is reported separately", not accepted and not loader.last_error.is_empty and loader.last_resolved_resource = Void)
			write_file (body, "root-correct")
			loader.reset
			handler.events.wipe_out
			accepted := parser.parse (input)
			verify ("failed nested load restores base on reparse", accepted and loader.last_error.is_empty and has_event (handler, "text:root-correct"))
			input := "<!DOCTYPE root [<!ENTITY ent SYSTEM 'body.ent'>]><root>&ent;</root>"
			parser.set_external_entity_base (utf8_path (sub1.extended ("document.xml")))
			loader.reset
			handler.events.wipe_out
			accepted := parser.parse (input)
			verify ("changing document base invalidates previous declarations", accepted and has_event (handler, "text:sub1-wrong"))
			parser.set_external_entity_base (utf8_path (document))
			loader.reset
			handler.events.wipe_out
			accepted := parser.parse (input)
			verify ("returning to prior base has no retained nested context", accepted and has_event (handler, "text:root-correct"))
			verify ("resource-backed DOCTYPE is not cached", parser.cached_doctype_byte_count = 0)

			write_file (root.extended ("standalone.dtd"), "<!ENTITY ext SYSTEM 'absent.ent'>")
			loader.reset
			accepted := parser.parse ("<?xml version='1.0' standalone='yes'?><!DOCTYPE root SYSTEM 'standalone.dtd'><root>&ext;</root>")
			verify ("standalone external declaration rejected before missing entity I/O", not accepted and loader.last_error.is_empty and loader.resolution_count = 1)
			loader.reset
			accepted := parser.parse ("<!DOCTYPE root [<!ENTITY ext SYSTEM 'absent.ent'>]><root a='&ext;'/>")
			verify ("external attribute entity rejected without I/O", not accepted and loader.last_error.is_empty and loader.resolution_count = 0)
			loader.reset
			accepted := parser.parse ("<!DOCTYPE root [<!ENTITY ext SYSTEM 'absent.ent'><!ATTLIST root a CDATA '&ext;'>]><root/>")
			verify ("external ATTLIST default entity rejected without I/O", not accepted and loader.last_error.is_empty and loader.resolution_count = 0)
			loader.reset
			handler.events.wipe_out
			accepted := parser.parse ("<!DOCTYPE root [<!ENTITY ent SYSTEM 'body.ent'><!ENTITY ent 'wrong-later'>]><root>&ent;</root>")
			verify ("first external binding wins over later internal declaration", accepted and loader.resolution_count = 1 and has_event (handler, "text:root-correct"))
			loader.reset
			handler.events.wipe_out
			accepted := parser.parse ("<!DOCTYPE root [<!ENTITY ent 'first-internal'><!ENTITY ent SYSTEM 'body.ent'>]><root>&ent;</root>")
			verify ("first internal binding wins without I/O", accepted and loader.resolution_count = 0 and has_event (handler, "text:first-internal"))

			raw := "%/255/%/254/%/65/%/0/"
			write_file (root.extended ("space file.ent"), raw)
			loader.reset
			verify ("percent-decoded local name returns original bytes", attached loader.resolve_external_entity_from_base ("ext", "", "space%%20file.ent", False, utf8_path (document)) as bytes and then bytes.same_string (raw))
			write_file (root.extended ("empty.ent"), "")
			verify ("empty external file is a successful load", attached loader.resolve_external_entity_from_base ("ext", "", "empty.ent", False, utf8_path (document)) as bytes and then bytes.is_empty and loader.last_error.is_empty)
			if attached sibling.entry as sibling_entry then
				verify ("sibling directory sharing suite prefix is denied", loader.resolve_external_entity_from_base ("ext", "", "../" + sibling_entry.name.to_string_8 + "/outside.ent", False, utf8_path (document)) = Void and not loader.last_error.is_empty and loader.last_resolved_resource = Void)
			else
				verify ("sibling fixture has a file-name component", False)
			end
			verify ("network resource is denied", loader.resolve_external_entity_from_base ("ext", "", "https://example.invalid/entity", False, utf8_path (document)) = Void and not loader.last_error.is_empty)
			verify ("file URI is denied", loader.resolve_external_entity_from_base ("ext", "", "file:///outside.ent", False, utf8_path (document)) = Void and not loader.last_error.is_empty)
			verify ("encoded path escape is denied", loader.resolve_external_entity_from_base ("ext", "", "..%%2f..%%2foutside.ent", False, utf8_path (document)) = Void and not loader.last_error.is_empty)
			verify ("encoded zero is denied", loader.resolve_external_entity_from_base ("ext", "", "bad%%00.ent", False, utf8_path (document)) = Void and not loader.last_error.is_empty)
			if {PLATFORM}.is_windows then
				verify ("Win32 trailing-space parent alias is denied", loader.resolve_external_entity_from_base ("ext", "", ".. /outside.ent", False, utf8_path (document)) = Void and not loader.last_error.is_empty)
				verify ("Win32 device name is denied", loader.resolve_external_entity_from_base ("ext", "", "nul.txt", False, utf8_path (document)) = Void and not loader.last_error.is_empty)
			end
			loader.reset
			verify ("reset releases failure and last resource", loader.last_error.is_empty and loader.last_resolved_resource = Void and loader.resolution_count = 0)
			verify ("ordinary load recovers after denied paths", attached loader.resolve_external_entity_from_base ("ext", "", "body.ent", False, utf8_path (document)) as bytes and then bytes.same_string ("root-correct") and loader.last_error.is_empty)
			cleanup
			Result := not failed
		rescue
			if seed /= Void and then not seed.is_closed then seed.close end
			cleanup
		end

feature {NONE} -- Fixture ownership and checks

	files: ARRAYED_LIST [PATH]

	directories: ARRAYED_LIST [PATH]

	failed: BOOLEAN

	verify (label: STRING_8; condition: BOOLEAN)
		do
			if not condition then
				failed := True
				io.put_string ("FAIL: local external resources: " + label + "%N")
			end
		end

	has_event (handler: XP_COLLECTING_HANDLER; expected: STRING_8): BOOLEAN
		do
			across handler.events as event loop
				Result := Result or else event.item.same_string (expected)
			end
		end

	utf8_path (path: PATH): STRING_8
		do
			Result := {UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (path.canonical_path.name)
		end

	create_directory (path: PATH)
		local
			directory: DIRECTORY
		do
			create directory.make_with_path (path)
			directory.create_dir
			directories.extend (path)
		end

	write_file (path: PATH; content: STRING_8)
		local
			file: RAW_FILE
		do
			create file.make_with_path (path)
			if not file.exists then files.extend (path) end
			file.open_write
			file.put_string (content)
			file.close
		rescue
			if file /= Void and then not file.is_closed then file.close end
		end

	remove_file (path: PATH)
		local
			file: RAW_FILE
		do
			create file.make_with_path (path)
			if file.exists then file.delete end
		end

	cleanup
			-- Delete only explicitly created files and then empty directories; no recursive deletion.
		local
			i: INTEGER
			directory: DIRECTORY
		do
			across files as path loop remove_file (path.item) end
			files.wipe_out
			from i := directories.count until i = 0 loop
				create directory.make_with_path (directories.i_th (i))
				if directory.exists then directory.delete end
				i := i - 1
			end
			directories.wipe_out
		end

end
