//
//  FDString.cpp
//  FireflyDevice
//
//  Created by Denis Bohm on 3/27/14.
//  Copyright (c) 2014 Firefly Design LLC / Denis Bohm. All rights reserved.
//

#include "FDString.h"

#include <cstdarg>
#include <vector>

namespace fireflydesign {

	std::string FDString::format(const std::string &fmt, ...) {
		std::vector<char> str(100, '\0');
		va_list ap;
		while (1) {
			va_start(ap, fmt);
			auto n = vsnprintf_s(str.data(), str.size(), _TRUNCATE, fmt.c_str(), ap);
			va_end(ap);
			if ((n > -1) && (size_t(n) < str.size())) {
				return str.data();
			}
			if (n > -1)
				str.resize(n + 1);
			else
				str.resize(str.size() * 2);
		}
		return str.data();
	}

}