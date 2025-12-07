extends TextureRect

@export var disabled : bool = false
@export var element : SignalBus.Element = SignalBus.Element.Water
@export var line_width : float = 6.0
@export var line_color : Color = Color.BLACK
@export var min_point_dist : float = 2.0
@export var show_outline : bool = true
@export var outline_fill : Color = Color(0, 0.5, 1.0, 0.10)
@export var outline_stroke : Color = Color(0, 0, 0, 0.7)
@export var outline_stroke_width : float = 2.0
@export var saved_fill : Color = Color(0.1, 0.8, 0.2, 0.5)
@export var saved_stroke : Color = Color(0.1, 0.8, 0.2, 1.0)
@export var simplify_enable : bool = true
@export var simplify_distance : float = 2.0
@export var simplify_collinear : float = 1.0
@onready var sav: TextureButton = $Sav
@onready var und: TextureButton = $Und
@onready var del: TextureButton = $Del
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var showing : bool = false
var strokes : Array[PackedVector2Array] = []
var current : PackedVector2Array = PackedVector2Array()
var polygons : Array[PackedVector2Array] = []
var is_drawing : bool = false

func _ready() -> void:
	SignalBus.allow_spell_crafting.connect(enable_drawing_area)
	SignalBus.stop_spell_crafting.connect(disable_drawing_area)
	rich_text_label.bbcode_enabled = true
	rich_text_label.scroll_active = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	disable_drawing_area()
	queue_redraw()

func _gui_input(event : InputEvent) -> void:
	var existing_polygon : bool = len(polygons) >= 1 or len(strokes) >= 1
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not existing_polygon:
		start_stop_draw(event)
	elif event is InputEventMouseMotion and is_drawing and not existing_polygon:
		move_and_draw(event)

func move_and_draw(event : InputEvent):
	if current.is_empty():
		current.append(event.position)
		queue_redraw()
		return
	var last : Vector2 = current[current.size() - 1]
	if event.position.distance_to(last) >= min_point_dist:
		current.append(event.position)
		queue_redraw()

func start_stop_draw(event : InputEvent):
	if event.pressed:
		is_drawing = true
		current = PackedVector2Array()
		current.append(event.position)
		queue_redraw()
	else:
		is_drawing = false
		if current.size() >= 2:
			strokes.append(current)
		current = PackedVector2Array()
		queue_redraw()

func undo_last_drawing():
	if strokes.size() > 0:
		strokes.resize(strokes.size() - 1)
		queue_redraw()
		accept_event()

func clear_unsaved_polygons():
	strokes.clear()
	current = PackedVector2Array()
	is_drawing = false
	queue_redraw()
	accept_event()

func save_all_polygons():
	var outlines : Array[PackedVector2Array] = get_outline_polygons(line_width * 0.5)
	if outlines.is_empty():
		return

	for poly in outlines:
		poly = _simplify_polygon(poly, simplify_distance, simplify_collinear)
		poly.append(poly[0])
		var area : float = polygon_area(poly)
		var max_area : float = self.size.x * self.size.y
		var percentage_area : float = area/max_area
		if poly.size() < 150 and percentage_area < 1:
			polygons.append(poly)
			print("Saved polygon with ", poly.size(), " vertices and ", percentage_area, " area.")
			SignalBus.update_poly.emit(poly, percentage_area, element)
		
	strokes.clear()
	current = PackedVector2Array()
	queue_redraw()
	accept_event()

func remove_all_polygons():
	polygons.clear()
	clear_unsaved_polygons()
	queue_redraw()
	accept_event()

func disable_drawing_area():
	rich_text_label.clear()
	rich_text_label.append_text("[font_size=24][wave]Return to the grove to change your spells[/wave][/font_size]")
	disabled = true
	del.hide()
	und.hide()
	sav.hide()

func enable_drawing_area():
	disabled = false
	rich_text_label.clear()
	del.show()
	und.show()
	sav.show()

func _draw() -> void:
	if !disabled:
		for stroke in strokes:
			if stroke.size() >= 2:
				draw_polyline(stroke, line_color, line_width, true)
		if current.size() >= 2:
			draw_polyline(current, line_color, line_width, true)
		if show_outline:
			var outlines : Array[PackedVector2Array] = get_outline_polygons(line_width * 0.5)
			for poly in outlines:
				if poly.size() >= 3:
					draw_colored_polygon(poly, outline_fill)
					var closed : PackedVector2Array = poly.duplicate()
					closed.append(poly[0])
					draw_polyline(closed, outline_stroke, outline_stroke_width, true)
		for poly in polygons:
			if poly.size() >= 3:
				draw_colored_polygon(poly, saved_fill)
				var closed_saved : PackedVector2Array = poly.duplicate()
				closed_saved.append(poly[0])
				draw_polyline(closed_saved, saved_stroke, outline_stroke_width, true)


func get_outline_polygons(half_width: float) -> Array[PackedVector2Array]:
	var outlines: Array[PackedVector2Array] = []

	for stroke in strokes:
		if stroke.size() >= 2:
			for poly in Geometry2D.offset_polyline(stroke, half_width):
				if poly.size() >= 3:
					outlines.append(poly)

	if current.size() >= 2:
		for poly in Geometry2D.offset_polyline(current, half_width):
			if poly.size() >= 3:
				outlines.append(poly)

	if outlines.is_empty():
		return []

	var merged: Array[PackedVector2Array] = []

	for outline in outlines:
		var absorbed := false

		for i in range(merged.size()):
			var result: Array = Geometry2D.merge_polygons(merged[i], outline)

			if result.size() == 1:
				merged[i] = result[0]
				absorbed = true
				break

		if not absorbed:
			merged.append(outline)

	return merged

func is_collinear(point_a : Vector2, point_b : Vector2, point_c : Vector2, tolerance : float) -> bool:
	var closest_point_to_segment : Vector2 = Geometry2D.get_closest_point_to_segment(point_b, point_a, point_c)
	return point_b.distance_to(closest_point_to_segment) <= tolerance

func _remove_duplicate_points(poly : PackedVector2Array) -> PackedVector2Array:
	if poly.size() <= 1:
		return poly
	var deduped_poly : PackedVector2Array = PackedVector2Array([poly[0]])
	for i in range(1, poly.size()):
		if poly[i] != poly[i - 1]:
			deduped_poly.append(poly[i])
	return deduped_poly

func _rdp_polyline(points : PackedVector2Array, epsilon : float) -> PackedVector2Array:
	if points.size() < 3:
		return points.duplicate()
		
	var max_distance : float = 0.0
	var index : int = 0
	var end_point : int = points.size() - 1
	
	for i in range(1, end_point):
		var closest_point : Vector2 = Geometry2D.get_closest_point_to_segment(points[i], points[0], points[end_point])
		var distance : float = points[i].distance_to(closest_point)
		if distance > max_distance:
			max_distance = distance
			index = i
	
	if max_distance > epsilon:
		var left : PackedVector2Array = _rdp_polyline(points.slice(0, index + 1), epsilon)
		var right : PackedVector2Array = _rdp_polyline(points.slice(index, end_point + 1), epsilon)
		left.resize(left.size() - 1)
		left.append_array(right)
		return left
	else:
		return PackedVector2Array([points[0], points[end_point]])

func _simplify_polygon(poly : PackedVector2Array, distance_epsilon : float, _collinear_epsilon : float) -> PackedVector2Array:
	if poly.size() < 3:
		return poly
		
	var cleaned_poly : PackedVector2Array = _remove_duplicate_points(poly)
	if cleaned_poly.size() < 3:
		return cleaned_poly
		
	var opened : PackedVector2Array = cleaned_poly.duplicate()
	opened.append(cleaned_poly[0])
	var rdp : PackedVector2Array = _rdp_polyline(opened, distance_epsilon)
	
	if rdp.size() >= 2 and rdp[0] == rdp[rdp.size() - 1]:
		rdp.resize(rdp.size() - 1)
	
	if rdp.size() < 3:
		rdp = cleaned_poly
	
	var changed : bool = true
	
	while changed and rdp.size() >= 3:
		changed = false
		var out2 : PackedVector2Array = PackedVector2Array()
		for i in range(rdp.size()):
			var prev_vertex : Vector2 = rdp[(i - 1 + rdp.size()) % rdp.size()]
			var current_vertex : Vector2 = rdp[i]
			var next_vertex : Vector2 = rdp[(i + 1) % rdp.size()]
			if is_collinear(prev_vertex, current_vertex, next_vertex, _collinear_epsilon):
				changed = true
			else:
				out2.append(current_vertex)
		rdp = out2
	return rdp

func polygon_area(poly : PackedVector2Array) -> float:
	var area := 0.0
	var n := poly.size()
	if n < 3:
		return 0.0

	for i in range(n):
		var j := (i + 1) % n
		area += poly[i].x * poly[j].y
		area -= poly[j].x * poly[i].y

	return abs(area) * 0.5
