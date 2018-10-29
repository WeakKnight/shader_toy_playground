float smoothMerge(float d1, float d2, float k)
{
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0-h);
}


float merge(float d1, float d2)
{
	return min(d1, d2);
}


float mergeExclude(float d1, float d2)
{
	return min(max(-d1, d2), max(-d2, d1));
}


float substract(float d1, float d2)
{
	return max(-d1, d2);
}


float intersect(float d1, float d2)
{
	return max(d1, d2);
}


//////////////////////////////
// Rotation and translation //
//////////////////////////////


vec2 rotateCCW(vec2 p, float a)
{
	mat2 m = mat2(cos(a), sin(a), -sin(a), cos(a));
	return p * m;	
}


vec2 rotateCW(vec2 p, float a)
{
	mat2 m = mat2(cos(a), -sin(a), sin(a), cos(a));
	return p * m;
}


vec2 translate(vec2 p, vec2 t)
{
	return p - t;
}


//////////////////////////////
// Distance field functions //
//////////////////////////////


float pie(vec2 p, float angle)
{
	angle = radians(angle) / 2.0;
	vec2 n = vec2(cos(angle), sin(angle));
	return abs(p).x * n.x + p.y*n.y;
}


float circleDist(vec2 p, float radius)
{
	return length(p) - radius;
}


float triangleDist(vec2 p, float radius)
{
	return max(	abs(p).x * 0.866025 + 
			   	p.y * 0.5, -p.y) 
				-radius * 0.5;
}


float triangleDist(vec2 p, float width, float height)
{
	vec2 n = normalize(vec2(height, width / 2.0));
	return max(	abs(p).x*n.x + p.y*n.y - (height*n.y), -p.y);
}


float semiCircleDist(vec2 p, float radius, float angle, float width)
{
	width /= 2.0;
	radius -= width;
	return substract(pie(p, angle), 
					 abs(circleDist(p, radius)) - width);
}


float boxDist(vec2 p, vec2 size, float radius)
{
	size -= vec2(radius);
	vec2 d = abs(p) - size;
  	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}


float lineDist(vec2 p, vec2 start, vec2 end, float width)
{
	vec2 dir = start - end;
	float lngth = length(dir);
	dir /= lngth;
	vec2 proj = max(0.0, min(lngth, dot((start - p), dir))) * dir;
	return length( (start - p) - proj ) - (width / 2.0);
}


///////////////////////
// Masks for drawing //
///////////////////////


float fillMask(float dist)
{
	return clamp(-dist, 0.0, 1.0);
}

///////////////
// The scene //
///////////////


float sceneDist(vec2 p)
{
	float c = circleDist(		translate(p, vec2(100, 250)), 40.0);
	float b1 =  boxDist(		translate(p, vec2(200, 250)), vec2(40, 40), 	0.0);
	float b2 =  boxDist(		translate(p, vec2(300, 250)), vec2(40, 40), 	10.0);
	float l = lineDist(			p, 			 vec2(370, 220),  vec2(430, 280),	10.0);
	float t1 = triangleDist(	translate(p, vec2(500, 210)), 80.0, 			80.0);
	float t2 = triangleDist(	rotateCW(translate(p, vec2(600, 250)), iTime), 40.0);
	
	float m = 	merge(c, b1);
	m = 		merge(m, b2);
	m = 		merge(m, l);
	m = 		merge(m, t1);
	m = 		merge(m, t2);
	
	float b3 = boxDist(		translate(p, vec2(100, sin(iTime * 3.0 + 1.0) * 40.0 + 100.0)), 
					   		vec2(40, 15), 	0.0);
	float c2 = circleDist(	translate(p, vec2(100, 100)),	30.0);
	float s = substract(b3, c2);
	
	float b4 = boxDist(		translate(p, vec2(200, sin(iTime * 3.0 + 2.0) * 40.0 + 100.0)), 
					   		vec2(40, 15), 	0.0);
	float c3 = circleDist(	translate(p, vec2(200, 100)), 	30.0);
	float i = intersect(b4, c3);
	
	float b5 = boxDist(		translate(p, vec2(300, sin(iTime * 3.0 + 3.0) * 40.0 + 100.0)), 
					   		vec2(40, 15), 	0.0);
	float c4 = circleDist(	translate(p, vec2(300, 100)), 	30.0);
	float a = merge(b5, c4);
	
	float b6 = boxDist(		translate(p, vec2(400, 100)),	vec2(40, 15), 	0.0);
	float c5 = circleDist(	translate(p, vec2(400, 100)), 	30.0);
	float sm = smoothMerge(b6, c5, 10.0);
	
	float sc = semiCircleDist(translate(p, vec2(500,100)), 40.0, 90.0, 10.0);
    
    float b7 = boxDist(		translate(p, vec2(600, sin(iTime * 3.0 + 3.0) * 40.0 + 100.0)), 
					   		vec2(40, 15), 	0.0);
	float c6 = circleDist(	translate(p, vec2(600, 100)), 	30.0);
	float e = mergeExclude(b7, c6);
    
	m = merge(m, s);
	m = merge(m, i);
	m = merge(m, a);
	m = merge(m, sm);
	m = merge(m, sc);
    m = merge(m, e);
	
	return m;
}


float sceneSmooth(vec2 p, float r)
{
	float accum = sceneDist(p);
	accum += sceneDist(p + vec2(0.0, r));
	accum += sceneDist(p + vec2(0.0, -r));
	accum += sceneDist(p + vec2(r, 0.0));
	accum += sceneDist(p + vec2(-r, 0.0));
	return accum / 5.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy + vec2(0.5);
	vec2 c = iResolution.xy / 2.0;
	
	//float dist = sceneSmooth(p, 5.0);
	float dist = sceneDist(p);
	
	
	
	// gradient
	vec4 col = vec4(0.5, 0.5, 0.5, 1.0) * (1.0 - length(c - p)/iResolution.x);
	// grid
	col *= clamp(min(mod(p.y, 10.0), mod(p.x, 10.0)), 0.9, 1.0);
	// shape fill
	col = mix(col, vec4(1.0, 0.4, 0.0, 1.0), fillMask(dist));

	fragColor = clamp(col, 0.0, 1.0);
}

