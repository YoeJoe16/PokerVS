extends SceneTree
var checks := 0
var failures := 0
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var intro = game.get_node("Intro")
	intro.set_process(false)
	check(game.state == "intro" and game.controls.is_empty(), "Cold launch starts intro without combat or menu buttons")
	check(not game.menu_cell.visible and not game.menu_cell.playing, "Cell remains hidden and stopped before intro ends")
	intro.request_next()
	check(intro.page == 0 and intro.phase == "panels", "Early next request cannot skip panels")
	intro.advance(1.0)
	check(intro.panel_alpha(0) == 1 and intro.panel_alpha(1) == 0 and intro.panel_alpha(2) == 0, "Only top panel is revealed first")
	check(not intro.next_button.visible and intro.next_button.disabled, "No advance button during reveal")
	intro.advance(2.4)
	check(intro.panel_alpha(1) > 0 and intro.panel_alpha(1) < 1 and intro.panel_alpha(2) == 0, "Middle panel fades in before last panel")
	game.cast_spell(0)
	check(game.state == "intro" and not game.arena.is_busy(), "Gameplay is blocked in cinematic")
	for page in 3:
		intro.advance(12.0)
		check(intro.page == page and intro.ready_to_continue and intro.next_button.visible, "Page %d waits for manual continuation" % page)
		check(intro.panels.size() == (2 if page == 2 else 3), "Correct number of panels on page %d" % page)
		for index in intro.panels.size():
			check(intro.panel_alpha(index) == 1, "Panel fully revealed before advancing")
		intro.next_button.pressed.emit()
		intro.request_next()
		check(intro.phase == "out" and intro.page == page and intro.next_button.disabled, "Double tap cannot skip transition")
		intro.advance(0.25)
		check(intro.page == page and is_equal_approx(intro.transition.color.a, 0.5), "Old page fades to black")
		intro.advance(0.25)
		check(intro.page == page + 1 and intro.phase == "in" and intro.transition.color.a == 1, "Page changes only behind opaque transition")
		if page == 2:
			check(game.state == "intro_transition" and game.menu_cell.playing and game.controls.is_empty(), "Final fade reveals cell while Start remains unavailable")
		intro.advance(0.25)
		check(is_equal_approx(intro.transition.color.a, 0.5), "New scene fades in")
		intro.advance(0.25)
	check(game.state == "menu" and not intro.visible and intro.phase == "done", "All pages lead to animated menu")
	check(not intro.is_processing() and game.controls.size() == 2, "Intro stops and menu controls appear")
	game.controls[1].pressed.emit()
	var fade = game.get_node("CombatTransition")
	check(fade.active and game.state == "menu", "Start fades the menu before loading combat")
	game.begin_run()
	fade.advance(0.5)
	check(game.state == "fight" and fade.color.a == 1, "Combat loads behind opaque fade")
	var timer: float = game.attack_timer
	game._process(0.25)
	game.cast_spell(0)
	check(game.attack_timer == timer and game.cooldown[0] == 0, "Combat timer and casting wait until fade finishes")
	fade.advance(0.5)
	check(not fade.active and not fade.visible, "Transition releases input after fade in")
	check(game.state == "fight" and game.battle == 1 and not game.menu_cell.playing, "Final Start begins first fight")
	game.new_run()
	check(not intro.visible and game.state == "fight", "Retry does not replay introduction")
	game.queue_free()
	await process_frame
	print("INTRO: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
