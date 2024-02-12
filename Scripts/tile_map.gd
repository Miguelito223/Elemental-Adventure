extends TileMap

@export var noise_imagen: NoiseTexture2D
@export var cave_noise_imagen: NoiseTexture2D
@export var rock_noise_imagen: NoiseTexture2D
@onready var noise: FastNoiseLite = noise_imagen.noise
@onready var cave_noise: FastNoiseLite = cave_noise_imagen.noise
@onready var rock_noise: FastNoiseLite = rock_noise_imagen.noise

var width = 1000
var height = 100

var dirt_grass_atlas = Vector2i(0,0)
var dirt_atlas = Vector2i(1,0)
var rock_atlas = Vector2i(4,0)

var tile_arg: Array = []

var noise_height 

var noise_seed
var cave_noise_seed
var rock_noise_seed

func _ready():
	if not get_parent().get_parent().multiplayer.is_server():
		rpc("get_noise_seeds")

	noise_seed = randi()
	cave_noise_seed = randi()
	rock_noise_seed = randi()
	world_generation_server()

		

func get_noise_seeds():
    # Enviar semillas de ruido al cliente
	rpc("set_noise_seeds", noise_seed, cave_noise_seed, rock_noise_seed)

func set_noise_seeds(noise_seed_server, cave_noise_seed_server, rock_noise_seed_server):
    # Recibir semillas de ruido del servidor en el cliente
	noise_seed = noise_seed_server
	cave_noise_seed = cave_noise_seed_server
	rock_noise_seed = rock_noise_seed_server

    # Generar mundo con las semillas de ruido recibidas
	send_world_generation_to_client.rpc(noise_seed, cave_noise_seed, rock_noise_seed)


@rpc("authority", "call_remote")
func world_generation_server():
	noise.seed = noise_seed
	cave_noise.seed = cave_noise_seed
	rock_noise.seed = rock_noise_seed

	for x in range(width):
		noise_height = int(noise.get_noise_1d(x) * 10)

		for y in range(height):
			if y > 5:
				set_cell(0, Vector2i(x, noise_height + y), 1, dirt_atlas)

			if cave_noise.get_noise_2d(x,y) < 0.4:
				if rock_noise.get_noise_2d(x,y) < -0.4:
					set_cell(0, Vector2i(x, noise_height + y), 0, rock_atlas)
				else:
					tile_arg.append(Vector2i(x, noise_height + y))

		if not tile_arg.find(Vector2i(x, noise_height + 1)):
			tile_arg.append(Vector2i(x, noise_height))

	BetterTerrain.set_cells(self, 0, tile_arg, 0)
	BetterTerrain.update_terrain_cells(self, 0, tile_arg, true)

@rpc("any_peer", "call_local")
func send_world_generation_to_client(noise_seed, noise_cave_seed, noise_rock_seed):
	noise.seed = noise_seed
	cave_noise.seed = cave_noise_seed
	rock_noise.seed = rock_noise_seed

	for x in range(width):
		noise_height = int(noise.get_noise_1d(x) * 10)

		for y in range(height):
			if y > 5:
				set_cell(0, Vector2i(x, noise_height + y), 1, dirt_atlas)

			if cave_noise.get_noise_2d(x,y) < 0.4:
				if rock_noise.get_noise_2d(x,y) < -0.4:
					set_cell(0, Vector2i(x, noise_height + y), 0, rock_atlas)
				else:
					tile_arg.append(Vector2i(x, noise_height + y))

		if not tile_arg.find(Vector2i(x, noise_height + 1)):
			tile_arg.append(Vector2i(x, noise_height))

	BetterTerrain.set_cells(self, 0, tile_arg, 0)
	BetterTerrain.update_terrain_cells(self, 0, tile_arg, true)