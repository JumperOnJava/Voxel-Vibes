#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform int fogMode;
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

uniform float viewHeight;
uniform float viewWidth;

uniform int isEyeInWater;

varying vec4 fragColor;
varying vec2 texCoord0;
varying vec2 texCoord1;

uniform vec3 cameraPosition;
varying vec3 playerPosSpace;

void main() {
    vec4 color = fragColor * texture2D(lightmap, texCoord1) * texture2D(texture, texCoord0);

    gl_FragData[0] = color;
}
