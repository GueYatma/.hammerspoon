-- ==========================================================
-- MODULE : GESTION DES BUREAUX (VERSION STABLE & PROPRE)
-- Fichier : modules/desktops.lua
-- ==========================================================

-- Variables de mémoire GPS
local currentLeftDesktop = 1
local currentRightDesktop = 9

-- Gestionnaires pour les alertes (Nettoyage propre)
local leftAlertID = nil
local rightAlertID = nil
local leftTimer = nil
local rightTimer = nil

-- TABLE DES BUREAUX (Noms et Couleurs)
_G.desktops = {
    -- === ÉCRAN GAUCHE (1 à 8) ===
    [1]  = { name = "e-Mail",                 color = {red=0.2, green=0.6, blue=1, alpha=0.95} },
    [2]  = { name = "N8N",                    color = {red=0.5, green=0.0, blue=0.5, alpha=0.95} },
    [3]  = { name = "Directus",               color = {red=1, green=0.4, blue=0.6, alpha=0.95} },
    [4]  = { name = "Postgre Admin",          color = {red=0.2, green=0.8, blue=0.2, alpha=0.95} },
    [5]  = { name = "Terminaux",              color = {red=1, green=0.8, blue=0.0, alpha=0.95} },
    [6]  = { name = "GitHub",                 color = {red=0.0, green=0.8, blue=0.8, alpha=0.95} },
    [7]  = { name = "Hostinger",              color = {red=0.9, green=0.3, blue=0.2, alpha=0.95} },
    [8]  = { name = "Anti-Gravity (Google)", color = {red=0.45, green=0.25, blue=0.95, alpha=0.95} },

    -- === ÉCRAN DROITE (9 à 16) ===
    [9]  = { name = "VS Code — koktek",       color = {red=1, green=0.5, blue=0.0, alpha=0.95} },
    [10] = { name = "koktek localhost/vps",   color = {red=0.3, green=0.3, blue=0.9, alpha=0.95} },
    [15] = { name = "VS Code — Hammerspoon", color = {red=0.15, green=0.55, blue=0.95, alpha=0.95} },
    [16] = { name = "Draft",                 color = {red=0.85, green=0.2, blue=0.5, alpha=0.95} }
}

local function getScreens()
    local allScreens = hs.screen.allScreens()
    table.sort(allScreens, function(a, b) return a:frame().x < b:frame().x end)
    return { left = allScreens[1], right = allScreens[2] or allScreens[1] }
end

-- Fonction pour nettoyer les anciens badges immédiatement
local function clearScreen(targetScreen, screens)
    if targetScreen == screens.left then
        if leftTimer then leftTimer:stop() end
        if leftAlertID then hs.alert.closeSpecific(leftAlertID) end
    else
        if rightTimer then rightTimer:stop() end
        if rightAlertID then hs.alert.closeSpecific(rightAlertID) end
    end
end

-- Affiche le Badge (Standard 2 secondes)
local function displayBadge(index, targetScreen)
    local screens = getScreens()
    
    -- On nettoie avant d'afficher
    clearScreen(targetScreen, screens)

    local data = _G.desktops[index]
    local displayName = "BUREAU " .. index
    local displayColor = {white=0.1, alpha=0.9}

    if data then
        if data.name and data.name ~= "" then displayName = data.name end
        if data.color then displayColor = data.color end
    end

    local newAlert = hs.alert.show(displayName, {
        fillColor   = displayColor,
        strokeColor = {white=1, alpha=0.3},
        strokeWidth = 2,
        textColor   = {white=1, alpha=1},
        textSize    = 80,
        radius      = 40,
        fadeInDuration  = 0.1,
        fadeOutDuration = 0.3,
        duration    = 2, 
        atScreenEdge = 0
    }, targetScreen)
    
    if targetScreen == screens.left then leftAlertID = newAlert
    else rightAlertID = newAlert end
end

-- Navigation via Pavé Numérique (Directe)
local function gotoSpaceByIndex(index)
    if not (hs.spaces and hs.spaces.spacesForScreen) then return false end

    local screens = getScreens()
    local targetScreen = (index <= 8) and screens.left or screens.right
    local spaces = hs.spaces.spacesForScreen(targetScreen)
    if not spaces or #spaces == 0 then return false end

    local pos = (index <= 8) and index or (index - 8)
    local spaceID = spaces[pos]
    if not spaceID then return false end

    if hs.spaces.gotoSpace then
        hs.spaces.gotoSpace(spaceID)
        return true
    end

    if hs.spaces.changeToSpace then
        hs.spaces.changeToSpace(spaceID)
        return true
    end

    return false
end

local function switchToDesktop(index)
    local screens = getScreens()
    local targetScreen = (index <= 8) and screens.left or screens.right
    
    -- Nettoyage immédiat pour réactivité
    clearScreen(targetScreen, screens)

    if index <= 8 then currentLeftDesktop = index else currentRightDesktop = index end

    local switched = gotoSpaceByIndex(index)
    if not switched then
        -- Fallback clavier si l'API Spaces n'est pas dispo
        if index <= 8 then
            hs.eventtap.keyStroke({"ctrl"}, tostring(index))
        elseif index == 9 then
            hs.eventtap.keyStroke({"ctrl"}, "9")
        elseif index == 10 then
            hs.eventtap.keyStroke({"ctrl"}, "0")
        else
            hs.eventtap.keyStroke({"ctrl", "shift"}, tostring(index - 10))
        end
    end

    -- Affichage
    local t = hs.timer.doAfter(0.5, function() displayBadge(index, targetScreen) end)
    if index <= 8 then leftTimer = t else rightTimer = t end
end

local function showDualGPS()
    hs.alert.closeAll()
    local screens = getScreens()
    if screens.left then displayBadge(currentLeftDesktop, screens.left) end
    if screens.right and screens.right ~= screens.left then displayBadge(currentRightDesktop, screens.right) end
end

-- ==========================================================
-- ESPION PASSIF (Le truc qui marche bien !)
-- ==========================================================

local function updateGPSMemory(direction)
    local mouseScreen = hs.mouse.getCurrentScreen()
    local screens = getScreens()
    
    local isLeft = (mouseScreen:id() == screens.left:id())
    local targetScreen = isLeft and screens.left or screens.right
    
    -- Nettoyage immédiat
    clearScreen(targetScreen, screens)
    
    if isLeft then
        local newIndex = currentLeftDesktop + direction
        if newIndex < 1 then newIndex = 1 end
        if newIndex > 8 then newIndex = 8 end
        currentLeftDesktop = newIndex
        leftTimer = hs.timer.doAfter(0.2, function() displayBadge(currentLeftDesktop, screens.left) end)
    else
        local newIndex = currentRightDesktop + direction
        if newIndex < 9 then newIndex = 9 end
        if newIndex > 16 then newIndex = 16 end
        currentRightDesktop = newIndex
        rightTimer = hs.timer.doAfter(0.2, function() displayBadge(currentRightDesktop, screens.right) end)
    end
end

-- WATCHER DES FLÈCHES (Uniquement pour le GPS, plus de souris Mission Control)
if _G.arrowWatcher then _G.arrowWatcher:stop() end
_G.arrowWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local keyCode = event:getKeyCode()
    local flags = event:getFlags()
    
    if flags.ctrl then
        if keyCode == 123 then -- FLÈCHE GAUCHE
            updateGPSMemory(-1)
            return false -- Laisse passer l'ordre à macOS
        elseif keyCode == 124 then -- FLÈCHE DROITE
            updateGPSMemory(1)
            return false -- Laisse passer l'ordre à macOS
        elseif keyCode == 126 then -- FLÈCHE HAUT (Mission Control)
            return false -- On ne fait RIEN, on laisse macOS gérer
        end
    end
    return false
end):start()

-- RACCOURCIS (PAVÉ NUMÉRIQUE)
for i = 1, 8 do hs.hotkey.bind({"ctrl"}, "pad" .. i, function() switchToDesktop(i) end) end
hs.hotkey.bind({"ctrl"}, "pad9", function() switchToDesktop(9) end)
hs.hotkey.bind({"ctrl"}, "pad0", function() switchToDesktop(10) end)
for i = 1, 6 do hs.hotkey.bind({"ctrl", "shift"}, "pad" .. i, function() switchToDesktop(i + 10) end) end
hs.hotkey.bind({"ctrl", "alt"}, "pad0", showDualGPS)
