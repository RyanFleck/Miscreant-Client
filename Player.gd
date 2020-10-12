extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#preload var handyman: HandyMan = get_node("HandyMan")
onready var handyman = get_node("HandyMan")

# Called when the node enters the scene tree for the first time.
func _ready():
	handyman.set_color(Color(0,150,0))



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
