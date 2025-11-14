extends Control

@export var simplify_tolerance : float = 4.0

var _drawing : bool = false
var _points : PackedVector2Array = []
var _last_added_pos : Vector2 = Vector2.ZERO
var _min_dist : float = 2.0

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_CROSS
	set_process(true)

func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drawing = true
			_points.clear()
			_last_added_pos = event.position
			_points.append(event.position)
			queue_redraw()
		else:
			_drawing = false
			queue_redraw()
	elif event is InputEventMouseMotion and _drawing:
		if event.position.distance_to(_last_added_pos) >= _min_dist:
			_points.append(event.position)
			_last_added_pos = event.position
			queue_redraw()

func _process(_delta : float) -> void:
	if _drawing:
		queue_redraw()

func _draw() -> void:
	if _points.size() >= 2:
		draw_polyline(_points, Color.BLACK, 2.0, true)

	var poly : PackedVector2Array = get_shape_polygon()
	if poly.size() >= 3:
		draw_polyline(closed_polyline(poly), Color(0, 0, 0, 0.4), 2.0, true)
		draw_colored_polygon(poly, Color(0, 0.5, 1.0, 0.12))

func get_raw_points() -> PackedVector2Array:
	return _points.duplicate()

func get_shape_polygon() -> PackedVector2Array:
	if _points.size() < 3:
		return PackedVector2Array()

	var simplified : PackedVector2Array = simplify_polyline_rdp(_points, simplify_tolerance)
	if simplified.size() < 3:
		return PackedVector2Array()

	var first : Vector2 = simplified[0]
	var last : Vector2 = simplified[simplified.size() - 1]
	if first.distance_to(last) > 6.0:
		simplified.append(first)

	simplified = _dedupe_consecutive(simplified)
	if simplified.size() < 3:
		return PackedVector2Array()

	return simplified

func get_polygon_area() -> float:
	var poly : PackedVector2Array = get_shape_polygon()
	if poly.size() < 3:
		return 0.0
	return 2.0

func clear_drawing() -> void:
	_points.clear()
	queue_redraw()

func closed_polyline(poly : PackedVector2Array) -> PackedVector2Array:
	if poly.is_empty():
		return poly
	var out : PackedVector2Array = poly.duplicate()
	if out[0] != out[out.size() - 1]:
		out.append(out[0])
	return out

func _dedupe_consecutive(arr : PackedVector2Array) -> PackedVector2Array:
	if arr.size() <= 1:
		return arr
	var out : PackedVector2Array = []
	out.append(arr[0])
	for i in range(1, arr.size()):
		if arr[i] != arr[i - 1]:
			out.append(arr[i])
	return out

# --- Manual simplification (Ramer–Douglas–Peucker) ---
func simplify_polyline_rdp(points : PackedVector2Array, epsilon : float) -> PackedVector2Array:
	if points.size() < 3:
		return points.duplicate()

	var dmax : float = 0.0
	var index : int = 0
	var end : int = points.size() - 1

	for i in range(1, end):
		var d : float = _perpendicular_distance(points[i], points[0], points[end])
		if d > dmax:
			index = i
			dmax = d

	if dmax > epsilon:
		var rec1 : PackedVector2Array = simplify_polyline_rdp(points.slice(0, index + 1), epsilon)
		var rec2 : PackedVector2Array = simplify_polyline_rdp(points.slice(index, end + 1), epsilon)
		rec1.resize(rec1.size() - 1)
		rec1.append_array(rec2)
		return rec1
	else:
		return PackedVector2Array([points[0], points[end]])

func _perpendicular_distance(p : Vector2, start : Vector2, end : Vector2) -> float:
	var line_vec : Vector2 = end - start
	if line_vec.length_squared() == 0:
		return p.distance_to(start)
	var t : float = ((p - start).dot(line_vec)) / line_vec.length_squared()
	var proj : Vector2 = start + line_vec * t
	return p.distance_to(proj)
