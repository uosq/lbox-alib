local settings = {
	font = 0, --- useless doesnt work idk why
	window = {
		background = { 40, 40, 40, 255 },
		outline = { enabled = true, thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { enabled = true, offset = 3, color = { 0, 0, 0, 200 } },
		title = {
			height = 20,
			background = { 50, 131, 168, 255 },
			text_color = { 255, 255, 255, 255 },
			text_shadow = false,
			fade = { enabled = false, horizontal = true, alpha_start = 255, alpha_end = 20 }
		}
	},
	button = {
		background = { 102, 255, 255, 255 },
		selected = { 150, 255, 150, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { text = true, offset = 2, color = { 0, 0, 0, 200 } },
		text_color = { 255, 255, 255, 255 },
		round = false,
	},
	checkbox = {
		background = { 20, 20, 20, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		checked_color = { 150, 255, 150, 255 },
		not_checked_color = { 255, 150, 150, 255 },
		shadow = { offset = 2, color = { 0, 0, 0, 200 } },
	},
	slider = {
		background = { 20, 20, 20, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		bar_color = { 102, 255, 255, 255 },
		bar_outlined = false,
		shadow = { offset = 2, color = { 0, 0, 0, 200 } },
	},
	list = {
		background = { 20, 20, 20, 255 },
		selected = { 102, 255, 255, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { offset = 3, color = { 0, 0, 0, 200 } },
		item_height = 20,
		text_color = { 255, 255, 255, 255 },
	},
}

return settings
