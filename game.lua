require('backgammon')

player1 = 1
player2 = 2
board = createBoard()

function score1(player, previousBoard, board)	
	local pointsCoefficient = 0.5
	local bearingOffCoefficient = 0.4
	local myBlotsCoefficient = 0.3
	local opponentCoefficient = 0.2

	local diffBearingOfCheckers = numberOfBearingOffCheckers(player, board) - numberOfBearingOffCheckers(player, previousBoard)
	local diffMyNumberOfBlots = numberOfBlots(player, board) - numberOfBlots(player, previousBoard)
	local diffOpponentNumberOfBLots = numberOfBlots(opponent(player), board) - numberOfBlots(opponent(player), previousBoard)

	if isCollecting(player, board) then
		pointsCoefficient = 0.0
		myBlotsCoefficient = 0.0
	end

	return numberOfPoints(player, board) * pointsCoefficient + diffBearingOfCheckers * bearingOffCoefficient - diffMyNumberOfBlots * myBlotsCoefficient + diffOpponentNumberOfBLots * opponentCoefficient
end

function score2(player, previousBoard, board)
	return 0
end

local interactive = false

while true do
	print("PLAYER 1 is playing...")
	local dice = rollDice()
	local move = play(player1, board, dice, score1)	
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

	
	if interactive then local line = io.read() end

	print("PLAYER 2 is playing...")
	dice = rollDice()

	move = play(player2, board, dice, score2)
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
	
	if interactive then local line = io.read() end
end