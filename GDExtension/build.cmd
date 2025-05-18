::@echo off
::echo on
godot --headless --dump-gdextension-interface
godot --headless --dump-extension-api
::odin run .
odin build . -build-mode:dll

rename GDExtension.dll libgdexample.dll
::del .\bin\libgdexample.dll
xcopy /v /i /Y libgdexample.dll .\testextension\bin\
del libgdexample.dll
godot .\testextension\project.godot