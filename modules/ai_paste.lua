-- ==========================================================
-- MODULE : AI PASTE (LA MÉTHODE DU "JUGE DE PAIX")
-- Fichier : modules/ai_paste.lua
-- ==========================================================

local authorizedAI = { ["Gemini"] = true, ["ChatGPT"] = true }
_G.captureTask = nil
_G.mouseWatcher = nil
_G.clipboardWatcher = nil -- On désactive l'ancien watcher sourd

-- MÉMOIRE : On retient le "numéro de série" du dernier copier-coller
local last_paste_count = hs.pasteboard.changeCount()

-- 1. FONCTION D'ENVOI
local function sendToAI()
    local app = nil
    for _, win in ipairs(hs.window.orderedWindows()) do
        if win:application() and authorizedAI[win:application():name()] then
            app = win:application()
            break
        end
    end

    if app then
        app:activate()
        hs.timer.doAfter(0.3, function()
            local win = app:mainWindow() or app:allWindows()[1]
            if win then
                local f = win:frame()
                -- Clic pour focus
                hs.eventtap.leftClick({ x = f.x + (f.w / 2), y = f.y + (f.h - 100) })
                -- Collage
                hs.timer.doAfter(0.1, function() 
                    hs.eventtap.keyStroke({"cmd"}, "v") 
                end)
            end
        end)
    else
        hs.alert.show("❌ IA introuvable")
    end
end

-- 2. DÉCLENCHEUR SOURIS + JUGE DE PAIX
_G.mouseWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(event)
    local app = hs.application.frontmostApplication()
    if not app then return end
    local id = app:bundleID()

    -- On surveille iTerm2 ET Terminal
    if (id == "com.googlecode.iterm2" or id == "com.apple.Terminal") then
        
        -- A. Si c'est Terminal Apple, on aide un peu (car il ne copie pas seul)
        if id == "com.apple.Terminal" then
             -- Astuce : On ne force PAS Cmd+C ici pour éviter les boucles.
             -- L'utilisateur doit faire Cmd+C manuellement sur Apple Terminal.
             -- OU ALORS, on accepte que sur Apple Terminal, c'est manuel.
        end

        -- B. VERIFICATION CHIRURGICALE (On attend 0.4s que la copie se fasse)
        hs.timer.doAfter(0.4, function()
            local current_count = hs.pasteboard.changeCount()
            
            -- LE TEST ULTIME :
            -- Est-ce que le compteur a changé depuis la dernière fois ?
            if current_count > last_paste_count then
                
                -- OUI : Ça veut dire que tu as vraiment sélectionné du nouveau texte.
                last_paste_count = current_count -- On met à jour la mémoire
                hs.alert.show("🚀 Envoi -> IA")
                sendToAI()
                
            else
                -- NON : Le compteur est le même. 
                -- Ça veut dire que tu as juste cliqué dans le vide ou désélectionné.
                -- ON NE FAIT RIEN. SILENCE ABSOLU.
            end
        end)
    end
end)
_G.mouseWatcher:start()

-- 3. CAPTURE D'ÉCRAN (Toujours là, fidèle au poste)
hs.hotkey.bind({"alt"}, "s", function()
    _G.captureTask = hs.task.new("/usr/sbin/screencapture", function(exitCode)
        if exitCode == 0 then sendToAI() end
    end, {"-c", "-i"}) 
    _G.captureTask:start()
end)

-- 4. BOUTON DE SECOURS (Option + V)
-- Si jamais l'automatisme échoue, tu fais ça et ça force l'envoi.
hs.hotkey.bind({"alt"}, "v", function()
    hs.alert.show("🛟 Envoi Forcé")
    sendToAI()
end)

hs.alert.show("✅ AI Paste : Mode Juge de Paix")