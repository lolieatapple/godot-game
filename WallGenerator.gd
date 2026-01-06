@tool
extends EditorScript

# 配置参数
@export var num_wall_groups: int = 10  # 生成多少组墙
@export var min_wall_length: int = 4  # 最小墙长度
@export var max_wall_length: int = 12  # 最大墙长度
@export var min_distance_from_center: float = 15.0  # 距离中心的最小距离
@export var max_distance_from_center: float = 40.0  # 距离中心的最大距离
@export var min_wall_spacing: int = 3  # 墙之间的最小间距

func _run() -> void:
	var scene_root = get_scene()
	if scene_root == null:
		print("错误：请先打开 Main.tscn 场景")
		return

	var wall_layer: TileMapLayer = scene_root.get_node_or_null("wall")
	if wall_layer == null:
		print("错误：找不到 'wall' TileMapLayer 节点")
		return

	print("==================================================")
	print("开始分析和生成随机墙...")
	print("==================================================")

	# 分析现有的墙瓦片
	var wall_tile_variants: Array = analyze_existing_walls(wall_layer)
	if wall_tile_variants.is_empty():
		print("错误：没有找到现有的墙瓦片")
		return

	print("找到 %d 种墙瓦片样式" % wall_tile_variants.size())
	for variant in wall_tile_variants:
		print("  - 源ID: %d, 坐标: %s" % [variant.source_id, variant.atlas_coords])

	# 获取现有的墙位置
	var existing_walls: Dictionary = {}
	for cell in wall_layer.get_used_cells():
		existing_walls[cell] = true

	print("现有墙瓦片数量: %d" % existing_walls.size())

	# 生成新的墙
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var generated_count = 0

	for i in range(num_wall_groups):
		var success = generate_wall_segment(wall_layer, wall_tile_variants, existing_walls, rng)
		if success:
			generated_count += 1

	print("==================================================")
	print("墙生成完成！")
	print("成功生成 %d 组墙" % generated_count)
	print("总墙瓦片数量: %d" % wall_layer.get_used_cells().size())
	print("请记得保存场景 (Ctrl+S)")
	print("==================================================")

func analyze_existing_walls(wall_layer: TileMapLayer) -> Array:
	"""分析现有墙使用的瓦片样式"""
	var variants: Dictionary = {}
	var cells = wall_layer.get_used_cells()

	for cell in cells:
		var source_id = wall_layer.get_cell_source_id(cell)
		var atlas_coords = wall_layer.get_cell_atlas_coords(cell)
		var key = "%d_%s" % [source_id, atlas_coords]

		if key not in variants:
			variants[key] = {
				"source_id": source_id,
				"atlas_coords": atlas_coords,
				"count": 0
			}
		variants[key].count += 1

	# 转换为数组并按使用频率排序
	var result: Array = []
	for variant in variants.values():
		result.append(variant)

	result.sort_custom(func(a, b): return a.count > b.count)
	return result

func generate_wall_segment(wall_layer: TileMapLayer, tile_variants: Array, existing_walls: Dictionary, rng: RandomNumberGenerator) -> bool:
	"""生成一段墙"""
	# 随机选择方向：0=水平，1=垂直，2=L形，3=U形
	var wall_type = rng.randi_range(0, 3)
	var wall_length = rng.randi_range(min_wall_length, max_wall_length)

	# 尝试找到一个有效的起始位置
	var attempts = 0
	var start_pos: Vector2i
	var is_valid = false

	while attempts < 100 and not is_valid:
		# 在环形区域内随机选择位置
		var angle = rng.randf() * TAU
		var distance = rng.randf_range(min_distance_from_center, max_distance_from_center)
		start_pos = Vector2i(
			int(cos(angle) * distance),
			int(sin(angle) * distance)
		)

		# 检查这个位置是否有效
		is_valid = is_position_valid(wall_layer, start_pos, existing_walls)
		attempts += 1

	if not is_valid:
		return false

	# 根据墙类型生成墙段
	var cells_to_place: Array = []

	match wall_type:
		0:  # 水平墙
			for j in range(wall_length):
				cells_to_place.append(start_pos + Vector2i(j, 0))
		1:  # 垂直墙
			for j in range(wall_length):
				cells_to_place.append(start_pos + Vector2i(0, j))
		2:  # L形墙
			var half_length = wall_length / 2
			for j in range(half_length):
				cells_to_place.append(start_pos + Vector2i(j, 0))
			for j in range(half_length):
				cells_to_place.append(start_pos + Vector2i(half_length - 1, j))
		3:  # U形墙
			var third_length = wall_length / 3
			for j in range(wall_length):
				cells_to_place.append(start_pos + Vector2i(j, 0))
			for j in range(1, third_length):
				cells_to_place.append(start_pos + Vector2i(0, j))
				cells_to_place.append(start_pos + Vector2i(wall_length - 1, j))

	# 检查所有位置是否有效
	for cell_pos in cells_to_place:
		if not is_position_valid(wall_layer, cell_pos, existing_walls):
			return false

	# 放置墙瓦片
	for cell_pos in cells_to_place:
		# 随机选择墙瓦片样式（偏向使用最常见的）
		var variant_index = 0
		var rand_val = rng.randf()
		if rand_val > 0.3 and tile_variants.size() > 1:
			variant_index = rng.randi_range(0, min(2, tile_variants.size() - 1))

		var variant = tile_variants[variant_index]
		wall_layer.set_cell(cell_pos, variant.source_id, variant.atlas_coords)
		existing_walls[cell_pos] = true

	return true

func is_position_valid(wall_layer: TileMapLayer, pos: Vector2i, existing: Dictionary) -> bool:
	"""检查位置是否有效（没有墙且不太靠近其他墙）"""
	# 检查该位置是否已有墙
	if pos in existing:
		return false

	# 检查最小间距范围内是否有墙
	for x in range(-min_wall_spacing, min_wall_spacing + 1):
		for y in range(-min_wall_spacing, min_wall_spacing + 1):
			var check_pos = pos + Vector2i(x, y)
			if check_pos in existing:
				return false

	return true
