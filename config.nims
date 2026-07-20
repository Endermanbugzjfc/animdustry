--path:"fau/src"
--passC:"-DSTBI_ONLY_PNG"
#--hints:off
--gc:arc
--d:nimPreviewHashRef
--d:msgpack_obj_to_map
#polymorph warnings
--warning:"BareExcept:off"
--hint:"ConvFromXtoItselfNotNeeded:off"

# reason: https://github.com/nim-lang/Nim/issues/18146
--tlsEmulation:off
--threads:off

when defined(release) or defined(danger):
  --passC:"-flto"
  --passL:"-flto"
  --d:strip
else:
  #better compiler/linker performance with local assets
  --d:localAssets

when defined(Android):
  #why isn't this the default??
  #--d:androidNDK
  --d:androidFullscreen

if defined(emscripten):
  --os:linux
  --cpu:i386
  --cc:clang
  --clang.exe:emcc
  --clang.linkerexe:emcc
  --clang.cpp.exe:emcc
  --clang.cpp.linkerexe:emcc
  --listCmd

  --d:danger

  # nimsoloud's SDL2 headers (soloud_sdl2_static.cpp) need to see
  # -s USE_SDL=2 at compile time too, not just link time, or emscripten's
  # fakesdl shim #errors out.
  switch("passC", "-s USE_SDL=2")

  #extra flags for smaller sizes:
  # -s ASSERTIONS=0 -DNDEBUG -s MALLOC=emmalloc
  # note: LLD_REPORT_UNDEFINED was removed in modern emscripten (now a hard link error)
  switch("passL", "-o build/web/index.html --shell-file fau/res/shell_minimal.html -O3 -s USE_SDL=2 -s ALLOW_MEMORY_GROWTH=1 --closure 1 --preload-file assets")
else:

  when defined(Windows):
    switch("passL", "-static-libstdc++ -static-libgcc")

  when defined(MacOSX):
    switch("clang.linkerexe", "g++")
  else:
    switch("gcc.linkerexe", "g++")
