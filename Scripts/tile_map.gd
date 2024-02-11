extends TileMap

@export var noise_imagen: NoiseTexture2D
@export var cave_noise_imagen: NoiseTexture2D

var width = 1000
var height = 100

var dirt_grass_atlas = Vector2i(0,0)
var dirt_atlas = Vector2i(1,0)

var tile_arg: Array = []

@rpc("call_local", "any_peer")
func generate_terrain():
	var noise: FastNoiseLite = noise_imagen.noise
	var cave_noise: FastNoiseLite = cave_noise_imagen.noise
	cave_noise.seed = randi()
	noise.seed = randi() 
	var noise_height 
	
	for x in width:
		noise_height = int(noise.get_noise_1d(x) * 10)

		for y in height:
			if y > 5:
				set_cell(0, Vector2i(x, noise_height + y),1, dirt_atlas)


			if cave_noise.get_noise_2d(x,y) < 0.4:
				tile_arg.append(Vector2i(x, noise_height + y))


		if tile_arg.find(Vector2i(x, noise_height + 1)) != 1:
			tile_arg.append(Vector2i(x, noise_height))
				

	BetterTerrain.set_cells(self, 0, tile_arg, 0)
	BetterTerrain.update_terrain_cells(self, 0, tile_arg, true)


func _ready():
	generate_terrain.rpc()

