-- ==========================================================
-- MODULE : AI PASTE (TOUT-TERRAIN + MODE MANUEL)
-- ==========================================================

-- Liste des applications PWA dédiées
local authorizedApps = { ["Gemini"] = true, ["ChatGPT"] = true }
-- Liste des navigateurs à scanner
local browsers = { ["Google Chrome"] = true, ["Arc"] = true, ["Brave Browser"] = true, ["Safari"] = true }

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

-- 2. FONCTION DE RECHERCHE (Appli ou Navigateur)
local function findAIWindow()
    -- orderedWindows renvoie les fenêtres de la plus récente à la plus ancienne
    -- C'est ce qui permet de trouver celle sur laquelle tu travailles en priorité
    local windows = hs.window.orderedWindows()
    
    for _, win in ipairs(windows) do
        local app = win:application()
        if app then
            local appName = app:name()
            local title = win:title() or ""
            
            -- CAS A : C'est une application officielle (PWA)
            if authorizedApps[appName] then
                return win
            end
            
            -- CAS B : C'est un navigateur (Chrome, etc.) et le titre contient l'IA
            if browsers[appName] then
                if string.find(title, "Gemini") or string.find(title, "ChatGPT") then
                    return win
                end
            end
        end
    end
    return nil
end

-- 3. FONCTION D'ENVOI
local function sendToAI(isImage)
    -- On cherche la fenêtre cible (PWA ou Navigateur)
    local targetWin = findAIWindow()

    if targetWin then
        targetWin:focus() -- On met la fenêtre au premier plan
        
        -- Délai d'attente initial (Image vs Texte)
        local waitTime = isImage and 0.5 or 0.15

        hs.timer.doAfter(waitTime, function()
            -- On revérifie que la fenêtre est toujours là
            if targetWin then
                local f = targetWin:frame()
                local currentScreen = targetWin:screen()
                local primaryScreen = hs.screen.primaryScreen()
                
                -- GÉOMÉTRIE (Basée sur ton code actuel : 0.90 partout)
                local heightRatio
                
                if currentScreen == primaryScreen then
                    -- Écran Principal (Mac)
                    heightRatio = 0.90
                else
                    -- Écran Secondaire (Acer)
                    heightRatio = 0.90
                end

                -- Calcul du point de clic
                local clickPoint = {
                    x = f.x + (f.w * 0.5), 
                    y = f.y + (f.h * heightRatio) 
                }
                
                -- Clic Focus
                hs.eventtap.leftClick(clickPoint)
                
                -- Collage (Cmd + V) uniquement
                hs.timer.doAfter(0.2, function() 
                    hs.eventtap.keyStroke({"cmd"}, "v") 
                    
                    -- NOTE : J'ai supprimé la touche "Entrée".
                    -- Le script s'arrête ici, te laissant la main pour valider.
                end)
            end
        end)
    else
        hs.alert.show("❌ IA introuvable (Ouvrez Gemini ou ChatGPT)")
    end
end

-- 4. DÉCLENCHEUR SOURIS (Terminal)
_G.mouseWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(event)
    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == "com.apple.Terminal" then
        hs.eventtap.keyStroke({"cmd"}, "c")
    end
end)
_G.mouseWatcher:start()

-- 5. SURVEILLANT PRESSE-PAPIER
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

-- 6. CAPTURE D'ÉCRAN
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