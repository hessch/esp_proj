#!/bin/bash
luatool.py --port /dev/cu.SLAB_USBtoUART --src main.lua --dest main.lua --verbose
luatool.py --port /dev/cu.SLAB_USBtoUART --src init.lua --dest init.lua --verbose
