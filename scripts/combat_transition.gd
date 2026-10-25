extends ColorRect

const DURATION := 0.5
var active := false
var phase := "out"
var elapsed := 0.0
var action: Callable

func _ready() -> void:
	hide()
	set_process(false)

func start(callback: Callable) -> void:
	if active:
		return
	active = true
	phase = "out"
	elapsed = 0.0
	action = callback
	color.a = 0.0
	show()
	set_process(true)

func _process(delta: float) -> void:
	advance(minf(delta, 0.1))

func advance(delta: float) -> void:
	if not active:
		return
	elapsed = minf(DURATION, elapsed + maxf(0, delta))
	color.a = elapsed / DURATION if phase == "out" else 1.0 - elapsed / DURATION
	if elapsed >= DURATION:
		if phase == "out":
			action.call()
			action = Callable()
			phase = "in"
			elapsed = 0.0
		else:
			active = false
			hide()
			set_process(false)
