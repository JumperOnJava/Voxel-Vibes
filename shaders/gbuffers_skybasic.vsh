/*
    XorDev's "Default Shaderpack"

    This was put together by @XorDev to make it easier for anyone to make their own shaderpacks in Minecraft (Optifine).
    You can do whatever you want with this code! Credit is not necessary, but always appreciated!

    You can find more information about shaders in Optfine here:
    https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt

*/
//Declare GL version.
#version 130

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

//Pass vertex information to fragment shader.
varying vec4 color;
varying vec2 coord0;

void main()
{   
    //Output position and fog to fragment shader.
    gl_Position = ftransform();

    //Output color to fragment shader.
    color = vec4(gl_Color.rgb, gl_Color.a);
    //Output diffuse texture coordinates to fragment shader.
    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}