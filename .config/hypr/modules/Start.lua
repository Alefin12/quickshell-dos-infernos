-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
 hl.on("hyprland.start", function ()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("matuwall --daemon")
    hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
    hl.exec_cmd("systemctl --user enable --now NetworkManager.service")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("elephant && walker --gapplication-service")
    hl.exec_cmd("sleep 1 && openrgb --startminimized")
 end)

