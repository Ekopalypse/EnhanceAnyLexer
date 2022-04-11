# EnhanceAnyLexer
Notepad++ plugin that adds an additional foreground colouring option to existing lexers

## Installation

- Download and unpack the EnhanceAnyLexer zip-archive (the EnhanceAnyLexer*86 or 64*.zip) from https://github.com/Ekopalypse/EnhanceAnyLexer/releases to the folder "Notepad++\plugins".

## Usage example

- Start Notepad++
- Configure additional coloring by calling "Open configuration file" from the EnhanceAnyLexer plugin menu.  
  (You will find a more detailed description in the configuration file.)
- Open a source file


## Building manually

This plugin is written in the [programming language V](https://github.com/vlang/v) and must therefore be available to build this plugin.  
Furthermore, a current version of the gcc compiler, >= version 10 recommended, must be installed.  
An example for the use with NppExec:

```
cd $(CURRENT_DIRECTORY)

set PROJECT=EnhanceAnyLexer
set VEXE=d:\programdata\compiler\v\v.exe

set ARCH=x64
set CC=gcc

set NPPPATH=D:\Tests\npp\812\$(ARCH)
set PLUGIN_DIR=$(NPPPATH)\plugins\$(PROJECT)

cmd /c if not exist $(PLUGIN_DIR) exit -1

if $(EXITCODE) == -1 then
  cmd /c mkdir $(PLUGIN_DIR)
endif

set PLUGIN_PATH=$(PLUGIN_DIR)\$(PROJECT).dll

set COMPILER_FLAGS= -cc gcc -prod -d static_boehm -gc boehm -keepc -enable-globals -shared -d no_backtrace -cflags -static-libgcc

if $(ARCH)==x64 then
  if $(CC)==gcc then
    $(VEXE) -cc $(CC) $(COMPILER_FLAGS) -cflags -static-libgcc -o $(PLUGIN_PATH) .
  endif  
else
  if $(CC)==gcc then
    ENV_SET PATH=D:\ProgramData\Compiler\mingw32\bin
    $(VEXE) -cc $(CC) -m32 -g $(COMPILER_FLAGS) -cflags -static-libgcc -o $(PLUGIN_PATH) .
    ENV_UNSET PATH
  endif
endif

```


## Release History
* 0.2.0
    * Display the color string in its own color
* 0.1.0
    * First beta version
* 0.0.2
    * Offset possibility added
* 0.0.1
    * First alpha release

## Meta

Distributed under the MIT license. See ``LICENSE`` for more information.