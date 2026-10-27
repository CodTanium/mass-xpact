note
	description: "Resumable stop at an external resource text-declaration callback."

class
	XP_XML_DECLARATION_STOP_HANDLER

inherit
	XP_SKIPPED_ENTITY_HANDLER
		redefine
			on_xml_declaration,
			stop_is_resumable
		end

create
	make

feature -- Configuration

	set_stop_on_declaration (a_enabled: BOOLEAN)
		do
			stop_on_declaration := a_enabled
			stop_requested := False
		end

feature -- Events

	on_xml_declaration (a_version, a_encoding: READABLE_STRING_8; a_standalone: INTEGER)
		do
			Precursor (a_version, a_encoding, a_standalone)
			stop_requested := stop_on_declaration
		end

	stop_is_resumable: BOOLEAN
		do
			Result := True
		end

feature {NONE} -- Storage

	stop_on_declaration: BOOLEAN

end
