version       = "0.0.1"
author        = "David Konsumer"
description   = "Example libretro core"
license       = "MIT"
srcDir        = "src"
bin           = @["example_libretro.so"]

requires "nim >= 1.6.10"
requires "futhark >= 0.9.0"

import os

# TODO: is there a more cross-platform way to do this?
task example, "Build C example to compare":
  exec("gcc example/example.c -shared -fPIC -o example_libretro_c.so")

task clean, "Clean built files":
  for file in listFiles("."):
    let ext = splitFile(file).ext
    if ext == ".dll" or ext == ".so" or ext == ".dylib":
      echo "Deleting ", file
      rmFile(file)
