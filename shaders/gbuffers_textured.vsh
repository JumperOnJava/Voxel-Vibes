//Declare GL version.
#version 120

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

//Pass vertex information to fragment shader.
varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;
float smoother(float x, float res, float n) {
    float modX = mod(x, res);
    float f = modX / res + sin((modX / res) * asin(1.0) * 2 * 2.0) * n;
    return floor(x / res) * res + f * res;
}
vec3 smoother(vec3 x, float m, float n) {
    return vec3(smoother(x.x, m, n),
                smoother(x.y, m, n),
                smoother(x.z, m, n));
}
void main()
{
    //Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;
    // pos = smoother(pos,1./16,-0.06);

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);

    //Calculate view space normal.
    vec3 normal = gl_NormalMatrix * gl_Normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;

    //Calculate simple lighting. Thanks to @PepperCode1
    float light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);

    //Output color with lighting to fragment shader.
    color = vec4(gl_Color.rgb * light, gl_Color.a);
    //Output diffuse and lightmap texture coordinates to fragment shader.
    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    coord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}
