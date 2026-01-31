-- ==========================================================
-- INIT.LUA - LE CHEF D'ORCHESTRE
-- ==========================================================

hs.alert.show("Hammerspoon : Chargement...")

-- 1. Outils Système (Reload, Caffeinate...)
require("modules.system")

-- 2. Gestion des Fenêtres (Moitiés, Tiers...)
require("modules.windows")

-- 3. Raccourcis d'Applications (Finder, Terminal...)
require("modules.shortcuts")

-- 4. Gestion des Bureaux & GPS
require("modules.desktops")

-- 5. Dashboard (Désactivé pour l'instant) modifs pour gth
require("modules.dashboard")

-- 6. Intelligence Artificielle (Le fameux ai_paste)
require("modules.ai_paste")  -- <--- CORRECTION ICI (un seul "modules")

hs.alert.show("✅ Hammerspoon : Tout est chargé !")