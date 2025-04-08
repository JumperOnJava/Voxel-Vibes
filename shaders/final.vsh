#version 130

out vec4 color;
out vec2 coord0;
void main()
{
    gl_Position = ftransform();
    color = gl_Color;
    coord0 = (gl_MultiTexCoord0).xy;
}
