--[[

X -> player 1
0 -> player 2

1 2 3 4 5 6   7 8 9 10 11 12  || 13 14 15 16 17 18  19 20 21 22 23 24
0         X     X          0  ||  X           0      0              X  
0         X     X          0  ||  X           0      0              X
          X     X          0  ||  X           0      0               
          X                0  ||  X                  0               
          X                0  ||  X                  0         
--]]
require("util")

DEBUG = true
function log(s)
	if DEBUG then 
		print(s) 
	end
end

-- player 1 has positive checkers.
-- player 2 has negative checkers.
-- return an initialized board.
function createBoard() 
	local board = {}
	board.checkers = {}
	board.checkers[1]  = -2
	board.checkers[12] = -5
	board.checkers[17] = -3
	board.checkers[19] = -5

	board.checkers[6]  = 5
	board.checkers[8]  = 3
	board.checkers[13] = 5
	board.checkers[24] = 2

	for i=1,24 do
		if board.checkers[i] == nil then board.checkers[i] = 0 end
	end
	--index 1 is for player 1. table holds number of hit checkers.
	board.hitCheckers = {0, 0}
	board.bearingOffCheckers = {0, 0}
	return board
end

-- returns an empty board (without any checkers)
function createEmptyBoard()
	local board = {}
	board.checkers = {}
	for i=1,24 do board.checkers[i] = 0 end

	board.hitCheckers = {0, 0}
	board.bearingOffCheckers = {0, 0}
	return board
end 

function cloneBoard(board)
	local newBoard = {}
	newBoard.checkers = clone(board.checkers)
	newBoard.hitCheckers = clone(board.hitCheckers)
	newBoard.bearingOffCheckers = clone(board.bearingOffCheckers)
	return newBoard
end

-- returns an updated board (original board is not modified), collected (bearing off) checker index (or nil) and punished checker index (or nil)
-- if destination is nil, then player is collecting the checker at source.
-- source must be non-nil
function move(player, board, source, destination)
	--log("Player " .. player .. " is moving : " .. source .. " -> " .. (destination or "NULL"))
	local newBoard = cloneBoard(board)
	local sourceCheckers = newBoard.checkers[source]
	local destinationCheckers = newBoard.checkers[destination]
	local punishedCheckerIndex = 0;
	local collectedCheckerIndex = 0;

	if not isMoveValid(player, newBoard, source, destination) then
		return nil
	end
	--log("Player " .. player .. " is moving : " .. (source or "NULL") .. " -> " .. (destination or "NULL"))
	if source ~= nil and destination == nil and isCollecting(player, board) then
		local lastFullIndex = -1
		for i=6, 1, -1 do
			local index = i
			if player == 2 then
				index = 24 - i + 1
			end
			if board.checkers[index] ~= 0 then
				lastFullIndex = index
				break
			end
		end

		if lastFullIndex > 0 and (player == 1 and source >= lastFullIndex) or (player == 2 and source <= lastFullIndex) then
			collectedCheckerIndex = lastFullIndex	
		else
			collectedCheckerIndex = source
		end
	end
	--print("collected checker index " .. collectedCheckerIndex .. " source " .. source)

	if player == 1 then
		if source ~= nil then
			if sourceCheckers > 0 then
				newBoard.checkers[source] = sourceCheckers - 1 
			else
				if collectedCheckerIndex > 0 then
					newBoard.checkers[collectedCheckerIndex] = newBoard.checkers[collectedCheckerIndex] - 1
				end
			end
		end
		if destination ~= nil then
			if destinationCheckers == -1 then -- player 2 has one checker at destination
				punishedCheckerIndex = destination
				newBoard.checkers[destination] = 1
			else 
				newBoard.checkers[destination] = destinationCheckers + 1
			end	
		end
	else 
		--player 2
		if source ~= nil then
			if sourceCheckers < 0 then
				newBoard.checkers[source] = sourceCheckers + 1 
			else
				if collectedCheckerIndex > 0 then
					newBoard.checkers[collectedCheckerIndex] = newBoard.checkers[collectedCheckerIndex] + 1
				end
			end
		end
		if destination ~= nil then
			if destinationCheckers == 1 then
				punishedCheckerIndex = destination
				newBoard.checkers[destination] = -1
			else 
				newBoard.checkers[destination] = destinationCheckers - 1
			end
		end
	end
	
	if collectedCheckerIndex > 0 then
		newBoard.bearingOffCheckers[player] = newBoard.bearingOffCheckers[player] + 1
	end

	if punishedCheckerIndex > 0 then
		newBoard.hitCheckers[opponent(player)] = newBoard.hitCheckers[opponent(player)] + 1
	end

	if source == nil and destination ~= nil  then		
		newBoard.hitCheckers[player] = newBoard.hitCheckers[player] - 1
	end
	return newBoard, collectedCheckerIndex, punishedCheckerIndex
end

function opponent(player)
	if player == 1 then 
		return 2 
	else 
		return 1
	end
end

function isMoveValid(player, board, source, destination)
	if source == nil and destination == nil then
		--log("source and destination parameters are nil.")
		return false
	end
	if source ~=nill and (source < 1 or source > 24) then
		--log("source (if not null) must be in range [1, 24]")
		return false
	end
	if destination ~=nill and (destination < 1 or destination > 24) then
		--log("destination (if not null) must be in range [1, 24]")
		return false
	end

	local sourceCheckers = board.checkers[source]
	local destinationCheckers = board.checkers[destination]

	if board.bearingOffCheckers[player] == 15 then
		--log("All checkers are collected")
		return false
	end


	if source == nil and destination ~= nil then
		--attempt to re-place hit checker
		if board.hitCheckers[player] == 0 then
			log("Hit checker not found for player " .. player)
			return false
		end
		if player == 1 and destinationCheckers < -1 then
			return false
		end
		if player == 2 and destinationCheckers > 1 then
			return false
		end
	end

	if source ~= nil and destination == nil then
		--attempt to collect (bear-off) checkers
		if not isCollecting(player, board) then
			--log("All checkers must be at home for collection")
			return false
		end
	end

	if source ~= nil and destination ~= nil and sourceCheckers == 0 then
		return false
	end

	if sourceCheckers == 0 and not isCollecting(player, board) then
		return false
	end

	if sourceCheckers == 0 and destination == nil then
		if not isCollecting(player, board) then
			return false
		end

		if player == 1 then
			for i=source + 1, 6 do
				if board.checkers[i]>0 then
					return false
				end
			end
		else
			for i=source - 1, 19, -1 do
				if board.checkers[i] < 0 then
					return false
				end
			end
		end
		--log("Source '" .. source .. "' is empty")
	end

	if (player == 1 and sourceCheckers ~= nil and sourceCheckers < 0) or 
	   (player == 2 and sourceCheckers ~= nil and sourceCheckers > 0) then
		--log("Player can only move his/her checkers.")
		return false
	end
	
	if destination ~= nill then
		if (player == 1 and source ~= nil and source <= destination) or 
		   (player == 2 and source ~= nil and source >= destination) then
			--log("Wrong direction.")
			return false
		end		
	end

	if destinationCheckers ~= nil then
		if (player == 1 and destinationCheckers~=nil and destinationCheckers < -1) or 
		   (player == 2 and destinationCheckers~=nil and destinationCheckers > 1) then
			--log("Destination is full. Can not move checker.")
			return false
		end
	end

	if player == 1 and destination == nil and source > 6 then
		--log("Can not collect checkers outside home.")
		return false
	end

	if player == 2 and destination == nil and source < 19 then
		--log("Can not collect checkers outside home.")
		return false
	end
	return true
end

-- returns true if player can collect checkers on board
function isCollecting( player, board)
	if player == 1 then
		for i= 7,24 do
			if board.checkers[i] > 0 then
				return false
			end
		end
	end

	if player == 2 then
		for i= 1,18 do
			if board.checkers[i] < 0 then 
				return false
			end
		end	
	end

	return true
end

function play(player, board, dice, scoreFunction)
	local moves = findAllPossibleMoves(player, board, dice)
	local move = selectBestMove(moves, player, board, scoreFunction)
	return move
end

function findAllPossibleMoves(player, board, dice)
	if dice[1] ~= dice[2] then
		return findAllPossibleMovesForDifferentDiceValues(player, board, dice)
	else
		return findAllPossibleMovesForDoubleDice(player, board, dice)
	end
end

function findAllPossibleMovesForDifferentDiceValues(player, board, dice)
	local allMoves = {}
	local tmpMoves1 = findAllPossibleMovesForASingleDie(player, board, dice[1], nil)
	if tmpMoves1 ~= nil then
		for i=1, #tmpMoves1 do
			local previousMove = tmpMoves1[i]
			append(allMoves, findAllPossibleMovesForASingleDie(player, previousMove.board, dice[2], previousMove))
		end
		if #allMoves == 0 then
			append(allMoves, tmpMoves1)
		end
	end
	
	local numberOfMoves = #allMoves

	-- revert dice values and find moves
	local tmpMoves2 = findAllPossibleMovesForASingleDie(player, board, dice[2], nil)
	
	if tmpMoves2 ~= nil then
		for i=1, #tmpMoves2 do
			local previousMove = tmpMoves2[i]
			append(allMoves, findAllPossibleMovesForASingleDie(player, previousMove.board, dice[1], previousMove))
		end
	end

	if numberOfMoves == #allMoves then
		append(allMoves, tmpMoves2)
	end
	return reduceMoves(allMoves)
end

function findAllPossibleMovesForDoubleDice(player, board, dice)
	local dieValue = dice[1]
	local tmpMoves1 = findAllPossibleMovesForASingleDie(player, board, dieValue, nil)
	if tmpMoves1 == nil then
		return {}
	end

	local tmpMoves2 = {}
	for i=1, #tmpMoves1 do
		append(tmpMoves2, findAllPossibleMovesForASingleDie(player, tmpMoves1[i].board, dieValue, tmpMoves1[i]))
	end
	if #tmpMoves2 == 0 then
		return tmpMoves1
	end
	local tmpMoves3 = {}
	for i=1, #tmpMoves2 do
		append(tmpMoves3, findAllPossibleMovesForASingleDie(player, tmpMoves2[i].board, dieValue, tmpMoves2[i]))
	end
	if #tmpMoves3 == 0 then
		return tmpMoves2
	end

	local tmpMoves4 = {}
	for i=1, #tmpMoves3 do
		append(tmpMoves4, findAllPossibleMovesForASingleDie(player, tmpMoves3[i].board, dieValue, tmpMoves3[i]))
	end

	if #tmpMoves4 == 0 then
		return tmpMoves3
	end
	return reduceMoves(tmpMoves4)
end

function placeHitChecker(player, board, dieValue, previousMove)	
	if (player == 1 and board.checkers[dieValue] < 0) or (player == 2 and board.checkers[dieValue] > 0) then
		return
	end
	local checkerIndex = dieValue
    if player == 1 then
        checkerIndex = 24 - dieValue + 1
    end
    local newBoard = move(player, board, nil, checkerIndex)
    if newBoard == nil then
    	return nil
    end
    if previousMove == nil then
    	return createMove(newBoard, "BAR", checkerIndex)
    else
    	local move = clone(previousMove)
    	move.board = newBoard
    	move.source = clone(previousMove.source)
    	move.destination = clone(previousMove.destination)
    	table.insert(move.source, "BAR")
    	table.insert(move.destination, checkerIndex)
    	return move
    end
end


function findAllPossibleMovesByMovingCheckers(player, board, dieValue, previousMove)
	local moves = {}
	for i=1, 24 do
		local destination = i + dieValue
		if player == 1 then
			destination = i - dieValue
		end
		local newBoard = move(player, board, i, destination)
		if newBoard ~= nil then
		    if previousMove == nil then
		    	local move = createMove(newBoard, i, destination)
		    	table.insert(moves, move)
		    else
		    	local move = clone(previousMove)
		    	move.board = newBoard
		    	move.source = clone(previousMove.source)
		    	move.destination = clone(previousMove.destination)
		    	table.insert(move.source, i)
		    	table.insert(move.destination, destination)
		    	table.insert(moves, move)
		    end									
		end
	end
	return moves
end

function findAllPossibleMovesByCollectingCheckers(player, board, dieValue, previousMove)
	local index = dieValue
	if player == 2 then
		index = 24 - dieValue + 1
	end
	
	local newBoard = move(player, board, index, nil)
	if newBoard == nil then
		return {}
	else 
		if previousMove == nil then
	    	local move = createMove(newBoard, index, "BAR")
	    	return {move}
	    else
	    	local move = clone(previousMove)
	    	move.board = newBoard
	    	move.source = clone(previousMove.source)
	    	move.destination = clone(previousMove.destination)
	    	table.insert(move.source, index)
	    	table.insert(move.destination, "BAR")
			return {move}
		end
	end
	
end

function findAllPossibleMovesForASingleDie( player, board, dieValue, previousMove)
	-- first play with the hit checkers 
	if board.hitCheckers[player] > 0 then
		local move = placeHitChecker(player, board, dieValue, previousMove)
		return {move}
	end

	local moves = {}

	append(moves, findAllPossibleMovesByMovingCheckers(player, board, dieValue, previousMove))
	if isCollecting(player, board) then
		local tmpMoves  = findAllPossibleMovesByCollectingCheckers(player, board, dieValue, previousMove)
		append(moves, tmpMoves)
	end
	return moves
end

function createMove(board, source, destination)
	local move = {}
	move.board = board
    move.source = {}
    move.destination = {}
    move.source[1] = source
    move.destination[1] = destination
    return move
end

--[[
returns a list of distinct moves ( distinct board )
]]
function reduceMoves(moves)
	--log("reducing " .. #moves .. " move(s)")
	local result = {}
	local boardHashset = {}
	for i=1, #moves do
		local hash = hashOfBoard(moves[i].board)
		if not boardHashset[hash] then
			table.insert(result, moves[i])
			boardHashset[hash] = 1
		end
	end
	return result
end

function selectBestMove(moves, player, previousBoard, scoreFunction)
	local bestMove = nil
	local bestScore = -99999
	for i=1,#moves do
		score = scoreFunction(player, previousBoard, moves[i].board)
		if score > bestScore then
			bestMove = moves[i]
			bestScore = score
		end
	end
	log("best move score " .. bestScore)
	return bestMove
end


function hashOfBoard(board) 
	local hash = ""
	for i=1,24 do
		hash = hash .. board.checkers[i]
	end
	if board.hitCheckers[1] then
		hash = hash .. "p1Hit:" .. board.hitCheckers[1]
	end
	if board.hitCheckers[2] then
		hash = hash .. "p2Hit:" .. board.hitCheckers[2]
	end
	if board.bearingOffCheckers[1] then
		hash = hash .. "p1Bearoff:" .. board.bearingOffCheckers[1]
	end
	if board.bearingOffCheckers[2] then
		hash = hash .. "p2Bearoff:" .. board.bearingOffCheckers[2]
	end	
	return hash
end

-- random dice values are stored in the first and secont element of the returned table.
function rollDice()
	local dice = {}	
	--math.randomseed( os.time() )
	dice[1] = math.random(6)
    dice[2] = math.random(6)
    print("DICE : " .. dice[1] .. "-" .. dice[2])
    return dice
end

function pipCount(board) 
    local p1Pip = 0
    local p2Pip = 0
    for i = 1, 24 do
        if board.checkers[i] > 0 then
            p1Pip = p1Pip + (board.checkers[i] * i)            
        end

        if board.checkers[i] < 0 then
            p2Pip = p2Pip + (board.checkers[i] * (24 - i + 1) * -1)
        end
    end
    return p1Pip, p2Pip
end



function numberOfBlots(player, board)
	local count = 0
	for i=1, 24 do
		if (player == 1 and board.checkers[i] == 1 ) or (player==2 and  board.checkers[i] == -1)  then
			count = count + 1
		end
	end
	return count
end

function numberOfBearingOffCheckers(player, board)
	return board.bearingOffCheckers[player]
end

function numberOfPoints(player, board)
	local count = 0
	for i=1, 24 do
		if (player == 1 and board.checkers[i] > 1 ) or (player==2 and  board.checkers[i] < -1)  then
			count = count + 1
		end
	end
	return count
end
