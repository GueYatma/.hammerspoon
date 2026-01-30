-- ==========================================================
-- MODULE : DASHBOARD (PLAN DE VOL)
-- ==========================================================

local dashboardCanvas = nil

local function toggleDashboard()
    if dashboardCanvas then
        dashboardCanvas:delete()
        dashboardCanvas = nil
        return
    end

    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()

    local panelWidth = 380
    local panelHeight = 620
    local panelX = frame.x + 90 
    local panelY = frame.y + (frame.h - panelHeight) / 2

    dashboardCanvas = hs.canvas.new({x=panelX, y=panelY, w=panelWidth, h=panelHeight})

    -- Fond
    dashboardCanvas[1] = { type = "rectangle", action = "fill", fillColor = { white = 0.1, alpha = 0.95 }, roundedRectRadii = { xRadius = 20, yRadius = 20 } }
    dashboardCanvas[2] = { type = "rectangle", action = "stroke", strokeColor = { white = 1, alpha = 0.15 }, strokeWidth = 1, roundedRectRadii = { xRadius = 20, yRadius = 20 } }

    -- Titre
    dashboardCanvas[3] = { type = "text", text = "PLAN DE VOL", textColor = { white = 1, alpha = 0.9 }, textSize = 20, textAlignment = "center", frame = { x = "0%", y = "3%", w = "100%", h = "10%" } }

    local startY = 60
    local rowHeight = 32

    for i = 1, 16 do
        -- On utilise la variable GLOBALE _G.desktops
        local data = _G.desktops[i] 
        local shortcutText = ""
        local nameText = "LIBRE"
        local nameColor = { white = 0.4, alpha = 1 }

        if data then
            if data.name and data.name ~= "" then nameText = data.name end
            if data.color then nameColor = data.color end
        end

        if i <= 9 then shortcutText = "CTRL + " .. i
        elseif i == 10 then shortcutText = "CTRL + 0"
        else shortcutText = "CTRL + SHIFT + " .. (i - 10) end
        
        local yPos = startY + ((i-1) * rowHeight)

        dashboardCanvas[#dashboardCanvas + 1] = { type = "text", text = shortcutText, textColor = { white = 0.5, alpha = 1 }, textSize = 13, textAlignment = "right", frame = { x = "2%", y = yPos, w = "35%", h = "100%" } }
        dashboardCanvas[#dashboardCanvas + 1] = { type = "text", text = nameText, textColor = nameColor, textSize = 14, textAlignment = "left", frame = { x = "40%", y = yPos, w = "42%", h = "100%" } }
        dashboardCanvas[#dashboardCanvas + 1] = { type = "text", text = "BUR. " .. i, textColor = { white = 1, alpha = 0.15 }, textSize = 12, textAlignment = "right", frame = { x = "82%", y = yPos + 1, w = "12%", h = "100%" } }
        
        if i < 16 then
             dashboardCanvas[#dashboardCanvas + 1] = { type = "segments", coordinates = { { x = "10%", y = yPos + 26 }, { x = "90%", y = yPos + 26 } }, strokeColor = { white = 1, alpha = 0.03 }, strokeWidth = 1 }
        end
    end

    dashboardCanvas:show()
    hs.timer.doAfter(6, function() if dashboardCanvas then dashboardCanvas:delete() dashboardCanvas = nil end end)
end

hs.hotkey.bind({"ctrl", "shift"}, "pad0", toggleDashboard)