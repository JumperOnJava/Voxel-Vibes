#version 120

uniform sampler2D texture;
uniform int frameCounter;

uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D dhDepthTex0;
uniform sampler2D normals;

#include "lib/skyColor.glsl"

in vec4 color;
in vec2 coord0;

uniform float fogStart;
uniform float fogEnd;
uniform float near;
uniform float far;
uniform int dhRenderDistance;

const int shadowMapResolution = 8192;
uniform vec3 cameraPosition;
const float sunPathRotation = 22.5;
const float shadowMapDistance = 128;

uniform mat4 dhProjection;
uniform mat4 dhProjectionInverse;
uniform mat4 dhPreviousProjection;

int ceilToClosestPowerOfTwo(float num) {
    if (num <= 0.0) return 0;
    return int(exp2(floor(log2(num))));
}
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
    vec4 homogeneousPos = projectionMatrix * vec4(position, 1.0);
    return homogeneousPos.xyz / homogeneousPos.w;
}
uniform int isEyeInWater;

vec3 screenToWorld(vec2 coord, float depth) {
    vec2 ndc = coord * 2 - 1;
    vec4 ndc4d = vec4(ndc,depth*2-1,1.0);
    vec4 viewPos = gbufferProjectionInverse * ndc4d;
    viewPos/=viewPos.w;
    vec4 offsetFromCamera = gbufferModelViewInverse * viewPos;
    offsetFromCamera/=offsetFromCamera.w;
    return offsetFromCamera.xyz;
}
vec3 dhScreenToWorld(vec2 coord, float depth) {
    vec2 ndc = coord * 2 - 1;
    vec4 ndc4d = vec4(ndc,depth*2-1,1.0);
    vec4 viewPos = dhProjectionInverse * ndc4d;
    viewPos/=viewPos.w;
    // vec4 offsetFromCamera = gbufferModelViewInverse * viewPos;
    // offsetFromCamera/=offsetFromCamera.w;
    // return offsetFromCamera.xyz;
    return viewPos.xyz;
}


uniform sampler2D shadow;
 
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}
void main()
{
    float depth = texture2D(depthtex0, coord0).x;
    float dhDepth = texture2D(dhDepthTex0, coord0).x;
    
    vec3 offsetFromCamera = screenToWorld(coord0,depth);
    vec3 dhOffsetFromCamera = dhScreenToWorld(coord0,dhDepth);
    
    float dist = length(offsetFromCamera);
    float dhDist = length(dhOffsetFromCamera);

    if(depth == 1){
        dist = dhDist;
    }

    vec4 textureColor= texture2D(texture,coord0);
    
    float fog = clamp((dist - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
    if(depth != 1 || dhDepth !=1 && textureColor.rgb != vec3(0)){

#ifdef DISTANT_HORIZONS
    #define FOG_DIST dhRenderDistance
#else
    #define FOG_DIST far
#endif

        textureColor.rgb = mix(textureColor.rgb, getSkyColor().rgb, pow(clamp(dist/(FOG_DIST*0.8),0,1),1.5));
    }

    float shadowmul=0.85;
    if(depth!=1 && dist<shadowMapDistance){
        vec3 shadowWorldPos;
    
        shadowWorldPos = (offsetFromCamera*.999) + cameraPosition;
        shadowWorldPos -= mod(shadowWorldPos,1/16.)+1/16;

        shadowWorldPos = shadowWorldPos - cameraPosition;

        int n = 16;
        vec4 shadowPos = shadowProjection * shadowModelView * vec4(shadowWorldPos, 1.0);
        shadowPos /= shadowPos.w;

        shadowPos = shadowPos * 0.5 + 0.5;
        vec2 shadowCoord = shadowPos.xy; 
        float shadowDepth = texture2D(shadow, shadowCoord).r;

        float currentDepth = shadowPos.z;

        float bias = 0.001;
        
        // float fadeout = clamp(map(dist,shadowMapDistance*0.8,shadowMapDistance,0,1),0,1);
        float fadeout = pow(dist/shadowMapDistance,1);
        float shadowAmount = mix(1.15,0.8,fadeout);
        shadowmul = currentDepth - bias > shadowDepth ? shadowAmount : .85;
    }

    vec4 finalColor = max(color * textureColor, texture2D(colortex4,coord0.xy)*1.1);
    
    finalColor.rgb = vec3(
        pow(finalColor.r,shadowmul),
        pow(finalColor.g,shadowmul),
        pow(finalColor.b,shadowmul)
    );
    finalColor *= map(shadowmul,0.85,1.15,1.05,0.95);

    gl_FragData[0] = finalColor;
    // if(coord0.x>.5){
    //     gl_FragData[0] = vec4(dist/500);
    // } else{
    //     gl_FragData[0] = vec4(dhDist/500);
    // }

}
