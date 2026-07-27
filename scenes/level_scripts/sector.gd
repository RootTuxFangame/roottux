extends Node2D
class_name Sector

@export var sector_name:String = "main"
## Width of your sector.
@export var sector_width:int = 100
## Adds to the height of your sector. Name is a bit misleading...
@export var sector_height:int = 0
## Whether the sector has snow particles or not. Make sure you have the snow particles node in this sector!
@export var snowing:bool = false
## Whether the sector has cloud particles or not. Make sure you have the cloud particles node in this sector!
@export var cloudy:bool = false
## The music for your sector.
@export_file("*.ogg", "*.wav") var song = "res://data/music/chipdisko.ogg"
## What song should be played when the level is done?
@export_file("*.ogg", "*.wav") var level_done_music = "res://data/music/leveldone.ogg"
## How many seconds should the game wait before putting the player back in the worldmap / level select?
## Set this to how long your "finish level" song is, if you changed it.
## Godot should really add a way to check the length of a sound... if it doesn't already.
@export var wait_to_end_level:float = 3.855

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("LevelSector")
	$Goal.connect("level_finished", _on_level_finished)

func _process(_delta: float) -> void:
	if snowing:
		$SnowParticles.visible = true
		$SnowParticles.global_position = get_parent().tux_camera.global_position - Vector2(0, 450)
	if cloudy:
		$CloudParticles.visible = true
		$CloudParticles.global_position = get_parent().tux_camera.global_position - Vector2(0, 450)

func _on_level_finished() -> void:
	Global.checkpoint_reached = false
	Music.stream = load(level_done_music)
	print(Music.stream) # Helpful debug thing.
	Music.play()
	await get_tree().create_timer(wait_to_end_level).timeout
	get_parent().finish_level()

func fade_tilemap(tilemap_to_fade:String):
	var tilemap = get_node(tilemap_to_fade)
	var fade_tween = create_tween()
	fade_tween.tween_property(tilemap, "modulate:a", 0.0, 1.0)
	fade_tween.tween_callback(tilemap.queue_free)
