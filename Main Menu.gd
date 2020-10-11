extends Node2D

onready var uuid = preload("uuid.gd").new()

# The URL we will connect to
# DEVELOPMENT VARIABLE
export var websocket_url = "ws://miscreant-services-v1.herokuapp.com/"
#export var websocket_url = "ws://localhost:8080"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var id = null
var ready = false

onready var MessageEditor = get_node("MessageEditor")
onready var MessageWindow = get_node("MessageWindow")
onready var SendMessageButton = get_node("SendMessageButton")
var messages = [ "System: Welcome to Miscreant!" ]

func update_message_window(new_message):
	messages.push_front(new_message)
	messages = messages.slice(0,5)
	var text = ""
	for item in messages:
		text = text + item + "\n"
	
	# Set the messagewindow text to this.
	MessageWindow.text = text

func _ready():
	print("Main menu is ready.")
	id = uuid.v4()
	
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	update_message_window("Sys: Disconnected from Server.")
	get_node("ServerButton").text = "Disconnected. Click to reconnect."
	ready = false

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	update_message_window("Sys: Connected to Server.")
	get_node("ServerButton").text = "Connected."
	ready = true
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	var auth_string = "Auth "+id
	_client.get_peer(1).put_packet(auth_string.to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", data)
	if data.begins_with("alive?"):
		_client.get_peer(1).put_packet("yep".to_utf8())
	elif data.begins_with("msg"):
		# Repeat message to self.
		update_message_window(data.trim_prefix("msg "))
	

	

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


func _on_ServerButton_pressed():
	get_node("ServerButton").text = "Connecting..."
	
	if ready == true:
		get_node("ServerButton").text = "Still connected."
		return
	
	print("Connecting to websocket...")
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		get_node("ServerButton").text = "Failed. Click to retry."


func _on_SendMessageButton_pressed():
	var content = "msg "+MessageEditor.text.strip_edges()
	MessageEditor.text = ""
	_client.get_peer(1).put_packet(content.to_utf8())

