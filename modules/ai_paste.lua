-- ==========================================================
-- MODULE : AI PASTE (GÉOMÉTRIE SÉPARÉE MAC vs ACER)
-- ==========================================================

local authorizedAI = { ["Gemini"] = true, ["ChatGPT"] = true }
_G.captureTask = nil
_G.mouseWatcher = nil
_G.clipboardWatcher = nil

-- 1. NOTIFICATION
local function notifyCopy(message)
    local mainScreen = hs.screen.primaryScreen()
    local style = {
        strokeColor = {white = 1, alpha = 0.2},
        fillColor = {black = 1, alpha = 0.7},
        radius = 10,
        atScreenEdge = 2
    }
    hs.alert.show(message or "Copié", style, mainScreen, 1.5)
end

-- 2. FONCTION D'ENVOI (INTELLIGENCE DE L'ÉCRAN)
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
        
        -- Délai d'attente initial (Image vs Texte)
        local waitTime = isImage and 0.5 or 0.15

        hs.timer.doAfter(waitTime, function()
            local win = targetApp:mainWindow()
            if win then
                local f = win:frame()
                local currentScreen = win:screen()
                local primaryScreen = hs.screen.primaryScreen()
                
                -- === C'EST ICI QUE SE FAIT LA SÉPARATION ===
                local heightRatio
                
                if currentScreen == primaryScreen then
                    -- CAS 1 : C'EST L'ÉCRAN DU MAC (Principal)
                    -- On tape très bas (95%) car ça marchait bien pour lui
                    heightRatio = 0.95
                    -- hs.alert.show("Mode Mac") -- De-commente pour tester
                else
                    -- CAS 2 : C'EST L'ÉCRAN ACER (Secondaire)
                    -- On remonte la souris (85%) pour ne pas taper le bord
                    heightRatio = 0.90
                    -- hs.alert.show("Mode Acer") -- De-commente pour tester
                end

                -- Calcul du point de clic selon l'écran détecté
                local clickPoint = {
                    x = f.x + (f.w * 0.5), 
                    y = f.y + (f.h * heightRatio) 
                }
                
                -- Clic Focus
                hs.eventtap.leftClick(clickPoint)
                
                -- Collage (Délai de sécurité 0.2s)
                hs.timer.doAfter(0.2, function() 
                    hs.eventtap.keyStroke({"cmd"}, "v") 
                    
                    -- Entrée UNIQUEMENT pour le Texte (Pas pour l'image)
                    if not isImage then
                        hs.timer.doAfter(0.1, function()
                            hs.eventtap.keyStroke({}, "return")
                        end)
                    end
                end)
            end
        end)
    else
        hs.alert.show("❌ IA introuvable")
    end
end

-- 3. DÉCLENCHEUR SOURIS (Terminal)
_G.mouseWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(event)
    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == "com.apple.Terminal" then
        hs.eventtap.keyStroke({"cmd"}, "c")
    end
end)
_G.mouseWatcher:start()

-- 4. SURVEILLANT PRESSE-PAPIER
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
            notifyCopy("Texte Copié")
            sendToAI(false)
        end
    end
end)
_G.clipboardWatcher:start()

-- 5. CAPTURE D'ÉCRAN
hs.hotkey.bind({"alt"}, "s", function()
    _G.captureTask = hs.task.new("/usr/sbin/screencapture", function(exitCode)
        if exitCode == 0 then 
            hs.timer.doAfter(0.6, function()
                notifyCopy("Image Copiée")
                sendToAI(true) -- C'est une image
            end)
        end
    end, {"-c", "-i"}) 
    _G.captureTask:start()
end)