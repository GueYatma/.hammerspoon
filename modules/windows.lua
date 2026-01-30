-- ==========================================================
-- MODULE : INTELLIGENCE DES FENÊTRES
-- ==========================================================

-- Fonction utilitaire : Le "Rayon Tracteur V2"
-- Déclarée en GLOBALE (_G) pour être utilisée partout
function _G.moveWindowToActiveScreen(win)
    if win then
        local targetScreen = hs.screen.mainScreen()
        win:moveToScreen(targetScreen)
        win:focus()
    end
end

-- Fonction d'ouverture intelligente
function _G.openNewWindow(appName)
    -- Cas 1 : Google Chrome
    if appName == "Google Chrome" then
        hs.execute("open -na 'Google Chrome' --args --new-window")
    
    -- Cas 2 : Finder
    elseif appName == "Finder" then
        hs.execute("open ~")
        hs.timer.doAfter(0.3, function()
            local app = hs.application.get("Finder")
            if app then _G.moveWindowToActiveScreen(app:mainWindow()) end
        end)
    
    -- Cas 3 : Terminal & iTerm
    elseif appName == "Terminal" or appName == "iTerm" then
        hs.execute("open -n -a '" .. appName .. "'")
        hs.timer.doAfter(0.3, function()
            local app = hs.application.get(appName)
            if app then _G.moveWindowToActiveScreen(app:mainWindow()) end
        end)
        
    -- Cas 4 : VS Code
    elseif appName == "Visual Studio Code" then
        local app = hs.application.get("Visual Studio Code")
        if app then
            app:activate()
            hs.timer.doAfter(0.1, function()
                hs.eventtap.keyStroke({"cmd", "shift"}, "n")
                hs.timer.doAfter(0.5, function()
                    local win = app:mainWindow()
                    _G.moveWindowToActiveScreen(win)
                end)
            end)
        else
            hs.application.launchOrFocus("Visual Studio Code")
            hs.timer.doAfter(2.0, function()
                local app = hs.application.get("Visual Studio Code")
                if app then _G.moveWindowToActiveScreen(app:mainWindow()) end
            end)
        end
        
    -- Cas 5 : Paperless-ngx
    elseif appName == "Paperless-ngx" then
        hs.application.launchOrFocus(appName) 
        hs.timer.doAfter(0.5, function()
            local app = hs.application.get(appName)
            if app then _G.moveWindowToActiveScreen(app:mainWindow()) end
        end)

    -- Cas 6 : Les autres applications
    else
        local app = hs.application.get(appName)
        if app then
            app:activate()
            hs.timer.doAfter(0.1, function()
                hs.eventtap.keyStroke({"cmd"}, "n")
                hs.timer.doAfter(0.3, function()
                    _G.moveWindowToActiveScreen(app:mainWindow())
                end)
            end)
        else
            hs.application.launchOrFocus(appName)
            hs.timer.doAfter(0.5, function()
                local app = hs.application.get(appName)
                if app then _G.moveWindowToActiveScreen(app:mainWindow()) end
            end)
        end
    end
end