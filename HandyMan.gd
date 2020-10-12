extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var walking = false;
onready var colored_components : Node2D = get_node("Body/Colored")


# Called when the node enters the scene tree for the first time.
func _ready():
	#set_color(Color(200,0,0))
	pass

func set_color(new_color:Color):
	colored_components.modulate = new_color

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
