local HttpService = game:GetService("HttpService")
local plr = game:GetService("Players").LocalPlayer
local scriptPath = plr.PlayerGui:WaitForChild("Client")
local pieces = {
	["Pawn"] = "p",
	["Knight"] = "n",
	["Bishop"] = "b",
	["Rook"] = "r",
	["Queen"] = "q",
	["King"] = "k"
}

-- Fuck you error logger
if game:GetService("ReplicatedStorage").Connections:FindFirstChild("ReportClientError") then
    game:GetService("ReplicatedStorage").Connections.ReportClientError:Destroy()
    for _,v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Disable()
    end
end

local client = nil
for _,v in pairs(getreg()) do
    if type(v) == "function" then
        for _, v in pairs(getupvalues(v)) do
            if type(v) == "table" and v.processRound then
                client = v
            end
        end
    end
end
assert(client, "failed to find client")


-- Board from client
function getBoard()
    for _,v in pairs(debug.getupvalues(client.processRound)) do
        if type(v) == "table" and v.tiles then
            return v
        end
    end

    return nil
end

-- Gets client's team (white/black)
function getLocalTeam(board)
    -- Bot match detection
    if board.players[false] == plr and board.players[true] == plr then
        return "w"
    end
    
    for i, v in pairs(board.players) do
        if v == plr then
            -- If the index is true, they are white
            if i then
                return "w"
            else
                return "b"
            end
        end
    end

    return nil
end

function willCauseDesync(board)
    -- Bot match detection
    if board.players[false] == plr and board.players[true] == plr then
        return board.activeTeam == false
    end

    for i,v in pairs(board.players) do
        if v == plr then
            -- If the index is true, they are white
            return not (board.activeTeam == i)
        end
    end
    
    return true
end

-- Converts awful format of board table to a sensible one
function createBoard(board)
    local newBoard = {}
    for _,v in pairs(board.whitePieces) do
        if v and v.position then
            local x, y = v.position[1], v.position[2]
            if not newBoard[x] then
                newBoard[x] = {}
            end
            newBoard[x][y] = string.upper(pieces[v.object.Name])
        end
    end
    for _,v in pairs(board.blackPieces) do
        if v and v.position then
            local x, y = v.position[1], v.position[2]
            if not newBoard[x] then
                newBoard[x] = {}
            end
            newBoard[x][y] = pieces[v.object.Name]
        end
    end

    return newBoard
end

-- Board to FEN encoding
function board2fen(board)
    local result = ""
    local boardPieces = createBoard(board)
    for y = 8, 1, -1 do
        local empty = 0
        for x = 8, 1, -1 do
            if not boardPieces[x] then boardPieces[x] = {} end
            local piece = boardPieces[x][y]
            if piece then
                if empty > 0 then
                    result = result .. tostring(empty)
                    empty = 0
                end
                result = result .. piece
            else
                empty += 1
            end
        end
        if empty > 0 then
            result = result .. tostring(empty)
        end
        if not (y == 1) then
            result = result .. "/"
        end
    end
    result = result .. " " .. getLocalTeam(board)
    return result
end

function runGame()
    -- Get chess board
    local board = getBoard()
    
    -- Check if we're able to run without desync
    if willCauseDesync(board) then
        return false
    end

    -- Ask engine for result using fen encoded board
    local res = syn.request({
        Url = "http://localhost:3000/api/solve?fen=" .. HttpService:UrlEncode(board2fen(board)),
        Method = "GET"
    })
    local result = res.Body

    -- Ensure result is valid
    if string.len(result) > 4 then
        error(result)
    end

    -- Extrapolate movement from result string
    local chars = {}
    for c in result:gmatch(".") do
	    table.insert(chars, c)
    end

    -- Get move positions from table
    local x1 = 9 - (string.byte(chars[1]) - 96)
    local y1 = tonumber(chars[2])
    
    local x2 = 9 - (string.byte(chars[3]) - 96)
    local y2 = tonumber(chars[4])

    -- Make the move
    game.ReplicatedStorage.Connections.MovePiece:FireServer(board.id,
        {x1, y1},
        {x2, y2, ["moveOnly"] = false, ["doublestep"] = 999}
    )
    client:processRound(
        board:getPiece({x1, y1}),
        {x2, y2, ["moveOnly"] = false, ["doublestep"] = 999}
    )
    
    return true
end

game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameProcessedEvent)
    -- Run AI
    if (inputObject.KeyCode == shared.runBind) and not gameProcessedEvent then
        if runGame() then
            print("Ran AI")
        else
            print("Cannot run AI right now")
        end
    end
end)
