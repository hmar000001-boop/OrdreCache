extends Control

const SAVE_PATH := "user://ordre_cache_save.cfg"
const SYMBOLS := ["sun", "rain", "moon", "wind"]
const GODOT_VERSION := "4.4.1"

const TEXT := {
	"fr": {
		"subtitle": "LE MONDE N'EXPLIQUE RIEN. IL RÉPOND.", "start": "ENTRER DANS LE JARDIN", "continue": "CONTINUER L'EXPLORATION", "trial": "OBSERVER", "reset": "Recommencer l'essai", "journal": "CARNET DES LOIS", "hint": "Indice discret", "back": "Retour", "language": "Langue", "level": "ÉPREUVE", "progress": "LOIS OBSERVÉES", "experiment": "Choisis un signe, puis observe sa réaction.", "locked": "La suite attend tes découvertes.", "home_intro": "Un lieu oublié. Des symboles muets. Des lois que personne ne t'expliquera.", "home_cta": "Chaque essai est une question. Chaque réaction est un indice.", "result": "La matière a changé.", "no_change": "Le signe répond, mais rien ne change. Cette absence est aussi une observation.", "sun": "SOLEIL", "rain": "PLUIE", "moon": "LUNE", "wind": "VENT", "seed": "graine", "sprout": "pousse", "sapling": "jeune plante", "bloom": "fleur ouverte", "carried": "graine emportée", "bud": "bouton fermé", "stone_cold": "pierre froide", "stone_warm": "pierre tiède", "stone_marked": "pierre marquée", "stone_open": "pierre entrouverte", "rule_sun": "La chaleur du soleil réveille la graine.", "rule_rain": "La pluie fait grandir la pousse.", "rule_moon": "La lune ouvre ce qui a grandi.", "rule_wind": "Le vent déplace ce qui est léger.", "rule_stone_sun": "Le soleil réchauffe la pierre froide.", "rule_stone_moon": "La lumière lunaire révèle une marque cachée.", "rule_stone_wind": "Le vent écarte les bords de la pierre marquée.", "p1_title": "La graine silencieuse", "p1_desc": "Une graine repose dans la poussière. Rien ne semble attendre, pourtant elle n'est pas morte.", "p2_title": "La terre assoiffée", "p2_desc": "Une pousse tremble au bord d'un sol sec. Elle a déjà changé une fois. Que lui manque-t-il ?", "p3_title": "La première floraison", "p3_desc": "La plante a grandi, mais son bouton reste fermé. La lumière du jour n'est plus là.", "p4_title": "Le saut du pollen", "p4_desc": "Une graine est isolée sur une dalle. La marque gravée au sol ressemble à un courant d'air.", "p5_title": "La pierre qui rêve", "p5_desc": "Une pierre obstrue le passage. Trois signes gravés autour d'elle semblent former une phrase.", "p6_title": "L'ordre caché", "p6_desc": "Une dernière graine. Aucun indice nouveau. Ce que tu sais déjà suffit peut-être.", "success": "LOI CONFIRMÉE", "next": "Continuer", "finish_title": "Le jardin se souvient", "finish_desc": "Tu n'as pas reçu les lois. Tu les as reconstruites. Au-delà des murs, d'autres lieux attendent des esprits curieux.", "restart": "Rejouer le jardin", "observed": "observée", "notebook_empty": "Aucune loi consignée pour l'instant. Essaie, observe, recommence.", "hint1": "Regarde la nature de l'objet et le symbole qui pourrait l'influencer.", "hint2": "Une loi déjà observée peut s'appliquer à un nouvel objet.", "hint3": "L'ordre compte : un état peut être la conséquence d'un essai précédent.", "notice": "Pas de pénalité. Le monde ne juge pas tes essais.", "menu": "JARDIN IMMOBILE", "chapter": "CHAPITRE I · JARDIN IMMOBILE"
	},
	"en": {
		"subtitle": "THE WORLD DOESN'T EXPLAIN. IT RESPONDS.", "start": "ENTER THE GARDEN", "continue": "CONTINUE EXPLORING", "trial": "OBSERVE", "reset": "Reset experiment", "journal": "NOTEBOOK OF LAWS", "hint": "A subtle hint", "back": "Back", "language": "Language", "level": "TRIAL", "progress": "OBSERVED LAWS", "experiment": "Choose a sign, then observe its reaction.", "locked": "The path ahead waits for your discoveries.", "home_intro": "A forgotten place. Silent symbols. Laws no one will explain.", "home_cta": "Every trial is a question. Every reaction is a clue.", "result": "The matter has changed.", "no_change": "The sign responds, but nothing changes. That absence is also an observation.", "sun": "SUN", "rain": "RAIN", "moon": "MOON", "wind": "WIND", "seed": "seed", "sprout": "sprout", "sapling": "young plant", "bloom": "open flower", "carried": "carried seed", "bud": "closed bud", "stone_cold": "cold stone", "stone_warm": "warm stone", "stone_marked": "marked stone", "stone_open": "open stone", "rule_sun": "Sunlight wakes the seed.", "rule_rain": "Rain makes the sprout grow.", "rule_moon": "Moonlight opens what has grown.", "rule_wind": "Wind moves what is light.", "rule_stone_sun": "Sunlight warms the cold stone.", "rule_stone_moon": "Moonlight reveals a hidden mark.", "rule_stone_wind": "Wind parts the edges of the marked stone.", "p1_title": "The Silent Seed", "p1_desc": "A seed rests in the dust. Nothing seems to be waiting, yet it is not dead.", "p2_title": "Thirsty Ground", "p2_desc": "A sprout trembles beside dry soil. It has changed once already. What does it need?", "p3_title": "The First Bloom", "p3_desc": "The plant has grown, but its bud remains closed. Daylight is gone.", "p4_title": "The Pollen Leap", "p4_desc": "A seed lies isolated on a slab. The mark on the floor resembles a current of air.", "p5_title": "The Dreaming Stone", "p5_desc": "A stone blocks the passage. Three signs carved around it seem to form a sentence.", "p6_title": "The Hidden Order", "p6_desc": "One final seed. No new clue. What you already know may be enough.", "success": "LAW CONFIRMED", "next": "Continue", "finish_title": "The Garden Remembers", "finish_desc": "You were not given the laws. You rebuilt them. Beyond these walls, other places await curious minds.", "restart": "Replay the garden", "observed": "observed", "notebook_empty": "No laws recorded yet. Experiment, observe, and try again.", "hint1": "Consider the object and the sign that might influence it.", "hint2": "A law you observed may apply to a different object.", "hint3": "Order matters: one state can be the result of an earlier experiment.", "notice": "There is no penalty. The world does not judge your experiments.", "menu": "STILL GARDEN", "chapter": "CHAPTER I · STILL GARDEN"
	},
	"ar": {
		"subtitle": "العالم لا يشرح. بل يستجيب.", "start": "ادخل الحديقة", "continue": "تابع الاستكشاف", "trial": "راقب", "reset": "أعد التجربة", "journal": "دفتر القوانين", "hint": "تلميح خفي", "back": "عودة", "language": "اللغة", "level": "التجربة", "progress": "القوانين المكتشفة", "experiment": "اختر رمزاً ثم راقب استجابته.", "home_intro": "مكان منسي. رموز صامتة. وقوانين لن يشرحها لك أحد.", "home_cta": "كل تجربة سؤال، وكل استجابة دليل.", "result": "لقد تغيرت المادة.", "no_change": "استجاب الرمز، لكن شيئاً لم يتغير. حتى غياب التغيير ملاحظة.", "sun": "الشمس", "rain": "المطر", "moon": "القمر", "wind": "الريح", "seed": "بذرة", "sprout": "برعم", "sapling": "نبتة صغيرة", "bloom": "زهرة متفتحة", "carried": "بذرة محمولة", "bud": "برعم مغلق", "stone_cold": "حجر بارد", "stone_warm": "حجر دافئ", "stone_marked": "حجر معلّم", "stone_open": "حجر مفتوح", "rule_sun": "توقظ حرارة الشمس البذرة.", "rule_rain": "يساعد المطر النبتة على النمو.", "rule_moon": "يفتح ضوء القمر ما نما.", "rule_wind": "تحرك الريح الأشياء الخفيفة.", "rule_stone_sun": "تدفئ الشمس الحجر البارد.", "rule_stone_moon": "يكشف ضوء القمر علامة مخفية.", "rule_stone_wind": "تفتح الريح أطراف الحجر المعلّم.", "p1_title": "البذرة الصامتة", "p1_desc": "تستقر بذرة في الغبار. لا يبدو أنها تنتظر شيئاً، لكنها لم تمت.", "p2_title": "أرض عطشى", "p2_desc": "يرتعش برعم بجانب تربة جافة. لقد تغير مرة بالفعل. ما الذي يحتاجه؟", "p3_title": "أول تفتح", "p3_desc": "نمت النبتة، لكن برعمها ما زال مغلقاً. لقد اختفى ضوء النهار.", "p4_title": "قفزة حبوب اللقاح", "p4_desc": "تستقر بذرة على لوح معزول. تبدو العلامة على الأرض كتيار هواء.", "p5_title": "الحجر الحالم", "p5_desc": "يسد حجر الطريق. تبدو الرموز المحفورة حوله كأنها جملة.", "p6_title": "النظام الخفي", "p6_desc": "بذرة أخيرة. لا دليل جديد. ربما يكفي ما تعرفه بالفعل.", "success": "تم تأكيد القانون", "next": "تابع", "finish_title": "الحديقة تتذكر", "finish_desc": "لم يمنحك أحد القوانين. لقد أعدت اكتشافها. وراء الجدران أماكن أخرى تنتظر العقول الفضولية.", "restart": "أعد لعب الحديقة", "observed": "مكتشف", "notebook_empty": "لم تسجل أي قوانين بعد. جرّب، راقب، ثم أعد المحاولة.", "hint1": "تأمل طبيعة الشيء والرمز الذي قد يؤثر فيه.", "hint2": "قد ينطبق قانون اكتشفته على شيء مختلف.", "hint3": "الترتيب مهم: قد تكون الحالة نتيجة تجربة سابقة.", "notice": "لا توجد عقوبة. العالم لا يحكم على تجاربك.", "menu": "الحديقة الساكنة", "chapter": "الفصل الأول · الحديقة الساكنة"
	}
}

const PUZZLES := [
	{"title": "p1_title", "desc": "p1_desc", "start": "seed", "goal": "sprout", "first": "sun", "target": "sun", "rule": "rule_sun", "hint": "hint1"},
	{"title": "p2_title", "desc": "p2_desc", "start": "sprout", "goal": "sapling", "first": "rain", "target": "rain", "rule": "rule_rain", "hint": "hint2"},
	{"title": "p3_title", "desc": "p3_desc", "start": "sapling", "goal": "bloom", "first": "moon", "target": "moon", "rule": "rule_moon", "hint": "hint2"},
	{"title": "p4_title", "desc": "p4_desc", "start": "seed", "goal": "carried", "first": "wind", "target": "wind", "rule": "rule_wind", "hint": "hint1"},
	{"title": "p5_title", "desc": "p5_desc", "start": "stone_cold", "goal": "stone_open", "first": "sun", "target": "wind", "rule": "rule_stone_wind", "hint": "hint3"},
	{"title": "p6_title", "desc": "p6_desc", "start": "seed", "goal": "bloom", "first": "sun", "target": "moon", "rule": "rule_moon", "hint": "hint3"}
]

const TRANSITIONS := {
	"seed|sun": "sprout",
	"seed|wind": "carried",
	"sprout|rain": "sapling",
	"sapling|moon": "bloom",
	"bud|moon": "bloom",
	"stone_cold|sun": "stone_warm",
	"stone_warm|moon": "stone_marked",
	"stone_marked|wind": "stone_open"
}

const FEEDBACK := {
	"seed|sun": "rule_sun", "sprout|rain": "rule_rain", "sapling|moon": "rule_moon", "seed|wind": "rule_wind",
	"stone_cold|sun": "rule_stone_sun", "stone_warm|moon": "rule_stone_moon", "stone_marked|wind": "rule_stone_wind"
}

var lang: String = "fr"
var screen: String = "home"
var puzzle_index: int = 0
var object_state: String = "seed"
var selected_symbol: String = "sun"
var discovered: Array[String] = []
var status_text: String = ""
var status_success: bool = false
var hint_visible: bool = false
var completed: bool = false
var trial_count: int = 0
var ui_root: Control
var art: Control

func _ready() -> void:
	_load_save()
	_build_background()
	_draw_ui()

func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		puzzle_index = clampi(int(cfg.get_value("progress", "puzzle_index", 0)), 0, PUZZLES.size() - 1)
		var saved_discovered: Variant = cfg.get_value("progress", "discovered", [])
		discovered.clear()
		if saved_discovered is Array:
			for item in saved_discovered:
				if item is String and not discovered.has(item):
					discovered.append(item)
		lang = str(cfg.get_value("settings", "language", "fr"))
		completed = bool(cfg.get_value("progress", "completed", false))
		object_state = str(cfg.get_value("progress", "object_state", str(PUZZLES[puzzle_index]["start"])))
		status_text = str(cfg.get_value("progress", "status_text", ""))
		status_success = bool(cfg.get_value("progress", "status_success", false))
		selected_symbol = str(cfg.get_value("progress", "selected_symbol", str(PUZZLES[puzzle_index]["first"])))
	if not TEXT.has(lang):
		lang = "fr"
	if object_state.is_empty():
		object_state = str(PUZZLES[puzzle_index]["start"])

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "puzzle_index", puzzle_index)
	cfg.set_value("progress", "discovered", discovered)
	cfg.set_value("progress", "completed", completed)
	cfg.set_value("progress", "object_state", object_state)
	cfg.set_value("progress", "status_text", status_text)
	cfg.set_value("progress", "status_success", status_success)
	cfg.set_value("progress", "selected_symbol", selected_symbol)
	cfg.set_value("settings", "language", lang)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Could not save local progress: %s" % err)

func _t(key: String) -> String:
	return str(TEXT.get(lang, TEXT["fr"]).get(key, TEXT["fr"].get(key, key)))

func _build_background() -> void:
	art = Control.new()
	art.name = "Atmosphere"
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.draw.connect(_draw_atmosphere)
	art.resized.connect(func(): art.queue_redraw())
	add_child(art)
	move_child(art, 0)

func _draw_atmosphere() -> void:
	var size := art.size
	var rect := Rect2(Vector2.ZERO, size)
	var background := load("res://assets/garden_background.jpg") as Texture2D
	if background != null:
		# The original painted environment is tinted slightly cool so foreground text stays legible.
		art.draw_texture_rect(background, rect, false, Color(0.72, 0.82, 0.84, 1.0))
	else:
		art.draw_rect(rect, Color("080f1e"))
	art.draw_rect(rect, Color(0.015, 0.035, 0.065, 0.36))
	# Soft foreground veil, restrained so the altar remains visible beneath the UI.
	art.draw_rect(Rect2(0, size.y * 0.55, size.x, size.y * 0.45), Color(0.015, 0.04, 0.06, 0.24))
	for i in range(32):
		var fx := fmod(float(i * 83 + 31), maxf(size.x, 1.0))
		var fy := fmod(float(i * 139 + 67), maxf(size.y, 1.0))
		art.draw_circle(Vector2(fx, fy), 1.0 + float(i % 3) * 0.55, Color(0.66, 0.91, 0.81, 0.24))

func _style_panel(color: Color = Color("111d2b"), border_color: Color = Color("35535b")) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border_color
	s.set_border_width_all(1)
	s.set_corner_radius_all(14)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s

func _make_label(value: String, font_size: int = 16, color: Color = Color("e2ece7"), bold: bool = false) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if bold:
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.2))
	return l

func _make_button(value: String, callback: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = value
	b.custom_minimum_size = Vector2(0, 48)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 15)
	var normal := _style_panel(Color("b6e4cf") if primary else Color("152635"), Color("b6e4cf") if primary else Color("46606a"))
	var hover := _style_panel(Color("d3f3dc") if primary else Color("1e3544"), Color("ddf7e4") if primary else Color("79b9ad"))
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", _style_panel(Color("152635"), Color("79b9ad")))
	b.add_theme_color_override("font_color", Color("0b1c20") if primary else Color("e2ece7"))
	b.add_theme_color_override("font_hover_color", Color("061518") if primary else Color("ffffff"))
	b.pressed.connect(callback)
	return b

func _draw_ui() -> void:
	if is_instance_valid(ui_root):
		ui_root.queue_free()
	ui_root = Control.new()
	ui_root.name = "Interface"
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.offset_left = 18
	ui_root.offset_right = -18
	ui_root.offset_top = 18
	ui_root.offset_bottom = -18
	ui_root.layout_direction = Control.LAYOUT_DIRECTION_RTL if lang == "ar" else Control.LAYOUT_DIRECTION_LTR
	add_child(ui_root)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui_root.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 12)
	scroll.add_child(col)
	if screen == "home":
		_build_home(col)
	elif screen == "notebook":
		_build_notebook(col)
	elif screen == "finish":
		_build_finish(col)
	else:
		_build_game(col)

func _build_header(parent: VBoxContainer, subtitle: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var brand := VBoxContainer.new()
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_child(_make_label("L’ORDRE CACHÉ", 18, Color("c0ead7"), true))
	brand.add_child(_make_label(subtitle, 9, Color("94b2b7")))
	row.add_child(brand)
	var langs := OptionButton.new()
	langs.custom_minimum_size = Vector2(74, 38)
	langs.add_theme_font_size_override("font_size", 12)
	langs.add_item("FR", 0)
	langs.add_item("EN", 1)
	langs.add_item("عربي", 2)
	langs.select(["fr", "en", "ar"].find(lang))
	langs.item_selected.connect(_on_language_selected)
	row.add_child(langs)

func _build_home(parent: VBoxContainer) -> void:
	_build_header(parent, _t("subtitle"))
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 24
	parent.add_child(spacer)
	var art_card := PanelContainer.new()
	art_card.add_theme_stylebox_override("panel", _style_panel(Color("101b29"), Color("41636b")))
	art_card.custom_minimum_size.y = 240
	parent.add_child(art_card)
	var art_col := VBoxContainer.new()
	art_col.alignment = BoxContainer.ALIGNMENT_CENTER
	art_col.add_theme_constant_override("separation", 8)
	art_card.add_child(art_col)
	var symbol := _make_label("✦", 62, Color("b6e4cf"), true)
	symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_col.add_child(symbol)
	var title := _make_label("L’ORDRE\nCACHÉ", 34, Color("edf7ed"), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_col.add_child(title)
	var line := _make_label("✧     ⟡     ✧", 16, Color("78bdb0"))
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_col.add_child(line)
	var intro := _make_label(_t("home_intro"), 17, Color("d4e3dc"))
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(intro)
	var cta := PanelContainer.new()
	cta.add_theme_stylebox_override("panel", _style_panel(Color(0.05, 0.11, 0.16, 0.92), Color("2d4d56")))
	parent.add_child(cta)
	cta.add_child(_make_label(_t("home_cta"), 14, Color("9ec3bc")))
	var btn_text := _t("start") if puzzle_index == 0 and not completed and not status_success else _t("continue")
	parent.add_child(_make_button(btn_text, _start_game, true))
	parent.add_child(_make_button(_t("journal"), _open_notebook))
	parent.add_child(_make_label("OFFLINE · SAUVEGARDE LOCALE · CHAPITRE I", 10, Color("77989d")))

func _build_game(parent: VBoxContainer) -> void:
	var p: Dictionary = PUZZLES[puzzle_index]
	_build_header(parent, _t("chapter"))
	var top := HBoxContainer.new()
	top.add_child(_make_label("%02d / %02d" % [puzzle_index + 1, PUZZLES.size()], 12, Color("b8e2d0"), true))
	var flex := Control.new()
	flex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(flex)
	top.add_child(_make_label("✦ %d" % discovered.size(), 12, Color("b8e2d0")))
	parent.add_child(top)
	var title := _make_label(_t(str(p["title"])), 25, Color("f0f4e9"), true)
	parent.add_child(title)
	parent.add_child(_make_label(_t(str(p["desc"])), 14, Color("b5c9c6")))
	var scene_card := PanelContainer.new()
	scene_card.add_theme_stylebox_override("panel", _style_panel(Color("0b1623"), Color("37545d")))
	scene_card.custom_minimum_size.y = 182
	parent.add_child(scene_card)
	var scene_col := VBoxContainer.new()
	scene_col.alignment = BoxContainer.ALIGNMENT_CENTER
	scene_col.add_theme_constant_override("separation", 6)
	scene_card.add_child(scene_col)
	var illustration := _make_label(_state_symbol(object_state), 60, Color("b6e4cf"), true)
	illustration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_col.add_child(illustration)
	var state_label := _make_label(_t(object_state), 15, Color("e7eee4"), true)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_col.add_child(state_label)
	var micro := _make_label("·   ·   ·", 14, Color("628f91"))
	micro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_col.add_child(micro)
	parent.add_child(_make_label(_t("experiment"), 13, Color("94b6b3")))
	var symbols := GridContainer.new()
	symbols.columns = 2
	symbols.add_theme_constant_override("h_separation", 8)
	symbols.add_theme_constant_override("v_separation", 8)
	parent.add_child(symbols)
	for symbol in SYMBOLS:
		var chosen: bool = (selected_symbol == symbol)
		var btn := _make_button(_symbol_icon(symbol) + "  " + _t(symbol), func(): _select_symbol(symbol), chosen)
		btn.custom_minimum_size.y = 48
		symbols.add_child(btn)
	if not status_text.is_empty():
		var status_panel := PanelContainer.new()
		status_panel.add_theme_stylebox_override("panel", _style_panel(Color("17322f") if status_success else Color("121f2a"), Color("6cba9e") if status_success else Color("395965")))
		parent.add_child(status_panel)
		status_panel.add_child(_make_label(status_text, 13, Color("d7f1de") if status_success else Color("b9d0d0")))
	if status_success:
		parent.add_child(_make_button(_t("next") if puzzle_index < PUZZLES.size() - 1 else _t("finish_title"), _advance, true))
	else:
		parent.add_child(_make_button(_t("trial"), _observe, true))
	parent.add_child(_make_button(_t("hint"), _toggle_hint))
	if hint_visible:
		var h := PanelContainer.new()
		h.add_theme_stylebox_override("panel", _style_panel(Color("111d29"), Color("9caa8e")))
		parent.add_child(h)
		h.add_child(_make_label(_t(str(p["hint"])), 13, Color("cfdacb")))
	parent.add_child(_make_button(_t("journal"), _open_notebook))
	parent.add_child(_make_button(_t("reset"), _reset_trial))
	parent.add_child(_make_label(_t("notice"), 10, Color("728f92")))

func _build_notebook(parent: VBoxContainer) -> void:
	_build_header(parent, _t("journal"))
	parent.add_child(_make_label(_t("journal"), 24, Color("eff7e9"), true))
	parent.add_child(_make_label(_t("notebook_empty") if discovered.is_empty() else "%d  %s" % [discovered.size(), _t("progress")], 13, Color("a8c9c0")))
	if discovered.is_empty():
		var empty_panel := PanelContainer.new()
		empty_panel.add_theme_stylebox_override("panel", _style_panel())
		parent.add_child(empty_panel)
		empty_panel.add_child(_make_label(_t("notebook_empty"), 14))
	else:
		for rule_id in discovered:
			var panel := PanelContainer.new()
			panel.add_theme_stylebox_override("panel", _style_panel(Color("10241f"), Color("3c7466")))
			parent.add_child(panel)
			var v := VBoxContainer.new()
			v.add_child(_make_label("✦  " + _t("observed"), 10, Color("8dc8ac"), true))
			v.add_child(_make_label(_t(rule_id), 15, Color("e2eee1")))
			panel.add_child(v)
	parent.add_child(_make_button(_t("back"), _back_from_notebook))
	parent.add_child(_make_label("L’ORDRE CACHÉ · NOTES PERSONNELLES", 10, Color("77989d")))


func _build_finish(parent: VBoxContainer) -> void:
	_build_header(parent, _t("chapter"))
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 38
	parent.add_child(spacer)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style_panel(Color("101d2b"), Color("83bda9")))
	card.custom_minimum_size.y = 330
	parent.add_child(card)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	card.add_child(content)
	var sigil := _make_label("✧  ✦  ✧", 34, Color("b6e4cf"), true)
	sigil.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(sigil)
	var title := _make_label(_t("finish_title"), 26, Color("edf6e8"), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var desc := _make_label(_t("finish_desc"), 15, Color("c1d6ce"))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(desc)
	parent.add_child(_make_label("%d / %d  ·  %s" % [discovered.size(), 7, _t("progress")], 12, Color("9cc7b6")))
	parent.add_child(_make_button(_t("restart"), _replay, true))
	parent.add_child(_make_button(_t("journal"), _open_notebook))
	parent.add_child(_make_button(_t("back"), _go_home))

func _replay() -> void:
	puzzle_index = 0
	object_state = str(PUZZLES[0]["start"])
	selected_symbol = "sun"
	status_text = ""
	status_success = false
	hint_visible = false
	completed = false
	trial_count = 0
	screen = "game"
	_save()
	_draw_ui()

func _go_home() -> void:
	screen = "home"
	_draw_ui()

func _start_game() -> void:
	screen = "game"
	if completed:
		screen = "finish"
	_draw_ui()

func _select_symbol(symbol: String) -> void:
	if status_success:
		return
	selected_symbol = symbol
	status_text = ""
	status_success = false
	_draw_ui()

func _observe() -> void:
	if screen == "finish" or status_success:
		return
	trial_count += 1
	var before := object_state
	var transition_key := "%s|%s" % [object_state, selected_symbol]
	if TRANSITIONS.has(transition_key):
		object_state = str(TRANSITIONS[transition_key])
		status_text = _t(str(FEEDBACK.get(transition_key, "result")))
		if transition_key == "stone_marked|wind":
			_discover("rule_stone_sun")
			_discover("rule_stone_moon")
			_discover("rule_stone_wind")
		elif FEEDBACK.has(transition_key):
			_discover(str(FEEDBACK[transition_key]))
		status_success = object_state == str(PUZZLES[puzzle_index]["goal"])
		if status_success:
			status_text = _t("success") + " — " + status_text
			if puzzle_index == PUZZLES.size() - 1:
				completed = true
		_save()
	else:
		status_text = _t("no_change")
		status_success = false
	if before == object_state:
		push_warning("Transition returned the same object state")
	_save()
	_draw_ui()

func _discover(rule_id: String) -> void:
	if not discovered.has(rule_id):
		discovered.append(rule_id)

func _advance() -> void:
	if puzzle_index < PUZZLES.size() - 1:
		puzzle_index += 1
		object_state = str(PUZZLES[puzzle_index]["start"])
		selected_symbol = str(PUZZLES[puzzle_index]["first"])
		status_text = ""
		status_success = false
		hint_visible = false
		screen = "game"
	else:
		screen = "finish"
		status_text = ""
		status_success = false
	_save()
	_draw_ui()

func _toggle_hint() -> void:
	hint_visible = not hint_visible
	_draw_ui()

func _reset_trial() -> void:
	object_state = str(PUZZLES[puzzle_index]["start"])
	status_text = ""
	status_success = false
	hint_visible = false
	_save()
	_draw_ui()

func _open_notebook() -> void:
	screen = "notebook"
	_draw_ui()

func _back_from_notebook() -> void:
	screen = "game" if not completed else "finish"
	_draw_ui()

func _on_language_selected(index: int) -> void:
	lang = ["fr", "en", "ar"][index]
	_save()
	_draw_ui()

func _state_symbol(state: String) -> String:
	var symbols := {"seed": "◉", "sprout": "♧", "sapling": "♣", "bloom": "✿", "carried": "❧", "bud": "❀", "stone_cold": "⬟", "stone_warm": "⬢", "stone_marked": "◈", "stone_open": "◇"}
	return str(symbols.get(state, "✧"))

func _symbol_icon(symbol: String) -> String:
	return str({"sun": "☼", "rain": "⌁", "moon": "☾", "wind": "≋"}.get(symbol, "✧"))
