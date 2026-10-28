note
	description: "Raw core parser that records element starts, ends and character data in a DR_TRACE."

class
	DR_CORE_PARSER

inherit
	XT_XML_PARSER_BASE

	XT_DEFAULT_PARSE_EVENTS
		rename
			on_attribute_list_declaration_ as on_attribute_list_declaration,
			on_cdata_section_start_ as on_cdata_section_start,
			on_cdata_section_end_ as on_cdata_section_end,
			on_comment_ as on_comment,
			on_default_ as on_default,
			on_doctype_declaration_start_ as on_doctype_declaration_start,
			on_element_declaration_ as on_element_declaration,
			on_entity_declaration_ as on_entity_declaration,
			on_external_entity_reference_ as on_external_entity_reference,
			on_namespace_declaration_end_ as on_namespace_declaration_end,
			on_namespace_declaration_start_ as on_namespace_declaration_start,
			on_not_standalone_ as on_not_standalone,
			on_notation_declaration_ as on_notation_declaration,
			on_processing_instruction_ as on_processing_instruction,
			on_skipped_entity_ as on_skipped_entity,
			on_unknown_encoding_ as on_unknown_encoding,
			on_unparsed_entity_declaration_ as on_unparsed_entity_declaration,
			on_xml_declaration_ as on_xml_declaration
		end

create
	make

feature -- Observation

	set_trace (a_trace: DR_TRACE)
		do
			trace := a_trace
		end

feature {NONE} -- Raw events

	on_element_start (buf: like buffer; context: XT_ELEMENT_CONTEXT; attributes: XT_ATTRIBUTE_LIST; token: INTEGER; parse_data: POINTER)
		do
			if attached trace as t then t.put_start (context.name) end
		end

	on_element_end (name: STRING_8; parse_data: POINTER)
		do
			if attached trace as t then t.put_end (name) end
		end

	on_content (buf: like buffer; start_index, end_index: INTEGER; parse_data: POINTER)
		local
			i: INTEGER
			text: STRING_8
		do
			if attached trace as t then
				create text.make (end_index - start_index + 1)
				from i := start_index until i > end_index loop
					text.append_character (buf [i])
					i := i + 1
				end
				t.put_text (text)
			end
		end

feature {NONE} -- Implementation

	trace: detachable DR_TRACE

end
