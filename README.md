# EnhanceAnyLexer
Notepad++ plugin that adds an additional foreground colouring option for your text content.
This means that you can define regular expressions to highlight parts of text/code, in addition to what standard lexers, such as those for Python, C, Rust, UDL ... do.

***NOTE: An existing EnhanceAnyLexerConfig.ini is obsolete if you use version 0.5.
This means that you must either rename the ini and let the plugin create a new one automatically
or add the following two lines to the global section yourself.***
~~~
regex_error_style_id=30
regex_error_color=0x756ce0
~~~
***Of course, these values are configurable.***

Some examples to show what can be done.
Normal text, no lexers involved

![normal_text](https://github.com/Ekopalypse/EnhanceAnyLexer/assets/47723516/0e19538e-0307-4cdd-a24a-320a9a0cc065)

Using the standard python lexer

![python_before](https://github.com/Ekopalypse/EnhanceAnyLexer/assets/47723516/354bbeb9-596c-4841-8dec-4c805b67014d)

and in addition using EnhanceAnyLexer plugin

![python_after](https://github.com/Ekopalypse/EnhanceAnyLexer/assets/47723516/a786bf63-ed5c-48e7-870e-7ffcfdc74f32)

## Installation

- Download and unpack the EnhanceAnyLexer zip-archive (the EnhanceAnyLexer*86 or 64*.zip) from https://github.com/Ekopalypse/EnhanceAnyLexer/releases to the folder "Notepad++\plugins".

## Usage example

- Start Notepad++
- Configure additional coloring by calling "Enhance current language" from the EnhanceAnyLexer plugin menu.
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
* 1.3.0
	* Support for plugin communication via NPPM_MSGTOPLUGIN. Currently only the use of the "config file saved" message is possible.
* 1.2.0
	* Introduce a per-regex whitelist option
* 1.1.3
	* Extend visual area
* 1.1.2
	* Revert optimization attempts.
* 1.1.1
	* Fix issue that Npp hangs when using word wrap and match reports a position outside defined range.
* 1.1.0
	* Support enabling/disabling the plugin globally, fix crash issue with Npp < 8.4.3
* 1.0.1
	* Documentation update
* 1.0.0
	* Support scrolling inactive view
* 0.5.0
    * Add a poor man regex linter functionality
* 0.4.0
    * Add convenience functions to make it easier to create the correct config sections
* 0.3.0
    * First official Notepad++ pluginAdmin release
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
