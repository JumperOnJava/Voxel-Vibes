/*
    XorDev's "Default Shaderpack"

    This was put together by @XorDev to make it easier for anyone to make their own shaderpacks in Minecraft (Optifine).
    You can do whatever you want with this code! Credit is not necessary, but always appreciated!

    You can find more information about shaders in Optfine here:
    https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt

*/
//Declare GL version.
#version 130
// #define 2PI 3.1415*2

//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;
uniform vec3 upPosition;

// uniform vec3 sunPosition;


varying vec4 color;
varying vec4 coord0;


#include "skycolor.glsl"

void main()
{
    vec4 col = color;

    //hack for stars
    if(!(color.x==color.y&& color.y==color.z) || color.xyz==vec3(0)){
        col = getSkyColor();
    }

    gl_FragData[0] = (col) * vec4(vec3(1.-blindness),1);
    
}
