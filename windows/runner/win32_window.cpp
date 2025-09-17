#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

constexpr const int kDefaultInitialX = CW_USEDEFAULT;
constexpr const int kDefaultInitialY = CW_USEDEFAULT;
constexpr const int kDefaultInitialWidth = 1280;
constexpr const int kDefaultInitialHeight = 720;

void EnableFullDpiSupportIfAvailable(HWND hwnd) {
  bool result = ::SetProcessDpiAwarenessContext(
      DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  if (!result) {
    result = ::SetProcessDpiAwarenessContext(
        DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE);
  }
  if (!result) {
    ::SetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE);
  }
}

}  // namespace

Win32Window::Win32Window() {
  ++g_active_window_count;
}

Win32Window::~Win32Window() {
  --g_active_window_count;
  Destroy();
}

bool Win32Window::Create(const std::wstring& title,
                        const Point& origin,
                        const Size& size) {
  Destroy();

  const wchar_t* window_class =
      GetWindowClass(GetModuleHandle(nullptr));

  const POINT target_point = {static_cast<LONG>(origin.x),
                             static_cast<LONG>(origin.y)};
  HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;

  HWND window = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW,
      Scale(origin.x, scale_factor), Scale(origin.y, scale_factor),
      Scale(size.width, scale_factor), Scale(size.height, scale_factor),
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!window) {
    return false;
  }

  UpdateTheme(window);

  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::Destroy() {
  OnDestroy();

  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  if (g_active_window_count == 0) {
    PostQuitMessage(0);
  }
}

FlutterDesktopWindowControllerRef Win32Window::GetController() {
  return controller_;
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() {
  EnableFullDpiSupportIfAvailable(window_handle_);

  flutter::DartProject project(L"data");

  auto command_line_arguments = GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  controller_ = FlutterDesktopViewControllerCreate(
      project.configuration(), window_handle_);
  if (!controller_) {
    return false;
  }

  RegisterPlugins(FlutterDesktopViewControllerGetEngine(controller_));

  SetChildContent(FlutterDesktopViewControllerGetView(controller_));

  return true;
}

void Win32Window::OnDestroy() {
  if (controller_) {
    FlutterDesktopViewControllerDestroy(controller_);
    controller_ = nullptr;
  }
}

LRESULT Win32Window::MessageHandler(HWND hwnd,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept {
  if (FlutterDesktopViewControllerHandleTopLevelWindowProc(
          controller_, hwnd, message, wparam, lparam, nullptr)) {
    return 0;
  }

  switch (message) {
    case WM_FONTCHANGE:
      FlutterDesktopEngineReloadSystemFonts(
          FlutterDesktopViewControllerGetEngine(controller_));
      break;
  }

  return DefWindowProc(hwnd, message, wparam, lparam);
}

int Win32Window::Scale(int source, double scale_factor) {
  return static_cast<int>(source * scale_factor);
}

const wchar_t* Win32Window::GetWindowClass(HINSTANCE hInstance) {
  if (!g_window_class_registerd) {
    WNDCLASS window_class{};
    window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
    window_class.lpszClassName = kWindowClassName;
    window_class.style = CS_HREDRAW | CS_VREDRAW;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = hInstance;
    window_class.hIcon =
        LoadIcon(hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
    window_class.hbrBackground = 0;
    window_class.lpszMenuName = nullptr;
    window_class.lpfnWndProc = Win32Window::WndProc;
    RegisterClass(&window_class);
    g_window_class_registerd = true;
  }
  return kWindowClassName;
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                    UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));

    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    EnableFullDpiSupportIfAvailable(window);
    that->window_handle_ = window;
  } else if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

void Win32Window::UpdateTheme(HWND const window) {
  BOOL dark_mode_supported = FALSE;
  HMODULE dwmapi = LoadLibraryEx(L"dwmapi.dll", nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
  if (dwmapi) {
    auto DwmSetWindowAttribute = reinterpret_cast<decltype(&::DwmSetWindowAttribute)>(
        GetProcAddress(dwmapi, "DwmSetWindowAttribute"));
    if (DwmSetWindowAttribute) {
      COLORREF color = 0x00000000;  // Dark color
      DwmSetWindowAttribute(window, DWMWA_BORDER_COLOR, &color, sizeof(color));
      DwmSetWindowAttribute(window, DWMWA_CAPTION_COLOR, &color, sizeof(color));
      
      BOOL dark_mode = TRUE;
      DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, sizeof(dark_mode));
    }
    FreeLibrary(dwmapi);
  }
}