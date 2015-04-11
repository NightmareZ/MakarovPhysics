unit MyEngine;

interface

uses
  Windows, OpenGL;

const
  ENGINE='data\engine\engine.dll';

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
procedure SetDCPixelFormat(DC:HDC);external ENGINE;
function About:ShortString;external ENGINE;
procedure LoadTexture(PackFile:ShortString;
                      NumberInPack:Integer;
                      NumberInMemory:Integer);external ENGINE;
procedure LoadTexture512(PackFile:ShortString;
                      NumberInPack:Integer;
                      NumberInMemory:Integer);external ENGINE;
procedure LoadTextureSphere(PackFile:ShortString;
                            NumberInPack:Integer;
                            NumberInMemory:Integer);external ENGINE;
procedure DrawOneSideTexturedBox(x,y,z,dx,dy,dz:Extended);external ENGINE;
procedure DrawSkyBox(x,y,z,dx,dy,dz:Extended;
                     tex1,tex2,tex3,tex4,tex5,tex6:Integer);external ENGINE;
procedure CalcNormal(x1,y1,z1,x2,y2,z2,x3,y3,z3:Extended; var nx,ny,nz:Extended);external ENGINE;

implementation
end.
