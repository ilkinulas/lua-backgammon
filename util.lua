-- return a copy of the table  t
function clone(t)
	local new = {}
	local i, v = next(t, nil)
	while i do
		new[i] = v
		i, v = next(t, i)
	end
	return new
end

function shuffle(t)
	local n = #t

	while n >= 2 do
		-- n is now the last pertinent index
		local k = math.random(n) -- 1 <= k <= n
		-- Quick swap
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end

	return t
end

function append(t1, t2)
	for i=1, #t2 do
		table.insert(t1, t2[i])
	end
	return t1
end

function concatTables(t1, t2)
	if t1 == nil or #t1 ==0 then
		return clone(t2)
	end

	if t2 == nil or #t2 ==0 then
		return clone(t1)
	end

	result = {}
	for i = 1, #t1 do
		table.insert(result, t1[i])
	end
	
	for i = 1, #t2 do
		table.insert(result, t2[i])
	end	
	return result
end

function isEmpty(t) 
    return next(t) == nil
end

function printBoard(board)
	for i=1,24 do
		print(board.checkers[i])
	end
end

--[[
prints the formatted backgammon board. ASCII visualisation of the board.
1 | 2 2                | 24
2 |                    | 23
3 |                 1 1| 22
4 |                    | 21
5 |                    | 20
6 | 1 1 1 1 1 2 2 2 2 2| 19
  ====================  
  ====================  
7 |                    | 18
8 | 1 1 1         2 2 2| 17
9 |                    | 16
10|                    | 15
11|                    | 14
12| 2 2 2 2 2 1 1 1 1 1| 13
]]
function prettyPrint(board)
	local player1Checker = "1"
	local player2Checker = "2"
	local maxNumberOfCheckersInARow = -1
	print(" ")
	for i=1, 12 do
		local j = 24 - i + 1
		num = math.abs(board.checkers[i]) + math.abs(board.checkers[j])
		if num > maxNumberOfCheckersInARow then
			maxNumberOfCheckersInARow = num
		end
	end

	for i=1, 12 do
		local j = 24 - i + 1
		local s = i .. " |"
		if i>9 then -- two digits
			s = i .. "|"
		end
		
		
		for ii =1, board.checkers[i] do 
			s = s .. " " .. player1Checker
		end
	
		for ii =board.checkers[i], -1 do 
			s = s .. " " .. player2Checker
		end			
	
		local numEmptyPlaces = maxNumberOfCheckersInARow - (math.abs(board.checkers[i]) + math.abs(board.checkers[j]))

		for ii=1, numEmptyPlaces do
			s = s .. "  "
		end
		
		for ii=1, board.checkers[j] do 
			s = s .. " " .. player1Checker
		end
	
		for ii = board.checkers[j], -1 do
			s = s .. " " .. player2Checker
		end						
	
		s = s .. "| " .. j

		print(s)			
		if i==6 then
			local bar = "  "
			for ii=1, maxNumberOfCheckersInARow do
				bar = bar .. "=="
			end
			bar = bar .. "  "
			print(bar)
			print(bar)
		end
	end
	if board.hitCheckers[1] > 0 then
		print("Player 1 has " .. board.hitCheckers[1] .. " hit checkers")
	end
	if board.hitCheckers[2] > 0 then
		print("Player 2 has " .. board.hitCheckers[2] .. " hit checkers")
	end
	print(" ")
end

--[[
 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 
 -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 
 2              1     1           2  1           2     2        1       
 2              1     1           2  1           2     2        1       
                1     1           2  1           2     2                
                1                 2  1                 2                
                1                 2  1                 2        
]]
function prettyPrint2(board)
	function twoDigit(number)
		if number > 9 then
			return ""..number
		else
			return " "..number
		end
	end

	local s =""
	local l =""
	for i=1, 6 do
		s = s .. twoDigit(i) .. " "
		l = l .. " - "
	end
	
	for i=7, 12 do
		s = s ..  twoDigit(i) .. " "
		l = l .. " - "
	end
	
	for i=13, 18 do
		s = s ..  twoDigit(i) .. " "
		l = l .. " - "
	end
	
	for i=19, 24 do
		s = s ..  twoDigit(i) .. " "
		l = l .. " - "
	end			
	print(s)
	print(l)

	
	for i=1, 15 do
		s = ""
		for j=1,24 do
			if math.abs(board.checkers[j])>=i then
				if board.checkers[j] > 0 then
					s = s .. " 1 " 
				else
					s = s .. " 2 "
				end
			else 
				s = s .. "   " 
			end
		end
		if string.find(s, "1") or  string.find(s, "2") then
			print(s)
		end
	end
	if board.hitCheckers[1] > 0 then
		print("Player 1 has " .. board.hitCheckers[1] .. " hit checkers")
	end
	if board.hitCheckers[2] > 0 then
		print("Player 2 has " .. board.hitCheckers[2] .. " hit checkers")
	end
end


function prettyPrintMove(move) 
	s = "MOVE : "
	for i=1, #move.source do
		s = s .. "[" .. move.source[i] .. " -> " ..move.destination[i] .. "] "
	end
	print(s)
	prettyPrint2(move.board)
end