note
	description: "Direct xpact verdict adapter; receives original document bytes and fixes namespace policy at construction."

class
	DW_BACKEND

create
	make

feature {NONE} -- Initialization

	make (namespaces: BOOLEAN)
		local
			handler: XP_NULL_EVENT_HANDLER
		do
			create memory
			create last_error.make_empty
			create resource_error.make_empty
			create resource_configuration_error.make_empty
			create handler.make
			create parser.make (handler)
			if attached parser as p then
				p.set_external_entity_policy (p.No_external_entities)
				p.set_external_entity_resolver (Void)
				p.set_skip_unread_external_entities (True)
				if namespaces then p.set_namespace_mode ('|') end
			end
		end

feature -- Whole-document boundary

	configure_external_resources (suite_root, document_path: PATH)
			-- Enable only suite-local resources and keep document origin independent of cwd.
		do
			resource_configuration_error.wipe_out
			create resolver.make (suite_root)
			if attached resolver as l_resolver and attached parser as p then
				if not l_resolver.last_error.is_empty then
					resource_configuration_error := l_resolver.last_error.twin
				elseif not l_resolver.is_allowed_document (document_path) then
					resource_configuration_error := "document is outside the ordinary local suite tree"
				end
				p.set_external_entity_base ({UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (document_path.canonical_path.name))
				p.set_external_entity_resolver (l_resolver)
				p.set_external_entity_policy (p.All_external_entities)
				p.set_skip_unread_external_entities (False)
			end
			resource_error := resource_configuration_error.twin
		end

	parse (document: STRING_8): BOOLEAN
		local
			was_collecting: BOOLEAN
		do
			was_collecting := memory.collecting
			resource_error := resource_configuration_error.twin
			if attached resolver as l_resolver then l_resolver.reset end
			if attached parser as p and then resource_error.is_empty then
				Result := p.parse (document)
				last_error := p.last_error.twin
				if attached resolver as l_resolver then resource_error := l_resolver.last_error.twin end
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
			resolver := Void
		end

	is_closed: BOOLEAN
		do
			Result := parser = Void and resolver = Void
		end

	resource_error: STRING_8
			-- Nonempty only for resource/harness failures.

	last_error: STRING_8

	gc_policy: STRING_8 = "normal"

feature {NONE} -- Owned references

	resolver: detachable XP_LOCAL_EXTERNAL_ENTITY_RESOLVER

	resource_configuration_error: STRING_8

	parser: detachable XP_PARSER

	memory: MEMORY

	restore_gc (collecting: BOOLEAN)
		do
			if memory.collecting /= collecting then
				if collecting then memory.collection_on else memory.collection_off end
			end
		end

end
