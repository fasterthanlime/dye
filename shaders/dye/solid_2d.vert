#version 150

uniform mat4 Projection;
uniform mat4 ModelView;

in vec2 Position;

void main()
{
    gl_Position = Projection * ModelView * vec4(Position, 0.0, 1.0);
}
