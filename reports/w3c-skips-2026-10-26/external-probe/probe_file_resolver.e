class PROBE_FILE_RESOLVER
inherit XP_EXTERNAL_ENTITY_RESOLVER
create make
feature
 make (directory, suite: PATH)
  do base_directory := directory; suite_directory := suite.canonical_path end
 suite_directory: PATH
 base_directory: PATH
 resolve_external_entity (a_name, a_public_id, a_system_id: READABLE_STRING_8; a_is_parameter: BOOLEAN): detachable STRING_8
  local
   system: STRING_8
   path: PATH
  do
   create system.make_from_string (a_system_id)
   io.error.put_string ("RESOLVE%T" + a_name + "%T" + system + "%N")
   if system.has (':') or system.starts_with ("/") or system.starts_with ("\") then
    io.error.put_string ("PROBE_RESOLVER_UNSUPPORTED_PATH%N")
   else
    path := base_directory.extended (system).canonical_path
    if path.name.as_lower.starts_with (suite_directory.name.as_lower + "\") then
     Result := read_bytes (path)
     if Result = Void then io.error.put_string ("PROBE_RESOLVER_MISSING_FILE%N") end
    else
     io.error.put_string ("PROBE_RESOLVER_UNSUPPORTED_PATH%N")
    end
   end
  end
 read_bytes (path: PATH): detachable STRING_8
  local file: RAW_FILE
  do
   create file.make_with_path (path)
   if file.exists and then file.is_plain and then file.is_readable then
    create Result.make (file.count)
    file.open_read
    from until Result.count >= file.count or else file.end_of_file loop
     file.read_stream (65536)
     Result.append (file.last_string)
    end
    file.close
   end
  rescue
   if file /= Void and then not file.is_closed then file.close end
  end
end
