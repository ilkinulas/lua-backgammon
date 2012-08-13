require('luaunit')
require('backgammon')

TestBackgammon = {} --class

	local player1 = 1
	local player2 = 2
	
	function TestBackgammon:testCreateBoard()
		local board = createBoard()
		assertEquals(board.checkers[1], -2)
		assertEquals(board.checkers[24], 2)
		assertEquals(board.checkers[2], 0)
	end


	function TestBackgammon:testClone()
		local board = createBoard()
		local clonedBoard = cloneBoard(board)

		for i=1,24 do
			assertEquals(clonedBoard.checkers[i], board.checkers[i])
		end
		
	end

	function TestBackgammon:testMoveExceptions()
		local board = createBoard()
		local newBoard = move(player1, board, 2, 3)
		assertEquals(newBoard, nil)

		newBoard = move(player1, board, 12, 10)
		assertEquals(newBoard, nil)

		newBoard = move(player2, board, 6, 8)
		assertEquals(newBoard, nil)
	
		newBoard = move(player1, board, 6, 8)
		assertEquals(newBoard, nil)

		newBoard = move(player2, board, 12, 10)
		assertEquals(newBoard, nil)		

		newBoard = move(player1, board, 24, 19)
		assertEquals(newBoard, nil)

		newBoard = move(player2, board, 1, 6)
		assertEquals(newBoard, nil)

		newBoard = move(player2, board, 2, 1)
		assertEquals(newBoard, nil)

		newBoard = clone(board)
		newBoard[2] = 2 -- place two checkers for player1
		-- player 1 is collecting checker at position 2
		assertEquals(isMoveValid (player1,  newBoard, 2, nil), false);

	end

	function  TestBackgammon:testMove()
		local board = createBoard()
		local newBoard, collected, punished = move(player1, board, 24, 22)
		assertEquals(collected, 0)
		assertEquals(punished, 0)
		assertEquals(newBoard.checkers[24], 1)
		assertEquals(newBoard.checkers[22], 1)

		newBoard, collected, punished = move(player2, board, 12, 16)
		assertEquals(collected, 0)
		assertEquals(punished, 0)
		assertEquals(newBoard.checkers[12], -4)
		assertEquals(newBoard.checkers[16], -1)
		--prettyPrint(newBoard)
	end

	function TestBackgammon:testCollectCheckers()
		local board = createEmptyBoard()
		board.checkers[1] = 3
		board.checkers[2] = 5
		board.checkers[3] = 2

		board.checkers[24] = -3
		board.checkers[23] = -5
		board.checkers[22] = -2
		local newBoard, collected, punished = move(player1, board, 2, nil)
		assertEquals(collected, 2)
		assertEquals(newBoard.bearingOffCheckers[player1], 1)
		assertEquals(punished, 0)
		assertEquals(newBoard.checkers[1], 3)
		assertEquals(newBoard.checkers[2], 4)

		newBoard, collected, punished = move(player2, board, 23, nil)
		assertEquals(collected, 23)
		assertEquals(newBoard.bearingOffCheckers[player2], 1)
		assertEquals(punished, 0)
		assertEquals(newBoard.checkers[23], -4)
		assertEquals(newBoard.checkers[22], -2)	

		board.checkers[20] = -1	
		newBoard, collected, punished = move(player2, board, 20, nil)
	end

	function TestBackgammon:testPunish()
		local board = createBoard()
		board.checkers[1] = -1
		local newBoard, collected, punished = move(player1, board, 6, 1)
		assertEquals(collected, 0)
		assertEquals(punished, 1)
		assertEquals(newBoard.hitCheckers[player2], 1)
		assertEquals(newBoard.checkers[1], 1)
		assertEquals(newBoard.checkers[6], 4)		
	end

	function TestBackgammon:testReduceMoves( )
		local moves = {}
		table.insert(moves, createMove(createBoard(), 1, 2))
		table.insert(moves, createMove(createBoard(), 1, 2))
		table.insert(moves, createMove(createBoard(), 1, 2))
		local reducedMoves = reduceMoves(moves)
		assertEquals(#reducedMoves, 1)

		local board = createBoard()
		board.hitCheckers[1] = 1
		local aMove = createMove(board, 1, 2)
		table.insert(moves, aMove)
		reducedMoves = reduceMoves(moves)
		assertEquals(#reducedMoves, 2)
	end

	function TestBackgammon:testFindAllPossibleMovesForASingleDie()
		local board = createBoard()
		--player 2
		local moves = findAllPossibleMovesForASingleDie(player2, board, 1, nil)
		assertEquals(#moves, 3)
		moves = findAllPossibleMovesForASingleDie(player2, board, 5, nil)
		assertEquals(#moves, 2)
		moves = findAllPossibleMovesForASingleDie(player2, board, 3, nil)
		assertEquals(#moves, 4)

		--player 1
		moves = findAllPossibleMovesForASingleDie(player1, board, 1, nil)
		assertEquals(#moves, 3)
		moves = findAllPossibleMovesForASingleDie(player1, board, 5, nil)
		assertEquals(#moves, 2)
		moves = findAllPossibleMovesForASingleDie(player1, board, 3, nil)
		assertEquals(#moves, 4)
	end

	function TestBackgammon:testFindAllPossibleMoves()
		local board = createBoard()
		local dice = {1, 2}
		local moves = findAllPossibleMoves(player2, board, dice)
		assertEquals(#moves, 15)
		for i=1, #moves do
			--prettyPrint(moves[i].board)
		end

		local moves = findAllPossibleMoves(player1, board, dice)
		assertEquals(#moves, 15)
		
		board = createBoard()
		assertEquals(numberOfPoints(player2, board), 4)
	end

	function TestBackgammon:testFindAllPossibleMovesForDoubleDice()
		local board = createEmptyBoard()
		board.checkers[1] = -2
		board.checkers[2] = 3
		board.checkers[4] = 3
		board.checkers[5] = 5
		board.checkers[6] = 2
		board.checkers[12] = -5
		board.checkers[16] = 2
		board.checkers[21] = -3
		board.checkers[23] = -5

		local moves = findAllPossibleMovesForDoubleDice(player1, board ,{4, 4})
		assertEquals(#moves, 1)
		local move = moves[1]
		assertEquals(6, move.source[1])
		assertEquals(6, move.source[2])
		assertEquals(2, move.destination[1])
		assertEquals(2, move.destination[2])
	end

	function TestBackgammon:testOneMove()
		local board = createBoard()
		for i=1,24 do
			board.checkers[i] = 0
		end
		board.checkers[6] = 5
		board.checkers[5] = 5
		board.checkers[4] = 5

		--prettyPrint(board)
		local dice = {6, 1}
		local moves = findAllPossibleMoves(player1, board, dice)
		--print(#moves)
	end

	function TestBackgammon:testNumberOfPoints()
		local board = createBoard()
		assertEquals(numberOfPoints(player1, board), 4)
		assertEquals(numberOfPoints(player2, board), 4)

		board.checkers[24] = 1
		board.checkers[23] = 1
		assertEquals(numberOfPoints(player1, board), 3)
	end

	function TestBackgammon:testNumberOfBlots()
		local board = createBoard()
		assertEquals(numberOfBlots(player1, board), 0)
		assertEquals(numberOfBlots(player2, board), 0)

		board.checkers[24] = 1
		board.checkers[23] = 1
		assertEquals(numberOfBlots(player1, board), 2)
	end

-- class TestBackgammon

TestTutu  = {}
	function TestTutu:testSil()
		local board = createEmptyBoard()
		board.checkers[1] = 6
		board.checkers[2] = 3
		board.checkers[3] = 2
		board.checkers[5] = 2
		board.checkers[22] = -3
		board.checkers[23] = -4
		board.checkers[24] = 2
		local moves = findAllPossibleMoves(player1, board, {6, 4})
		for i=1, #moves do
			prettyPrintMove(moves[i])
		end
		
	end

LuaUnit:run()
