const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;
const int MAX_MARCHING_STEPS = 255;

float sphereSDF(vec3 p, vec3 center, float radius){
    return length(p - center) - radius;
}

float sceneSDF(vec3 p){
    return sphereSDF(p, vec3(0.0), 1.0);
}

float rayMarching(vec3 eye, vec3 marchingDirection, float start, float end){
    float depth = start;
    for(int i = 0; i < MAX_MARCHING_STEPS; i++){
        float dist = sceneSDF(eye + depth * marchingDirection);
        if(dist < EPSILON){
            return depth;
        }
        depth += dist;
        if(depth >= end){
            return end;
        }
    }
    return end;
}

vec3 rayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
    vec2 xy = fragCoord - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec3 dir = rayDirection(45.0, iResolution.xy, fragCoord);
    vec3 eye = vec3(0.0, 0.0, 5.0);
    float dist = rayMarching(eye, dir, MIN_DIST, MAX_DIST);

    if(dist > MAX_DIST - EPSILON){
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    fragColor = vec4(1.0,0.0,0.0,1.0);
}