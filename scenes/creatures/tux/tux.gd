extends CharacterBody2D

# code from godottux

# Movement
@export var speed:int = 320
@export_range(0, 0.1) var acceleration:float = 0.06
@export_range(0, 0.1) var deceleration:float = 0.06
@export var max_jump_height:int = 576
@export var min_jump_height:float = 512.0 # This is a float just to avoid a warning.
@export var decelerate_on_jump_release:float = 0.5 # May seem useless, but it could be used for ST 0.3.3+ variable jump height.
var max_flaps = 1 # How many times Tux can flap
var flap_count = 0 # How many times Tux has flapped

# Cutscene / scripting variables
var in_cutscene:bool = false
var auto_walk:bool = false
var auto_walk_speed:int = 0 # Don't change this.

# Invincible variables
var inv_seconds:int = 1
var invincible:bool = false

# Holding objects variable
var held_object:CharacterBody2D = null

# Powerup Bullet variables
var can_shoot_bullets:bool = true
var max_fireballs_allowed:int = 2

# Rock detecting variable
var rock_above:bool = false

# Buttjump variable (currently just a visual thing!)
var buttjump:bool = false

# Whether Tux was just on the floor or not
var was_on_floor:bool = false

# Jump buffering variables
@export var jump_buffer_time:float = 0.1
var jump_buffer_timer:float = 0.0

# Death variables
var dead:bool = false
@export var dead_jump:int = 700
var restart_scene_timer:float = 3.0

# Whether Tux shows stars while not star_invincible
var show_stars:bool = false

# Duck variable
var duck:bool = false

# Skid variables
var skid:bool = false
@export var how_fast_to_skid:int = 200
@export_range(0, 0.1) var skid_deceleration:float = 0.01 # Doesn't seem to work?
@export var skid_speed:int = 35

# The sound that plays when getting the stars
@export_file("*.ogg", "*.wav") var get_star_sound = "res://data/sounds/herring.wav"

# The music that plays when getting the star.
@export_file("*.ogg", "*.wav") var invincible_music = "res://data/music/salcon.ogg"

# Onready varaibles
@onready var big_image = $BigImage
@onready var fire_image = $FireImage
@onready var big_stars_image = $BigStarsImage
@onready var small_collision = $SmallCollision
@onready var big_collision = $BigCollision
@onready var stomp = $Stomp
@onready var rock_detector = $RockDetector
@onready var rock_detector_collision = $RockDetector/CollisionShape2D
@onready var ceiling_raycast = $CeilingRaycast
@onready var camera = $Camera
@onready var big_jump_sound = $BigJumpSound
@onready var skid_sound = $SkidSound
@onready var death_sound = $DeathSound
@onready var grow_sound = $GrowSound
@onready var flower_sound = $FlowerSound
@onready var bullet_sound = $BulletSound
@onready var coyote_timer = $CoyoteTimer
@onready var star_timer = $StarTimer
@onready var tile_timer = $TileTimer

func _ready() -> void:
	add_to_group("Player")
	stomp.add_to_group("Stomp")
	reload_player()
	stomp.connect("area_entered", _on_stompable_object_detected)
	#star_timer.connect("timeout", _on_star_timer_finished)

func _physics_process(delta: float) -> void:
	if dead and Input.is_action_just_pressed("ui_cancel"):
		get_tree().call_deferred("reload_current_scene")
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if position.x < camera.limit_left:
		position.x = 0
	
	if position.y > camera.limit_bottom and not in_cutscene:
		die()
	
	if position.x > camera.limit_right - small_collision.shape.size.x:
		position.x = camera.limit_right - small_collision.shape.size.x
	
	if not is_on_floor() and tile_timer.is_stopped():
		velocity += get_gravity() * delta
	
	for body in rock_detector.get_overlapping_bodies():
		if body.is_in_group("Holdable"):
			var tux_under = body.global_position.y < global_position.y
			if tux_under and body.velocity.y > 0:
				global_position.y -= 2
				body.bounce()
	
	if not in_cutscene:
		if dead:
			move_and_slide()
			return
		move()
		shoot()
	
	if auto_walk:
		velocity.x = TuxManager.facing_direction * auto_walk_speed
	
	if get_tree().get_nodes_in_group("FireBullet").size() >= max_fireballs_allowed:
		can_shoot_bullets = false
	else:
		can_shoot_bullets = true
	
	if not dead:
		animate()
	
	if Input.is_action_just_released("player_action") and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	if in_cutscene and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor() and not Input.is_action_just_pressed("player_jump"):
		coyote_timer.start()
		tile_timer.start()

func die():
	if not dead:
		dead = true
		if Global.tux_star_invincible:
			Music.stream = load(Global.sector_song)
			Music.play()
			Global.tux_star_invincible = false
		TuxManager.current_state = TuxManager.powerup_states.Big
		set_collision_mask_value(1, false)
		set_collision_mask_value(9, false)
		set_collision_layer_value(32, true)
		set_collision_layer_value(2, false)
		stomp.set_deferred("monitorable", false)
		stomp.set_deferred("monitoring", false)
		big_image.play("flap")
		death_sound.play()
		velocity.x = 0
		if Global.coins >= 25:
			Global.coins -= 25
		velocity.y = -dead_jump
		# $FadeOut/AnimationTween.play("fade_out")
		await get_tree().create_timer(restart_scene_timer).timeout
		get_tree().call_deferred("reload_current_scene")

func move():
	if is_on_floor():
		flap_count = 0
		buttjump = false
	
	was_on_floor = is_on_floor()
	
	var direction := Input.get_axis("player_left", "player_right")
	var duck_on_floor = duck and is_on_floor()

	if direction and not duck_on_floor:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	elif not direction or duck_on_floor:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
	
	if direction and not sign(velocity.x) == direction and abs(velocity.x) > how_fast_to_skid and not in_cutscene and is_on_floor() and not duck: # who the (bad fire place) starts a conversation like that, i just sat down!
		if not skid:
			skid_sound.play()
			velocity.x += -direction * skid_speed
		
		skid = true
		velocity.x = move_toward(velocity.x, 0, speed * skid_deceleration)
	else:
		if skid and TuxManager.facing_direction == 1 and velocity.x >= 0:
			skid = false
		elif skid and TuxManager.facing_direction == -1 and velocity.x <= 0:
			skid = false
		if in_cutscene: # TODO: Is this needed?
			skid = false
	
	if in_cutscene:
		skid = false

	if direction == -1:
		TuxManager.facing_direction = -1
	elif direction == 1:
		TuxManager.facing_direction = 1
	
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = jump_buffer_time
	
	# Tux Jumping stuff
	var player_jump = Input.is_action_just_pressed("player_jump") #or jump_buffer_timer > 0
	if player_jump:
		if is_on_floor() or not coyote_timer.is_stopped():
			big_jump_sound.play()
			if abs(velocity.x) == speed:
				velocity.y = -max_jump_height
			else:
				velocity.y = -min_jump_height
		elif not is_on_floor() and flap_count < max_flaps:
			velocity.y = -416 # replace with a variable at some point
			flap_count += 1
		
		# jump_buffer_timer = 0
		coyote_timer.stop()
		tile_timer.stop()

	# Decelerate on jump release
	if velocity.y < 0:
		if not Input.is_action_pressed("player_jump"):
			velocity.y *= decelerate_on_jump_release
	
	if not is_on_floor():
		if Input.is_action_just_pressed("player_down"):
			print("Buttjumping!")
			buttjump = true
		var buttjump_but_not_buttjump = buttjump and Input.is_action_just_released("player_down") # this feels more like a HACK than anything else (because it is)
		if buttjump_but_not_buttjump:
			buttjump = false
	else:
		buttjump = false
		
	if Input.is_action_pressed("player_down") and is_on_floor():
		duck = true
	elif not Input.is_action_pressed("player_down") and not ceiling_raycast.is_colliding():
		duck = false
		
	if duck:
		small_collision.set_deferred("disabled", false)
		big_collision.set_deferred("disabled", true)
		rock_detector_collision.position.y = -0.5
	else:
		small_collision.set_deferred("disabled", true)
		big_collision.set_deferred("disabled", false)
		rock_detector_collision.position.y = -24.5

func animate():
	if Global.tux_star_invincible:
		big_stars_image.visible = true

	if TuxManager.current_state == TuxManager.powerup_states.Fire:
		fire_image.visible = true
		big_image.visible = false
	
	if not is_on_floor() and not skid and not buttjump and not duck and not flap_count > 0:
		big_image.play("jump")
		fire_image.play("jump")
	elif not is_on_floor() and not skid and not buttjump and not duck and flap_count > 0:
		if not big_image.animation == "flap": # won't work well if max_flaps is increased!
			big_image.play("flap")
			fire_image.play("flap")
	elif is_on_floor() and skid and not in_cutscene and not buttjump and not duck:
		big_image.play("skid")
		fire_image.play("skid")
	elif not abs(velocity.x) == 0 and not is_on_wall() and not skid and not buttjump and not duck:
		big_image.play("walk")
		fire_image.play("walk")
	elif velocity.x == 0 and not skid and not buttjump and not duck:
		big_image.play("stand")
		fire_image.play("stand")
	elif not is_on_floor() and buttjump and not duck:
		big_image.play("buttjump")
		fire_image.play("buttjump")

	if is_on_wall() and is_on_floor() and not duck:
		big_image.play("stand")
		fire_image.play("stand")
	
	if duck:
		big_image.play("duck")
		fire_image.play("duck")
	
	if TuxManager.facing_direction == -1:
		big_image.flip_h = true
		fire_image.flip_h = true
	elif TuxManager.facing_direction == 1:
		big_image.flip_h = false
		fire_image.flip_h = false

func damage():
	if not invincible or Global.tux_star_invincible:
		invincible = true
		print("3:")
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			TuxManager.current_state = TuxManager.powerup_states.Big
			max_fireballs_allowed = 2
			death_sound.play()
		elif TuxManager.current_state == TuxManager.powerup_states.Big:
			die() # add health system soon :3 :3 :3 :3 :3
		
		reload_player() # in case you're confused at what this is, it came from peppertux-haxe.
		await get_tree().create_timer(inv_seconds).timeout
		invincible = false
	else:
		print("Tux is invincible.")
		print("If this is after touching the goal, Tux would usually be able to kill enemies.")
		print("If he is star invincible, he just killed that enemy you touched.")

func reload_player():
	print("Reloading player...")
	if TuxManager.current_state == TuxManager.powerup_states.Fire:
		Global.tux_state = TuxManager.current_state
		small_collision.set_deferred("disabled", true)
		big_image.visible = false
		big_collision.set_deferred("disabled", false)
		fire_image.visible = true
		rock_detector_collision.position.y = -24.5
	elif TuxManager.current_state == TuxManager.powerup_states.Big:
		Global.tux_state = TuxManager.current_state
		small_collision.set_deferred("disabled", true)
		big_image.visible = true
		big_collision.set_deferred("disabled", false)
		fire_image.visible = false
		rock_detector_collision.position.y = -24.5

func stomp_bounce():
	if Input.is_action_pressed("player_jump"):
		velocity.y = -min_jump_height
	else:
		velocity.y = -min_jump_height / 2
	
func hold_object(object):
	if held_object == null:
		held_object = object
		object.pick_up(self)

func throw_object():
	if not held_object == null:
		held_object.throw(TuxManager.facing_direction) # should probably remove the argument from throw()
		held_object = null

func grow(powerup:String):
	if powerup == "egg":
		TuxManager.current_state = TuxManager.powerup_states.Big
		grow_sound.play()
		reload_player()
	elif powerup == "fire_flower":
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			max_fireballs_allowed += 1
		TuxManager.current_state = TuxManager.powerup_states.Fire
		flower_sound.play()
		reload_player()
	else: # so the game doesn't crash
		print("Tux: That is not a valid power-up. Not growing. I refuse to.")

func shoot():
	if TuxManager.current_state == TuxManager.powerup_states.Fire and Input.is_action_just_pressed("player_action") and can_shoot_bullets:
		var fire_bullet = load("uid://c0xvn5d7j0sdu").instantiate()
		get_tree().current_scene.call_deferred("add_child", fire_bullet)
		bullet_sound.play()
		fire_bullet.position = self.position + Vector2(16, 4)
		fire_bullet.set_direction(TuxManager.facing_direction, self)

func _on_stompable_object_detected(area):
	if area.is_in_group("BouncingEnemyTuxDetector") and area.get_parent():
		invincible = true
		await get_tree().create_timer(0.1).timeout
		invincible = false

#func get_star():
	#if not in_cutscene:
		#Global.tux_star_invincible = true
		#
		#$InvincibleSound.play()
		#Music.stream = load(invincible_music)
		#Music.play()
		#
		#$StarTimer.start()

#func _on_star_timer_finished():
	#if not in_cutscene: # NOTE: May cause problems later, but it's here because of the goal. TODO 2193824: Add a way to disable star_invincible in scripting blocks
		#Global.tux_star_invincible = false
		#Music.stream = load(Global.sector_song)
		#Music.play()
