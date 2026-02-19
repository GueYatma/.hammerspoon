-- ==========================================================
-- MODULE : DASHBOARD (PLAN DE VOL)
-- ==========================================================

local dashboardCanvases = nil
local dashboardClickWatcher = nil
local dashboardKeyWatcher = nil
local dashboardMouseWatcher = nil
local dashboardArmed = false

local function closeDashboard()
    if dashboardClickWatcher then
        dashboardClickWatcher:stop()
        dashboardClickWatcher = nil
    end
    if dashboardKeyWatcher then
        dashboardKeyWatcher:stop()
        dashboardKeyWatcher = nil
    end
    if dashboardMouseWatcher then
        dashboardMouseWatcher:stop()
        dashboardMouseWatcher = nil
    end
    dashboardArmed = false

    if dashboardCanvases then
        for _, canvas in ipairs(dashboardCanvases) do
            canvas:delete()
        end
        dashboardCanvases = nil
    end
end

local function pointInFrame(point, frame)
    return point.x >= frame.x
        and point.x <= (frame.x + frame.w)
        and point.y >= frame.y
        and point.y <= (frame.y + frame.h)
end

local function buildDashboardCanvas(screen)
    local frame = screen:frame()

    local panelWidth = math.min(490, frame.w * 0.60)
    local panelHeight = 700
    local panelX = frame.x + (frame.w - panelWidth) / 2
    local panelY = frame.y + (frame.h - panelHeight) / 2

    local canvas = hs.canvas.new({x = panelX, y = panelY, w = panelWidth, h = panelHeight})

    -- Fond
    canvas[1] = { type = "rectangle", action = "fill", fillColor = { white = 0, alpha = 1.0 }, roundedRectRadii = { xRadius = 22, yRadius = 22 } }
    canvas[2] = { type = "rectangle", action = "stroke", strokeColor = { white = 1, alpha = 0.15 }, strokeWidth = 1, roundedRectRadii = { xRadius = 20, yRadius = 20 } }

    -- Titre
    canvas[3] = { type = "text", text = "PLAN DE VOL", textColor = { white = 1, alpha = 0.9 }, textSize = 22, textAlignment = "center", frame = { x = "0%", y = "3%", w = "100%", h = "10%" } }

    local startY = 72
    local rowHeight = 36

    local leftMargin = 18
    local rightMargin = 14
    local numW = 64
    local rightW = 128
    local dashW = 70
    local gap = 4
    local numX = leftMargin
    local rightX = panelWidth - rightMargin - rightW
    local nameX = numX + numW + gap
    local nameW = rightX - gap - nameX

    for i = 1, 16 do
        -- On utilise la variable GLOBALE _G.desktops
        local data = _G.desktops[i] 
        local shortcutText = ""
        local nameText = "LIBRE"
        local nameColor = { white = 0.7, alpha = 0.9 }

        if data then
            if data.name and data.name ~= "" then nameText = data.name end
            if data.color then nameColor = data.color end
        end

        if i <= 8 then shortcutText = "CTRL+PAD" .. i
        elseif i == 9 then shortcutText = "CTRL+PAD9"
        elseif i == 10 then shortcutText = "CTRL+PAD0"
        else shortcutText = "CTRL+SHIFT+PAD" .. (i - 10) end
        
        local yPos = startY + ((i-1) * rowHeight)

        canvas[#canvas + 1] = { type = "text", text = tostring(i), textColor = nameColor, textSize = 18, textAlignment = "center", frame = { x = numX, y = yPos, w = numW, h = rowHeight } }
        canvas[#canvas + 1] = { type = "text", text = nameText, textColor = nameColor, textSize = 14, textAlignment = "left", frame = { x = nameX, y = yPos, w = nameW, h = rowHeight } }
        local dashX = rightX - dashW - 6
        canvas[#canvas + 1] = {
            type = "text",
            text = "----------",
            textColor = { red = nameColor.red or 1, green = nameColor.green or 1, blue = nameColor.blue or 1, alpha = 0.55 },
            textSize = 14,
            textAlignment = "center",
            textFont = "Helvetica-Bold",
            frame = { x = dashX, y = yPos, w = dashW, h = rowHeight }
        }
        canvas[#canvas + 1] = { type = "text", text = shortcutText, textColor = nameColor, textSize = 12, textAlignment = "right", frame = { x = rightX, y = yPos, w = rightW, h = rowHeight } }
        
        -- Pas de séparateurs : le surlignage sert de repère
    end

    return canvas
end

local function toggleDashboard()
    if dashboardCanvases then
        closeDashboard()
        return
    end

    dashboardCanvases = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        table.insert(dashboardCanvases, buildDashboardCanvas(screen))
    end

    for _, canvas in ipairs(dashboardCanvases) do
        canvas:show()
    end

    dashboardArmed = false
    hs.timer.doAfter(0.2, function()
        dashboardArmed = true
    end)

    dashboardClickWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function()
        if not dashboardArmed then return false end
        local pos = hs.mouse.absolutePosition()
        local clickedInside = false

        if dashboardCanvases then
            for _, canvas in ipairs(dashboardCanvases) do
                if pointInFrame(pos, canvas:frame()) then
                    clickedInside = true
                    break
                end
            end
        end

        if not clickedInside then
            closeDashboard()
        end

        return false
    end)
    dashboardClickWatcher:start()

    dashboardKeyWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function()
        if not dashboardArmed then return false end
        closeDashboard()
        return false
    end)
    dashboardKeyWatcher:start()

    dashboardMouseWatcher = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function()
        if not dashboardArmed then return false end
        closeDashboard()
        return false
    end)
    dashboardMouseWatcher:start()
end

hs.hotkey.bind({"ctrl", "shift"}, "pad0", toggleDashboard)
