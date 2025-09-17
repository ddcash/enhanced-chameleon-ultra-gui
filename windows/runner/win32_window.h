#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>
#include <functional>
#include <memory>
#include <string>

class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  bool CreateAndShow(const std::wstring& title, const Point& origin,
                     const Size& size);

  HWND GetHandle();

  void SetQuitOnClose(bool quit_on_close);

  bool SetIcon(const std::wstring& icon_path);

  bool SetIcon(const HICON icon);

 protected:
  virtual bool OnCreate();

  virtual void OnDestroy();

  virtual LRESULT MessageHandler(HWND window, UINT const message,
                               WPARAM const wparam, LPARAM const lparam);

  HWND window_handle_ = nullptr;

  void SetChildContent(HWND content);

  RECT GetClientArea();

 private:
  bool quit_on_close_ = false;

  void RegisterWindowClass();

  static LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                                WPARAM const wparam, LPARAM const lparam);

  std::wstring window_class_name_ = {};
};

#endif  // RUNNER_WIN32_WINDOW_H_