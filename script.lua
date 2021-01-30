
-- Used to get chess board
local HttpService = game:GetService("HttpService");
local aux = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/ohaux.lua"))();
local scriptPath = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.client;

-- Constants
local closureName = "deviewMatch";
local upvalueIndex = 1;
local closureConstants = {
	[1] = "screen",
	[2] = "back",
	[3] = "Visible",
	[4] = "deview",
	[5] = "transitionScreen",
	[6] = "setPlayerDisplay"
}
local closure = aux.searchClosure(scriptPath, closureName, upvalueIndex, closureConstants)

local pieces = {
	[1] = "p",
	[2] = "n",
	[3] = "b",
	[4] = "r",
	[5] = "q",
	[6] = "k"
};

local player = "w";

-- Get current chess board from script
function GetBoard()
    return debug.getupvalue(closure, upvalueIndex)["chess"]["grid"];
end

-- Get which player is currently playing
function Playing() 
    return debug.getupvalue(closure, upvalueIndex)["chess"]["currentTurn"];
end

-- Convert board to fen
function Board2Fen(board)
    local result = "";
    for y = 1, 8 do
        local empty = 0;
        for x = 1, 8 do
            local p = board[x][y];
            if not (typeof(p) == "boolean") then
                if (empty > 0) then
                    result = result .. tostring(empty);
                end
                empty = 0;
                local piece = pieces[p["type"]];
                if (p["player"]) then
                    piece = string.upper(piece);
                end
                result = result .. piece;
            else
                empty = empty + 1;
            end
        end
        if (empty > 0) then
            result = result .. tostring(empty);
        end
        if not (y == 8) then
            result = result .. '/';
        end
    end
    result = result .. " " .. player;
    return result;
end

-- Run AI
function RunGame()
    -- Get board
    local board = GetBoard();
    
    -- Ask chess engine what to do
    local res = syn.request({
        Url = "http://localhost:3000/api/solve?fen=" .. HttpService:UrlEncode(Board2Fen(board)),
        Method = "GET"
    });

    -- Store result from AI
    local result = res.Body;
    
    -- Make sure response is a position
    if (string.len(result) > 4) then
        error(result);
    end
    
    -- Convert position to arguments to MakeMove
    local chars = {}
    for c in result:gmatch(".") do
        print(c);
	    table.insert(chars, c);
    end
    
    local x1 = string.byte(chars[1]) - 96;
    local y1 = 9 - tonumber(chars[2]);
    
    local x2 = string.byte(chars[3]) - 96;
    local y2 = 9 - tonumber(chars[4]);
    
    -- Make the move
    game.ReplicatedStorage.remotes.makeMove:FireServer(x1, y1, x2, y2);
end

game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameProcessedEvent)
    -- Run for white
    if (inputObject.KeyCode == Enum.KeyCode.V) then
        print("Ran AI on white");
        player = "w";
        RunGame();
    end
    
    -- Run for black
    if inputObject.KeyCode == Enum.KeyCode.B then
        print("Ran AI on black");
        player = "b";
        RunGame();
    end
end)
