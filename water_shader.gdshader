shader_type canvas_item;

uniform vec4 tint : source_color = vec4(1.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

//for each pixel on the screen
void fragment(){
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	// mix the color to the tint (30% tint)
	color = mix(color,tint,0.3);
	
	//mix the gray to the current color, so it won't change our current color
	//since we put a value of mixing above one, he makes our color stronger (more saturated)
	color = mix(vec4(0.5),color,1.4);
	
	//sets our color 
	COLOR = color;
}