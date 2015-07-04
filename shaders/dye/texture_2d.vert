#version 150

uniform mat4 Projection;
uniform mat4 ModelView;

in vec2 Position;
in vec2 TexCoordIn;
out vec2 TexCoordOut;

void main()
{
    TexCoordOut = TexCoordIn;
    gl_Position = Projection * ModelView * vec4(Position, 0.0, 1.0);
}
