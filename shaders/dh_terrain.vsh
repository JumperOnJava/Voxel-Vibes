#version 120

attribute float mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;

uniform int frameCounter;


varying vec4 fragColor;
varying vec2 texCoord0;
varying vec2 texCoord1;
varying vec3 playerPosSpace;


void main() {
    playerPosSpace = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;
    
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(playerPosSpace, 1.0);
    gl_FogFragCoord = length(playerPosSpace);

    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    normal = (mc_Entity == 1.0) ? vec3(0.0, 1.0, 0.0) : (gbufferModelViewInverse * vec4(normal, 0.0)).xyz;

    float lightIntensity = min(normal.x * normal.x * 0.4 + normal.y * normal.y * 0.25 * (3.0 + normal.y) + normal.z * normal.z * 0.6, 1.0);

    fragColor = vec4(gl_Color.rgb * lightIntensity, gl_Color.a);

    texCoord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    texCoord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}