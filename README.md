## Building
This project uses a special build of Godot that includes [Voxel Tools](https://github.com/Zylann/godot_voxel/).

Build Godot with custom modules and double precision:
```
scons platform=<platform> target=editor precision=double custom_modules='../modules
```