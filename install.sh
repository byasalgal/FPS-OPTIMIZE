#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

print_modname() {
  ui_print "*******************************"
  ui_print "     SystemFlux Module      "
  ui_print "     by byasalgal 🔧⚡        "
  ui_print "*******************************"
}

on_install() {
  ui_print "- Placing module files..."
  cp -af "$MODPATH/service.sh" "$MODPATH/"
  cp -af "$MODPATH/post-fs-data.sh" "$MODPATH/"
}

set_permissions() {
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/post-fs-data.sh 0 0 0755
}
