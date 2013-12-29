#!/usr/bin/sh

coffee -c maze.coffee
zip maze.nw libs/* imgs/* package.json index.html maze.js
