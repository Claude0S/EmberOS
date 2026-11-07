-- Ember OS theme: {{name}} (генерується командою /theme — не редагуй вручну)
hl.config({
    general = {
        col = {
            active_border   = { colors = { "rgba({{accent}}ee)", "rgba({{accent3}}ee)" }, angle = 45 },
            inactive_border = "rgba({{surface}}66)",
        },
    },
    misc = { background_color = 0xff{{bg}} },
})

-- кольори для заголовків вікон (hyprbars)
ember_colors = { bg = "{{bg}}", fg = "{{fg}}", surface = "{{surface}}", accent = "{{accent}}" }
