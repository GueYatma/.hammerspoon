-- ==========================================================
-- MODULE : AI PASTE (VITESSE + AUTO-SEND + NOTIF DISCRÈTE)
-- ==========================================================

local authorizedAI = { ["Gemini"] = true, ["ChatGPT"] = true }
_G.captureTask = nil
_G.mouseWatcher = nil
_G.clipboardWatcher = nil

-- 1. NOTIFICATION DISCRÈTE (En bas à droite)
local function notifyCopy()
    local mainScreen = hs.screen.primaryScreen()
    local screenFrame = mainScreen:fullFrame()
    
    -- Style du badge : petit, sombre, semi-transparent
    local style = {
        strokeColor = {white = 1, alpha = 0.2},
        fillColor = {black = 1, alpha = 0.7},
        radius = 10,
        atScreenEdge = 2 -- En bas à droite
    }
    
    hs.alert.show("Sélection copiée", style, mainScreen, 1.5)
end

-- 2. FONCTION D'ENVOI (Optimisée et plus rapide)
local function sendToAI()
    local windows = hs.window.orderedWindows()
    local targetApp = nil

    for _, win in ipairs(windows) do
        local app = win:application()
        if app and authorizedAI[app:name()] then
            targetApp = app
            break
        end
    end

    if targetApp then
        targetApp:activate()
        -- Délai divisé par deux (0.15s)
        hs.timer.doAfter(0.15, function()
            local win = targetApp:mainWindow()
            if win then
                local f = win:frame()
                -- Clic zone de texte
                hs.eventtap.leftClick({ x = f.x + (f.w / 2), y = f.y + (f.h - 100) })
                
                -- Collage ultra-rapide
                hs.timer.doAfter(0.05, function() 
                    hs.eventtap.keyStroke({"cmd"}, "v") 
                    -- AUTO-SEND : On appuie sur Entrée
                    hs.timer.doAfter(0.05, function()
                        hs.eventtap.keyStroke({}, "return")
                    end)
                end)
            end
        end)
    end
end

-- 3. DÉCLENCHEUR SOURIS (Terminal Apple)
_G.mouseWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(event)
    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == "com.apple.Terminal" then
        hs.eventtap.keyStroke({"cmd"}, "c")
    end
end)
_G.mouseWatcher:start()

-- 4. SURVEILLANT DISCRET
local lastCount = hs.pasteboard.changeCount()

_G.clipboardWatcher = hs.pasteboard.watcher.new(function()
    local currentCount = hs.pasteboard.changeCount()
    if currentCount == lastCount then return end
    lastCount = currentCount

    local app = hs.application.frontmostApplication()
    if not app then return end
    local id = app:bundleID()

    if (id == "com.googlecode.iterm2" or id == "com.apple.Terminal") then
        if hs.pasteboard.readString() then
            notifyCopy() -- Nouvelle notification discrète
            sendToAI()
        end
    end
end)
_G.clipboardWatcher:start()

-- 5. CAPTURE D'ÉCRAN (Alt + S)
hs.hotkey.bind({"alt"}, "s", function()
    _G.captureTask = hs.task.new("/usr/sbin/screencapture", function(exitCode)
        if exitCode == 0 then sendToAI() end
    end, {"-c", "-i"}) 
    _G.captureTask:start()
end)

hs.alert.show("✅ AI Paste : Turbo Mode")