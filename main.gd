extends Node3D

# Feasibility prototype only. No Supabase credentials or production writes.
const MALE := "res://assets/man-base-character.glb"
const FEMALE := "res://assets/woman-base-character.glb"
const EQUIPMENT_DIR := "res://assets/equipment/"

var body: Node3D
var equipment: Node3D
var pivot: Node3D
var camera: Camera3D
var status: Label
var equipment_name: LineEdit
var gender := "male"
var dragging := false
var last_pointer := Vector2.ZERO
var zoom := 4.5

func _ready() -> void:
	_build_scene()
	_build_ui()
	_load_body("male")

func _build_scene() -> void:
	pivot = Node3D.new()
	add_child(pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.4, zoom)
	camera.look_at(Vector3(0, 1.0, 0))
	add_child(camera)
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 2.0
	add_child(light)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("151322")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("a8a4bd")
	env.ambient_light_energy = 0.7
	world.environment = env
	add_child(world)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	floor_mesh.mesh = plane
	floor_mesh.position.y = -0.02
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("292537")
	floor_mesh.material_override = material
	add_child(floor_mesh)

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(310, 0)
	ui.add_child(panel)
	var stack := VBoxContainer.new()
	panel.add_child(stack)
	var title := Label.new()
	title.text = "FRACTURED NEXUS | Godot Test"
	stack.add_child(title)
	status = Label.new()
	status.text = "Waiting for model..."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(status)
	var male_button := Button.new()
	male_button.text = "Load male GLB"
	male_button.pressed.connect(func(): _load_body("male"))
	stack.add_child(male_button)
	var female_button := Button.new()
	female_button.text = "Load female GLB"
	female_button.pressed.connect(func(): _load_body("female"))
	stack.add_child(female_button)
	equipment_name = LineEdit.new()
	equipment_name.placeholder_text = "equipment filename (e.g. iron-helmet.glb)"
	stack.add_child(equipment_name)
	var equip_button := Button.new()
	equip_button.text = "Load equipment GLB"
	equip_button.pressed.connect(_load_equipment)
	stack.add_child(equip_button)
	var clear_button := Button.new()
	clear_button.text = "Remove equipment"
	clear_button.pressed.connect(_clear_equipment)
	stack.add_child(clear_button)
	var hint := Label.new()
	hint.text = "Drag to rotate model. Mouse wheel to zoom.\nModels stay local; no player data is changed."
	stack.add_child(hint)

func _load_body(next_gender: String) -> void:
	gender = next_gender
	if is_instance_valid(body):
		body.queue_free()
		body = null
	_clear_equipment()
	var path := MALE if gender == "male" else FEMALE
	if not ResourceLoader.exists(path):
		status.text = "Missing GLB: " + path + "\nCopy the actual asset into assets/ first."
		return
	var resource := load(path)
	if not (resource is PackedScene):
		status.text = "GLB import failed: " + path
		return
	body = (resource as PackedScene).instantiate() as Node3D
	if body == null:
		status.text = "GLB imported but root is not Node3D."
		return
	pivot.add_child(body)
	status.text = "Loaded " + gender + " GLB. Inspect material, rig and proportions."

func _load_equipment() -> void:
	if not is_instance_valid(body):
		status.text = "Load a body before equipment."
		return
	var filename := equipment_name.text.strip_edges().get_file()
	if filename.is_empty() or not filename.ends_with(".glb"):
		status.text = "Enter an equipment .glb filename."
		return
	var path := EQUIPMENT_DIR + filename
	if not ResourceLoader.exists(path):
		status.text = "Equipment GLB missing: " + path
		return
	var resource := load(path)
	if not (resource is PackedScene):
		status.text = "Equipment import failed: " + path
		return
	_clear_equipment()
	equipment = (resource as PackedScene).instantiate() as Node3D
	if equipment == null:
		status.text = "Equipment GLB root is not Node3D."
		return
	# Basic static attachment test; rigged skin binding requires asset-specific validation.
	body.add_child(equipment)
	status.text = "Equipment loaded: " + filename + "\nCheck alignment and animation binding manually."

func _clear_equipment() -> void:
	if is_instance_valid(equipment):
		equipment.queue_free()
		equipment = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_pointer = event.position
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = max(2.0, zoom - 0.25)
			_update_camera()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = min(9.0, zoom + 0.25)
			_update_camera()
	elif event is InputEventMouseMotion and dragging:
		pivot.rotation.y -= event.relative.x * 0.008
	elif event is InputEventScreenTouch:
		dragging = event.pressed
		last_pointer = event.position
	elif event is InputEventScreenDrag and dragging:
		pivot.rotation.y -= event.relative.x * 0.008

func _update_camera() -> void:
	camera.position = Vector3(0, 1.4, zoom)
	camera.look_at(Vector3(0, 1.0, 0))
