extends TileMap

@export var noise_imagen: NoiseTexture2D
@export var cave_noise_imagen: NoiseTexture2D
@export var rock_noise_imagen: NoiseTexture2D
@onready var noise: FastNoiseLite = noise_imagen.noise
@onready var cave_noise: FastNoiseLite = cave_noise_imagen.noise
@onready var rock_noise: FastNoiseLite = rock_noise_imagen.noise

var width = 1000
var height = 100

var dirt_grass_atlas = Vector2i(0, 0)
var dirt_atlas = Vector2i(1, 0)
var rock_atlas = Vector2i(4, 0)

var tile_map = self

var tile_arg: Array = []
var rock_arg: Array = []

var noise_height 

var noise_seed
var cave_noise_seed
var rock_noise_seed

func _ready():

	if not Network.is_networking:
		return
		
	if not get_parent().get_parent().multiplayer.is_server():
		request_seeds(1)
	else:
		generate_seeds()
		receive_seeds.rpc(noise_seed, cave_noise_seed,rock_noise_seed)


func generate_seeds():
	noise_seed = randi()
	cave_noise_seed = randi()
	rock_noise_seed = randi()
	

func request_seeds(id):
	receive_seeds.rpc_id(id, noise_seed, cave_noise_seed,rock_noise_seed)
	
	
@rpc("call_local", "authority", "reliable")
func receive_seeds(received_noise_seed, received_cave_noise_seed, received_rock_noise_seed):
	print("recibiendo semillas...")
	noise_seed = received_noise_seed
	cave_noise_seed = received_cave_noise_seed
	rock_noise_seed = received_rock_noise_seed
	world_generation()

func world_generation():
	print("Generating world...")
	
	print(noise_seed,cave_noise_seed,rock_noise_seed )

	noise.seed = noise_seed
	cave_noise.seed = cave_noise_seed
	rock_noise.seed = rock_noise_seed

	for x in range(width):
		noise_height = int(noise.get_noise_1d(x) * 10)

		for y in range(height):
			if y > 5:
				set_cell(0, Vector2i(x, noise_height + y), 1, dirt_atlas)

			if (cave_noise.get_noise_2d(x, y) > 0.6) and y > 20:	
				rock_arg.append(Vector2i(x, y))
			else:
				tile_arg.append(Vector2(x, noise_height+y))

		if not tile_arg.find(Vector2i(x, noise_height + 1)):
			tile_arg.append(Vector2i(x, noise_height))
			var rand_num = randi_range(0,20)
			if rand_num == 1:
				set_cell(0, Vector2(x, noise_height-1),0, dirt_grass_atlas)

	BetterTerrain.set_cells(self, 0, tile_arg, 0)
	BetterTerrain.update_terrain_cells(self, 0, tile_arg, true)

	BetterTerrain.set_cells(tile_map, 0,rock_arg, 1)
	BetterTerrain.update_terrain_cells(tile_map, 0,rock_arg,true )
