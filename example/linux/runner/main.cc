#include <file_viewer_flutter_linux/file_viewer_flutter_linux_plugin.h>
#include "my_application.h"

int main(int argc, char** argv) {
  const int cef_exit = initCEFProcesses(argc, argv);
  if (cef_exit >= 0) return cef_exit;
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
