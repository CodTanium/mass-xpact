note
	description: "Application-provided resolver for xpact external entities."

deferred class
	XP_EXTERNAL_ENTITY_RESOLVER

feature -- Resolution

	last_resolution_is_external_child_parse: BOOLEAN
			-- Did the last resolution return parser-control text after
			-- delegating the entity body to an external child parser?
		do
		end

	last_resolution_replacement_byte_count: INTEGER
			-- Logical replacement byte count from the last resolution.
		do
		ensure
			non_negative: Result >= 0
		end

	set_next_resolution_is_parameter_literal (a_enabled: BOOLEAN)
			-- Mark whether the next parameter entity resolution is inside an entity literal.
		do
		ensure
			accepted: True
		end

	last_resolved_resource: detachable STRING_8
			-- Absolute UTF-8 resource path used for the last successful resolution, if known.
			-- Cleared on unsuccessful resolution; legacy resolvers may leave it Void.
		do
		end

	resolve_external_entity_from_base (a_name, a_public_id, a_system_id: READABLE_STRING_8; a_is_parameter: BOOLEAN; a_base: detachable READABLE_STRING_8): detachable STRING_8
			-- Resolve relative to the resource containing the declaration.
			-- Existing in-memory and native callback resolvers retain their original behavior.
		require
			name_attached: a_name /= Void
			name_not_empty: not a_name.is_empty
			public_id_attached: a_public_id /= Void
			system_id_attached: a_system_id /= Void
		do
			Result := resolve_external_entity (a_name, a_public_id, a_system_id, a_is_parameter)
		end

	resolve_external_entity (a_name, a_public_id, a_system_id: READABLE_STRING_8; a_is_parameter: BOOLEAN): detachable STRING_8
			-- Replacement text for external entity, or Void to deny/not-found.
			--
			-- xpact never opens files or network resources itself. Implementations decide
			-- which system identifiers are allowed and return the already-loaded text.
		require
			name_attached: a_name /= Void
			name_not_empty: not a_name.is_empty
			public_id_attached: a_public_id /= Void
			system_id_attached: a_system_id /= Void
		deferred
		end

end
