extends TileMap

@export var noise_imagen: NoiseTexture2D
@export var cave_noise_imagen: NoiseTexture2D

var width = 2000
var height = 100

var dirt_grass_atlas = Vector2i(0,0)
var dirt_atlas = Vector2i(1,0)

var tile_arg: Array = []

func _ready():
	var noise: FastNoiseLite = noise_imagen.noise
	var noise_height 
	var cave_noise: FastNoiseLite = cave_noise_imagen.noise
	for x in width:
		noise_height = int(noise.get_noise_1d(x) * 10)

		for y in height:
			if y > 5:
				set_cell(1, Vector2i(x, noise_height + y),0, dirt_atlas)


			if cave_noise.get_noise_2d(x,y) < 0.4:
				tile_arg.append(Vector2i(x, noise_height + y))


		if tile_arg.find(Vector2i(x, noise_height + 1)) != 1:
			tile_arg.append(Vector2i(x, noise_height))
				

	BetterTerrain.set_cells(self, 0, tile_arg, 0)
	BetterTerrain.update_terrain_cells(self, 0, tile_arg, true)

