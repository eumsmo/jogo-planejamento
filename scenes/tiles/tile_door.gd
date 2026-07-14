extends TileTrigger


@export_group("Animation")
@export var open_animation: String
@export var close_animation: String

var is_open: bool = false

func _ready() -> void:
	super()
	is_open = !is_open
	set_open(!is_open)

func set_open(is_open: bool) -> void:
	if is_open == self.is_open:
		return
	
	self.is_open = is_open
	
	if is_open:
		animator.play(open_animation)
	else:
		animator.play(close_animation)

func _on_enter(body: Node3D) -> void:
	if is_open:
		return

	var had = bodies_inside.has(body)
	super(body)
	
	if body.is_in_group(body_group) and not had:
		var subject: Subject = body
		subject.die()

func refresh_animation() -> void:
	if animator == null:
		return
