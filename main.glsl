float smoothMerge(float d1, float d2, float k){
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0-h);
}
float merge(float d1, float d2){
	return min(d1, d2);
}
float mergeExclude(float d1, float d2){
	return min(max(-d1, d2), max(-d2, d1));
}
float substract(float d1, float d2){
	return max(-d1, d2);
}
float intersect(float d1, float d2){
	return max(d1, d2);
}
vec2 rotateCCW(vec2 p, float a){
	mat2 m = mat2(cos(a), sin(a), -sin(a), cos(a));
	return p * m;	
}
vec2 rotateCW(vec2 p, float a){
	mat2 m = mat2(cos(a), -sin(a), sin(a), cos(a));
	return p * m;
}
vec2 translate(vec2 p, vec2 t){
	return p - t;
}
float pie(vec2 p, float angle){
	angle = radians(angle) / 2.0;
	vec2 n = vec2(cos(angle), sin(angle));
	return abs(p).x * n.x + p.y*n.y;
}
float circleDist(vec2 p, float radius){
	return length(p) - radius;
}
float triangleDist(vec2 p, float radius){
	return max(	abs(p).x * 0.866025 + 
			   	p.y * 0.5, -p.y) 
				-radius * 0.5;
}
float triangleDist(vec2 p, float width, float height){
	vec2 n = normalize(vec2(height, width / 2.0));
	return max(	abs(p).x*n.x + p.y*n.y - (height*n.y), -p.y);
}
float triangleDist(vec2 p, vec2 a, vec2 b, vec2 c){
	return 0.0;
}
float semiCircleDist(vec2 p, float radius, float angle, float width){
	width /= 2.0;
	radius -= width;
	return substract(pie(p, angle), 
					 abs(circleDist(p, radius)) - width);
}
float boxDist(vec2 p, vec2 size, float radius){
	size -= vec2(radius);
	vec2 d = abs(p) - size;
  	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}
float lineDist(vec2 p, vec2 start, vec2 end, float width){
	vec2 dir = start - end;
	float lngth = length(dir);
	dir /= lngth;
	vec2 proj = max(0.0, min(lngth, dot((start - p), dir))) * dir;
	return length( (start - p) - proj ) - (width / 2.0);
}
float fillMask(float dist){
	return clamp(-dist, 0.0, 1.0);
}
float sceneDist(vec2 p){
	float c = circleDist(		translate(p, vec2(320, 180)), 150.0);
	float innerC = circleDist(		translate(p, vec2(320, 180)), 95.0);
    float boxL = boxDist(translate(p, vec2(320 - 38, 180)), vec2(58, 95), 30);
	float m = substract(innerC, c);
	m = substract(boxL, m);
	float boxInner = boxDist(translate(p, vec2(320 - 90, 180)), vec2(28, 98), 20);
	m = merge(boxInner, m);
	float triangle = triangleDist(translate(p, vec2(320 + 5, 180 - 120)), 20.0, 200.0);
	m = merge(triangle, m);
	return m;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 p = fragCoord.xy + vec2(0.5);
	vec2 c = iResolution.xy / 2.0;
	float dist = sceneDist(p);
	vec4 col = vec4(1.0, 1.0, 1.0, 1.0);
	col = mix(col, vec4(0.17, 0.41, 0.26, 1.0), fillMask(dist));
	fragColor = clamp(col, 0.0, 1.0);
}

