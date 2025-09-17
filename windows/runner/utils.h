#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

void CreateAndAttachConsole();

std::vector<std::string> GetCommandLineArguments();

std::wstring Utf8ToWide(const std::string& utf8_string);

std::string WideToUtf8(const std::wstring& wide_string);

#endif  // RUNNER_UTILS_H_