note
	description: "Mutable raw-byte resources for external entity boundary regressions."

class
	XP_MAPPED_ENTITY_RESOLVER

inherit
	XP_EXTERNAL_ENTITY_RESOLVER

create
	make

feature {NONE} -- Initialization

	make
		do
			create resources.make (4)
		end

feature -- Configuration

	put_resource (a_system_id, a_bytes: READABLE_STRING_8)
		do
			resources.force (a_bytes.to_string_8.twin, a_system_id.to_string_8.twin)
		end

feature -- Resolution

	resolve_external_entity (a_name, a_public_id, a_system_id: READABLE_STRING_8; a_is_parameter: BOOLEAN): detachable STRING_8
		do
			if attached resources.item (a_system_id.to_string_8) as l_bytes then
				Result := l_bytes.twin
			end
		end

feature {NONE} -- Storage

	resources: HASH_TABLE [STRING_8, STRING_8]

end
