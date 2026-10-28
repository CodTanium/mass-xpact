note
	description: "Records skipped-entity callbacks and can abort from that boundary."

class
	XP_SKIPPED_ENTITY_HANDLER

inherit
	XP_COLLECTING_HANDLER
		redefine
			on_skipped_entity,
			stop_requested
		end

create
	make

feature -- Configuration

	set_stop_on_skip (a_enabled: BOOLEAN)
		do
			stop_on_skip := a_enabled
			stop_requested := False
		end

feature -- Status

	stop_requested: BOOLEAN

feature -- Events

	on_skipped_entity (a_name: READABLE_STRING_8; a_is_parameter: BOOLEAN)
		do
			events.extend ("skipped:" + a_name.to_string_8 + ":" + a_is_parameter.to_integer.out)
			stop_requested := stop_on_skip
		end

feature {NONE} -- Configuration storage

	stop_on_skip: BOOLEAN

end
