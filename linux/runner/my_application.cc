#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <gio/gio.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "SAGE File Manager");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "SAGE File Manager");
  }

  gtk_window_set_default_size(window, 1280, 720);

  {
    gboolean icon_set = FALSE;
    gchar* self_exe = g_file_read_link("/proc/self/exe", nullptr);
    if (self_exe != nullptr) {
      gchar* exe_dir = g_path_get_dirname(self_exe);
      g_free(self_exe);
      gchar* icon_path = g_build_filename(
          exe_dir, "data", "flutter_assets", "assets", "icons", "fileman.png",
          nullptr);
      g_free(exe_dir);
      if (g_file_test(icon_path, G_FILE_TEST_EXISTS)) {
        gtk_window_set_icon_from_file(window, icon_path, nullptr);
        gtk_window_set_default_icon_from_file(icon_path, nullptr);
        icon_set = TRUE;
      }
      g_free(icon_path);
    }
    if (!icon_set) {
      const gchar* legacy =
          "/usr/share/icons/hicolor/256x256/apps/filemanager.png";
      const gchar* installed =
          "/usr/share/icons/hicolor/256x256/apps/com.sagefile.manager.png";
      if (g_file_test(installed, G_FILE_TEST_EXISTS)) {
        gtk_window_set_icon_from_file(window, installed, nullptr);
        gtk_window_set_default_icon_from_file(installed, nullptr);
        icon_set = TRUE;
      } else if (g_file_test(legacy, G_FILE_TEST_EXISTS)) {
        gtk_window_set_icon_from_file(window, legacy, nullptr);
        gtk_window_set_default_icon_from_file(legacy, nullptr);
        icon_set = TRUE;
      }
    }
    if (icon_set) {
      gtk_window_set_icon_name(window, "com.sagefile.manager");
    }
  }

  // Enable GPU acceleration and hardware rendering
  g_setenv("FLUTTER_ENGINE_SWITCH", "enable-impeller", TRUE);
  g_setenv("LIBGL_ALWAYS_SOFTWARE", "0", TRUE);
  g_setenv("GALLIUM_DRIVER", "auto", TRUE);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#F5F5F5"); // Light gray background
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  // super_drag_and_drop handles drag & drop automatically, no manual plugin registration needed

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  
  // Process command line arguments
  // When app is set as default file manager, it receives folder paths as arguments
  // Format: sage-file-manager [folder_path1] [folder_path2] ...
  gchar** args = *arguments;
  int argc = g_strv_length(args);
  
  // First argument is binary name, skip it
  // Collect folder paths from arguments (file:// URIs or direct paths)
  GPtrArray* folder_paths = g_ptr_array_new_with_free_func(g_free);
  
  for (int i = 1; i < argc; i++) {
    gchar* arg = args[i];
    
    // Handle file:// URIs (common when opening from desktop)
    if (g_str_has_prefix(arg, "file://")) {
      // Decode URI to path
      gchar* decoded = g_uri_unescape_string(arg + 7, nullptr);
      if (decoded != nullptr) {
        g_ptr_array_add(folder_paths, g_strdup(decoded));
        g_free(decoded);
      }
    } else if (g_str_has_prefix(arg, "file:")) {
      // Alternative URI format
      gchar* decoded = g_uri_unescape_string(arg + 5, nullptr);
      if (decoded != nullptr) {
        g_ptr_array_add(folder_paths, g_strdup(decoded));
        g_free(decoded);
      }
    } else {
      // Direct path
      // Check if it's a valid directory
      GFile* file = g_file_new_for_path(arg);
      if (file != nullptr) {
        GFileInfo* info = g_file_query_info(file, G_FILE_ATTRIBUTE_STANDARD_TYPE,
                                           G_FILE_QUERY_INFO_NONE, nullptr, nullptr);
        if (info != nullptr) {
          if (g_file_info_get_file_type(info) == G_FILE_TYPE_DIRECTORY) {
            g_ptr_array_add(folder_paths, g_strdup(arg));
          }
          g_object_unref(info);
        }
        g_object_unref(file);
      }
    }
  }
  
  // Store folder paths as environment variables or pass to Dart
  // We'll pass them as Dart entrypoint arguments
  gchar** dart_args = g_new(gchar*, folder_paths->len + 1);
  for (guint i = 0; i < folder_paths->len; i++) {
    dart_args[i] = g_strdup((gchar*)g_ptr_array_index(folder_paths, i));
  }
  dart_args[folder_paths->len] = nullptr;
  
  // If no folder paths provided, use original arguments
  if (folder_paths->len == 0) {
    self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);
  } else {
    // Prepend "--folder" flag to indicate folder paths follow
    gchar** final_args = g_new(gchar*, folder_paths->len + 2);
    final_args[0] = g_strdup("--folder");
    for (guint i = 0; i < folder_paths->len; i++) {
      final_args[i + 1] = g_strdup((gchar*)g_ptr_array_index(folder_paths, i));
    }
    final_args[folder_paths->len + 1] = nullptr;
    self->dart_entrypoint_arguments = final_args;
  }
  
  g_ptr_array_free(folder_paths, TRUE);
  g_strfreev(dart_args);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Process / WM class: must match StartupWMClass in com.sagefile.manager.desktop
  // so shells (e.g. GNOME) map the window to the correct launcher icon.
  g_set_prgname("sage-file-manager");

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
