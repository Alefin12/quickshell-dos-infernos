
---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "walker"
local web         = "firefox"
local notepad     = "mousepad"
local calculator  = "deepin-calculator"

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({action = "toggle"}))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(notepad))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(web))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(calculator))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + CONTROL + W", hl.dsp.exec_cmd("matuwall"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.local/share/quickshell-lockscreen/lock.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
--- Example Hyprland Lua config using split-monitor-workspaces.
--- This file serves as an example to show what's possible, not necessarily a recommended config.

--- Hyprland sets package.path to only search relative to the config directory,
--- so absolute-path require() calls do not work. Add the library directory to
--- package.path first, then require by module name.
-- somewhere in your Hyprland config

package.path = package.path .. ";./?.lua;./?/init.lua"
local smw = require("plugins.split-monitor-workspaces")

--- Required setup call with your custom configuration.
smw.setup({
    --- Number of workspaces assigned to each monitor.
    workspace_count = 5,

    --- Monitor priority order: determines which monitor gets the lowest workspace IDs.
    --- Monitors not listed are assigned priorities in the order Hyprland reports them.
    monitor_priority = { "DP-1", "DP-2" },

    --- Per-monitor workspace count overrides (optional).
    --- Monitors not listed fall back to workspace_count.
    -- max_workspaces = { ["DP-2"] = 3 }, -- DP-2 gets only 3 workspaces, DP-1 is not overridden and gets 5.

    --- Keep the currently focused workspace when the config is reloaded (recommended).
    keep_focused = true,

    --- Show a Hyprland notification on init and remap.
    enable_notifications = false,

    --- Keep workspaces alive even when empty.
    enable_persistent_workspaces = false,

    --- Wrap around when cycling past the first or last workspace.
    -- enable_wrapping = true,

    --- Switch all monitors simultaneously when changing workspaces (Gnome-style).
    link_monitors = false,
})

--- `get_amount_of_workspaces` is an easy helper function that simply returns the workspace_count you passed to the setup function.
local mainMod = "SUPER"
for i = 1, smw.get_amount_of_workspaces() do
    local n = tostring(i)
    if n == "10" then n = "0" end -- Optional if you configured 10 workspaces: bind workspace 10 to SUPER + 0
    -- Switch to the Nth workspace on the currently focused monitor.
    hl.bind(mainMod .. " +" .. n, smw.workspace(n))
    -- Move the active window to the Nth workspace on the currently focused monitor silently (no focus change).
    hl.bind(mainMod .. " + SHIFT +" .. n, smw.move_to_workspace_silent(n))
end

--- Cycle workspaces on the current monitor.
--- Accepts "next", "prev", "+N", or "-N" (e.g. "+2" skips two workspaces at once. why would you want to do that? idk but you can).
hl.bind(mainMod .. " + mouse_down", smw.cycle_workspaces("next"))
hl.bind(mainMod .. " + mouse_up", smw.cycle_workspaces("prev"))

--- Relative workspace switching using workspace().
--- "+N" / "-N" jump N workspaces forward/backward from the currently active one.
--- Wrapping behaviour follows the enable_wrapping config option.
hl.bind(mainMod .. " + PAGE_UP", smw.workspace("+1"))   -- Next workspace (relative).
hl.bind(mainMod .. " + PAGE_DOWN", smw.workspace("-1")) -- Previous workspace (relative).

--- "empty" workspace: switch to the first empty workspace on the current monitor.
--- It can also be used as an argument with move_to_workspace(_silent) to move windows to the first empty workspace on the monitor.
--- Falls back to the last workspace in the monitor's range if all are occupied.g





-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))


-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

