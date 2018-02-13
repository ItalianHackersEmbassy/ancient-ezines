tasm vmedemo;
tasm vme0;
tasm rand;
tasm host;
tlink /t vmedemo vme0 rand host, vme0demo.com
copy vme0demo.com vmedemo.com
