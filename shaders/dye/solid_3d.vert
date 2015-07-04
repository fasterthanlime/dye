#version 150

uniform mat4 Projection;
uniform mat4 ModelView;

in vec3 Position;
out vec3 OutPosition;

void main()
{
  gl_Position = Projection * ModelView * vec4(Position, 1.0);
  OutPosition = Position;
}
