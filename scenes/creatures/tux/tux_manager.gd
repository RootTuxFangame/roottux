extends CharacterBody2D

enum powerup_states {Small, Big, Fire}

# Used for Iceblocks. Moved it here in GodotTux so whatever...
var facing_direction:int = 1

# This is the thing I moved here for Bonus Blocks in GodotTux
var current_state:TuxManager.powerup_states = Global.tux_state
