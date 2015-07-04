#version 150

uniform sampler2D Texture;

in vec2 TexCoordOut;
out vec4 OutColor;
uniform vec4 InColor;

void main()
{
    OutColor = texture(Texture, TexCoordOut) * InColor;
}
