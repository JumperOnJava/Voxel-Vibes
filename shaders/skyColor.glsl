#define PI 3.1415

uniform int worldTime;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform float rainStrength;

vec4 getSunriseColor(float time) {
    float f = 0.4F;
    float f1 = cos(time * (3.1415 * 2)) - 0.0;
    float f2 = -0.0;
    if (f1 >= -0.4F && f1 <= 0.4F) {
        float f3 = (f1 - -0.0) / 0.4F * 0.5F + 0.5F;
        float f4 = 1.0 - (1.0 - sin(f3 * 3.1415)) * 0.99;
        f4 *= f4;
        vec4 sunriseCol;
        sunriseCol[0] = f3 * 0.3 + 0.7;
        sunriseCol[1] = f3 * f3 * 0.7 + 0.2;
        sunriseCol[2] = f3 * f3 * 0.0 + 0.2;
        sunriseCol[3] = f4;
        return sunriseCol;
    } else {
         return vec4(0);
    }
}
vec3 getSkyColor(float time) {
      float f = time;
      vec3 vec31 = skyColor;
      float f1 = cos(f * (3.1415 * 2)) * 2.0 + 0.5;
      f1 = clamp(f1, 0.0, 1.0);
      float f2 = vec31.x * f1;
        float f3 = vec31.y * f1;
        float f4 = vec31.z * f1;
        float f5 = rainStrength;
        if (f5 > 0.0F) {
            float f6 = (f2 * 0.3F + f3 * 0.59F + f4 * 0.11F) * 0.6F;
            float f7 = 1.0F - f5 * 0.75F;
         f2 = f2 * f7 + f6 * (1.0F - f7);
         f3 = f3 * f7 + f6 * (1.0F - f7);
         f4 = f4 * f7 + f6 * (1.0F - f7);
      }

      float f9 = 0;//this.getThunderLevel(time);
      if (f9 > 0.0F) {
         float f10 = (f2 * 0.3F + f3 * 0.59F + f4 * 0.11F) * 0.2F;
         float f8 = 1.0F - f9 * 0.75F;
         f2 = f2 * f8 + f10 * (1.0F - f8);
         f3 = f3 * f8 + f10 * (1.0F - f8);
         f4 = f4 * f8 + f10 * (1.0F - f8);
      }

      int i = 0;//this.getSkyFlashTime();
      if (i > 0) {
         float f11 = i - time;
         if (f11 > 1.0F) {
            f11 = 1.0F;
         }

         f11 *= 0.45F;
         f2 = f2 * (1.0F - f11) + 0.8F * f11;
         f3 = f3 * (1.0F - f11) + 0.8F * f11;
         f4 = f4 * (1.0F - f11) + 1.0F * f11;
      }

      return vec3(f2, f3, f4);
   }

uniform mat4 gbufferModelViewInverse;       
uniform mat4 gbufferProjectionInverse;    
uniform float viewWidth;
uniform float viewHeight;  

vec3 getWorldRay() {
    vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
    vec2 screenUV = screenPos.xy;
    vec2 ndc = screenUV * 2.0 - 1.0;
    vec4 clip = vec4(ndc, -1.0, 1.0);

    vec4 view = gbufferProjectionInverse * clip;
    view.z = -1.0;
    view.w = 0.0;
    vec4 world = gbufferModelViewInverse * view;

    return normalize(world.xyz);
}
vec4 getSkyColor(){
    float time = (worldTime)/24000.-0.25;
    vec3 sunPosition = normalize(vec3(-sin(time*2*PI),cos(time*2*PI),0));
    vec3 ray = getWorldRay();
    float sunAmount = dot(ray,normalize(sunPosition));
    float fogAmount = dot(ray,vec3(0,-1,0));

    fogAmount = (2*fogAmount)/3.+2/3.;
    sunAmount=tan(pow(sunAmount,1.8)*PI/4);
    vec4 sunriseColor = getSunriseColor(time);
    vec4 skybox = vec4(mix(mix(getSkyColor(time),fogColor,fogAmount),sunriseColor.xyz,max((sunAmount*pow(sunriseColor.w,.5) ),0)), 1.0);
    return skybox;
}