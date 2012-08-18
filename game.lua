require('backgammon')

--[[
Backgammon game simulation.
]]

player1 = 1
player2 = 2
board = createBoard()

local debugMode = false

while true do
	print("PLAYER 1 is playing...")
	local dice = rollDice()
	local move = play(player1, board, dice, selectBestMove)	
	if move == nil then
		print("Can not play, waiting...")
	else 
		board = move.board
		prettyPrintMove(move)
		if board.bearingOffCheckers[player1] == 15 then
			print("PLAYER 1 WINS")
			break
		end
	end

	
	if debugMode then local line = io.read() end

	print("PLAYER 2 is playing...")
	dice = rollDice()

	move = play(player2, board, dice, nil)
	if move == nil then
		print("Can not play, waiting...")
	else 
		board = move.board
		prettyPrintMove(move)
		if board.bearingOffCheckers[player2] == 15 then
			print("PLAYER 2 WINS")
			break
		end

	end
	
	if debugMode then local line = io.read() end
end