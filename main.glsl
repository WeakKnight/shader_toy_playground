#define PI 3.1415926535897932384626433832795
float merge_smooth(float d1, float d2, float k){
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0-h);
}
float merge(float d1, float d2){
	return min(d1, d2);
}
float substract(float d1, float d2){
	return max(-d1, d2);
}
vec2 rotate(vec2 p, float a){
	return p * mat2(cos(a), sin(a), -sin(a), cos(a));	
}
vec2 translate(vec2 p, vec2 t){
	return p - t;
}
float sdf_circle(vec2 p, float radius){
	return length(p) - radius;
}
float sdf_triangle(vec2 p, float width, float height){
	vec2 n = normalize(vec2(height, width / 2.0));
	return max(	abs(p).x*n.x + p.y*n.y - (height*n.y), -p.y);
}
float sdf_square(vec2 p, vec2 size, float radius){
	size -= vec2(radius);
	vec2 d = abs(p) - size;
  	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}
bool two_point_in_same_side_of_one_line(vec2 p1, vec2 p2, vec2 start, vec2 end){
	vec3 start_to_end = vec3(end.x, end.y, 0.0) - vec3(start.x, start.y, 0.0);
	vec3 start_to_p1 = vec3(p1.x, p1.y, 0.0) - vec3(start.x, start.y, 0.0);
	vec3 start_to_p2 = vec3(p2.x, p2.y, 0.0) - vec3(start.x, start.y, 0.0);
	return dot(cross(start_to_end,start_to_p1), cross(start_to_end, start_to_p2)) > 0.0;
}
bool point_in_triangle(vec2 p, vec2 a, vec2 b, vec2 c){
	return two_point_in_same_side_of_one_line(p, c, a, b) && two_point_in_same_side_of_one_line(p, b, a, c) && two_point_in_same_side_of_one_line(p, a, b, c); 
}
float udf_line(vec2 p, vec2 start, vec2 end){
	vec2 start_to_p = p - start;
	vec2 start_to_end = end - start;
	vec2 end_to_start = start - end;
	vec2 end_to_p = p - end;
	if(dot(start_to_p, start_to_end) < 0.0){
		return length(start_to_p);
	}
	else if(dot(end_to_p, end_to_start) < 0.0){
		return length(end_to_p);
	}
	else{
		vec2 normal = normalize(rotate(start_to_end, PI/2.0));
		return abs(dot(normal, start_to_p));
	}
}
float sdf_round_triangle(vec2 p, vec2 a, vec2 b, vec2 c, float r){
	float dis = min(udf_line(p, a, b), min(udf_line(p, b, c), udf_line(p, a, c)));
	bool is_inside = point_in_triangle(p, a, b, c);
	return is_inside? -dis - r: dis - r;
}
float fill_mask(float dist){
	return clamp(-dist, 0.0, 1.0);
}
float sdf_leaves(vec2 p){
	float leaves = sdf_round_triangle(translate(p, vec2(291.9, 105.0)), vec2(2.0, 13.0), vec2(19.0, 7.5), vec2(42.0, 32.0), 2.0);
	leaves = merge(sdf_round_triangle(translate(p, vec2(277.0, 121.0)), vec2(0.0, 13.5), vec2(11.0, 4.0), vec2(55.0, 23.0), 2.5), leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(270.0, 140.8)), vec2(0.0, 15.8), vec2(7.2, 4.0), vec2(144.0, 25.2), 2.5), leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(272.0, 160.8)), vec2(0.0, 17.8), vec2(3.2, 5.5), vec2(96.0, 12.2), 2.5), leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(276.0, 181.5)), vec2(0.6, 17.8), vec2(3.2, 6.5), vec2(106.0, -2.2), 2.5), leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(284.5, 200.9)), vec2(0.6, 15.8), vec2(3.2, 5.5), vec2(126.0, -22.2), 2.0),leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(293.5, 215.2)), vec2(0.6, 15.8), vec2(0.6, 7.5), vec2(156.0, -45.2), 2.0),leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(303.5, 227.2)), vec2(0.6, 15.8), vec2(0.6, 8.5), vec2(156.0, -62.2), 2.0),leaves);
	leaves = merge(sdf_round_triangle(translate(p, vec2(311.8, 235.9)), vec2(0.6, 15.8), vec2(0.6, 11.2), vec2(156.0, -79.2), 2.0),leaves);
	return substract(sdf_square(translate(p, vec2(425.0, 175.0)), vec2(100.0, 105.0), 0.0), leaves);
}
float sdf_scene(vec2 p){
	float circle = sdf_circle(translate(p, vec2(320.0, 180.0)), 150.0);
	float circle_inner = sdf_circle(translate(p, vec2(320.0, 180.0)), 95.0);
    float square_left = sdf_square(translate(p, vec2(282.0, 180.0)), vec2(58.0, 95.0), 30.0);
	float result = substract(circle_inner, circle);
	result = substract(square_left, result);
	float square_inner = sdf_square(translate(p, vec2(230.0, 180.0)), vec2(28.0, 98.0), 20.0);
	result = merge_smooth(square_inner, result, 3.5);
	float triangle = sdf_triangle(translate(p, vec2(325.0, 60.0)), 22.0, 270.0);
	float triangle_sub = sdf_triangle(translate(p, vec2(325.0, 253.0)), 22.0, 270.0);
	float triangle_top = sdf_triangle(translate(p, vec2(325.0, 251.25)), 7.34, 8.7);
	triangle = substract(triangle_sub, triangle);
	triangle = merge(triangle, triangle_top);
	result = merge(triangle, result);
	result = merge(sdf_leaves(p), result);
	vec2 mirrored_p = vec2((-p.x + 651.0), p.y);
	return merge(sdf_leaves(mirrored_p), result);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 p = fragCoord.xy + vec2(0.5);
	vec2 c = iResolution.xy / 2.0;
	float dist = sdf_scene(p);
	vec4 col = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.17, 0.41, 0.26, 1.0), fill_mask(dist));
	fragColor = clamp(col, 0.0, 1.0);
}