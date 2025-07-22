extends Node2D

@export var speed := 30.0
@export var max_hp := 8
@export var damage := 2
@export var attack_interval := 2.0

@onready var anim = $AnimationPlayer
@onready var chase_area = $ChaseArea

var hp := max_hp
var is_attacking = false
var is_chasing = false
var attack_timer := 0.0
var current_target: Node2D = null

func _ready():
	anim.play("Walk")
	chase_area.connect("area_entered", Callable(self, "_on_chase_area_entered"))
	chase_area.connect("area_exited", Callable(self, "_on_chase_area_exited"))

func _process(delta):
	if is_attacking:
		if current_target == null or not is_instance_valid(current_target):
			stop_attacking()
			return

		attack_timer -= delta
		if attack_timer <= 0:
			attack_target()
			attack_timer = attack_interval
	elif is_chasing and current_target:
		# Move toward the current target
		var direction = (current_target.global_position - global_position).normalized()
		position += direction * speed * 2 * delta  # chase speed is 2x
	else:
		# Default movement
		position.x -= speed * delta

func _on_detector_area_entered(area: Area2D) -> void:
	var detected = area.get_parent()

	if not detected.is_in_group("player"):
		return
	if area.name == "ChaseArea":
		return

	print("Cat 2 detector triggered by: ", detected)

	is_attacking = true
	is_chasing = false
	speed = 0
	anim.play("Attack")
	current_target = detected
	attack_timer = 0

func _on_chase_area_entered(area: Area2D):
	var detected = area.get_parent()

	if detected.is_in_group("player") and not is_attacking:
		print("Cat 2 chasing: ", detected)
		current_target = detected
		is_chasing = true
		anim.play("Walk")

func _on_chase_area_exited(area: Area2D):
	var detected = area.get_parent()
	if detected == current_target and is_chasing:
		print("Cat 2 lost chase target.")
		current_target = null
		is_chasing = false

func attack_target():
	if current_target and current_target.has_method("take_damage"):
		print("Cat 2 attacking: ", current_target)
		current_target.take_damage(damage)

func take_damage(amount: int) -> void:
	hp -= amount
	print("Cat 2 HP: ", hp)
	if hp <= 0:
		queue_free()

func stop_attacking():
	print("Target dead or gone. Resuming walk.")
	is_attacking = false
	current_target = null
	is_chasing = false
	speed = 30.0
	anim.play("Walk")
