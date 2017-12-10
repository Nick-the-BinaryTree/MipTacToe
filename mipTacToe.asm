#=============================================================
# Mip-Tac-Toe by Nicholas Hartunian (nih15101 - 2341175)
# Initialization code
.data # data segment
nl: .asciiz "\n" # New line
x: .asciiz " X "
o: .asciiz " O "
space: .asciiz " _ "
vicX: .asciiz "\nX has won\n"
vicO: .asciiz "\nO has won\n"
dl: .asciiz "\nGame has ended in a deadlock\n"
welcome: .asciiz "\nWelcome to Mip-Tac-Toe!\n"
turnX: .asciiz "\nPlayer X, please insert a row #, and hit enter. Then a column #, and hit enter.\n"
turnO: .asciiz "\nPlayer O, please insert a row #, and hit enter. Then a column #, and hit enter.\n"

.text
.globl main

main:
	jal initialize
	jal play_a_game
	
	addi $a0, $0, 2
	addi $a1, $0, 2
	jal play_Y
	
	addi $a0, $0, 1
	addi $a1, $0, 2
	jal play_Y
	
	addi $a0, $0, 1
	addi $a1, $0, 2
	jal play_X
	
	addi $a0, $0, 0
	addi $a1, $0, 2
	jal play_Y
	
	j exit

initialize: # make space for 3 by 3 matrix on stack
	add $v0, $sp, $0
	addi $sp, $sp, -36
	add $s6, $v0, $0 # board pointer
	add $s7, $0, $0 # turn count
	
	la $a0, welcome
	li $v0, 4
	syscall
	
	jr $ra

coordToAddress: # row = $a0, col = $a1
	mul $t0, $a0, 12 # x * 12 for byte addressing
	sll $t1, $a1, 2 # y * 4 for byte addressing
	add $t0, $t0, $t1 # offset in matrix
	add $v0, $s6, $t0 # address in matrix
	jr $ra

#=============================================================
# Place pieces functions	
play_X: # row = $a0, col = $a1
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal coordToAddress
	lw $t0, 0($v0) # check if cell already occupied
	bne $t0, 0, endPlay # if so, end turn
	addi $s7, $s7, 1 # increment turn count
	addi $t1, $0, 1
	sw $t1, 0($v0) # 1 represents x
	jal win
	j endPlay
	
play_Y:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal coordToAddress
	lw $t0, 0($v0)
	bne $t0, 0, endPlay
	addi $s7, $s7, 1
	addi $t1, $0, 2
	sw $t1, 0($v0) # 2 represents y
	jal win
	j endPlay

endPlay:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

#=============================================================
# Win Conditions

checkTeamX: # return 1 for team x
	addi $t0, $0, 1
	bne $a0, $t0, checkTeamO
	add $v0, $0, $a0
	jr $ra
	
checkTeamO: # return 2 for team o
	addi $t0, $0, 2
	bne $a0, $t0, noTeam
	add $v0, $0, $a0
	jr $ra
	
noTeam: # return 0 for empty space
	add $v0, $0, $a0
	jr $ra
	
isRow0:
	beq $s0, $0, rowIs0 # check if row is zero
	jr $ra
	
rowIs0:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $a0, $s0, 1 # check below row
	add $a1, $s1, $0
	jal coordToAddress
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, 12($v0)  # check below below row
	lw $t1, 0($v0)
	bne $s2, $t0, return # same team occupies?
	bne $s2, $t1, return
	j victoryX

isRow1:
	beq $s0, 1, rowIs1
	jr $ra

rowIs1:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $a0, $s0, 1 # check below row
	add $a1, $s1, $0
	jal coordToAddress
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, -24($v0)  # check above row
	lw $t1, 0($v0)
	bne $s2, $t0, return # same team occupies?
	bne $s2, $t1, return
	j victoryX
	
isRow2:
	beq $s0, 2, rowIs2
	jr $ra

rowIs2:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $a0, $s0, -1 # check above row
	add $a1, $s1, $0
	jal coordToAddress
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, -12($v0)  # check above above row
	lw $t1, 0($v0)
	bne $s2, $t0, return # same team occupies?
	bne $s2, $t1, return
	j victoryX
	
isCol0:
	beq $s1, 0, colIs0
	jr $ra

colIs0:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $a0, $s0, $0
	addi $a1, $s1, 1 # check right col
	jal coordToAddress
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, 4($v0)  # check right right col
	lw $t1, 0($v0)
	bne $s2, $t0, return # same team occupies?
	bne $s2, $t1, return
	j victoryX

isCol1:
	beq $s1, 1, colIs1
	jr $ra

colIs1:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $a0, $s0, $0
	addi $a1, $s1, 1 # check right col
	jal coordToAddress
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, -8($v0)  # check left col (from original)
	lw $t1, 0($v0)
	bne $s2, $t0, return # same team occupies?
	bne $s2, $t1, return
	j victoryX
	
isCol2:
	beq $s1, 2, colIs2
	jr $ra

colIs2:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $a0, $s0, $0
	addi $a1, $s1, -1 # check left col
	jal coordToAddress
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, -4($v0)  # check left left col
	lw $t1, 0($v0)
	bne $s2, $t0, return # same team occupies?
	bne $s2, $t1, return
	j victoryX
	
isRowCol:
	beq $s0, $s1, rowIsCol
	jr $ra

rowIsCol:
	lw $t0, 0($s6) # check 0, 0
	lw $t1, 16($s6) # check center
	lw $t2, 32($s6) # check 2, 2
	bne $s2, $t0, return
	bne $s2, $t1, return
	bne $s2, $t2, return
	j victoryX
	
isRowPlusCol2:
	add $t0, $s0, $s1
	beq $t0, 2, rowPlusColIs2
	jr $ra

rowPlusColIs2:
	lw $t0, 8($s6) # check row 0, col 2
	lw $t1, 16($s6) # check center
	lw $t2, 24($s6) # check row 2, col 0
	bne $s2, $t0, return
	bne $s2, $t1, return
	bne $s2, $t2, return
	j victoryX
	
checkDeadlock:
	beq $s7, 9, deadlock
	j return

victoryX:
	bne $s2, 1, victoryO
	la $a0, vicX
	li $v0, 4
	syscall
	j exit
	
victoryO:
	la $a0, vicO
	li $v0, 4
	syscall
	j exit
	
deadlock:
	la $a0, dl
	li $v0, 4
	syscall
	j exit
	
return:
	jr $ra

win: # row = $a0, col = $a1
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	add $s0, $0, $a0 # save x and y
	add $s1, $0, $a1
	jal coordToAddress # get address of target cell
	lw $a0, 0($v0) # get team num at target cell
	jal checkTeamX
	add $s2, $0, $v0 # save the team we're checking victory for
	jal draw_board
	
	jal isRow0
	jal isRow1
	jal isRow2
	jal isCol0
	jal isCol1
	jal isCol2
	jal isRowCol
	jal isRowPlusCol2
	jal checkDeadlock
			
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
#=============================================================
# Draw Functions
numToStr: # toConvert = $a0
	bne $a0, $0, checkX
	la $v0, space # 0 -> _
	jr $ra
	
checkX:
	addi $t0, $0, 1
	bne $a0, $t0, checkY
	la $v0, x # 1 -> X
	jr $ra
	
checkY:
	la $v0, o # 2 -> O
	jr $ra

draw_board:
	addi $sp, $sp, -4 # preserve return address
	sw $ra, 0($sp)
	
	la $a0, nl # new line
	li $v0, 4
	syscall
	
	lw $a0, 0($s6) # load cell number data
	jal numToStr # convert number to string
	add $a0, $v0, $0 # transfer string to correct syscall register
	li $v0, 4 # syscall setting to print string
	syscall
	
	lw $a0, 4($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	lw $a0, 8($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	la $a0, nl # new line every three cells
	li $v0, 4
	syscall
	
	lw $a0, 12($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	lw $a0, 16($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	lw $a0, 20($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	la $a0, nl # new line every three cells
	li $v0, 4
	syscall
	
	lw $a0, 24($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	lw $a0, 28($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	lw $a0, 32($s6)
	jal numToStr
	add $a0, $v0, $0
	li $v0, 4
	syscall
	
	la $a0, nl # new line
	li $v0, 4
	syscall
	
	lw $ra, 0($sp) # restore return address
	addi $sp, $sp, 4
	jr $ra
	
#=============================================================
# 2 Person Gameplay
play_a_game:
	la $a0, turnX # Player X instructions
	li $v0, 4
	syscall
	
	li $v0, 5 # Get row
	syscall
	add $a0, $0, $v0
	
	li $v0, 5 # Get col
	syscall
	add $a1, $0, $v0
	
	jal play_X # Add move, draw board, check win
	
	la $a0, turnO # Player X instructions
	li $v0, 4
	syscall
	
	li $v0, 5 # Get row
	syscall
	add $a0, $0, $v0
	
	li $v0, 5 # Get col
	syscall
	add $a1, $0, $v0
	
	jal play_Y # Add move, draw board, check win
	
	j play_a_game

#=============================================================

exit:
