note
	description: "Position callbacks after DTD token expansion."

class
	XP_DTD_POSITION_HANDLER

inherit
	XP_POSITION_COLLECTING_HANDLER
		redefine
			on_comment,
			on_element_decl
		end

create
	make

feature -- Events

	on_comment (a_text: READABLE_STRING_8)
		do
			record_event ("comment", a_text)
		end

	on_element_decl (a_name: READABLE_STRING_8; a_model: XP_CONTENT_MODEL)
		do
			record_event ("element", a_name)
		end

end
