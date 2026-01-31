-- ==========================================================
-- MODULE : RACCOURCIS APPS (Alt + Lettre)
-- ==========================================================

-- WEB
hs.hotkey.bind({"alt"}, "C", function() _G.openNewWindow("Google Chrome") end)
hs.hotkey.bind({"alt"}, "G", function() _G.openNewWindow("Gemini") end)
hs.hotkey.bind({"alt"}, "D", function() hs.urlevent.openURL("https://docs.google.com/") end)
hs.hotkey.bind({"alt"}, "X", function() _G.openNewWindow("Paperless-ngx") end)
hs.hotkey.bind({"alt"}, "I", function() _G.openNewWindow("ChatGPT") end)

-- DEV & TOOLS
hs.hotkey.bind({"alt"}, "V", function() _G.openNewWindow("Visual Studio Code") end)
hs.hotkey.bind({"alt"}, "T", function() _G.openNewWindow("Terminal") end)
hs.hotkey.bind({"alt"}, "O", function() _G.openNewWindow("Obsidian") end)
hs.hotkey.bind({"alt"}, "F", function() _G.openNewWindow("Finder") end)
hs.hotkey.bind({"alt"}, "P", function() _G.openNewWindow("Preview") end)

-- COMMS
hs.hotkey.bind({"alt"}, "E", function() _G.openNewWindow("Mail") end)
hs.hotkey.bind({"alt"}, "W", function() _G.openNewWindow("WhatsApp") end)
hs.hotkey.bind({"alt"}, "N", function() _G.openNewWindow("Notes") end)
hs.hotkey.bind({"alt"}, "A", function() _G.openNewWindow("Calendar") end)
hs.hotkey.bind({"alt"}, "1", function() _G.openNewWindow("FirstSeed Calendar") end)