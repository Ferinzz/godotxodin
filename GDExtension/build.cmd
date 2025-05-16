::@echo off
::echo on
godot --headless --dump-gdextension-interface
godot --headless --dump-extension-api
::odin run .
odin build . -build-mode:shared