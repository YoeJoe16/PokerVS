extends SceneTree

var failures := 0
var checks := 0
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var counts := [0, 0, 0, 0, 0]
	var valid := true
	for sample in 20000:
		var offers := SpellBook.offers([0, 1, 2], rng)
		counts[SpellBook.QUALITY[offers[0]]] += 1
		valid = valid and offers.size() == 3
		for id in offers:
			valid = valid and id not in [0, 1, 2] and offers.count(id) == 1
	check(valid, "Offers contain three distinct unowned spells")
	for quality in 5:
		check(absf(counts[quality] / 20000.0 - SpellBook.WEIGHTS[quality] / 100.0) < 0.015, "Seeded first-offer frequency matches category weight %d" % quality)
	check(SpellBook.offers(range(SpellBook.NAMES.size()), rng).is_empty(), "Full collection exhausts shop safely")
	var remainder := SpellBook.offers(range(14) + [16], rng)
	check(remainder.size() == 2 and 14 in remainder and 15 in remainder, "Only two unowned spells yields two offers")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.arena.set_process(false)
	game.new_run()
	game.state = "shop"
	game.shop_offers = [6, 14, 15]
	game.coins = 400
	game.build_buttons()
	game.toggle_inventory()
	game.toggle_inventory()
	game.selected_slot = 1
	game.build_buttons()
	check(game.shop_offers == [6, 14, 15], "Browsing inventory and changing slots never rerolls")
	game.select_spell(13)
	check(game.coins == 400 and 13 not in game.owned, "Cannot buy an unoffered spell")
	game.select_spell(14)
	check(game.coins == 250 and game.equipped[1] == 14, "Black magic costs 150 and equips")
	game.select_spell(14)
	check(game.coins == 250 and game.owned.count(14) == 1, "Repeated purchase cannot charge twice")
	game.selected_slot = 0
	game.select_spell(14)
	check(game.equipped == [14, 0, 2], "Owned spell swaps slots without duplication")
	game.coins = 0
	game.select_spell(15)
	check(15 not in game.owned, "Insufficient funds blocks purchase")
	game.toggle_inventory()
	game.inventory_page = 1
	game.build_buttons()
	check(game.shop_items() == [14], "Inventory can reach purchased spell on later page")
	game.battle = 15
	for id in range(6, 16):
		game.start_battle()
		game.hp = 60
		game.shield = 0
		game.equipped = [id, 0, 2]
		game.cast_spell(id)
		check(game.enemy_hp == 420 - SpellBook.DAMAGE[id], "Damage for new spell %d" % id)
		check(is_equal_approx(game.cooldown[id], SpellBook.COOLDOWNS[id]), "Cooldown for new spell %d" % id)
		game.arena.advance(0.25)
		check(game.arena.player.frame == 3 + SpellBook.POSES[id], "Valid hand animation for spell %d" % id)
		var before: int = game.enemy_hp
		game.cast_spell(id)
		check(game.enemy_hp == before, "Cannot repeat new spell during cooldown %d" % id)
		match id:
			7: check(is_equal_approx(game.frozen, 0.6), "Wind briefly delays enemy")
			8: check(game.hp == 78 and game.shield == 12, "Sprout heals and shields")
			10: check(is_equal_approx(game.frozen, 4.0), "Glacier freezes for four seconds")
			12: check(game.hp == 80 and game.shield == 48, "Aegis grants health and full barrier")
			14: check(game.hp == 26, "Blood sacrifices 34 health")
			15: check(is_equal_approx(game.paralyzed, 3.0), "Void causes three seconds paralysis")
	game.start_battle()
	game.equipped = [9, 0, 2]
	game.enemy_ward = 48
	game.cast_spell(9)
	check(game.enemy_hp == 360 and game.enemy_ward == 48, "Lance bypasses barrier without consuming it")
	game.start_battle()
	game.equipped = [14, 0, 2]
	game.hp = 34
	game.shield = 48
	game.enemy_hp = 100
	game.cast_spell(14)
	check(game.hp == 0 and game.pending_outcome == "dead" and game.coins == 0, "Lethal sacrifice ignores shield and prevents simultaneous victory rewards")
	game.start_battle()
	game.equipped = [15, 0, 2]
	game.hp = 100
	game.shield = 0
	game.cast_spell(15)
	game.cast_spell(0)
	check(game.cooldown[0] == 0 and game.enemy_hp == 240, "Paralysis blocks other casts")
	game.attack_timer = 0
	game._process(0.1)
	check(game.hp == 82 and game.paralyzed > 0, "Enemy attacks while player is paralyzed")
	game._process(3.0)
	game.cast_spell(0)
	check(game.paralyzed == 0 and game.cooldown[0] > 0, "Casting resumes when paralysis expires")
	game.paralyzed = 3
	game.start_battle()
	check(game.paralyzed == 0, "Paralysis clears between encounters")
	game.new_run()
	check(game.owned == [0, 1, 2] and game.shop_offers.is_empty() and game.cooldown.size() == SpellBook.NAMES.size(), "Restart resets new spell progression")
	game.battle = 15
	game.start_battle()
	game.equipped = [16, 0, 2]
	game.hp = 100
	game.shield = 24
	game.cast_spell(16)
	check(game.reflection == 1.5 and game.cooldown[16] == 10, "Reflection arms short window and long cooldown")
	game.attack_timer = 0
	game._process(0.01)
	check(game.hp == 100 and game.shield == 24 and game.enemy_hp == 402 and game.reflection == 0, "Reflection returns one attack without spending shield")
	game.attack_count = 2
	game.attack_timer = 0
	game._process(0.01)
	check(game.shield == 4 and game.enemy_hp == 402, "Next attack is not reflected")
	game.start_battle()
	game.cast_spell(16)
	game._process(1.6)
	game.attack_timer = 0
	game._process(0.01)
	check(game.enemy_hp == 420, "Expired reflection cannot return attacks")
	game.start_battle()
	game.cast_spell(16)
	game.attack_count = 1
	game.attack_timer = 0
	game._process(0.01)
	check(game.reflection > 0 and game.enemy_ward == 24, "Enemy support spell does not consume reflection")
	game.attack_count = 3
	game.attack_timer = 0
	game._process(0.01)
	check(game.enemy_ward == 0 and game.enemy_hp == 412, "Reflected damage respects enemy barrier")
	game.start_battle()
	game.encounter.damages = [100]
	game.cast_spell(16)
	game.attack_timer = 0
	game._process(0.01)
	check(game.enemy_hp == 380, "Reflected damage capped at forty")
	game.battle = 4
	game.start_battle()
	game.hp = 100
	game.shield = 0
	game.cast_spell(16)
	game.attack_timer = 0
	game._process(0.01)
	game.attack_timer = 0
	game._process(0.01)
	check(game.hp == 92 and game.enemy_hp == game.enemy_max - 8, "Only first pulse of double attack is reflected")
	game.battle = 15
	game.start_battle()
	game.enemy_hp = 1
	game.cast_spell(16)
	game.attack_timer = 0
	game._process(0.01)
	check(game.pending_outcome == "victory" and game.state == "resolving", "Reflected killing blow resolves through normal victory flow")
	for step in 40:
		game.arena.advance(1.0)
		game._process(0.0)
	check(game.state == "victory" and game.last_reward == 130, "Reflected final blow finishes animations and grants boss reward")
	check(SpellBook.QUALITY[16] == 3 and SpellBook.price(16) == 120, "Reflection uses legendary price and rarity")
	game.new_run()
	check(game.reflection == 0, "Restart clears reflection")
	game.queue_free()
	await process_frame
	print("SPELLS: %d checks, %d failures; distribution %s" % [checks, failures, counts])
	quit(1 if failures else 0)
