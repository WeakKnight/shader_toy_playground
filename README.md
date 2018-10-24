# An image shader play ground like shadertoy

## Usage

Write your shader code into playground.glsl with glsl syntax,

This environment provide Some uniform variables which samely provided in shadertoy like iMouse, iResolution, iTime

You can write code just like this or simply copy one intriguing shader artwork from shadertoy

```glsl
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}
```

## Screen Shot

![Image](https://github.com/WeakKnight/shader_toy_playground/blob/master/ScreenShot0.png?raw=true)
Default Shadertoy shader
![Image](https://github.com/WeakKnight/shader_toy_playground/blob/master/ScreenShot1.png?raw=true)
This Image uses the shader made by Inigo Quilez
