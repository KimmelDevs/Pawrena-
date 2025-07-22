extends Node2D

@export var speed := 30.0
@export var max_hp := 8
@export var damage := 2
@export var attack_interval := 2.0
@export var projectile_scene: PackedScene = preload("res://Projectiles/cat_projectile.tscn")

@onready var anim = $AnimationPlayer
@onready var chase_area = $ChaseArea
@onready var detector_area = $Detector  # Make sure this exists in your scene!

var hp := max_hp
var is_attacking = false
var is_chasing = false
var attack_timer := 0.0
var current_target: Node2D = null

func _ready():
	anim.play("Walk")
	chase_area.connect("area_entered", _on_chase_area_entered)
	chase_area.connect("area_exited", _on_chase_area_exited)
	detector_area.connect("area_entered", _on_detector_area_entered)

func _process(delta):
	if is_attacking:
		if current_target == null or not is_instance_valid(current_target):
			stop_attacking()
			return

		look_at(current_target.global_position)
		attack_timer -= delta
		if attack_timer <= 0:
			fire_projectile()
			attack_timer = attack_interval
	elif is_chasing and current_target:
		var direction = (current_target.global_position - global_position).normalized()
		position += direction * speed * delta
	else:
		position.x += speed * delta  # Default walk

func _on_detector_area_entered(area: Area2D):
	var detected = area.get_parent()
	if not detected.is_in_group("enemy"):
		return

	print("Cat 3 target acquired: ", detected)
	is_attacking = true
	is_chasing = false
	speed = 0
	anim.play("Attack")
	current_target = detected
	attack_timer = 0

func _on_chase_area_entered(area: Area2D):
	var detected = area.get_parent()
	if detected.is_in_group("enemy") and not is_attacking:
		print("Cat 3 sees target, chasing: ", detected)
		current_target = detected
		is_chasing = true
		anim.play("Walk")

func _on_chase_area_exited(area: Area2D):
	var detected = area.get_parent()
	if detected == current_target and is_chasing:
		print("Cat 3 lost chase target.")
		current_target = null
		is_chasing = false

func fire_projectile():
	if not projectile_scene or not current_target:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.target = current_target
	projectile.damage = damage
	get_tree().current_scene.add_child(projectile)

func take_damage(amount: int) -> void:
	hp -= amount
	print("Cat 3 HP: ", hp)
	if hp <= 0:
		queue_free()

func stop_attacking():
	print("Target gone. Cat 3 resumes walk.")
	is_attacking = false
	current_target = null
	speed = 30.0
	anim.play("Walk")
