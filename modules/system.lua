-- ==========================================================
-- MODULE : SYSTÈME & NAVIGATION
-- ==========================================================

local reloadStampKey = "koktek_auto_reload_pending"

-- 1. Reload Config (Ctrl + Alt + R)
hs.hotkey.bind({"ctrl", "alt"}, "R", function()
  hs.settings.set(reloadStampKey, true)
  hs.reload()
end)

-- 2. Verrouillage écran (Ctrl + Alt + L)
hs.hotkey.bind({"ctrl", "alt"}, "L", function()
    hs.caffeinate.lockScreen()
end)

-- 3. Saut de Souris entre écrans (Ctrl + Alt + Espace)
hs.hotkey.bind({"ctrl", "alt"}, "space", function()
    local screen = hs.mouse.getCurrentScreen()
    local nextScreen = screen:next()
    local rect = nextScreen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    hs.mouse.absolutePosition(center)
    hs.alert.show("Focus : " .. nextScreen:name())
end)

-- ==========================================================
-- CORRECTIF : Simuler Shift pour avoir le point
-- ==========================================================
hs.hotkey.bind({}, "pad,", function()
    -- On simule Shift + la touche du pavé
    hs.eventtap.keyStroke({"shift"}, "pad,")
end)

-- ==========================================================
-- LE RÉVEIL-MATIN iTERM (Mode Ninja)
-- Raccourci Utilisateur : CTRL + ESPACE
-- Raccourci Secret iTerm : CTRL + SHIFT + ESPACE
-- ==========================================================
hs.hotkey.bind({"ctrl"}, "space", function()
    local app = hs.application.get("iTerm2")
    
    if app then
        -- iTerm est là : On envoie le raccourci secret (Ctrl + Shift + Space)
        hs.eventtap.keyStroke({"ctrl", "shift"}, "space")
    else
        -- iTerm dort : On le lance
        hs.application.launchOrFocus("iTerm2")
        
        -- On attend qu'il soit prêt et on déclenche
        hs.timer.doAfter(0.5, function()
            hs.eventtap.keyStroke({"ctrl", "shift"}, "space")
        end)
    end
end)

-- ==========================================================
-- AUTO-RELOAD HAMMERSPOON SUR CHANGEMENT DE FICHIER
-- ==========================================================
local function showReloadStamp()
    if _G.reloadStampTimer then
        _G.reloadStampTimer:stop()
        _G.reloadStampTimer = nil
    end
    if _G.reloadStampCanvas then
        _G.reloadStampCanvas:delete()
        _G.reloadStampCanvas = nil
    end

    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()

    local width = 260
    local height = 64
    local margin = 24

    local x = frame.x + frame.w - width - margin
    local y = frame.y + margin

    local canvas = hs.canvas.new({x = x, y = y, w = width, h = height})
    canvas:level(hs.canvas.windowLevels.status)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    _G.reloadStampCanvas = canvas

    local fill = {red = 0.98, green = 0.86, blue = 0.72, alpha = 0.98}
    local textColor = {white = 0.1, alpha = 0.9}
    local i = 1
    local closeRect = {x = width - 34, y = 8, w = 24, h = 24}

    -- Ombre légère pour l'effet flottant
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = {white = 0, alpha = 0.22},
        roundedRectRadii = {xRadius = 24, yRadius = 24},
        frame = {x = 3, y = 3, w = width - 3, h = height - 3}
    }
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = fill,
        roundedRectRadii = {xRadius = 24, yRadius = 24}
    }
    i = i + 1
    canvas[i] = {
        type = "text",
        text = "Hammerspoon rechargé",
        textColor = textColor,
        textSize = 14,
        textAlignment = "left",
        frame = {x = "8%", y = "24%", w = "78%", h = "52%"}
    }

    -- Bouton fermer
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = {white = 1, alpha = 0.0},
        roundedRectRadii = {xRadius = 6, yRadius = 6},
        frame = closeRect
    }
    i = i + 1
    canvas[i] = {
        type = "text",
        text = "×",
        textColor = {white = 0.15, alpha = 0.55},
        textSize = 14,
        textAlignment = "center",
        frame = closeRect
    }

    canvas:show()

    local function dismiss()
        if canvas then
            canvas:delete()
            canvas = nil
        end
    end

    canvas:mouseCallback(function(_, msg, _, xPos, yPos)
        if msg == "mouseUp" then
            if xPos >= closeRect.x and xPos <= (closeRect.x + closeRect.w)
                and yPos >= closeRect.y and yPos <= (closeRect.y + closeRect.h) then
                dismiss()
            end
        end
    end)

    _G.reloadStampTimer = hs.timer.doAfter(3.5, dismiss)
end

if hs.settings.get(reloadStampKey) then
    hs.settings.clear(reloadStampKey)
    showReloadStamp()
end

local function reloadConfig(files)
    local shouldReload = false
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            shouldReload = true
            break
        end
    end

    if shouldReload then
        if _G.autoReloadTimer then _G.autoReloadTimer:stop() end
        _G.autoReloadTimer = hs.timer.doAfter(0.8, function()
            hs.settings.set(reloadStampKey, true)
            hs.reload()
        end)
    end
end

if _G.configFileWatcher then _G.configFileWatcher:stop() end
_G.configFileWatcher = hs.pathwatcher.new(hs.configdir, reloadConfig)
_G.configFileWatcher:start()
