local util = require("img-clip.util")

local M = {}

---@return string | nil
M.get_clip_cmd = function()
  -- Linux (X11)
  if os.getenv("DISPLAY") then
    if util.executable("xclip") then
      return "xclip"
    else
      util.error("Dependency check failed. 'xclip' is not installed.")
      return nil
    end

  -- Linux (Wayland)
  elseif os.getenv("WAYLAND_DISPLAY") then
    if util.executable("wl-paste") then
      return "wl-paste"
    else
      util.error("Dependency check failed. 'wl-clipboard' is not installed.")
      return nil
    end

  -- MacOS
  elseif util.has("mac") then
    if util.executable("osascript") then
      return "osascript"
    else
      util.error("Dependency check failed. 'osascript' is not installed.")
      return nil
    end

  -- Windows
  elseif util.has("win32") or util.has("wsl") then
    if util.executable("powershell.exe") then
      return "powershell.exe"
    else
      util.error("Dependency check failed. 'powershell.exe' is not installed.")
      return nil
    end

  -- Other OS
  else
    util.error("Operating system is not supported.")
    return nil
  end
end

---@param cmd string
---@return boolean
M.check_if_content_is_image = function(cmd)
  -- Linux (X11)
  if cmd == "xclip" then
    local output = util.execute("xclip -selection clipboard -t TARGETS -o")
    if not output then
      return false
    end
    return string.find(output, "image/png") ~= nil

  -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    -- TODO: Implement clipboard check for Wayland
    return false

  -- MacOS
  elseif cmd == "osascript" then
    local output = util.execute("osascript -e 'clipboard info'")
    if not output then
      return false
    end
    return string.find(output, "class PNGf") ~= nil

  -- Windows
  elseif cmd == "powershell.exe" then
    -- TODO: Implement clipboard check for Windows
    return false
  end

  return false
end

---@param cmd string
---@param file_path string
---@return boolean
M.save_clipboard_image = function(cmd, file_path)
  -- Linux (X11)
  if cmd == "xclip" then
    local command = string.format('xclip -selection clipboard -o -t image/png > "%s"', file_path)
    local exit_code = os.execute(command)
    return exit_code == 0

  -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    -- TODO: Implement clipboard write for Wayland
    return false

  -- MacOS
  elseif cmd == "osascript" then
    local command = string.format(
      "osascript -e 'set theFile to (open for access POSIX file \"%s\" with write permission)' -e 'try' -e 'write (the clipboard as «class PNGf») to theFile' -e 'end try' -e 'close access theFile' > /dev/null 2>&1",
      file_path
    )
    local exit_code = os.execute(command)
    return exit_code == 0

  -- Windows
  elseif cmd == "powershell.exe" then
    -- TODO: Implement clipboard write for Windows
    return false
  end

  return false
end

return M
