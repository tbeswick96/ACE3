/*
 * ace_parse_imagepath.cpp
 * Author: PabstMirror
 * Gets raw image path from structured text input.
 *
 * Takes:
 * Structured text that usualy has an image:
 * Example: "<img image='\A3\Ui_f\data\IGUI\Cfg\Actions\open_door_ca.paa' size='2.5' />";
 *
 * Returns:
 * Just the image path or "" if none
 */

#include "shared.hpp"

#include <stdlib.h>
#include <sstream>
#include <string>

extern "C" {
    EXPORT void __stdcall RVExtension(char *output, int outputSize, const char *function);
}

std::string getImagePathFromStructuredText(const std::string & input) {
	std::string returnValue = "";
	std::size_t endIndex = input.find(".paa");
	std::size_t startIndex = endIndex - 1;
	if ((endIndex != std::string::npos) && (endIndex > 1)) {
		endIndex = endIndex + 4;
		while ((startIndex > 0) && (returnValue == "")) {
			if ((input[startIndex]) == '\'') {
				returnValue = input.substr((startIndex + 1), (endIndex - startIndex - 1));
			};
			startIndex = startIndex - 1;
		};
	};
	return returnValue;
}

void __stdcall RVExtension(char *output, int outputSize, const char *function) {
    ZERO_OUTPUT();
    if (!strcmp(function, "version")) {
        strncpy(output, ACE_FULL_VERSION_STR, outputSize - 1);
    } else {
        strncpy(output, getImagePathFromStructuredText(function).c_str(), outputSize - 1);
    }
    EXTENSION_RETURN();
}
