extends Node2D

@export var speed := 200.0
@export var damage := 1
var target: Node2D = null
var has_hit := false  # ✅ Add flag to prevent multiple hits

@onready var chase_area = $ChaseArea
@onready var anim = $AnimationPlayer

func _ready():
	if anim:
		anim.play("Fly")  # Optional flying animation
	chase_area.connect("area_entered", Callable(self, "_on_chase_area_entered"))

func _process(delta):
	if has_hit:
		return  # ✅ Don't move or do anything if already hit
	
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
	else:
		queue_free()

func _on_chase_area_entered(area: Area2D):
	if has_hit:
		return  # ✅ Already hit once, ignore further collisions

	# Ignore detection areas like "ChaseArea"
	if area.name == "ChaseArea" or area.is_in_group("detection_zones"):
		return

	var body = area.get_parent()

	if body == target:
		if "take_damage" in body:
			body.take_damage(damage)
		has_hit = true
		queue_free()  # ✅ Remove projectile after hitting target
