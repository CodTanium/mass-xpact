note
	description: "Parser event handler that records every callback as one readable line."

class
	XP_TRACE_HANDLER

inherit
	XP_EVENT_HANDLER
		redefine
			wants_automatic_character_data_default,
			wants_default_events,
			on_start_namespace_decl,
			on_end_namespace_decl,
			on_processing_instruction,
			on_xml_declaration,
			on_comment,
			on_start_cdata_section,
			on_end_cdata_section,
			on_start_doctype_decl,
			on_end_doctype_decl,
			on_entity_decl,
			on_skipped_entity
		end

create
	make

feature {NONE} -- Initialization

	make
		do
			create events.make (16)
		ensure
			empty: events.is_empty
		end

feature -- Access

	events: ARRAYED_LIST [STRING_8]
			-- One line per callback, in delivery order.

feature -- Settings

	wants_automatic_character_data_default: BOOLEAN
			-- Do not mirror character data to the default handler.
		do
			Result := False
		end

	wants_default_events: BOOLEAN
			-- Raw default-handler text is not traced.
		do
			Result := False
		end

feature -- Events

	on_start_element (a_name: READABLE_STRING_8; a_attributes: XP_ATTRIBUTES)
		local
			l_line: STRING_8
			i: INTEGER
		do
			l_line := "start-element  " + a_name
			from
				i := 1
			until
				i > a_attributes.count
			loop
				l_line.append (" " + a_attributes.i_th_name (i) + "=")
				if attached a_attributes.item (a_attributes.i_th_name (i)) as l_value then
					l_line.append (quoted (l_value))
				end
				i := i + 1
			end
			events.extend (l_line)
		end

	on_end_element (a_name: READABLE_STRING_8)
		do
			events.extend ("end-element    " + a_name)
		end

	on_character_data (a_text: READABLE_STRING_8)
		do
			events.extend ("text           " + quoted (a_text))
		end

	on_start_namespace_decl (a_prefix: detachable READABLE_STRING_8; a_uri: READABLE_STRING_8)
		do
			events.extend ("start-ns       prefix=" + optional (a_prefix) + " uri=" + quoted (a_uri))
		end

	on_end_namespace_decl (a_prefix: detachable READABLE_STRING_8)
		do
			events.extend ("end-ns         prefix=" + optional (a_prefix))
		end

	on_processing_instruction (a_target, a_data: READABLE_STRING_8)
		do
			events.extend ("pi             " + a_target + " " + quoted (a_data))
		end

	on_xml_declaration (a_version, a_encoding: READABLE_STRING_8; a_standalone: INTEGER)
		do
			events.extend ("xml-decl       version=" + quoted (a_version) + " encoding=" + quoted (a_encoding) + " standalone=" + a_standalone.out)
		end

	on_comment (a_text: READABLE_STRING_8)
		do
			events.extend ("comment        " + quoted (a_text))
		end

	on_start_cdata_section
		do
			events.extend ("start-cdata")
		end

	on_end_cdata_section
		do
			events.extend ("end-cdata")
		end

	on_start_doctype_decl (a_name: READABLE_STRING_8; a_system_id, a_public_id: detachable READABLE_STRING_8; a_has_internal_subset: BOOLEAN)
		do
			events.extend ("start-doctype  " + a_name + " system=" + optional (a_system_id) + " public=" + optional (a_public_id) + " internal-subset=" + a_has_internal_subset.out)
		end

	on_end_doctype_decl
		do
			events.extend ("end-doctype")
		end

	on_entity_decl (a_name: READABLE_STRING_8; a_is_parameter: BOOLEAN; a_value: detachable READABLE_STRING_8; a_public_id, a_system_id, a_notation_name: detachable READABLE_STRING_8)
		do
			events.extend ("entity-decl    " + a_name + " parameter=" + a_is_parameter.out + " value=" + optional (a_value) + " system=" + optional (a_system_id))
		end

	on_skipped_entity (a_name: READABLE_STRING_8; a_is_parameter: BOOLEAN)
		do
			events.extend ("skipped-entity " + a_name + " parameter=" + a_is_parameter.out)
		end

feature {NONE} -- Formatting

	quoted (a_text: READABLE_STRING_8): STRING_8
			-- `a_text' in double quotes with control characters made visible.
		do
			create Result.make (a_text.count + 2)
			Result.append_character ('"')
			across a_text as c loop
				inspect c.item
				when '%N' then
					Result.append ("\n")
				when '%R' then
					Result.append ("\r")
				when '%T' then
					Result.append ("\t")
				else
					Result.append_character (c.item)
				end
			end
			Result.append_character ('"')
		end

	optional (a_text: detachable READABLE_STRING_8): STRING_8
			-- Quoted `a_text', or "none" when absent.
		do
			if attached a_text as l_text then
				Result := quoted (l_text)
			else
				Result := "none"
			end
		end

end
