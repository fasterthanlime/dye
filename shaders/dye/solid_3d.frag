#version 150

out vec4 OutColor;
uniform vec4 InColor;

in vec3 OutPosition;

void main()
{
  OutColor = vec4(OutPosition, 1.0);
}
