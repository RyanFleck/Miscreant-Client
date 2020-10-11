extends Node2D

onready var uuid = preload("uuid.gd").new()

var id = null
var connection = null
var peerstream = null
var velocity = Vector2()
export (int) var speed = 200
var values = [
	true,false,
	1, -1, 500, -500,
	1.2, -1.2, 50.1, -50.1, 80.852078542,
	"test1", "test2", "test3"
]
var test = null
var actions = []

func _ready():
	print("Start client TCP")
	# Assign ID
	id = uuid.v4()
	# Connect
	connection = StreamPeerTCP.new()
	connection.connect_to_host("127.0.0.1", 1984)
	peerstream = PacketPeerStream.new()
	peerstream.set_stream_peer(connection)

func _process(delta):
	get_input()
	if connection.is_connected_to_host():
		if connection.get_available_bytes() > 0 :
			test = connection.get_var()
			print(test)
		if values.size() > 0 :
			peerstream.put_var(id+","+str(velocity.x)+","+str(velocity.y))
		else:
			peerstream.put_var(id+","+str(velocity.x)+","+str(velocity.y))
	else:
		print("Attempting connection to host...")
		connection.connect_to_host("127.0.0.1", 1984)
		peerstream = PacketPeerStream.new()
		peerstream.set_stream_peer(connection)


func _on_Button_pressed():
	# Start the server
	pass


func _on_Button2_pressed():
	# Start the client
	pass

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	velocity = velocity.normalized()
