# AutoChessAPI
Welcome! This project was originally made (and will probably remain) as part of a roblox chess engine script kinda thing. The entire point of this was to allow me to interface with a chess engine from within a sandboxed locked down environment where I couldn't access the actual process's input/output streams.

For that reason I decided to make a little api using expressjs and node-UCI.

## How to run it?!
```js
npm install
node .
```

If you wish to use the roblox script that uses this API
```lua
shared.runBind = Enum.KeyCode.B;
loadstring(game:HttpGet('https://raw.githubusercontent.com/bonezone2001/AutoChessAPI/main/script.lua'))();
```

NOTE: Be sure the change "enginePath" to the path / name (if it's in the same path as index.js) as the engine you have and wish to use.
