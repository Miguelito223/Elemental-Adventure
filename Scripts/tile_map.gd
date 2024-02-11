extends TileMap

enum {

	GRASS = 0,
	DIRT = 1,
	ROCK = 4,
	SAND = 5,
}

var noise = $noise.texture.noise


func _ready():
	randomize()
	noise.seed = randi() % 1000

	for x in 100:
		var ground = abs(noise.get_noise_2d(x,0) * 60)
		for y in range(ground, 100):
			if noise.get_noise_2d(x, y) > 0: 
				set_cell(0 , Vector2i(x, y), DIRT)
				if randi() % 2 ==  1 and get_cell_source_id(0, Vector2i(x,y-1)) == -1:
					set_cell(0, Vector2i(x,y-1), GRASS)

