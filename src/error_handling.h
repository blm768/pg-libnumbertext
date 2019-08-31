#pragma once

#include <exception>

void report_out_of_memory();
void report_exception(const std::exception& exception);
