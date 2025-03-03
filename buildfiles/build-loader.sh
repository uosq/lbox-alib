#!/bin/bash
luabundler bundle src/loader/main.lua -p "dependencies/*.lua" -p "?.lua" -p "src/loader/?.lua" -i -o build/alib.lua