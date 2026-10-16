extends CanvasLayer

signal start_requested(race: bool)
signal retry_requested
signal resume_requested
signal menu_requested
signal mute_requested

const YELLOW := Color("f4ce31")
const PAPER := Color("eeeede")
const INK := Color("11191eea")
var root: Control
var menu: PanelContainer
var pause_panel: PanelContainer
var result_panel: PanelContainer
var speed_label: Label
var timer_label: Label
var checkpoint_label: Label
var stunt_label: Label
var toast_label: Label
var countdown_label: Label
var result_label: Label
var best_label: Label
var balance: ProgressBar
var telemetry: Control
var mute_button: Button


func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 18
	theme.set_color("font_color", "Label", PAPER)
	theme.set_color("font_color", "Button", PAPER)
	theme.set_color("font_hover_color", "Button", YELLOW)
	theme.set_color("font_focus_color", "Button", YELLOW)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("273036") if state == "normal" else Color("3b4549")
		style.border_color = YELLOW if state == "focus" else Color("56615d")
		style.set_border_width_all(2 if state == "focus" else 1)
		style.content_margin_left = 22
		style.content_margin_right = 22
		style.content_margin_top = 14
		style.content_margin_bottom = 14
		theme.set_stylebox(state, "Button", style)
	root.theme = theme
	_build_menu()
	_build_telemetry()
	pause_panel = _panel(Vector2(430, 360), Vector2(0.5, 0.5))
	var pause_box := _column(pause_panel)
	_label(pause_box, "TAKE A BREATHER", 30, YELLOW)
	_button(pause_box, "RESUME", func(): resume_requested.emit())
	_button(pause_box, "RESTART RUN", func(): retry_requested.emit())
	_button(pause_box, "BACK TO YARD", func(): menu_requested.emit())
	pause_panel.hide()
	result_panel = _panel(Vector2(480, 380), Vector2(0.5, 0.5))
	var result_box := _column(result_panel)
	_label(result_box, "RUN COMPLETE", 32, YELLOW)
	result_label = _label(result_box, "", 27)
	_button(result_box, "RUN IT AGAIN", func(): retry_requested.emit())
	_button(result_box, "BACK TO YARD", func(): menu_requested.emit())
	result_panel.hide()


func _build_menu() -> void:
	# Game stays live behind the menu. Illustration becomes a title backdrop when available.
	if ResourceLoader.exists("res://assets/art/title-crew-yard.png"):
		var artwork := TextureRect.new()
		artwork.name = "TitleArtwork"
		artwork.texture = load("res://assets/art/title-crew-yard.png")
		artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(artwork)
	menu = _panel(Vector2(490, 620), Vector2(0.05, 0.5))
	var column := _column(menu)
	_label(column, "DUMPMONKEYCREW  /  RACING", 16, YELLOW)
	_label(column, "OWN THE\nSTREETS.", 64)
	_label(column, "CREW YARD  /  01", 24, YELLOW)
	_label(column, "Find your line. Lift the front.\nMake the next run yours.", 19)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	column.add_child(spacer)
	_button(column, "TIME TRIAL     →", func(): start_requested.emit(true))
	_button(column, "FREE RIDE      →", func(): start_requested.emit(false))
	best_label = _label(column, "", 16)
	_label(column, "W / ↑  throttle     S / ↓  brake\nA D / ← →  steer     SPACE  wheelie\nQ / E  lower / raise balance\nR  respawn     ESC  pause", 16)
	mute_button = _button(column, "SOUND ON", func(): mute_requested.emit())


func _build_telemetry() -> void:
	telemetry = Control.new()
	telemetry.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	telemetry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(telemetry)
	var header := _panel(Vector2(330, 104), Vector2(0.025, 0.025), telemetry)
	var header_box := _column(header, 14)
	_label(header_box, "CREW YARD / 01", 17, YELLOW)
	checkpoint_label = _label(header_box, "FREE RIDE", 23)
	var clock := _panel(Vector2(270, 104), Vector2(0.975, 0.025), telemetry)
	var clock_box := _column(clock, 14)
	_label(clock_box, "RUN TIME", 15, YELLOW)
	timer_label = _label(clock_box, "00:00.00", 32)
	var speed_panel := _panel(Vector2(240, 145), Vector2(0.975, 0.96), telemetry)
	var speed_box := _column(speed_panel, 14)
	speed_label = _label(speed_box, "000", 58)
	_label(speed_box, "KM/H    /    CREW SPEC", 14, YELLOW)
	var tips := _panel(Vector2(410, 100), Vector2(0.025, 0.96), telemetry)
	var tips_box := _column(tips, 14)
	_label(tips_box, "SPACE  wheelie    Q / E  balance", 17)
	_label(tips_box, "R  respawn    ESC  pause    M  sound", 15, YELLOW)
	var stunt_panel := _panel(Vector2(420, 110), Vector2(0.5, 0.96), telemetry)
	var stunt_box := _column(stunt_panel, 12)
	stunt_label = _label(stunt_box, "LIFT IT. HOLD IT.", 24, YELLOW)
	balance = ProgressBar.new()
	balance.custom_minimum_size = Vector2(350, 12)
	balance.max_value = 1.12
	balance.show_percentage = false
	stunt_box.add_child(balance)
	toast_label = _label(telemetry, "", 23, YELLOW)
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast_label.offset_left = -290
	toast_label.offset_right = 290
	toast_label.offset_top = 145
	toast_label.offset_bottom = 185
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label = _label(telemetry, "", 100, YELLOW)
	countdown_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	countdown_label.offset_left = -200
	countdown_label.offset_right = 200
	countdown_label.offset_top = -100
	countdown_label.offset_bottom = 40
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	telemetry.hide()


func show_menu() -> void:
	menu.show()
	telemetry.hide()
	pause_panel.hide()
	result_panel.hide()
	if root.has_node("TitleArtwork"):
		root.get_node("TitleArtwork").show()
	_focus_first(menu)


func start_run() -> void:
	menu.hide()
	pause_panel.hide()
	result_panel.hide()
	telemetry.show()
	if root.has_node("TitleArtwork"):
		root.get_node("TitleArtwork").hide()


func set_paused(value: bool) -> void:
	pause_panel.visible = value
	if value:
		_focus_first(pause_panel)


func show_result(text: String) -> void:
	result_label.text = text
	result_panel.show()
	_focus_first(result_panel)


func _focus_first(panel: Node) -> void:
	var buttons := panel.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		buttons[0].grab_focus()


func _panel(dimensions: Vector2, anchor: Vector2, parent: Control = null) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.anchor_left = anchor.x
	panel.anchor_right = anchor.x
	panel.anchor_top = anchor.y
	panel.anchor_bottom = anchor.y
	var factor := Vector2(0.0 if anchor.x < 0.25 else (1.0 if anchor.x > 0.75 else 0.5), 0.0 if anchor.y < 0.25 else (1.0 if anchor.y > 0.75 else 0.5))
	panel.offset_left = -dimensions.x * factor.x
	panel.offset_top = -dimensions.y * factor.y
	panel.offset_right = dimensions.x * (1.0 - factor.x)
	panel.offset_bottom = dimensions.y * (1.0 - factor.y)
	var style := StyleBoxFlat.new()
	style.bg_color = INK
	style.border_color = Color("647064")
	style.border_width_top = 2
	panel.add_theme_stylebox_override("panel", style)
	(root if parent == null else parent).add_child(panel)
	return panel


func _column(parent: Control, margin: int = 24) -> VBoxContainer:
	var padding := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		padding.add_theme_constant_override("margin_" + edge, margin)
	parent.add_child(padding)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	padding.add_child(column)
	return column


func _label(parent: Node, text: String, font_size: int, color: Color = PAPER) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size.y = 48
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
