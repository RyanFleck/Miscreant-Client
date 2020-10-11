extends Node2D

onready var uuid = preload("uuid.gd").new()

# The URL we will connect to
# DEVELOPMENT VARIABLE
export var websocket_url = "ws://miscreant-services-v1.herokuapp.com/"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var id = null
var connection_attempts = 0
var ready = false

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

	# Initiate connection to the given URL.
	print("Connecting to websocket...")
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		while connection_attempts < 10:
			print("Unable to connect, retrying...")
			_client.connect_to_url(websocket_url)
			if err != OK:
				connection_attempts = connection_attempts + 1
			else:
				connection_attempts = 10
			
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
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
	if "alive?" in data:
		_client.get_peer(1).put_packet("yep".to_utf8())

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
