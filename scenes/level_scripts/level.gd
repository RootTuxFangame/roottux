extends Node2D
class_name Level

## Name of the level.[br]Shows up in the level intro (doesn't exist yet) but not the worldmap.
@export var level_name:String = "Unnamed"
## Your name goes here.[br][br]Shows up in the level intro.[br]Set this to blank if you don't want to be credited.
@export var level_creator:String = "Level Creator"
## The license for your level.[br][br]Doesn't show up anywhere.[br]You can use multiple licenes if you want.[br]I don't recommend changing this unless you know what you're doing.
@export var license:String = "CC-BY-SA 4.0"
## A note for your level.[br][br]Doesn't show up anywhere.[br]Useful for saying that your level is unfinished.
@export var level_note:String
## The sector that the player goes to when loading the level.
@export var main_sector:String = "main"
## The spawnpoint that the player goes to when loading the level.
@export var main_spawnpoint:String = "main"
## Whether the keys should be displayed or not. Doesn't affect keys in level, only HUD.
@export var show_keys:bool = false

var sector_name_to_use:String

# AnatolyStev: makes the switching sector!!!

# tux
@onready var tux = $Tux
@onready var tux_camera = $Tux/Camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_sector()
	activate_sector(sector_name_to_use)
	TuxManager.current_state = Global.tux_state
	print(TuxManager.current_state)
	print("Useful level debugging info, possibly:")
	print("Width in pixels: " + str(Global.width_of_level) + ". If this is 0, and you didn't set Level Width to 0, there's most likely a bug you should report.")
	print("Height in pixels: " + str(Global.height_of_level) + ". If this is 0, and you didn't set Level Height to 0, there's most likely a bug you should report.")
	print("No more useful level debugging info.")

func _process(_delta: float) -> void:
	if Global.debug and Input.is_key_pressed(KEY_0):
		finish_level()

# TODO: Replace worldmap spawnpoint finding with this
func find_spawnpoint():
	if not Global.checkpoint_reached or Global.coins <= 25:
		for spawn in get_tree().get_nodes_in_group("LevelSpawnPoint"):
			if spawn.spawnpoint_name == main_spawnpoint:
				if TuxManager.current_state == TuxManager.powerup_states.Small:
					tux.global_position = spawn.global_position
				else:
					tux.global_position = spawn.global_position - Vector2(0, 23)
	else:
		print("Spawning at checkpoint...")
		if TuxManager.current_state == TuxManager.powerup_states.Small:
			tux.global_position = Global.checkpoint_position
		else:
			tux.global_position = Global.checkpoint_position - Vector2(0, 23)

func find_sector():
	if Global.checkpoint_reached and Global.coins >= 25:
		sector_name_to_use = Global.checkpoint_sector
	else:
		sector_name_to_use = main_sector
	
	for sector in get_tree().get_nodes_in_group("LevelSector"):
		if sector.sector_name == sector_name_to_use:
			find_spawnpoint()

func finish_level():
	Engine.time_scale = 1.0
	Global.tux_star_invincible = false
	if scene_file_path not in Global.completed_levels:
		Global.completed_levels.append(scene_file_path)
	
	if Global.current_worldmap == "":
		get_tree().change_scene_to_file("res://scenes_and_scripts/menu/menu.tscn")
	else:
		get_tree().change_scene_to_file(Global.current_worldmap)

func switch_sector(sector_name:String, spawnpoint_name:String):
	activate_sector(sector_name)
	
	for sector in get_tree().get_nodes_in_group("LevelSector"):
		if sector.sector_name == sector_name:
			find_spawnpoint_in_sector(sector, spawnpoint_name)

func find_spawnpoint_in_sector(sector:Node2D, new_spawnpoint_name:String):
	for spawn in get_tree().get_nodes_in_group("LevelSpawnPoint"):
		if spawn.spawnpoint_name == new_spawnpoint_name:
			tux.call_deferred("reparent", sector)
			if TuxManager.current_state == TuxManager.powerup_states.Small:
				tux.global_position = spawn.global_position
				tux.in_cutscene = false
			else:
				tux.global_position = spawn.global_position - Vector2(0, 23)
				tux.in_cutscene = false

func activate_sector(sector_name:String):
	for sector in get_tree().get_nodes_in_group("LevelSector"):
		if sector.sector_name == sector_name:
			sector.visible = true
			sector.process_mode = Node.PROCESS_MODE_PAUSABLE
			Global.width_of_level = sector.sector_width * 32
			Global.height_of_level = sector.sector_height * 32
			tux_camera.limit_top = -Global.height_of_level
			tux_camera.limit_right = Global.width_of_level
			if not Global.tux_star_invincible:
				if not Global.sector_song == sector.song:
					Music.stream = load(sector.song)
					Music.play()
			Global.sector_song = sector.song
		else:
			sector.visible = false
			sector.process_mode = Node.PROCESS_MODE_DISABLED
