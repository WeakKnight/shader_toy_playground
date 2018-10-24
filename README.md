# An image shader playground like shadertoy

## Usage

Write your shadertoy shader into playground.glsl with glsl syntax,

The environment provides some uniform variables which also provided by shadertoy like iMouse, iResolution, iTime

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

## Roadmap

iChannel uniform,
Buffer,
Sound

## Screen Shot

![Image](https://raw.githubusercontent.com/WeakKnight/shader_toy_playground/master/ScreenShot0.png)
Default Shadertoy shader
![Image](https://raw.githubusercontent.com/WeakKnight/shader_toy_playground/master/ScreenShot1.png)
This Image uses the shader made by Inigo Quilez
