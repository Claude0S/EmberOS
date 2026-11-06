-- Ember OS mode: little (для слабых компьютеров)
hl.config({
    decoration = {
        blur = { enabled = false },
        shadow = { enabled = false },
        inactive_opacity = 1.0,
    },
})
hl.animation({ leaf = "windowsIn",   enabled = true,  speed = 2, bezier = "default" })
hl.animation({ leaf = "windowsOut",  enabled = true,  speed = 2, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true,  speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true,  speed = 2, bezier = "default", style = "fade" })
hl.animation({ leaf = "borderangle", enabled = false })
