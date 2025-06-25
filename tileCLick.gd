extends TileMapLayer

var coordinates_array: Array[Vector3i]

#Arrays of all the types of tiles

var totalTiles = [coordinates_array]
var portConnectArray = []
#Indexing Array for all tiles

var currentcell = Vector2i()
#Checker to stop tiles from being swapped every frame
var tileType = 0
var port: bool
var portplaced: bool
#var portcell = Vector2i()
var portConnectOptions = []
var oldPortNear = []
var nearCounter = 0


func _unhandled_input(event):
	#changes what type of tile is being placed
	#Takes in input every frame of the application
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	#Checks if left click is being pressed or held, and if the mouse is moving from cell to cell
		if local_to_map(event.position) != currentcell:
			if not portplaced and not Vector3i(local_to_map(event.position).x, local_to_map(event.position).y, tileType) in coordinates_array:
		#Checks if it is already in the array you're trying to put it in or not
				coordinates_array.append(Vector3i(local_to_map(event.position).x, local_to_map(event.position).y, tileType))
				if get_cell_source_id(local_to_map(event.position)) != -1:
					coordinates_array.erase(Vector3i(local_to_map(event.position).x, local_to_map(event.position).y, tileType))
				#Removes tile from any other array it might be in
				if not port:
					set_cell(local_to_map(event.position), tileType, Vector2i(0,0))
					currentcell = local_to_map(event.position)
				
				if port:
					portConnectOptions = get_surrounding_cells(local_to_map(event.position))
					for neighbor in portConnectOptions:
						oldPortNear.append(get_cell_source_id(neighbor))
						set_cell(neighbor, 13, Vector2i(0,0))
						portplaced = true
					
			elif not portplaced and Vector3i(local_to_map(event.position).x, local_to_map(event.position).y, tileType) in coordinates_array:
				#Erases the cell if it's already there
				coordinates_array.erase(Vector3i(local_to_map(event.position).x, local_to_map(event.position).y, tileType))
				erase_cell(local_to_map(event.position))
				currentcell = local_to_map(event.position)
			elif portplaced:
				if not Vector2i(local_to_map(event.position)) in portConnectOptions:
					print("DIE")
				else:
					portConnectArray.append(local_to_map(event.position))
					print(portConnectOptions)
					print(oldPortNear)
					for neighbor in portConnectOptions:
						set_cell(neighbor, oldPortNear[portConnectOptions.find(neighbor)], Vector2i(0,0))
					portplaced = false
					portConnectOptions = []
					oldPortNear = []
			
	elif event is InputEventKey:
		#Saves to file
		if event.key_label == KEY_ESCAPE:
			saveToFile("res://test.txt", coordinates_array)
			openFile("res://test.txt")
		if event.key_label == KEY_B:
			for neighbor in portConnectOptions:
				set_cell(neighbor, oldPortNear[nearCounter], Vector2i(0,0))
			portplaced = false
			portConnectOptions = []
			oldPortNear = []

func saveToFile(path: String, allArrays):
	var file = FileAccess.open(path, FileAccess.WRITE_READ)
	file.store_line(var_to_str(allArrays))
	file.store_line(var_to_str(portConnectArray))
	
func openFile(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var array = str_to_var(file.get_line())
	print(array[0])
		
func _on_random_toggled(_toggled_on: bool) -> void:
	if port:
		tileType = 7
	elif not port:
		tileType = 0
	
func _on_wood_toggled(_toggled_on: bool) -> void:
	if port:
		tileType = 8
	elif not port:
		tileType = 1

func _on_brick_toggled(_toggled_on: bool) -> void:
	if port:
		tileType = 9
	elif not port:
		tileType = 2

func _on_sheep_toggled(_toggled_on: bool) -> void:
	if port:
		tileType = 10
	elif not port:
		tileType = 3

func _on_wheat_toggled(_toggled_on: bool) -> void:
	if port:
		tileType = 11
	elif not port:
		tileType = 4

func _on_stone_toggled(_toggled_on: bool) -> void:
	if port:
		tileType = 12
	elif not port:
		tileType = 5

func _on_desert_toggled(_toggled_on: bool) -> void:
	tileType = 6
	

func PortToggle(toggled_on: bool) -> void:
	if toggled_on:
		port = true
		%Desert.disabled = true
		if %Desert.button_pressed:
			%Desert.button_pressed = false
			%Random.button_pressed = true
	elif not toggled_on:
		%Desert.disabled = false
		port = false
