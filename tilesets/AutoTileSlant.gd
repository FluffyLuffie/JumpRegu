tool
extends TileSet

# warning-ignore:unused_argument
func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	return neighbor_id in get_tiles_ids()
