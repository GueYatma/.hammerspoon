-- ==========================================================
-- MODULE : GIT PUSH (KOKTEK)
-- ==========================================================

local repoPath = hs.configdir
local defaultPrefix = "maintenance:"

local function buildCommitMessage(prefix)
    local dateStamp = os.date("%d/%m/%Y %H:%M")
    return string.format("%s sauvegarde automatique du %s", prefix, dateStamp)
end

local function showStamp(message, accentColor, subMessage)
    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()

    local width = 380
    local height = 90
    local margin = 24

    local x = frame.x + frame.w - width - margin
    local y = frame.y + margin

    local canvas = hs.canvas.new({x = x, y = y, w = width, h = height})
    canvas:level(hs.canvas.windowLevels.status)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    local stroke = accentColor or {red = 0.2, green = 0.8, blue = 0.4, alpha = 0.95}

    local i = 1
    -- Ombre légère pour l'effet flottant
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = {white = 0, alpha = 0.28},
        roundedRectRadii = {xRadius = 14, yRadius = 14},
        frame = {x = 3, y = 3, w = width - 3, h = height - 3}
    }
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = {white = 0.05, alpha = 0.9},
        roundedRectRadii = {xRadius = 14, yRadius = 14}
    }
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "stroke",
        strokeColor = stroke,
        strokeWidth = 3,
        roundedRectRadii = {xRadius = 14, yRadius = 14}
    }
    -- Stamp "OK" à gauche
    i = i + 1
    canvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = stroke,
        roundedRectRadii = {xRadius = 8, yRadius = 8},
        frame = {x = "4%", y = "24%", w = "12%", h = "52%"}
    }
    i = i + 1
    canvas[i] = {
        type = "text",
        text = "OK",
        textColor = {white = 0, alpha = 0.85},
        textSize = 14,
        textAlignment = "center",
        frame = {x = "4%", y = "30%", w = "12%", h = "40%"}
    }
    i = i + 1
    canvas[i] = {
        type = "text",
        text = message,
        textColor = {white = 1, alpha = 0.95},
        textSize = 15,
        textAlignment = "left",
        frame = {x = "20%", y = "22%", w = "76%", h = "40%"}
    }
    if subMessage then
        i = i + 1
        canvas[i] = {
            type = "text",
            text = subMessage,
            textColor = {white = 0.85, alpha = 0.85},
            textSize = 11,
            textAlignment = "left",
            frame = {x = "20%", y = "56%", w = "76%", h = "30%"}
        }
    end

    canvas:show()
    hs.timer.doAfter(2.6, function() canvas:delete() end)
end

local function runGit(args, callback)
    local fullArgs = {"-C", repoPath}
    for _, arg in ipairs(args) do
        table.insert(fullArgs, arg)
    end

    local task = hs.task.new("/usr/bin/git", function(exitCode, stdOut, stdErr)
        if callback then callback(exitCode, stdOut or "", stdErr or "") end
    end, fullArgs)

    task:start()
end

local function isStatusClean(output)
    return output:gsub("%s+", "") == ""
end

function _G.pushHammerspoon(prefixOverride)
    local prefix = prefixOverride or defaultPrefix
    local commitMessage = buildCommitMessage(prefix)

    runGit({"status", "--porcelain"}, function(code, out, err)
        if code ~= 0 then
            showStamp("Erreur git status", {red = 0.9, green = 0.2, blue = 0.2, alpha = 0.95})
            return
        end

        if isStatusClean(out) then
            showStamp("Rien a pousser", {white = 0.6, alpha = 0.9})
            return
        end

        runGit({"add", "-A"}, function(addCode)
            if addCode ~= 0 then
                showStamp("Erreur git add", {red = 0.9, green = 0.2, blue = 0.2, alpha = 0.95})
                return
            end

            runGit({"commit", "-m", commitMessage}, function(commitCode, commitOut, commitErr)
                if commitCode ~= 0 then
                    if (commitOut .. commitErr):find("nothing to commit") then
                        showStamp("Rien a pousser", {white = 0.6, alpha = 0.9})
                    else
                        showStamp("Erreur git commit", {red = 0.9, green = 0.2, blue = 0.2, alpha = 0.95})
                    end
                    return
                end

                runGit({"push"}, function(pushCode)
                    if pushCode == 0 then
                        showStamp("Code bien pousse sur GitHub !", {red = 0.2, green = 0.8, blue = 0.4, alpha = 0.95}, "Reload Hammerspoon en cours")
                        hs.timer.doAfter(0.8, function()
                            hs.reload()
                        end)
                    else
                        showStamp("Erreur git push", {red = 0.9, green = 0.2, blue = 0.2, alpha = 0.95})
                    end
                end)
            end)
        end)
    end)
end

hs.hotkey.bind({"ctrl", "alt"}, "P", function()
    _G.pushHammerspoon()
end)
