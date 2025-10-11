## Building
This project uses a special build of Godot that includes [Voxel Tools](https://github.com/Zylann/godot_voxel/) and [Godex](https://github.com/GodotECS/godex/).

### Step 1
First, build Godot with double precision:
```
cd godot/
scons platform=<platform> target=release_debug precision=double
```

### Step 2
Then, rebuild with modules:
```
scons platform=<platform> target=release_debug precision=double custom_modules='../modules
```

I don't know why you have to do the build twice, and why you can't just run the second build command first but whatever, it works.