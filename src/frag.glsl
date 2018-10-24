#version 330 core
out vec4 fragColor;
in vec2 fragCoord;
uniform vec2 iResolution;
uniform float iTime;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}

void main()
{
    vec4 color = vec4(0.0,0.0,0.0,1.0);
    mainImage( color, fragCoord.xy );
    color.w = 1.0;
    fragColor = color;
}