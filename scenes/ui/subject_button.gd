extends Button


func set_color(col: Color) -> void:
	add_theme_color_override("icon_normal_color", col)
	add_theme_color_override("icon_focus_color", col.lightened(0.15))
	add_theme_color_override("icon_hover_color", col.lightened(0.25))
	add_theme_color_override("icon_pressed_color", col.darkened(0.25))
	add_theme_color_override("icon_hover_pressed_color", col.darkened(0.25))
