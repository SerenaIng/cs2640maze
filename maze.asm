
########################################################################
# Program: Maze, HW 4				Programmer: Serena Ing
# Due Date: Dec. 13, 2019				Course: CS 2640
########################################################################
# Overall Program Functional Description:
#	The program generates a maze. The user is able to enter the width 
# 		and height of the maze. The computer is then tasked with finding
# 		a route from a randomly generated entrance to the randomly 
# 		generated exit. The completed maze is then printed.
#
########################################################################
# Register usage in Main:
#	$v0, $a0 -- outputs and arguments for subroutines
# 	$t0  -- address for the board, general computations
# 	$t1  -- holds value wid*hgt - 1
########################################################################
# Pseudocode Description:
#	1. Print a welcome message
#	2. Get the width and height of the maze  			  (Call getSize)
#	3. Identify the border and non-border cells of the maze. (initBoard)
#	4. Randomly generate an entrance 					  (pickEntrance)	
# 	5. Randomly generate an exit 						  	  (pickExit)
# 	6. Print the board 										(printBoard)
# 		6.5 While numLeft > 0, call takeMove 				  (takeMove)
# 	7. Compute how many squares are left, 
# 		which will be wid.size * hgt.size - 1 
# 		(minus 1 because we already took the entrance square). 
# 	8. Clean up, print a 'bye' message, and leave.
#
########################################################################
	.data
	.align 2
wid: 	.word 10 # Length of one row, must be 4n - 1
hgt: 	.word 10 # Number of rows
cx: 	.word 0
cy: 	.word 0
numLeft: .word 0
board: .space 1600 # Max 40 x 40 maze
prompt: .asciiz "Please enter a random seed: "
bye: 	.asciiz "\nThanks for playing!"
#Test variables
	numCells: .asciiz  "\nNumber of Cells Left: "
	#testing: .asciiz 	" x "
	#newline: .asciiz 	"\n"
	pause: 	 .asciiz 	"Please press enter:"
	.globl main
	.text
main:
	li $v0, 4 		#Call the Print String I/O Service to print string
	la $a0, prompt  #Ask the user for a random value to seed rand with
	syscall
	li $v0, 5 		#Call the I/O Service to Read Int
	syscall
	move $a0, $v0 	#Move the output from syscall so it is an argument for seedrand
	jal seedrand 	#Call seedrand to store the value

	la 		$t0, board 	#Load from memory to reg the pointer address to the board (length of one row) for the 2D array from memory to register
	
	jal 	getSize

#Loading 0s and 5s into array
	jal 	initBoard
	jal pickExit
	jal pickEntrance 	#Don't pick the entrance before the exit. You overwrite the cx, cy values

	lw $t0, wid 		# 	load value of wid
	addi $t0, $t0, 1 	#Actually need wid.size 
	lw $t1, hgt 		# 	load value of hgt 		
	addi $t1, $t1, 1 	#need hgt.size
	mult $t0 $t1 		#Multiply wid.size * hgt.size
	mflo $t1 			#Move to $t1
	addi $t1, $t1, -1 	#Subtract one from the value since entrance was already taken

	move $t6, $t1 		#Copy the number of cells from $t1 to $t6
loopTakeMove:
	jal takeMove
	addi $t6, $t6, -1  	#Decrement the number of cells each time takeMove is taken
	bnez $t6, loopTakeMove #If $t6 is not equal to zero, loopTakeMoves


#	li 		$v0, 4		#Call the Print String I/O Service to print String
#	la 		$a0, pause 	# 	Pause here
#	syscall
#	li 		$v0, 5		#Call the Read Integer I/O Service to read int, forces system to pause 
#	syscall
	jal printBoard


	
#	li 		$v0, 4			#Print wid.size *hgt.size -1  with the syscall function
#	la 		$a0, numCells
#	syscall
#	move 		$a0, $t6 	
#	li 		$v0, 1
#	syscall

end:
	li 		$v0, 4 	#Print bye to let user know program is ending
	la 		$a0, bye
	syscall

########################################################################
# Function Name: getSize
########################################################################
# Functional Description:
# Ask the user for the size of the maze. If they ask for a dimension
# less than 5, we will just use 5. If they ask for a dimension greater
# than 40, we will just use 40. This routine will store the size into
# the globals wid and hgt.
#
########################################################################
# Register Usage in the Function:
# $t1, $t2 	-- addresses for wid - 1 and hgt - 1, the values for the 
# 					right edge and	bottom row.
# $t3 		-- a flag for setWidth
# $t7, $t8 	-- values 5 and 40 respectively, to check for range
# $v0, $a0  -- input and output registers
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Prompt for the two values
# 2. Fetch each of the two values
# 3. Limit the values to the range 5 <= n <= 40
# 4. Store into wid and hgt
#
########################################################################
	.data
	.align 2
askWid: 	.asciiz 	"\nWhat is the width of the maze: "
askHgt: 	.asciiz 	"\nWhat is the height of the maze: "
	.text
getSize:
	la 		$t1, wid 	#Load from memory to reg the address for wid/length of a row
	la 		$t2, hgt 	#Load from memory to reg the address for the number of rows
	li 	$t3, 0 			#Use $t3 as a flag for setWidth, if 0, it has not yet been set
	li 	$t8, 40			#Prep $t8 with hard coded val of 40
	li 	$t7, 5			#Prep $t7 with hard coded val of 5
	li 	$v0, 4			#Call the Print String I/O Service to print String
	la 	$a0, askWid		# 	Asking for the width of the maze
	syscall
	li 	$v0, 5			#Call the Read Integer I/O Service to read int
	syscall
	bgt $v0, $t8, big40 #If the size is greater than 40, branch 	
	blt	$v0, $t7, les5 	#If the size is less than 5, branch
setWidth:
	addi $v0, $v0, -1 	#Add (-1) + width, save into $t1
	sw 	$v0, 0($t1) 	#Store from $v0 register to address at $t1, memory location wid
	addi $t3, $t3, 1 	#Set as flag to show setWidth has been reached
	li 	$v0, 4 			#Call the Print String I/O Service to print String
	la 	$a0, askHgt 	#	 Asking for the height of the maze
	syscall
	li 	$v0, 5 			#Call the Read Integer I/O Service to read int
	syscall	
	bgt $v0, $t8, big40
	blt $v0, $t7, les5
setHeight:
	addi $v0, $v0, -1 	#Add (-1) + height, save into $t2
	sw 	$v0, 0($t2) 	#Store from $v0 register to address at $t2, memory location hgt
	jr 	$ra
big40:
	li 	$v0, 40 			#If the input was greater than 40, set the input register value to 40
	beqz $t3, setWidth   	#Check if width was set, if not, branch to width
	j 	setHeight			#If it was, jump to setHeight
les5:
	li 	 $v0, 5				#If input was less than 5, set the value to 5
	beqz $t3, setWidth 	#Check if width was set: if not, branch to setWidth
	j 	 setHeight			#Else, jump to setHeight


########################################################################
# Function Name: initBoard
########################################################################
# Functional Description:
# Initialize the board array. All of the cells in the middle of the
# board will be set to 0 (empty), and all the cells on the edges of
# the board will be set to 5 (border).
#
########################################################################
# Register Usage in the Function:
# $t0 -- Pointer into the board
# $t1, $t2 -- wid - 1 and hgt - 1, the values for the right edge and
# bottom row.
# $t3, $t4 -- loop counters
# $t6 -- the value to store
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Set $t0 to point to the board
# 2. Build nested loops for each row and column
# 2a. If we are in the first or last iteration of either loop,
# place a 5 in the board.
# 2b. Otherwise, place a 0 in the board
# 2c. Increment $t0 after each placement, to go to the next cell.
#
########################################################################
	.data
	.text
initBoard:
	la	$t0, board 		#$t0  have board pointer loaded
	lw 	$t1, 0($t1) 	#Load the inner loop counter limit. Set it equal to the value from address at $t1, wid
	lw  $t2, 0($t2)		#Load the outer loop counter limit. Set it equal to the value from address at $t2, hgt
	li  $t3, 0 			#Initialize the loop counters
	li  $t4, 0
	li  $t6, 5 			#Set $t6 to the value needed to be loaded for the borders
outer:
	bgt $t4, $t2, outerend 		#If $t4>$t2 exit loop
	li 	$t3, 0  				#set inner loop counter to 0
inner:
	bgt  $t3, $t1, innerend 	#If $t3>$t1 exit loop
	beqz $t4, ifEdge 			#If $t4 == 0 (outer loop counter is zero)
	beq  $t4, $t2, ifEdge 		#If $t4 == hgt (is at top row)
	beqz $t3, ifEdge 			#If $t3 == 0
	beq  $t3, $t1, ifEdge		#If $t3 == wid (is at end of row)
	sw 	 $zero, 0($t0) 			#Store 0 if it is not an edge
	j increment
ifEdge:
	sw 	$t6, 0($t0) 			#Store 5 if it is an edge
increment:
	addi	$t3, $t3, 1 #Increment the inner loop counter
	addi 	$t0, $t0, 4 #Move to the next array location
	j 	inner	
innerend:
	addi 	$t4, $t4, 1 #Increment the outer loop counter
	j 	outer
outerend:
	jr 	$ra
########################################################################
# Function Name: placeInSquare
########################################################################
# Functional Description:
# A value is passed in $a0, the number to be placed in one square of
# the board. The global variables cx and cy indicate which square.
#
########################################################################
# Register Usage in the Function:
# $a0 -- The value to be placed
# $t0, $t1 -- general computations
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. compute the effective address, board + cy * wid + cx
# 	a. 	NOTE TO SELF: multiply (cy * wid.size +cx) by 4 before adding to board
# 		bc DATA ALIGNMENT IS IMPORTANT AND MIPS WILL THROW AN ERROR otherwise
# 2. Store the byte in $a0 at this address.
#
########################################################################
	.data
	.text
placeInSquare:
	la $t0, cy	 		#Load to $t0 the address of cy
	lw $t0, 0($t0) 		#Load to $t0 the value from address for cy
	la $t1, wid 		#Load to $t1 the address of wid
	lw $t1, 0($t1) 		#Load to $t1 the value from address for wid
	addi $t1, $t1, 1 	# wid is an index, but need the row size here, so add wid+1
	mult $t0, $t1 		#Multiply cy and wid (in registers $t0 and $t1)
	mflo $t0			#	Move product to $t0
	la 	$t1, cx	 		#Load to $t1 the address of cx
	lw  $t1, 0($t1) 	#Load to $t1 the value from address for cx	
	add $t0, $t0, $t1 	#Load to $t0 the sum of $t0 + $t1 (cy *wid.size + cx)
	sll $t0, $t0, 2 	#Shift $t0 by two to MULTIPLY IT BY 4
	la 	$t1, board 		#Load to $t1 the address of board
	add $t0, $t0, $t1 	#$t0 = $t0 + $t1 ([cy*wid.size + cx] + board), points to a space on the board
	sw $a0, 0($t0) 		#Store to the address at ($v0 + offset 0) the value from $a0
	jr $ra

########################################################################
# Function Name: pickEntrance
########################################################################
# Functional Description:
# This picks the entrance for the maze. It goes to one of the
# cells on the north edge of the map (inside the border), then changes
# it's value from 0 (empty) to 1 (came from north).
# This routine will exit with cx, cy set to the cell, so we are ready
# to find a path here through the maze.
#
########################################################################
# Register Usage in the Function:
# $a0, $v0 -- used for syscall linkage, and calculations
# We save $ra on stack, because we call the rand and placeInSquare
# functions
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save $ra on the stack
# 2. Pick a random column, from 1 to wid - 1
# 3. Place '1' in the chosen border cell
# 4. Restore the $ra value
#
########################################################################
	.data
	.text
pickEntrance:
	addiu 	$sp, $sp, -4 	#Clear 4 bits on the stack pointer
	sw 	 	$ra, 0($sp)		#Save $ra onto the stack
	sw $zero, cy
	lw $a0, wid
	jal rand				#Generate a number from 0 to wid -1 (calling it col) by calling rand subroutine, returns val in $v0
 	sw $v0, cx
 	li $a0, 1 		#Load a 1 into $a0 as an argument for the placeInSquare subroutine
 	jal placeInSquare
done:
	lw 		$ra, 0($sp) 	#Load to the $ra register the old $ra from the stack
	addiu 	$sp, $sp, 4 	#Clean up the stack, re-add the 4 bits
	jr $ra
########################################################################
# Function Name: pickExit
########################################################################
# Functional Description:
# This picks the exit for the maze. It goes to one of the border
# cells on the south edge of the map, then changes it's value from
# 5 (border) to 1 (came from north).
#
########################################################################
# Register Usage in the Function:
# $a0, $v0 -- used for syscall linkage, and calculations
# We save $ra on stack, because we call the rand and placeInSquare
# functions
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save $ra on the stack
# 2. Pick a random column, from 1 to wid - 1
# 3. Place '6' in the chosen border cell 
# 		Serena's Edit: Use '6' instead of '1' to differentiate the exit
# 		from the entrance and any cell's in the row that 'came from north.'
# 4. Restore the $ra value
#
########################################################################
	.data
	.text
pickExit:
	addiu 	$sp, $sp, -4 	#Clear 4 bits on the stack
	sw 	 	$ra, 0($sp)		#Save $ra onto the stack
	la $v0, cy 		#Load address of cy into $v0
	la $a0, hgt 	#Load address of hgt into $a0
	lw $a0, 0($a0) 	#Load the value of hgt into $a0, use hgt bc actually need numRows-1 to get indexes of last row cells 
	sw $a0, 0($v0) 	#Store hgt into the address at $v0, cy, since exit is in the last row of the board
	la $a0, wid 		#Load the address of wid into $a0
	lw $a0, 0($a0)		#Load the value of wid into $a0 to seed the random generator
	jal rand			#Generate a number from 0 to wid -1 (calling it col) by calling rand subroutine, returns val in $v0
	la $a0, cx 			#Load the address of cx into $a0
	sw $v0, 0($a0) 		#Load the number from the rand subroutine to cx
	li $a0, 6 			#Load 1 into $a0 as an argument
	jal placeInSquare	#Call placeInSquare subroutine
	lw 		$ra, 0($sp) 	#Load to the $ra register the old $ra from the stack
	addiu 	$sp, $sp, 4 	#Clean up the stack, re-add the 4 bits
	jr $ra
########################################################################
# Function Name: printBoard
########################################################################
# Functional Description:
# This prints the final maze to the console
#
########################################################################
# Register Usage in the Function:
# $a0, $v0 -- used for syscall linkage
# $t8 -- pointer to first cell in current row
# $t9 -- loop counter for rows
# $t7, $t6 -- pointers to neighboring cells as we scan rows
# $t5 -- loop counter for columns
# $t0, $t1 -- general computations
# $s0, $s1 -- Loop counter limits
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Loop for each row on the board. $t8 will point to the first cell
# in the row, and $t9 is the loop counter.
# 	1a. Loop for each column, printing the north wall/door. $t7 will
# 		point to the north cell, $t6 to the south cell, and $t5 is
# 		loop counter.
# 		1a1. If board[$t7] came from south or board[$t6] came from
# 			north, print open door. Otherwise print wall.
# 	1b. At end of row, print closing char and newline.
# 	1c. If we are in the last row of the board, don't print the 'cells'
# 		at the bottom edge, they are the border of the map. Skip
# 		steps 1d and 1e.
# 	1d. Loop for each column, printing the west wall/door. $t7 will
# 		point to the west cell, $t6 to the east cell, and $t5 is
# 		loop counter.
# 		1d1. If board[$t7] came from east or board[$t6] came from
# 		west, print open door. Otherwise print wall.
# 	1e. At end of row, print closing char and newline.
#
########################################################################
 	.data
 	.align 2
topWall:  .asciiz "+--"
topDoor:  .asciiz "+  "
topEnd:   .asciiz "+\n"
sideWall: .asciiz "|  "
openWall: .asciiz "   "
sideEnd:  .asciiz "|\n"
 	.text
printBoard:
	la $s0, wid 	#Load the address of wid into $s0
	lw $s0, 0($s0)	#Load the value of wid into $s0. Limit for colLoop counter 
	addi $s0, $s0, 1 #Add one to make it the size of the row
	la $s1, hgt 	#Load the address of hgt into $s1
	lw $s1, 0($s1) 	#Load the value of hgt into $s1. Limit for rowLoop counter

	li $t9, 0 	#Initialize the rowLoop counter to zero
loopRow:
	bgt $t9, $s1, outRowLoop 	#If rowLoop counter is greater than limit in $s1	
	li $t5, 0 			#Initialize the colLoop counter to zero
#Loading $t8 with the address of the first cell of the row
#Using registers $s0, $s1, $t0, $t9, $t8, $t5
	move $t0, $s0 	 	#Load the value of wid to $t0 from $s0
	mult $t0, $t9 	 	#Multiply the row size and the rowLoop counter. This is (rowSize*y)
	mflo $t0 		 	# 	Move the product to the $t0 register
	sll $t0, $t0, 2  	#Multiply by 4 to get an aligned memory address
	la $t8, board 		#Load to $t8 the address of the board, the first cell of the first row
	add $t8, $t8, $t0 	#Add the address of the board + (rowSize*y) to get the address of the first cell in row y

loopCol: 	#This is looping through the columns, setting $t6 to the south cell
	bge  $t5, $s0, printTopEnd	#outColLoop  #If colLoop counter equals wid.size in $s0, print the topEnd string and move to the next loop
	
#Set $t6, the South Cell
	sll  $t0, $t5, 2 	#Multiply $t5, colLoop counter, by 4. Load to $t0
	add  $t0, $t0, $t8 	#Add x + address of the first cell in this row. This is [x + (rowSize*y)].  
	lw 	 $t6, 0($t0) 	#Load the value from the address of the cell to $t6. $t6 is the value of the south cell
	bgt  $t9, $s1, bottomEdge   #If hgt counter is greater than hgt, it is a special case. Skip comparison of $t6 here and assigning $t7 
	li 	 $t1, 1 				#See if $t6 came from the north (1)
	beq  $t6, $t1, printDoor 	#If $t6 came from the north, print a door
	beqz $t9, printWall		#If is in the first row, do not set $t7 to an address bc $t7 does not exist
	sll  $t7, $s0, 2 	#Calculate the address of the north cell by taking the size of one row, multiplying it by 4,
	sub  $t7, $t0, $t7 	# 	And subtracting it from the address of the south cell, that was stored in $t0 previously
	lw 	 $t7, 0($t7) 	#Load the value from the address of the cell to $t7 to $t7. Now it's the value of the north cell	
	li 	 $t1, 2 		#See if $t7 came from the south (2)
	beq  $t7, $t1, printDoor 	#If $t7 came from the south, print a door
printWall:
	li  $v0, 4 			#The else statement basically. $t6!=1 && $t7!=2 (The south cell did not come from north, the north cell did not come from south)
	la  $a0, topWall   	# 	So we are printing a topWall
	syscall
	j  	incrementRow 
printDoor: 			#Printing a door
	li 	$v0, 4
	la  $a0, topDoor
	syscall
	j 	incrementRow
printTopEnd: 		#Printing the last character of the row and exiting the loop
	li 	$v0, 4
	la  $a0, topEnd
	syscall
	li  $t5, 0 			#Reset the rowLoop counter so can loop through the row again
	bgt $t9, $s1, bottomEdgePrinted  	#If was printing the bottom edge, skip printing sideWalls, exit loops
	j  	loopEastCell	#outColLoop
incrementRow:
	addi $t5, $t5, 1 	#Increment the colLoop counter, $t5. This moves you through the x coordinates in one row
	j loopCol
bottomEdge: 		#Special case. Prints the bottom edge of the maze with one exit
	li  $t1, 6
	beq $t6, $t1, printDoor 	#If it is an exit (6), print the exit
	j printWall 				#Else print a wall
	
#Set $t6 to the East Cell
loopEastCell:
	bge  $t5, $s0, printSideEnd #If the loop counter goes beyond the row limit, print the closing character and start a new line
	beqz $t5, printSideWall 	#If $t6 is the first cell in the row, print a wall. Otherwise set $t6
	sll  $t0, $t5, 2 	#Multiply $t5, colLoop counter, by 4. Load to $t0
	add  $t0, $t0, $t8 	#Add x + address of the first cell in this row. This is [x + (rowSize*y)].  
	lw 	 $t6, 0($t0) 	#Load the value from the address of the cell to $t6. $t6 is the value of the east cell
	li 	 $t1, 4 		#See if $t6 came from the west (4)
	beq  $t6, $t1, printOpenWall 	#If $t6 came from the west, print a door
	beqz $t5, printSideWall		#If is in the first column, do not set $t7 to an address bc $t7 does not exist
	li   $t7, 4 		#Calculate the address of the west cell.
	sub  $t7, $t0, $t7  #Subtract 4 from the address of $t6, giving the previous cell in memory, or the 'west' cell
	lw 	 $t7, 0($t7) 	#Load the value from the address of the cell to $t7 to $t7. Now it's the value of the north cell
	li 	 $t1, 3 		#See if $t7 came from the east (3)
	beq  $t7, $t1, printOpenWall 	#If $t7 came from the east, print an open wall
printSideWall:
	li  $v0, 4 		#The else statement basically. $t6!=1 && $t7!=2 (The south cell did not come from north, the north cell did not come from south)
	la  $a0, sideWall   # 	So we are printing a sideWall
	syscall
	j  	incrementRow2
printOpenWall:
	li 	$v0, 4
	la  $a0, openWall
	syscall
	j 	incrementRow2
printSideEnd:
	li 	$v0, 4
	la  $a0, sideEnd
	syscall
	li  $t5, 0
	j outColLoop
incrementRow2:	
#REMOVE CODE ONCE FINISHED
#For testing purposes, we are printing the integer from the address
#	lw  $a0, 0($t0) 	#Load the value from the address of the cell on the board
#	li  $v0, 1 			#Read an Integer Syscall fcn
#	syscall
#END REMOVE CODE ONCE FINISHED

	addi $t5, $t5, 1 	#Increment the colLoop counter, $t5. This moves you through the x coordinates in one row
	j loopEastCell

outColLoop: 		#This is outside loopCol. Finished looping from column to column, need to move to next row
	li $v0, 4 			#Call Print String from System I/O
	addi $t9, $t9, 1 	#Increment the rowLoop counter, $t9. This moves you to the next row.
	j loopRow

outRowLoop: 		#Have to print the bottom edge of the board. No more rows or columns to print after finish the bottom edge.
	li  $t5, 0 	#Looping through the last row one more time to print the bottom edge
	j loopCol 	#Jumps to the loopCol one last time before jumping to bottomEdgePrinted
bottomEdgePrinted: 
	jr $ra 		#Done with rowLoop. jump to return address

#The following are the version of rand and seedrand for this program.
########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
# This routine generates a pseudorandom number using the xorsum
# algorithm. It depends on a non-zero value being in the 'seed'
# location, which can be set by a prior call to seedrand. For this
# version, pass in a number N in $a0. The return value will be a
# number between 0 and N-1.
#
########################################################################
# Register Usage in the Function:
# $t0 -- a temporary register used in the calculations
# $v0 -- the register used to hold the return value
# $a0 -- the input value, N
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Fetch the current seed value into $v0
# 2. Perform these calculations:
# $v0 ^= $v0 << 13
# $v0 ^= $v0 >> 17
# $v0 ^= $v0 << 5
# 3. Save the resulting value back into the seed.
# 4. Mask the number, then get the modulus (remainder) dividing by $a0.
#
########################################################################
 .data
seed: .word 31415 # An initial value, in case seedrand wasn't called
 .text
rand:
 lw $v0, seed # Fetch the seed value
 sll $t0, $v0, 13 # Compute $v0 ^= $v0 << 13
 xor $v0, $v0, $t0
 srl $t0, $v0, 17 # Compute $v0 ^= $v0 >> 17
 xor $v0, $v0, $t0
 sll $t0, $v0, 5 # Compute $v0 ^= $v0 << 5
 xor $v0, $v0, $t0
 sw $v0, seed # Save result as next seed
 andi $v0, $v0, 0xFFFF # Mask the number (so we know its positive)
 div $v0, $a0 # divide by N. The reminder will be
 mfhi $v0 # in the special register, HI. Move to $v0.
 jr $ra # Return the number in $v0
########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
# This routine sets the seed for the random number generator. The
# seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
# $a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
 sw $a0, seed
 jr $ra

########################################################################
# Function Name: takeMove
########################################################################
# Functional Description:
# This adds one more cell to the maze. It starts with the cell cx, cy.
# 		It then counts how many of the neighboring cells are currently
#  		empty.
# 	* If there is only one, then it adds that square to the maze,
# 		having that square point to this one, and moving cx, cy to that
# 		square.
# 	* If there are two or three, it randomly picks one, then does the
# 		same as the only one case.
# 	* If there are none, the routine clears the numLeft value, signifying
# 		that we are done with the maze (TBD change this in part 3).
#
########################################################################
# Register Usage in the Function:
# $a0, $v0 -- used for syscall linkage, and calculations
# We save $ra on stack, as well as $s0-$s5
# $t0, $t1,  -- pointers to cy and cx
# $t2, $t8 -- general use
# $s0 -- pointer to the square at cx, cy
# $s1 -- pointer to a neighboring cell
# $s2 -- how many neighbors are empty?
# $s3-$s5 -- possible neighbors to move to
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save $ra and $s registers on the stack
# 2. Set $s0 to point to the current cell
# 3. Count the number of neighbors that have a 0 value. The count
# will be in $s2, and $s3-$s5 will be the possible moves to
# neighbors: 1 = move north, 2 = move south, 3 = move east,
# 4 = move west.
# 3a. If we have one choice, move to that square and have it point back
# to this square.
# 3b. If we have two or three choices, pick one at random.
# 3c. If we have no choices, stop the generator
# 4. Restore the $ra and $s register values
#
########################################################################
takeMove:
.text
	addiu $sp, $sp, -8 	#Allocate 8 bits on the stack
	sw  $ra, 0($sp) 	#Save the return address onto the stack
#	#testing
#	li 		$v0, 4		#Call the Print String I/O Service to print String
#	la 		$a0, pause 	# 	Pause here
#	syscall
#	li 		$v0, 5		#Call the Read Integer I/O Service to read int, forces system to pause 
#	syscall

 	
 	lw  $t0, cy 		#Load the values of cy to $t0
 	lw  $t1, cx 		#Load the value of cx to $t1
 #Find the value in the cell at (cx, cy)
 	lw  $t2, wid      	# 	get the value of wid into $t2 for calculations
	addi $t2, $t2, 1 	# wid is an index, but need the row size here, so add wid+1
	mult $t0, $t2 		#Multiply cy and wid.size (in registers $t0 and $t2)
	mflo $s0			#	Move product to $s0
	add $s0, $s0, $t1 	#Add $s0 + $t1 [(cy *wid.size) + cx], save sum to $s0 
	sll $s0, $s0, 2 	#Shift $ts0 by two to MULTIPLY IT BY 4
	la 	$t2, board 		#Load to $t2 the address of board
	add $s0, $s0, $t2 	#$s0 = $s0 + $t2 ([cy*wid.size + cx] + board), points to a space on the board
	lw  $t2, wid 		# Reload wid into $t2 for comparisons

	li  $s2, 0			#Initialize the counter for the neighboring cells in $s2
 xNeighbors:
 	beqz $t1, noWest 	#If the x coordinate is zero, it means the cell does not have a left neighbor
 	lw $s1, -4($s0) 	#Else: There IS a left neighbor, check its value by offsetting the current cell's address by -4
 	li $t3, 5 			#Use for comparisons to the border for now
 	beq $t3, $s1, westCell #Ignore next branch step if value of $s1 is 5
 	bnez $s1, noWest	#If the value is not equal to zero, it is not an open cell
 westCell:
 	addi $s3, $s0, -4 	#The west cell exists, it is open, we can save the address to $s3 and increment the neighborCellCount
 	addi $s2, $s2, 1 	#Increment the count of neighboring cells
 noWest:	 			#Checking east cell
 	beq  $t1, $t2, yNeighbors 	#If x coordinate is equal to wid, it's in the last column. the cell has no right neighbor; already checked for eastNeighbor
 	lw  $s1, 4($s0) 				#	Else: There IS a right neighbor, check value by offset current cell's address by 4
 	beq $t3, $s1, eastCell #Ignore next branch step if value of $s1 is 5
 	bnez $s1,yNeighbors  	#If the value is not equal to zero, it is not an open cell
 eastCell:
 	beqz $s3, noS3addrEW 		#Check if an address has been saved to $s3 for EW(East West) addresses. If not, save the address here
 	addi $s4, $s0, 4		#Else: There IS a right neighbor, add 4 to the address of he current cell and save it in $s4
 	j 	eastWestChecked
 noS3addrEW:	
 	addi $s3, $s0, 4
 eastWestChecked:
 	addi $s2, $s2, 1 	#east and west cells checked for values. At least one was available and the $s2 address needs to be incremented.
 yNeighbors:
 	lw 		$t2, hgt 	#Load value of hgt to $t2, which previously held wid.size
 	addi 	$t2, $t2, 1 #Add 1 to hgt, to get hgt.size
 	sll 	$t2, $t2, 2 #Multiply hgt.size by 4 for proper addressing
 	beqz 	$t0, noNorth 	#If the cy is zero, there is no north neighbor
 	sub 	$s1, $s0, $t2 	#Find the north cell address. Subtract the size of one row from the current cell's address to find the address of the north cell
 	lw 		$s1, 0($s1) 	#Load the value from the north cell 
 
 	beq $t3, $s1, northCell #Ignore next branch step if value of $s1 is 5
 	bnez 	$s1, noNorth 	#If the value is not zero, it is not an open cell
 northCell:		
 	beqz 	$s3, noS3addrN  #Check if an address has been saved to $s3 before the north cell. If not, save north address to $s3
 	beqz 	$s4, noS4addrN 	#Check if an address has been saved to $s4. If not save north address to $s4 (Already checked $s3)
 	sub 	$s5, $s0, $t2 	#Find the north cell address. Subtract the size of one row from the current cell's address. Save it to $s5
 	j northChecked
 noS4addrN:
 	sub 	$s4, $s0, $t2 	#Find the north cell address. Subtract the size of one row from the current cell's address. Save it to $s4
 	j northChecked
 noS3addrN:
 	sub 	$s3, $s0, $t2 	#Find the north cell address. Subtract the size of one row from the current cell's address. Save it to $s3
 northChecked:
 	addi 	$s2, $s2, 1 	#Increment the counter of available neighbors after saving the north cell address somewhere.
 noNorth: 	#Check south cell
 	lw 	$s1, hgt 	#Set $s1 to the value of hgt for a comparison
 	beq $t0, $s1, chooseNext  #If cy == hgt, skip checking the south cell
 	add $s1, $s0, $t2 	#Find the south cell address. Add the size of one row to the current cell's address to find the address of the south cell.
 	lw  $s1, 0($s1) 	#Load the value from the south cell
 	
 	beq $t3, $s1, southCell #Ignore next branch step if value of $s1 is 5
 	bnez $s1, chooseNext #If the value is not zero, it is not an open cell
southCell: 	
 	beqz 	$s3, noS3addrS  #Check if an address has been saved to $s3 before the south cell. If not, save south address to $s3
 	beqz 	$s4, noS4addrS 	#Check if an address has been saved to $s4. If not save south address to $s4 (Already checked $s3)
 	add 	$s5, $s0, $t2 	#Find the south cell address. Add the size of one row from the current cell's address. Save it to $s5
 	j southChecked 
 noS4addrS:
  	add 	$s4, $s0, $t2 	#Find the south cell address. Add the size of one row from the current cell's address. Save it to $s4
  	j southChecked
  noS3addrS:
  	add 	$s3, $s0, $t2 	#Find the south cell address. Add the size of one row from the current cell's address. Save it to $s3
  southChecked:
  	addi 	$s2, $s2, 1 	#Increment the counter of available neighbors after saving the south cell address.
  chooseNext:
  	beqz 	$s2, stopGen 	#Stop the generator if there are no moves
  	li 	$t2, 1 				#Load 1 for comparisons
  	beq $s2, $t2, choose1 	#Only one choice if $s2 ==1
  	#bgt $s2, $t2, chooseRand #Random choice if there are 2 or 3 options
  	move $a0, $s2 	#Copy the value from $s2 to $a0
  	
#Need to save stuff onto the stack T.T
  	jal rand 		#to get a random value
 	lw $t0, cy 	#Reload the cy values in case rand messed with it
 	lw $t1, cx  #Reload the cx values

 	beqz $v0, choose1 #The result was a 0, go to choose1 w/ $s3
 	li $a0, 1
  	beq $a0, $v0, randomize
  #Else it was equal to 2, choose $s5
  	move $s3, $s5 	
  	j choose1
randomize:
	move $s3, $s4
	

choose1:
	blt $s3, $s0, northOrWest #If $s0<$s3, the address is either for the north cell or west cell
	addi $t2, $s0, 5 #Add 5 to the address of the current cell, saving the value to $t2 for comparisons
	bgt $s3, $t2 isSouth #If $s3>$t2 (which is current cell address+5), it's the south cell. If not, it's the east cell
isEast: 
	li $t2, 4 #Want a move west (4) in the east cell for it to point back to the original cell
	sw $t2, 0($s3) 	#Store the 4 at the address in $s3
	addi $t1, $t1, 1 #Move cx one to the right to point to the new current cell
	sw $t1, cx 		#Store the result to cx
	j finishMove
northOrWest:
	addi $t2, $s0, -5 	#Add -5 to the address of the current cell, saving the value to $t2 for comparisons
	blt $s3, $t2, isNorth #If $s3<$t2 (which is the current cell address -5), it's the north cell
isWest:
	li $t2, 3 #Want a move east (3) in the west cell for it to point back to the original cell
	sw $t2, 0($s3) 	#Store the 3 at the address in $s3
	addi $t1, $t1, -1 #Move cx one to the left to point to the new current cell
	sw $t1, cx 		#Store the result to cx
	j finishMove
isNorth:
	li $t2, 2 #Want a move south (2) in the north cell for it to point back to the original cell
	sw $t2, 0($s3) 	#Store the 2 at the address in $s3
	addi $t0, $t0, -1 #Move cy one above to point to the new current cell
	sw $t0, cy 		#Store the result to cy
	j finishMove
isSouth:
	li $t2, 1 #Want a move north (1) in the south cell for it to point back to the original cell
	sw $t2, 0($s3) 	#Store the 1 at the address in $s3
	addi $t0, $t0, 1 #Move cy one down to point to the new current cell
	sw $t0, cy 		#Store the result to cy
	j finishMove
stopGen:
 	li $t6, 1 		#Reset the generator to one so it gets decremented to zero once it returns and stops the loop
 finishMove:
	li $s0, 0 		#Reset the $s registers for any other routine that calls them after
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0

	lw $ra, 0($sp)  	#Re-load the return address
	addiu $sp, $sp, 8 	#ReAdd the 8 bits onto the stack
	jr $ra