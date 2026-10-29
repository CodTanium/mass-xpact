/* One W3C conformance case through the Expat-compatible DLL.
 *
 * With --entity-root, external entities and the external DTD subset are
 * loaded the way Expat applications (and xmlwf -p) do it: the
 * ExternalEntityRefHandler reads the file and parses it with
 * XML_ExternalEntityParserCreate, so text declarations, encodings and
 * well-formedness of the entity are checked by xpact itself. Only relative
 * system identifiers that stay below the entity root are opened.
 *
 * Output and exit codes match the Eiffel conformance harness:
 *   XPACT_CONFORMANCE<TAB>ACCEPT, exit 0
 *   XPACT_CONFORMANCE<TAB>REJECT, diagnostic line, exit 1
 *   usage or input file errors, exit 2
 */
#include "xpact.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PATH_SIZE 4096

static char g_root[PATH_SIZE];
static char g_entity_error[PATH_SIZE * 2 + 256];
static int g_null_base_count;

static char *read_file(const char *path, long *length)
{
	FILE *file = fopen(path, "rb");
	char *data;
	long size;

	if (file == NULL) {
		return NULL;
	}
	if (fseek(file, 0, SEEK_END) != 0 || (size = ftell(file)) < 0 || fseek(file, 0, SEEK_SET) != 0) {
		fclose(file);
		return NULL;
	}
	data = (char *) malloc((size_t) size + 1);
	if (data != NULL && fread(data, 1, (size_t) size, file) != (size_t) size) {
		free(data);
		data = NULL;
	}
	fclose(file);
	*length = size;
	return data;
}

static int starts_with_ignore_case(const char *text, const char *prefix)
{
	for (; *prefix != '\0'; text++, prefix++) {
		if (tolower((unsigned char) *text) != tolower((unsigned char) *prefix)) {
			return 0;
		}
	}
	return 1;
}

/* Full path of `system_id' relative to the directory of `base', or 0 when it
 * is not a relative reference below the entity root. */
static int resolve(const char *base, const char *system_id, char *result)
{
	char joined[PATH_SIZE * 2];
	const char *slash;
	size_t directory_length = 0;
	size_t root_length = strlen(g_root);

	if (system_id == NULL || system_id[0] == '\0' || system_id[0] == '/' || system_id[0] == '\\'
			|| strchr(system_id, ':') != NULL || strchr(system_id, '#') != NULL) {
		return 0;
	}
	if (base != NULL) {
		slash = strrchr(base, '/');
		if (strrchr(base, '\\') > slash) {
			slash = strrchr(base, '\\');
		}
		if (slash != NULL) {
			directory_length = (size_t) (slash - base) + 1;
		}
	}
	if (directory_length + strlen(system_id) + 1 > sizeof joined) {
		return 0;
	}
	memcpy(joined, base, directory_length);
	memcpy(joined + directory_length, system_id, strlen(system_id) + 1);
	if (_fullpath(result, joined, PATH_SIZE) == NULL) {
		return 0;
	}
	return starts_with_ignore_case(result, g_root)
		&& (result[root_length] == '\\' || result[root_length] == '/');
}

static int XMLCALL external_entity(XML_Parser parser, const XML_Char *context, const XML_Char *base,
		const XML_Char *system_id, const XML_Char *public_id)
{
	char path[PATH_SIZE];
	char *data;
	long length = 0;
	XML_Parser child;
	int ok;

	(void) public_id;
	if (base == NULL) {
		/* Workaround: xpact passes no base here although XML_SetBase was
		 * called (Expat passes it). Use the parser's own base, which this
		 * program sets for the document and for every child parser. */
		g_null_base_count++;
		base = XML_GetBase(parser);
	}
	if (!resolve(base, system_id, path)) {
		snprintf(g_entity_error, sizeof g_entity_error, "external entity not allowed: %s (base %s)", system_id ? system_id : "(none)", base ? base : "(none)");
		return XML_STATUS_ERROR;
	}
	data = read_file(path, &length);
	if (data == NULL) {
		snprintf(g_entity_error, sizeof g_entity_error, "external entity not readable: %s", path);
		return XML_STATUS_ERROR;
	}
	child = XML_ExternalEntityParserCreate(parser, context, NULL);
	if (child == NULL) {
		free(data);
		snprintf(g_entity_error, sizeof g_entity_error, "external entity parser not created: %s", path);
		return XML_STATUS_ERROR;
	}
	XML_SetBase(child, path);
	ok = XML_Parse(child, data, (int) length, 1) == XML_STATUS_OK;
	if (!ok && g_entity_error[0] == '\0') {
		snprintf(g_entity_error, sizeof g_entity_error, "in %s line %lu column %lu: %s", system_id,
			(unsigned long) XML_GetCurrentLineNumber(child), (unsigned long) XML_GetCurrentColumnNumber(child),
			XML_ErrorString(XML_GetErrorCode(child)));
	}
	XML_ParserFree(child);
	free(data);
	return ok ? XML_STATUS_OK : XML_STATUS_ERROR;
}

int main(int argc, char **argv)
{
	const char *path = NULL;
	const char *entity_root = NULL;
	int namespaces = 0;
	char full_path[PATH_SIZE];
	char *data;
	long length = 0;
	XML_Parser parser;
	int i;
	int ok;

	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "--conformance-file") == 0 && i + 1 < argc && path == NULL) {
			path = argv[++i];
		} else if (strcmp(argv[i], "--entity-root") == 0 && i + 1 < argc && entity_root == NULL) {
			entity_root = argv[++i];
		} else if (strcmp(argv[i], "--namespaces") == 0 && !namespaces) {
			namespaces = 1;
		} else {
			path = NULL;
			break;
		}
	}
	if (path == NULL) {
		fputs("usage: --conformance-file PATH [--namespaces] [--entity-root DIR]\n", stderr);
		return 2;
	}
	if (entity_root != NULL && _fullpath(g_root, entity_root, sizeof g_root) == NULL) {
		fputs("entity root not resolvable\n", stderr);
		return 2;
	}
	if (_fullpath(full_path, path, sizeof full_path) == NULL || (data = read_file(full_path, &length)) == NULL) {
		fputs("conformance cannot read XML file\n", stderr);
		return 2;
	}
	parser = namespaces ? XML_ParserCreateNS(NULL, '|') : XML_ParserCreate(NULL);
	if (parser == NULL) {
		free(data);
		fputs("parser not created\n", stderr);
		return 2;
	}
	XML_SetBase(parser, full_path);
	if (entity_root != NULL) {
		XML_SetParamEntityParsing(parser, XML_PARAM_ENTITY_PARSING_ALWAYS);
		XML_SetExternalEntityRefHandler(parser, external_entity);
	}
	ok = XML_Parse(parser, data, (int) length, 1) == XML_STATUS_OK;
	if (ok) {
		puts("XPACT_CONFORMANCE\tACCEPT");
	} else {
		puts("XPACT_CONFORMANCE\tREJECT");
		printf("line %lu column %lu: %s%s%s\n", (unsigned long) XML_GetCurrentLineNumber(parser),
			(unsigned long) XML_GetCurrentColumnNumber(parser), XML_ErrorString(XML_GetErrorCode(parser)),
			g_entity_error[0] != '\0' ? "; " : "", g_entity_error);
	}
	if (g_null_base_count > 0) {
		printf("XPACT_NULL_BASE\t%d\n", g_null_base_count);
	}
	XML_ParserFree(parser);
	free(data);
	return ok ? 0 : 1;
}
