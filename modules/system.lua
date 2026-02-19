-- ==========================================================
-- MODULE : SYSTÈME & NAVIGATION
-- ==========================================================

-- 1. Reload Config (Ctrl + Alt + R)
hs.hotkey.bind({"ctrl", "alt"}, "R", function()
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
local reloadStampKey = "koktek_auto_reload_pending"

local function showReloadStamp()
    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()

    local width = 240
    local height = 70
    local margin = 24

    local x = frame.x + frame.w - width - margin
    local y = frame.y + margin

    local canvas = hs.canvas.new({x = x, y = y, w = width, h = height})
    canvas:level(hs.canvas.windowLevels.status)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    local stroke = {red = 0.2, green = 0.8, blue = 0.4, alpha = 0.95}
    local i = 1

    -- Ombre légère pour l'effet flottant
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = {white = 0, alpha = 0.28},
        roundedRectRadii = {xRadius = 12, yRadius = 12},
        frame = {x = 3, y = 3, w = width - 3, h = height - 3}
    }
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = {white = 0.05, alpha = 0.9},
        roundedRectRadii = {xRadius = 12, yRadius = 12}
    }
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "stroke",
        strokeColor = stroke,
        strokeWidth = 3,
        roundedRectRadii = {xRadius = 12, yRadius = 12}
    }
    -- Stamp "OK" à gauche
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = stroke,
        roundedRectRadii = {xRadius = 7, yRadius = 7},
        frame = {x = "5%", y = "22%", w = "14%", h = "56%"}
    }
    i = i + 1
    canvas[i] = {
        type = "text",
        text = "OK",
        textColor = {white = 0, alpha = 0.85},
        textSize = 13,
        textAlignment = "center",
        frame = {x = "5%", y = "28%", w = "14%", h = "44%"}
    }
    i = i + 1
    canvas[i] = {
        type = "text",
        text = "Reload OK",
        textColor = {white = 1, alpha = 0.95},
        textSize = 14,
        textAlignment = "left",
        frame = {x = "24%", y = "26%", w = "70%", h = "48%"}
    }

    canvas:show()
    hs.timer.doAfter(2.0, function() canvas:delete() end)
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
