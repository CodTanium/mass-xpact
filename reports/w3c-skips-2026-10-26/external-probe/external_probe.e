class EXTERNAL_PROBE
create make
feature {NONE}
 make
  local
   args: ARGUMENTS
   path: PATH
   loader: PROBE_FILE_RESOLVER
   handler: XP_NULL_EVENT_HANDLER
   parser: XP_PARSER
   environment: EXECUTION_ENVIRONMENT
  do
   create args
   create path.make_from_string (args.argument (1))
   create loader.make (path.parent, create {PATH}.make_from_string (args.argument (2)))
   create handler.make
   create parser.make (handler)
   parser.set_external_entity_policy (parser.All_external_entities)
   parser.set_external_entity_resolver (loader)
   if args.argument_count > 2 then parser.set_namespace_mode ('|') end
   if attached loader.read_bytes (path) as bytes then
    if parser.parse (bytes) then
     io.put_string ("XPACT_CONFORMANCE%TACCEPT%N")
    else
     io.put_string ("XPACT_CONFORMANCE%TREJECT%N")
     io.error.put_string (parser.last_error + "%N")
     create environment
     exit_with_code (1)
    end
   else
    io.error.put_string ("HARNESS_INPUT_READ_ERROR%N")
    create environment
    exit_with_code (2)
   end
  end
 exit_with_code (code: INTEGER)
  external
   "C inline use <stdlib.h>"
  alias
   "exit ($code);"
  end
end

