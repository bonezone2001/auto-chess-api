# auto-chess-api
Welcome! This project was originally made (and will probably remain) as part of a roblox chess engine script kinda thing. The entire point of this was to allow me to interface with a chess engine from within a sandboxed locked down environment where I couldn't access the actual process's input/output streams.

For that reason I decided to make a little api using expressjs and node-UCI. The roblox scripts that interface with it have also been included.

### Video tutorial (click image)

[![Video Tutorial](https://img.youtube.com/vi/P3JAT6lrCs8/2.jpg)](https://www.youtube.com/watch?v=P3JAT6lrCs8)

## How to run it?!
```js
npm install
node .
```

If you wish to use the roblox script that uses this API (require's a roblox exploit of some kind to run on the roblox game it was programmed to run on)
```lua
shared.runBind = Enum.KeyCode.B;
loadstring(game:HttpGet('https://raw.githubusercontent.com/bonezone2001/AutoChessAPI/main/script.lua'))();
```

NOTE: Be sure the change "enginePath" to the path / name (if it's in the same path as index.js) as the engine you have and wish to use.
