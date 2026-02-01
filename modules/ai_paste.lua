-- ==========================================================
-- MODULE : AI PASTE (SMART MODE : Rapide Texte / Stable Image)
-- ==========================================================

local authorizedAI = { ["Gemini"] = true, ["ChatGPT"] = true }
_G.captureTask = nil
_G.mouseWatcher = nil
_G.clipboardWatcher = nil

-- 1. NOTIFICATION DISCRÈTE (Ta version personnalisée)
local function notifyCopy(message)
    local mainScreen = hs.screen.primaryScreen()
    
    local style = {
        strokeColor = {white = 1, alpha = 0.2},
        fillColor = {black = 1, alpha = 0.7},
        radius = 10,
        atScreenEdge = 2 -- En bas à droite
    }
    
    hs.alert.show(message or "Sélection copiée", style, mainScreen, 1.5)
end

-- 2. FONCTION D'ENVOI INTELLIGENTE
-- On ajoute un paramètre 'isImage' pour savoir si on doit ralentir
local function sendToAI(isImage)
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
        
        -- LE SECRET : Si c'est une image, on attend 0.6s. Si c'est du texte, 0.15s (Turbo)
        local waitTime = isImage and 0.6 or 0.15

        hs.timer.doAfter(waitTime, function()
            local win = targetApp:mainWindow()
            if win then
                local f = win:frame()
                -- Clic zone de texte
                hs.eventtap.leftClick({ x = f.x + (f.w / 2), y = f.y + (f.h - 100) })
                
                -- Collage
                hs.timer.doAfter(0.1, function() 
                    hs.eventtap.keyStroke({"cmd"}, "v") 
                    
                    -- Si Image : on attend un peu plus avant de faire Entrée (upload)
                    local enterDelay = isImage and 0.8 or 0.05
                    hs.timer.doAfter(enterDelay, function()
                        hs.eventtap.keyStroke({}, "return")
                    end)
                end)
            end
        end)
    else
        hs.alert.show("❌ IA introuvable")
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

-- 4. SURVEILLANT DISCRET (iTerm2 & Terminal)
local lastCount = hs.pasteboard.changeCount()

_G.clipboardWatcher = hs.pasteboard.watcher.new(function()
    local currentCount = hs.pasteboard.changeCount()
    if currentCount == lastCount then return end
    lastCount = currentCount

    local app = hs.application.frontmostApplication()
    if not app then return end
    local id = app:bundleID()

    -- On vérifie ici que c'est du TEXTE
    if (id == "com.googlecode.iterm2" or id == "com.apple.Terminal") then
        if hs.pasteboard.readString() then
            notifyCopy("Texte Copié")
            sendToAI(false) -- false = "Ce n'est pas une image, fonce !"
        end
    end
end)
_G.clipboardWatcher:start()

-- 5. CAPTURE D'ÉCRAN (Alt + S)
hs.hotkey.bind({"alt"}, "s", function()
    _G.captureTask = hs.task.new("/usr/sbin/screencapture", function(exitCode)
        if exitCode == 0 then 
            -- On force une petite pause pour laisser l'outil de capture disparaître
            hs.timer.doAfter(0.5, function()
                notifyCopy("Image Copiée")
                sendToAI(true) -- true = "Attention c'est une image, prends ton temps"
            end)
        end
    end, {"-c", "-i"}) 
    _G.captureTask:start()
end)

hs.alert.show("✅ AI Paste : Fix Image")