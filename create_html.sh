#!/bin/bash
cat h.txt > index.html
echo "<script id=\"fsCloud\" type=\"notjs\">" >> index.html
cat noise.glsl >> index.html
echo "</script>" >> index.html
echo "<script id=\"fragment\" type=\"notjs\">" >> index.html
cat moria.glsl >> index.html
echo "</script>" >> index.html
cat b.txt >> index.html
