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