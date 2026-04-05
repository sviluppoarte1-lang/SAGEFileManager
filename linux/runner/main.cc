#include "my_application.h"

#include <glib.h>

/* Ensure XCURSOR_THEME is set before Gdk loads: some sessions only set the
 * cursor via XSettings/gsettings; Gtk can start without XCURSOR_THEME exported,
 * then fail to resolve DnD cursor names (dnd-none/move/copy) during drag. */
static void sage_file_manager_prepare_cursor_env(void) {
  if (g_getenv("SAGE_FILE_MANAGER_SKIP_CURSOR_ENV") != NULL ||
      g_getenv("FILEMANAGER_SKIP_CURSOR_ENV") != NULL) {
    return;
  }
  const gchar* theme = g_getenv("XCURSOR_THEME");
  if (theme == NULL || theme[0] == '\0') {
    g_setenv("XCURSOR_THEME", "Adwaita", TRUE);
  }
}

int main(int argc, char** argv) {
  sage_file_manager_prepare_cursor_env();
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
