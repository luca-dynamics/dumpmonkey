extends CanvasLayer

signal start_requested(race: bool)
signal garage_requested
signal journey_requested
signal lesson_requested
signal skip_arrival_requested
signal skip_lesson_requested
signal retry_requested
signal resume_requested
signal menu_requested
signal mute_requested
signal motion_requested
signal ui_confirmed

const YELLOW := Color("f4ce31")
const PAPER := Color("f0f0e8")
const MUTED := Color("b0b9b5")
const INK := Color("11191ef0")
const DISPLAY_FONT = preload("res://assets/fonts/BarlowCondensed-ExtraBold.ttf")
const BODY_FONT = preload("res://assets/fonts/Barlow-Medium.ttf")
const Lesson = preload("res://modes/ride_lesson.gd")
var root: Control
var menu: PanelContainer
var garage: Control
var garage_section_title: Label
var garage_section_copy: Label
var garage_sound_button: Button
var garage_motion_button: Button
var menu_title: Label
var menu_racing: Label
var menu_chapter: Label
var menu_choices: HBoxContainer
var menu_options: HBoxContainer
var menu_hint: Label
var pause_panel: PanelContainer
var result_panel: PanelContainer
var invitation_panel: PanelContainer
var arrival: Control
var arrival_title: Label
var arrival_caption: Label
var lesson_panel: PanelContainer
var lesson_title: Label
var lesson_copy: Label
var lesson_keys: Label
var lesson_step: Label
var lesson_progress: ProgressBar
var speed_label: Label
var timer_label: Label
var checkpoint_label: Label
var stunt_label: Label
var toast_label: Label
var countdown_label: Label
var result_label: Label
var result_time: Label
var best_label: Label
var primary_button: Button
var motion_button: Button
var balance: ProgressBar
var telemetry: Control
var tips_panel: PanelContainer
var clock_panel: PanelContainer
var stunt_panel: PanelContainer
var mute_button: Button
var invitation_title: Label
var invitation_copy: Label
var reduced_motion: bool = false
var gamepad_prompts: bool = false
var _tweens: Dictionary = {}
var modal_scrim: ColorRect
var cinema_shutter: ColorRect


func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.theme = _theme()
	_build_menu()
	_build_garage()
	_build_telemetry()
	_build_arrival()
	_build_lesson()
	_build_overlays()
	get_viewport().size_changed.connect(_layout_menu)
	call_deferred("_layout_menu")


func _theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = BODY_FONT
	theme.default_font_size = 20
	theme.set_color("font_color", "Label", PAPER)
	for state in ["font_color", "font_hover_color", "font_focus_color"]:
		theme.set_color(state, "Button", PAPER if state == "font_color" else YELLOW)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("ffffff0a") if state != "normal" else Color.TRANSPARENT
		style.border_color = YELLOW
		style.border_width_left = 3 if state in ["hover", "focus"] else 0
		style.content_margin_left = 20
		style.content_margin_right = 20
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		theme.set_stylebox(state, "Button", style)
	for key in ["background", "fill"]:
		var style := StyleBoxFlat.new()
		style.bg_color = YELLOW if key == "fill" else Color("ffffff22")
		theme.set_stylebox(key, "ProgressBar", style)
	return theme


func _build_menu() -> void:
	var artwork := TextureRect.new()
	artwork.name = "TitleArtwork"
	artwork.texture = load("res://assets/art/onboarding-crew-yard-v2.png")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(artwork)
	var gradient := Gradient.new()
	gradient.set_color(0, Color("0c1218f2"))
	gradient.set_color(1, Color("0c121800"))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.1, 0)
	texture.fill_to = Vector2(0.72, 0)
	var veil := TextureRect.new()
	veil.name = "TitleVeil"
	veil.texture = texture
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(veil)
	menu = _panel(Vector2(490, 710), Vector2(0.055, 0.5), null, true)
	var box := _column(menu, 0, 9)
	_label(box, "DUMPMONKEYCREW PRESENTS", 17, YELLOW)
	menu_title = _label(box, "DUMP\nMONKEY", 102)
	menu_title.add_theme_constant_override("line_spacing", -27)
	menu_racing = _label(box, "RACING", 40, YELLOW)
	menu_chapter = _label(box, "CREW YARD  /  CHAPTER 01", 17, MUTED)
	_spacer(box, 12)
	primary_button = _button(box, "START RIDING     >", func(): journey_requested.emit(), true)
	_button(box, "OPEN CREW GARAGE", func(): garage_requested.emit())
	menu_choices = HBoxContainer.new()
	menu_choices.add_theme_constant_override("separation", 10)
	box.add_child(menu_choices)
	var trial := _button(menu_choices, "TIME TRIAL", func(): start_requested.emit(true))
	var free_ride := _button(menu_choices, "FREE RIDE", func(): start_requested.emit(false))
	for choice in [trial, free_ride]:
		choice.custom_minimum_size.x = 138
		choice.add_theme_font_size_override("font_size", 14)
	_button(box, "REPLAY RIDING INTRO", func(): lesson_requested.emit())
	best_label = _label(box, "", 16, MUTED)
	menu_options = HBoxContainer.new()
	menu_options.add_theme_constant_override("separation", 10)
	box.add_child(menu_options)
	mute_button = _button(menu_options, "SOUND ON", func(): mute_requested.emit())
	mute_button.add_theme_font_size_override("font_size", 15)
	motion_button = _button(menu_options, "REDUCED MOTION OFF", func(): motion_requested.emit())
	motion_button.add_theme_font_size_override("font_size", 15)
	menu_hint = _label(box, "SELECT  Enter / A     •     NAVIGATE  Arrows / D-pad", 14, MUTED)


func _layout_menu() -> void:
	if not is_instance_valid(menu):
		return
	var viewport_size := root.get_viewport_rect().size
	var compact := viewport_size.x < 760.0 or viewport_size.y < 620.0 or viewport_size.x / maxf(viewport_size.y, 1.0) < 1.25
	var width := minf(490.0, maxf(280.0, viewport_size.x - (48.0 if compact else 100.0)))
	var height := minf(710.0, maxf(420.0, viewport_size.y - (36.0 if compact else 80.0)))
	var left := 24.0 if compact else maxf(48.0, viewport_size.x * 0.055)
	menu.anchor_left = 0.0
	menu.anchor_right = 0.0
	menu.anchor_top = 0.5
	menu.anchor_bottom = 0.5
	menu.offset_left = left
	menu.offset_right = left + width
	menu.offset_top = -height * 0.5
	menu.offset_bottom = height * 0.5
	menu_title.add_theme_font_size_override("font_size", 68 if compact else 102)
	menu_title.add_theme_constant_override("line_spacing", -18 if compact else -27)
	menu_racing.add_theme_font_size_override("font_size", 31 if compact else 40)
	menu_chapter.add_theme_font_size_override("font_size", 13 if compact else 17)
	primary_button.add_theme_font_size_override("font_size", 20 if compact else 24)
	for choice in menu_choices.get_children():
		choice.add_theme_font_size_override("font_size", 16 if compact else 14)
		choice.custom_minimum_size.y = 44 if compact else 48
	for button in [mute_button, motion_button]:
		button.add_theme_font_size_override("font_size", 13 if compact else 15)
		button.custom_minimum_size.y = 40 if compact else 48
	best_label.add_theme_font_size_override("font_size", 14 if compact else 16)
	menu_hint.add_theme_font_size_override("font_size", 11 if compact else 14)


func _build_garage() -> void:
	garage = Control.new()
	garage.name = "Garage"
	garage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	garage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(garage)

	var artwork := TextureRect.new()
	artwork.name = "GarageArtwork"
	artwork.texture = load("res://assets/art/garage-tuning-v1.png")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	garage.add_child(artwork)

	var veil := ColorRect.new()
	veil.color = Color("05080dcc")
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	garage.add_child(veil)

	var left_fade := Gradient.new()
	left_fade.set_color(0, Color("05080df5"))
	left_fade.set_color(1, Color("05080d00"))
	var left_texture := GradientTexture2D.new()
	left_texture.gradient = left_fade
	left_texture.fill_from = Vector2(0, 0)
	left_texture.fill_to = Vector2(1, 0)
	var left_overlay := TextureRect.new()
	left_overlay.texture = left_texture
	left_overlay.anchor_right = 0.58
	left_overlay.anchor_bottom = 1
	left_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	garage.add_child(left_overlay)

	var heading := _label(garage, "CREW GARAGE", 34, PAPER)
	heading.position = Vector2(54, 38)
	var subheading := _label(garage, "YELLOWLINE MK I  /  STREET STUNT BUILD", 15, YELLOW)
	subheading.position = Vector2(57, 84)

	var navigation := _panel(Vector2(290, 610), Vector2(0.035, 0.5), garage, false)
	var nav_box := _column(navigation, 24, 5)
	_label(nav_box, "WORKSHOP", 15, MUTED)
	_button(nav_box, "BIKE TUNING", func(): _show_garage_section("BIKE TUNING"), true)
	_button(nav_box, "RIDER SETUP", func(): _show_garage_section("RIDER SETUP"))
	_button(nav_box, "SETTINGS", func(): _show_garage_section("SETTINGS"))
	_spacer(nav_box, 18)
	_label(nav_box, "CURRENT BUILD", 14, MUTED)
	_label(nav_box, "YELLOWLINE MK I", 25)
	_label(nav_box, "STREET / CLASS 01\nSTOCK CREW SPEC", 15, YELLOW)
	_spacer(nav_box, 12)
	_label(nav_box, "GARAGE OPTIONS", 14, MUTED)
	garage_sound_button = _button(nav_box, "SOUND ON", func(): mute_requested.emit())
	garage_sound_button.add_theme_font_size_override("font_size", 15)
	garage_motion_button = _button(nav_box, "REDUCED MOTION OFF", func(): motion_requested.emit())
	garage_motion_button.add_theme_font_size_override("font_size", 15)
	_button(nav_box, "BACK TO TITLE", func(): menu_requested.emit())

	var detail := _panel(Vector2(570, 540), Vector2(0.96, 0.56), garage, false)
	var detail_box := _column(detail, 28, 8)
	garage_section_title = _label(detail_box, "BIKE TUNING", 44)
	garage_section_copy = _label(detail_box, "Dial in the machine before you find your line.", 19, MUTED)
	_spacer(detail_box, 12)
	var specs := GridContainer.new()
	specs.columns = 2
	specs.add_theme_constant_override("h_separation", 30)
	specs.add_theme_constant_override("v_separation", 8)
	detail_box.add_child(specs)
	_spec_card(specs, "ENGINE", "82", "THROTTLE RESPONSE")
	_spec_card(specs, "GRIP", "74", "CORNER CONTROL")
	_spec_card(specs, "BALANCE", "68", "WHEELIE ASSIST")
	_spec_card(specs, "STYLE", "91", "CREW PRESENCE")
	_spacer(detail_box, 12)
	_label(detail_box, "EQUIPPED PARTS", 15, YELLOW)
	_label(detail_box, "EXHAUST  /  STREET FLOW        WHEELS  /  GRIP SET", 17)
	_label(detail_box, "BODYWORK  /  YELLOWLINE KIT  SUSPENSION  /  CREW SPEC", 17)
	_spacer(detail_box, 16)
	_button(detail_box, "RIDE THIS BUILD    >", func(): journey_requested.emit(), true)
	garage.hide()


func _spec_card(parent: Node, title: String, value: String, caption: String) -> void:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(230, 76)
	parent.add_child(card)
	_label(card, title, 14, MUTED)
	_label(card, value + "  /  100", 29, YELLOW)
	_label(card, caption, 13, MUTED)


func _show_garage_section(section: String) -> void:
	garage_section_title.text = section
	match section:
		"RIDER SETUP":
			garage_section_copy.text = "Set the rider silhouette, kit and stance for the next run."
		"SETTINGS":
			garage_section_copy.text = "Tune the presentation for your screen, sound and play style."
		_:
			garage_section_copy.text = "Dial in the machine before you find your line."


func _build_telemetry() -> void:
	telemetry = Control.new()
	telemetry.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	telemetry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(telemetry)
	var box := _column(_panel(Vector2(330, 100), Vector2(0.025, 0.025), telemetry), 14)
	_label(box, "CREW YARD / 01", 16, YELLOW)
	checkpoint_label = _label(box, "FREE RIDE", 27)
	clock_panel = _panel(Vector2(260, 100), Vector2(0.975, 0.025), telemetry)
	box = _column(clock_panel, 14)
	_label(box, "RUN TIME", 15, MUTED)
	timer_label = _label(box, "00:00.00", 34)
	box = _column(_panel(Vector2(210, 140), Vector2(0.975, 0.96), telemetry), 14, 0)
	speed_label = _label(box, "000", 68)
	_label(box, "KM/H  /  CREW SPEC", 14, YELLOW)
	tips_panel = _panel(Vector2(390, 90), Vector2(0.025, 0.96), telemetry)
	box = _column(tips_panel, 14)
	_label(box, "SPACE  wheelie    Q / E  balance", 17)
	_label(box, "R  respawn    ESC  pause    M  sound", 15, YELLOW)
	stunt_panel = _panel(Vector2(400, 100), Vector2(0.5, 0.96), telemetry)
	box = _column(stunt_panel, 12)
	stunt_label = _label(box, "LIFT IT. HOLD IT.", 28, YELLOW)
	balance = _progress(box, 350)
	balance.max_value = 1.12
	toast_label = _label(telemetry, "", 24, YELLOW)
	_center(toast_label, Vector2(0.5, 0), Vector2(700, 48), 132)
	countdown_label = _label(telemetry, "", 120, YELLOW)
	_center(countdown_label, Vector2(0.5, 0.5), Vector2(500, 170), -100)
	telemetry.hide()


func _build_arrival() -> void:
	arrival = Control.new()
	arrival.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arrival.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(arrival)
	for bottom in [false, true]:
		var bar := ColorRect.new()
		bar.color = Color("080c10")
		bar.anchor_right = 1
		bar.anchor_top = 1 if bottom else 0
		bar.anchor_bottom = bar.anchor_top
		bar.offset_top = -86 if bottom else 0
		bar.offset_bottom = 0 if bottom else 86
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arrival.add_child(bar)
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, 0.8))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	var caption_backdrop := TextureRect.new()
	caption_backdrop.texture = texture
	caption_backdrop.anchor_right = 1
	caption_backdrop.anchor_top = 1
	caption_backdrop.anchor_bottom = 1
	caption_backdrop.offset_top = -280
	caption_backdrop.offset_bottom = -86
	caption_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrival.add_child(caption_backdrop)
	cinema_shutter = ColorRect.new()
	cinema_shutter.color = Color(0, 0, 0, 0)
	cinema_shutter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cinema_shutter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrival.add_child(cinema_shutter)
	arrival_title = _label(arrival, "CREW YARD", 66)
	arrival_title.anchor_top = 1
	arrival_title.anchor_bottom = 1
	arrival_title.offset_left = 64
	arrival_title.offset_top = -220
	arrival_caption = _label(arrival, "HOME OF DUMPMONKEYCREW", 17, YELLOW)
	arrival_caption.anchor_top = 1
	arrival_caption.anchor_bottom = 1
	arrival_caption.offset_left = 67
	arrival_caption.offset_top = -140
	var skip := _button(arrival, "SKIP ARRIVAL  /  ENTER", func(): skip_arrival_requested.emit())
	skip.anchor_left = 1
	skip.anchor_right = 1
	skip.anchor_top = 1
	skip.anchor_bottom = 1
	skip.offset_left = -340
	skip.offset_right = -40
	skip.offset_top = -67
	skip.offset_bottom = -12
	arrival.hide()


func _build_lesson() -> void:
	lesson_panel = _panel(Vector2(540, 252), Vector2(0.035, 0.94))
	var box := _column(lesson_panel, 24, 6)
	lesson_step = _label(box, "FIRST RIDE   /   01 — 05", 16, YELLOW)
	lesson_title = _label(box, "FEEL THE THROTTLE", 40)
	lesson_copy = _label(box, "", 20)
	lesson_keys = _label(box, "", 19, YELLOW)
	lesson_progress = _progress(box, 480)
	var actions := HBoxContainer.new()
	box.add_child(actions)
	_label(actions, "R  retry this step", 15, MUTED)
	_button(actions, "SKIP LESSON", func(): skip_lesson_requested.emit()).add_theme_font_size_override("font_size", 15)
	lesson_panel.hide()


func _build_overlays() -> void:
	modal_scrim = ColorRect.new()
	modal_scrim.color = Color("080c1077")
	modal_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(modal_scrim)
	modal_scrim.hide()
	pause_panel = _panel(Vector2(470, 370), Vector2(0.5, 0.5))
	var box := _column(pause_panel, 30)
	_label(box, "TAKE A BREATHER", 44)
	_button(box, "RESUME", func(): resume_requested.emit(), true)
	_button(box, "RESTART", func(): retry_requested.emit())
	_button(box, "BACK TO TITLE", func(): menu_requested.emit())
	pause_panel.hide()
	result_panel = _panel(Vector2(560, 410), Vector2(0.5, 0.5))
	box = _column(result_panel, 32)
	_label(box, "CREW YARD / TIME TRIAL", 17, YELLOW)
	_label(box, "THAT’S YOUR LINE.", 48)
	result_time = _label(box, "00:00.00", 78)
	result_label = _label(box, "", 20, YELLOW)
	_button(box, "BEAT YOUR TIME    >", func(): retry_requested.emit(), true)
	_button(box, "BACK TO TITLE", func(): menu_requested.emit())
	result_panel.hide()
	invitation_panel = _panel(Vector2(590, 400), Vector2(0.5, 0.5))
	box = _column(invitation_panel, 32)
	_label(box, "YOUR FIRST RIDE", 17, YELLOW)
	invitation_title = _label(box, "YOU’RE IN THE CREW.", 52)
	invitation_copy = _label(box, "Five skills. One bike. Now make it a run.", 21)
	_button(box, "TAKE ON THE TIME TRIAL    >", func(): start_requested.emit(true), true)
	_button(box, "KEEP PRACTICING", func(): start_requested.emit(false))
	_button(box, "BACK TO TITLE", func(): menu_requested.emit())
	invitation_panel.hide()


func show_menu() -> void:
	_hide_overlays()
	menu.show()
	telemetry.hide()
	root.get_node("TitleArtwork").show()
	root.get_node("TitleVeil").show()
	_reveal(menu)
	primary_button.grab_focus()


func show_garage() -> void:
	_hide_overlays()
	menu.hide()
	root.get_node("TitleArtwork").hide()
	root.get_node("TitleVeil").hide()
	garage.show()
	_reveal(garage)
	_focus_first(garage)


func start_run() -> void:
	_hide_overlays()
	menu.hide()
	telemetry.show()
	clock_panel.show()
	tips_panel.show()
	stunt_panel.show()
	root.get_node("TitleArtwork").hide()
	root.get_node("TitleVeil").hide()


func show_arrival() -> void:
	start_run()
	telemetry.hide()
	arrival.show()
	_focus_first(arrival)


func show_lesson(step: int, progress_value: float, elapsed: float = 0.0) -> void:
	var changing: bool = not lesson_panel.visible or lesson_step.get_meta("step", -1) != step
	lesson_step.set_meta("step", step)
	lesson_panel.show()
	clock_panel.hide()
	tips_panel.hide()
	stunt_panel.hide()
	checkpoint_label.text = "FIRST RIDE"
	lesson_step.text = "FIRST RIDE   /   %02d — 05" % (step + 1)
	var keyboard: Array[String] = ["HOLD  W / UP ARROW", "HOLD  S / DOWN ARROW", "W + A / D  •  GENTLE INPUT", "W + SPACE  •  Q / E TO BALANCE", "RELEASE SPACE  •  TAP S TO LOWER"]
	var pad: Array[String] = ["HOLD  RIGHT TRIGGER", "HOLD  LEFT TRIGGER", "RIGHT TRIGGER + LEFT STICK", "RIGHT TRIGGER + A  •  RIGHT STICK TO BALANCE", "RELEASE A  •  LEFT TRIGGER TO LOWER"]
	var titles: Array[String] = ["FEEL THE THROTTLE", "FIND YOUR BRAKES", "CHOOSE YOUR LINE", "LIFT IT. HOLD IT.", "BRING IT HOME"]
	var copy: Array[String] = ["Build up to 15 km/h on the straight.", "Release the throttle and come to a stop.", "Roll forward and make a gentle turn.", "Hold a balanced wheelie for 1.2 seconds.", "Lower the front wheel while still rolling."]
	lesson_title.text = titles[step]
	lesson_copy.text = copy[step]
	if elapsed > 18 and step == Lesson.Step.WHEELIE:
		lesson_copy.text = "Get above 20 km/h, then hold the wheelie."
	lesson_keys.text = (pad if gamepad_prompts else keyboard)[step]
	lesson_progress.value = progress_value
	if changing:
		_reveal(lesson_panel)


func show_invitation(completed: bool) -> void:
	lesson_panel.hide()
	telemetry.hide()
	invitation_title.text = "YOU’RE IN THE CREW." if completed else "YOUR YARD AWAITS."
	invitation_copy.text = "Five skills. One bike. Now make it a run." if completed else "The riding lesson is always here when you want it."
	invitation_panel.show()
	_set_modal(invitation_panel)
	_reveal(invitation_panel)
	_focus_first(invitation_panel)


func set_paused(value: bool) -> void:
	pause_panel.visible = value
	if value:
		_set_modal(pause_panel)
		_reveal(pause_panel)
		_focus_first(pause_panel)
	else:
		_set_modal(null)
		root.get_viewport().gui_release_focus()


func show_result(text: String) -> void:
	var lines := text.split("\n", true, 1)
	result_time.text = lines[0]
	result_label.text = lines[1] if lines.size() > 1 else "Clean run. Ready to go faster?"
	result_panel.show()
	_set_modal(result_panel)
	_reveal(result_panel)
	_focus_first(result_panel)


func _hide_overlays() -> void:
	_set_modal(null)
	for control in [pause_panel, result_panel, arrival, lesson_panel, invitation_panel, garage]:
		control.hide()
		_stop_tween(control)
		control.modulate.a = 1.0


func _set_modal(panel: Control) -> void:
	modal_scrim.visible = panel != null
	for button: Button in root.find_children("*", "Button", true, false):
		button.disabled = panel != null and not panel.is_ancestor_of(button)


func _stop_tween(control: Control) -> void:
	var id := control.get_instance_id()
	if _tweens.has(id):
		var tween: Tween = _tweens[id]
		if tween.is_valid():
			tween.kill()
		_tweens.erase(id)


func _reveal(control: Control) -> void:
	_stop_tween(control)
	control.modulate.a = 1.0 if reduced_motion else 0.0
	if not reduced_motion:
		var tween := create_tween()
		tween.tween_property(control, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tweens[control.get_instance_id()] = tween


func _focus_first(panel: Node) -> void:
	var buttons := panel.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		buttons[0].grab_focus()


func _panel(dimensions: Vector2, anchor: Vector2, parent: Control = null, transparent: bool = false) -> PanelContainer:
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
	style.bg_color = Color.TRANSPARENT if transparent else INK
	style.border_color = YELLOW
	style.border_width_left = 0 if transparent else 2
	panel.add_theme_stylebox_override("panel", style)
	(root if parent == null else parent).add_child(panel)
	return panel


func _column(parent: Control, margin: int = 24, separation: int = 8) -> VBoxContainer:
	var padding := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		padding.add_theme_constant_override("margin_" + edge, margin)
	parent.add_child(padding)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", separation)
	padding.add_child(column)
	return column


func _label(parent: Node, text: String, font_size: int, color: Color = PAPER) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if font_size >= 27:
		label.add_theme_font_override("font", DISPLAY_FONT)
	if text in ["000", "00:00.00"]:
		var numeric := FontVariation.new()
		numeric.base_font = DISPLAY_FONT
		numeric.opentype_features = {"tnum": 1}
		label.add_theme_font_override("font", numeric)
	parent.add_child(label)
	return label


func _button(parent: Node, text: String, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size.y = 48
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if primary:
		for state in ["normal", "hover", "pressed", "focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = YELLOW if state != "pressed" else Color("c5a425")
			style.set_content_margin_all(18)
			style.border_color = PAPER
			style.set_border_width_all(2 if state in ["focus", "hover"] else 0)
			button.add_theme_stylebox_override(state, style)
		for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
			button.add_theme_color_override(state, Color("11191e"))
		button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(func():
		ui_confirmed.emit()
		callback.call()
	)
	parent.add_child(button)
	return button


func _progress(parent: Control, width: float) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(width, 5)
	bar.max_value = 1.0
	bar.show_percentage = false
	parent.add_child(bar)
	return bar


func _spacer(parent: Control, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	parent.add_child(spacer)


func _center(control: Label, anchor: Vector2, dimensions: Vector2, top: float) -> void:
	control.anchor_left = anchor.x
	control.anchor_right = anchor.x
	control.anchor_top = anchor.y
	control.anchor_bottom = anchor.y
	control.offset_left = -dimensions.x / 2
	control.offset_right = dimensions.x / 2
	control.offset_top = top
	control.offset_bottom = top + dimensions.y
	control.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
