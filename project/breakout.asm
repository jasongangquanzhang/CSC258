################ CSC258H1S Winter 2023 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Jason Zhang, 1007627294
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    512
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################
MY_COLOURS:
	.word	0xff0000    # red
	.word	0x00ff00    # green
	.word	0x0000ff    # blue
	.word   0xFF00FF    # purple
	.word   0x808080    # grey: paddle + wall
	.word   0x00F5FF    # ball colour
	.word   0x000000
	.word   0xFFFF00    # second colour
##############################################################################
# Code
##############################################################################
	.text
	addi $k0, $zero, 3 # live count

DRAW:
	
	lw $t0, ADDR_DSPL 	# $t0 stores the base address for display
	li $t1, 0x808080 	# $t1 stores the gery colour code
	
	# initialize the loop variables $t5, $t6
	add $t5, $zero, $zero	# set $t5 to zero
	addi $t6, $zero, 64	# set $t6 to 64

	
	
paint_wall_top:
	beq $t5, $t6, side_walls_init	# Branch to side_walls_init if $t5 == 16

	sw $t1, 0($t0) 		# paint the first (top-left) unit gery.
	addi $t0, $t0, 256   	# move to the next pixel over in the bitmap
	sw $t1, 0($t0) 		# paint the first unit on the second row gery.
	
	#sw $t1, 7680($t0)# cheat
	

	addi $t0, $t0, -252	# move up to the previous row, beside the green pixel	

	addi $t5, $t5, 1	# increment $t5 by 1
	j paint_wall_top	# jump to the beginning of the loop
	
side_walls_init:
	addi $t0, $t0, 256   	# this is the address of the first row of left side wall
	
	addi $a0, $t0, 516      # the address of the first brick

	
paint_wall_side:
	beq $t0, 268476416, END_DRAW_SIDE_WALL_LOOP   # paint unitl reach the end of the display
	
	sw $t1, 0($t0)		# paint left wall
	addi $t0, $t0, 252	# find the address of the right wall in the same row
	sw $t1, 0($t0) 		# paint right wall
	
	addi $t0, $t0, 4	# the address of the left wall in the next row
	j paint_wall_side	# jump to the beginning of the loop

END_DRAW_SIDE_WALL_LOOP:
	nop
	


	add $t1, $zero, $a0 	# $t1 stores the base address for display brick
	la $t0, MY_COLOURS

	addi $a1, $zero, 4 # $a1 stores the number of rows
	addi $t5, $zero, 0 
	
DRAW_BRICKS:	
	beq $t5, $a1, DRAW_UNBREAKABLE_BRICKS # end draw if $t5 = 4
	
	lw $t6, 0($t0)   # $t6 store the color of the row
	
	addi $t7, $t1, 248 #$t7 stores the end address of brick row
	
	draw_row:
	
	beq $t1, $t7, end_row_draw # end draw the row if $t1 = $t7
	
	sw $t6, 0($t1)	#draw
	
	addi $t1, $t1, 4  
	

	j draw_row
	
        end_row_draw:
        addi $t0, $t0, 4  # get the next color for next row
        addi $t5, $t5,1   # add 1 to $t5
        addi $t1,$t1,8    # get the address of first of next row
        j DRAW_BRICKS
        
DRAW_UNBREAKABLE_BRICKS:

	la $t8, MY_COLOURS
	
	lw $t1, 16($t8)	# $t1 stores the gery colour code
	
	addi $t2, $zero, 6      # $t2 is the length of the unbreakable brick
	addi $t3, $zero, 0
	lw $t0,ADDR_DSPL 
	addi $t0,$t0,6456     	# $t0 is the initial location of unbreakable brick
	
	add $t4, $t4, $zero  #initialize counter of number of unbreakable brick
	
UNBREAK_DRAW:

	beq $t4, 2, END_BRICK_DRAW
	
draw_unbreakable:

	beq $t3, $t2, end_draw_unbreakable
	
	sw $t1, 0($t0)	#draw
	
	addi $t0,$t0,4
	addi $t3, $t3,1	
	j draw_unbreakable
	
end_draw_unbreakable:
	addi $t4,$t4,1
	addi $t0, $t0, -424
	addi $t3, $zero, 0
	j UNBREAK_DRAW
	
END_BRICK_DRAW:
nop

DRAW_PADDLE:
	la $t8, MY_COLOURS
	
	lw $t1, 16($t8)	# $t1 stores the gery colour code
	
	addi $t2, $zero, 8      # $t2 is the length of paddle
	addi $t3, $zero, 0
	
	lw $t0,ADDR_DSPL 
	addi $t0,$t0,7788     	# $to is the initial location of paddle
	add $t5, $zero, $t0    
	
	draw_paddle:
	
	beq $t3, $t2, END_DRAW_PADDLE
	
	sw $t1, 0($t0)	#draw
	sw $t1, -2496($t0)	#draw
	
	addi $t0,$t0,4
	addi $t3, $t3,1
	
	j draw_paddle
	
END_DRAW_PADDLE:
	nop


	
	
DRAW_BALL: #we want the ball appear at the centre of the paddle
        add $t0, $t0, $t5
        div $t0, $t0, 2
        mflo $t1	# get the centre of the paddle
        addi $t1, $t1, -256	#location is upper level
        lw $t0, 20($t8)	# $t0 stores the ball colour code
        sw $t0, 0($t1)	#draw

END_DRAW_BALL:
	nop
	

	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    
    lw $t0,ADDR_DSPL
    
    addi $s1,$t0,7788  # $s1 is the leftmost location of paddle
    addi $s2, $s1, 28   # s2 is the right most location of paddle 
    addi $s0, $s1, -240 # s0 is the location of the ball
    addi $s6, $s1, -2496 # s6 is the leftmost location of the second paddle
    addi $s7, $s6, 28	# s7 is the right most location of the second paddle
    addi $s3, $zero, 2  #s3 stores the direction of the ball movement init be 2, 0(up_left), 1(up_right), 2(down_left), 3(down_right)
    
    
    addi $s5, $t0, 8448 # this this the last line of the display

REBORN:
    
    lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboardx
    beq $t8, 1, check_start      # If first word 1, key 
    j REBORN
    
check_start:
    lw $a0, 4($t1)                  # Load second word from keyboard
    jal CHECK_BALL_MOVE 	# CHECK if ball is moved before the game start
    jal CHECK_BALL_DIRECTION_CHANGE	#check if ball direction is changed
    beq $a0, 0x31, game_loop 
    j REBORN

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen

	
    lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboardx
    
    jal CHECK_LOSE
    
    jal CHECK_KEYBOARD
    
    jal CHECK_COLLUSION
    
    jal BALL_MOVE

    li $v0, 32	# 4. Sleep
    li $a0, 100
    syscall
    
    j game_loop
    
CHECK_KEYBOARD:
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	jr $ra

keyboard_input:                     # A key is pressed
    lw $a0, 4($t1)                  # Load second word from keyboard
    la $t9, MY_COLOURS
    lw $t2, 16($t9)  # $t2 stores the gery colour code
    lw $t3, 24($t9)  # $t3 stores the black colour code
    
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x70, respond_to_P     # Check if the key p was pressed
    beq $a0, 0x2c, respond_to_comma     # Check if the key , was pressed
    beq $a0, 0x2e, respond_to_dot     # Check if the key . was pressed

    jr $ra
    
respond_to_A:

 	addi $t7, $t0, 7684 # left most location of left most
 	
 	beq $s1, $t7, end_respond_to_A
 
 	sw $t3 , 0($s2)  # make rightmost unit black
 	addi $s1, $s1, -4 # update the left most and right most 
 
 	addi $s2, $s2, -4
 	sw $t2 , 0($s1)  # make left one unit grey
 	
end_respond_to_A:
 	jr $ra

 
respond_to_D: 	
 	addi $t7, $t0, 7928 # left most location of left most
 	beq $s2, $t7, end_respond_to_D
 	sw $t3 , 0($s1)  # make leftmost unit black
 	addi $s1, $s1, 4 # update the left most and right most 
 
 	addi $s2, $s2, 4
 	sw $t2 , 0($s2)  # make right one unit grey
 	
end_respond_to_D:
 	jr $ra
 	
 	
respond_to_comma:
	addi $t7, $t0, 5124 # left most location of left most
 	
 	beq $s6, $t7, end_respond_to_comma
 
 	sw $t3 , 0($s7)  # make rightmost unit black
 	addi $s6, $s6, -4 # update the left most and right most 
 
 	addi $s7, $s7, -4
 	sw $t2 , 0($s6)  # make left one unit grey
	

end_respond_to_comma:
	jr $ra

respond_to_dot:
	addi $t7, $t0, 5368 # left most location of left most
 	beq $s7, $t7, end_respond_to_dot
 	sw $t3 , 0($s6)  # make leftmost unit black
 	addi $s6, $s6, 4 # update the left most and right most 
 
 	addi $s7, $s7, 4
 	sw $t2 , 0($s7)  # make right one unit grey

end_respond_to_dot:
	jr $ra

 
respond_to_P:
	
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	lw $a0, 4($t1)                  # Load second word from keyboard
	beq $a0, 0x70, end_respond_to_P

	j respond_to_P
	
end_respond_to_P:
	
	jr $ra

respond_to_Q:
	j END_GAME


 			
 	
 	
CHECK_COLLUSION: # s0 is the ball location, s3 stores the direction of the ball movement  init be 2, 0(up_left), 1(up_right), 2(down_left)
			#3(down_right)
	la $t9, MY_COLOURS
 
 	lw $t8, 16($t9)  # $t8 stores the gery colour code
 	lw $t7, 24($t9)  # $t7 stores the black colour code
 	lw $a1, 28($t9)	 # a1 stores the second color code
 	
 		
	
	beq $s3, 0, check_up_left
	beq $s3, 1, check_up_right
	beq $s3, 2, check_down_left
	beq $s3, 3, check_down_right
	
check_up_left:
	addi $t2, $s0, -256 #up location of the ball
	lw $t4, 0($t2)	#up color
	
	addi $t3, $s0, -4  #left location of the ball
	lw $t5, 0($t3)# left color
	
	add $t6, $t4, $t5  
	
	beqz $t6, check_direction_up_left # they are all black, so if proceed, at least one of them are not colored
		
	beqz $t5, CHECK_AND_ELIMINATE_UP # up collusion
	
	beqz $t4, CHECK_AND_ELIMINATE_LEFT # left collusion
	
	
	# up_left collusion
	
	beq $t5, $t8, check_up_color # if left color is grey
	
	bne $t5, $a1, up_left_second_left #if left color is not grey, check if it is second color, if not, second it
	sw $t7, 0($t3) #if left color is second, change to black
	j check_up_color
	
up_left_second_left:
	sw $a1, 0($t3) #if left color is not the second color, change to second
	
check_up_color:	
	beq $t4, $t8, change_to_down_right # if up color is grey
	bne $t4, $a1, up_left_second_up #if up color is not grey, check if it is second color, if not, second it
	
	sw $t7, 0($t2) #if up color is second, change to black
	j change_to_down_right
up_left_second_up:
	sw $a1, 0($t2) #if up color is not the second color, change to second
		
	j change_to_down_right
	
check_direction_up_left: # t2 up-left location, t4 up-left color
	addi $t2, $s0, -260  # up left location of the ball
	lw $t4, 0($t2)	# up left color
	beqz $t4, end_check_up_left  # if it is black, end_check
	beq $t4, $t8, change_to_down_right # if up_left color is not black, check if up-left color is grey
	
	bne $t4, $a1, up_left_second_up_left # if up-left color is not grey, check if it is second
	
	sw $t7, 0($t2) #if up-left color is second, change to black
	j change_to_down_right
	
up_left_second_up_left:
	sw $a1, 0($t2) #if up-left color is not second, change to second
	j change_to_down_right

end_check_up_left:
	
	jr $ra

		
						

check_up_right: 
	addi $t2, $s0, -256 	#up location of the ball
	lw $t4, 0($t2)
	addi $t3, $s0, 4	# right location of the ball
	lw $t5, 0($t3)
	
	add $t6, $t4, $t5
	
	beqz $t6, check_direction_up_right #they are all black, check up-right
	
	beqz $t5, CHECK_AND_ELIMINATE_UP # right black, up not black (up collusion)
	
	beqz $t4, CHECK_AND_ELIMINATE_RIGHT # up black, right not black (right collusion)
	
	# up right collusion
	beq $t4, $t8, check_right_color # if up color is grey
	bne $t4, $a1, up_right_second_up # if up color is not grey, check if it is second color, if not, second it
	sw $t7, 0($t2) #if up color is second, change to black
	j check_right_color
	
up_right_second_up:
	sw $a1, 0($t2) #second up color
	
check_right_color:	
	beq $t5, $t8, change_to_down_left # if right color is grey
	bne $t5, $a1, up_right_second_right # if right color is not grey, check if it is second color, if not, second it
	
	sw $t7, 0($t3) #if right color is not grey, change to black
	j change_to_down_left # up right collusion
	
up_right_second_right:
	sw $a1, 0($t3) #second right color
	j change_to_down_left
	
	
check_direction_up_right: # t2 up-right location, t4 up-right color
	addi $t2, $s0, -252  # up right location of the ball
	lw $t4, 0($t2)	# up right color
	beqz $t4, end_check_up_right # if up-right is black, end check
	beq $t4, $t8, change_to_down_left # if up-right color is grey
	
	bne $t4, $a1, up_right_second_up_right # if up-right color is not grey, check if up-right color is yellow
	
	sw $t7, 0($t2) #if up-right color is not grey, change to black

	j change_to_down_left # up right collusion
	
up_right_second_up_right:
	sw $a1, 0($t2) # if up-right is not second, change to second
	
	j change_to_down_left # up right collusion
	
end_check_up_right:
	jr $ra
	




check_down_left:
	addi $t2, $s0, 256	#down location of the ball
	lw $t4, 0($t2)
	
	addi $t3, $s0, -4  #left location of the ball
	lw $t5, 0($t3)
	
	add $t6, $t4, $t5
	
	beqz $t6, check_direction_down_left #they are all black
	
	beqz $t5, CHECK_AND_ELIMINATE_DOWN # down collusion
	
	beqz $t4, CHECK_AND_ELIMINATE_LEFT # left collusion
	
	# down left collusion
	beq $t4, $t8, check_left_color # if down color is grey
	bne $t4, $t8, down_left_second_down #if down color is not grey, check whether it is second, if not, second it
	sw $t7, 0($t2) #if down color is second, change to black
	j check_left_color
	
down_left_second_down:
	sw $a1, 0($t2) #if down color is second, change to black
	
check_left_color:	
	beq $t5, $t8, change_to_up_right # if left color is grey
	bne $t5, $a1, down_left_second_left # if left color is not grey, check if it is second, if not, second it
	sw $t7, 0($t3) #if left color is second, change to black
	j change_to_up_right

down_left_second_left:
	sw $a1, 0($t3) #if down color is not second, second it
	j change_to_up_right
	
check_direction_down_left: # t2 is down left location, t4 is down left color
	addi $t2, $s0, 252  # down left location of the ball
	lw $t4, 0($t2)	# down left color
	beqz $t4, end_check_down_left
	beq $t4, $t8, change_to_up_right # if down-left color is grey
	bne $t4, $a1, down_left_second_down_left # if not grey, check whether it is second, if not second it

	
	sw $t7, 0($t2) #if down-left color is second, change to black

	j change_to_up_right # down-left collusion

down_left_second_down_left:
	sw $a1, 0($t2) #if down-left color is second, change to black
	j change_to_up_right # down-left collusion
	
end_check_down_left:
	jr $ra



check_down_right:
	addi $t2, $s0, 256	#down location of the ball
	lw $t4, 0($t2)
	
	addi $t3, $s0, 4	# right location of the ball
	lw $t5, 0($t3)
	
	add $t6, $t4, $t5
	
	beqz $t6, check_direction_down_right #they are all black
	
	beqz $t5, CHECK_AND_ELIMINATE_DOWN # down collusion
	
	beqz $t4, CHECK_AND_ELIMINATE_RIGHT # right collusion
	
	#down right collusion
	beq $t5, $t8, check_left_color # if right color is grey
	bne $t5, $a1, down_right_second_right# if right color is not grey, check if it is second
	sw $t7, 0($t3) #if right color is second, change to black
	j check_down_color
	
down_right_second_right:
	sw $a1, 0($t3) #if right color is not second, second it


check_down_color:	
	beq $t4, $t8, change_to_up_left # if down color is grey
	bne $t4, $a1, down_right_second_down # if down is not grey, check if it is second, if not, second it
	
	sw $t7, 0($t2) #if down color is second, change to black
	j change_to_up_left

down_right_second_down:
	sw $a1, 0($t2) #if down color is not second, second it
	j change_to_up_left
	
check_direction_down_right: # t2 down-right location, t4 down-right color
	addi $t2, $s0, 260  # down right location of the ball
	lw $t4, 0($t2)	# down right color
	beqz $t4, end_check_down_right
	beq $t4, $t8, change_to_up_left # if down-right color is grey, change to opposite
	bne $t4, $a1, down_right_second_down_right # if not grey, check whether it is second, if not second it
	
	sw $t7, 0($t2) #if down-right color is second, change to black
	j change_to_up_left # up right collusion
down_right_second_down_right:
	sw $a1, 0($t2) #if down-right color is second, change to black
	j change_to_up_left # up right collusion
			
end_check_down_right:	
	jr $ra


	
# s0 is the ball location, s3 be ball direction	  0(up left), 1(up right), 2(down left), 3(down right)

CHECK_AND_ELIMINATE_LEFT: # t4 be up or down color  t5 be left or right color   t2 be up/down location  t3 be left/right location
	
	beq $t5, $t8, check_direction_left_collusion # if left color is grey
	bne $t5,$a1, change_left_to_second	# if the color is not gery, check if it is the second color, if not, change to second
	sw $t7, 0($t3) #if left color is second, change to black
	j check_direction_left_collusion

change_left_to_second:
	sw $a1, 0($t3) #if left color is not the second color, change to second
		
check_direction_left_collusion:
	beq $s3, 0, change_to_up_right
	beq $s3, 2, change_to_down_right



CHECK_AND_ELIMINATE_RIGHT:

 	beq $t5, $t8, check_direction_right_collusion# if right color is grey
 	bne $t5,$a1, change_right_to_second	# if the color is not gery, check if it is the second color, if not, change to second
 	sw $t7, 0($t3) #if right color second, change to black
 	j check_direction_right_collusion
 	
change_right_to_second:
	sw $a1,0($t3)
	
check_direction_right_collusion:
	beq $s3, 1, change_to_up_left
	beq $s3, 3, change_to_down_left
	



CHECK_AND_ELIMINATE_UP:

 	beq $t4, $t8, check_direction_up_collusion #check if the color of the brick is grey
 	bne $t4, $a1, change_up_to_second	# if the color is not gery, check if it is the second color, if not, change to second
 	sw $t7, 0($t2) #if up color is the second color, change to black
 	j check_direction_up_collusion
 
change_up_to_second:	
	sw $a1, 0($t2) #if up color is not the second color, change to second

 	
check_direction_up_collusion:
	beq $s3, 0, change_to_down_left
	beq $s3, 1, change_to_down_right


	

CHECK_AND_ELIMINATE_DOWN:
 	beq $t4, $t8, check_direction_down_collusion #check if the color of the brick is grey
 	bne $t4, $a1, change_down_to_second	# if the color is not gery, check if it is the second color, if not, change to second
 	sw $t7, 0($t2) 	#if down color is the second, change to black
 	j check_direction_down_collusion


change_down_to_second:
	sw $a1, 0($t2) #if down color is not the second color, change to second
	
check_direction_down_collusion:
	beq $s3, 2, change_to_up_left
	beq $s3, 3, change_to_up_right
			
								



change_to_up_left: # collusion to down or right or both

	addi $s3, $zero,0
	jr $ra

change_to_up_right:

	addi $s3, $zero,1
	jr $ra

change_to_down_left:

	addi $s3, $zero,2
	jr $ra

change_to_down_right:

	addi $s3, $zero,3
	jr $ra	
	

BALL_MOVE:

	la $t8, MY_COLOURS
	lw $t7, 20($t8)	# $t7 stores the ball colour code
	lw $t6, 24($t8)	# $t6 stores the black colour code
	
	
	
next_ball_location: # get next location  # s0 is the ball location, s3 be ball direction
	beq $s3, 0, move_up_left
	beq $s3, 1, move_up_right
	beq $s3, 2, move_down_left
	beq $s3, 3, move_down_right

move_up_left:
	add $s4, $zero, $s0 # store the current location
	addi $s0, $s0, -260 	# the next location of the ball
	sw $t6, 0($s4) # paint original location black
	sw $t7, 0($s0)	# paint $s0 ball
	
	jr $ra
	
move_up_right:
	add $s4, $zero, $s0 # store the current location
	addi $s0, $s0, -252 	# the next location of the ball
	sw $t6, 0($s4) # paint original location black
	sw $t7, 0($s0)	# paint $s0 ball
	
	jr $ra
	

move_down_left:
	add $s4, $zero, $s0 # store the current location
	addi $s0, $s0, 252	# the next location of the ball
	sw $t6, 0($s4) # paint original location black
	sw $t7, 0($s0)	# paint $s0 ball
	
	jr $ra
	

move_down_right:
	add $s4, $zero, $s0 # store the current location
	addi $s0, $s0, 260	# the next location of the ball
	sw $t6, 0($s4) # paint original location black
	sw $t7, 0($s0)	# paint $s0 ball
	
	jr $ra
	


CHECK_BALL_MOVE:# check if the ball is moved before the game  A(move left) S(move_down) D(move_right) W(move_up)
	la $t9, MY_COLOURS
    	lw $t2, 16($t9)  # $t2 stores the gery colour code
    	lw $t3, 20($t9)	# $t3 stores the ball colour code
    	lw $t4, 24($t9) # t4 is black
    	
    	
	beq $a0, 0x41, move_left # A is pressed
	beq $a0, 0x44, move_right # D is pressed
	beq $a0, 0x57, move_up # W is pressed
	beq $a0, 0x53, move_down # S is pressed
	jr $ra
	
# s0 is ball location s5 is the last line of display
	
move_up:
	lw $t7, -256($s0)#t7 stores the next location color
	bne $t7, $t4, END_CHECK_BALL_MOVE # if not black, no use movement
	sw $t4, 0($s0) # paint original location black
	sw $t3, -256($s0)	# paint $s0 ball
	addi $s0, $s0, -256
	j END_CHECK_BALL_MOVE
	
	

move_down:
	lw $t7, 256($s0)#t7 stores the next location color
	bne $t7, $t4, END_CHECK_BALL_MOVE # if not black, no use movement
	bgt $s0, $s5, END_CHECK_BALL_MOVE #if reach the limit, no use movement
	sw $t4, 0($s0) # paint original location black
	sw $t3, 256($s0)	# paint $s0 ball
	addi $s0, $s0, 256
	j END_CHECK_BALL_MOVE
	
	
move_left:
	lw $t7, -4($s0)#t7 stores the next location color
	bne $t7, $t4, END_CHECK_BALL_MOVE # if not black, no use movement
	sw $t4, 0($s0) # paint original location black
	sw $t3, -4($s0)	# paint $s0 ball
	addi $s0, $s0, -4
	j END_CHECK_BALL_MOVE

move_right:
	lw $t7, 4($s0)#t7 stores the next location color
	bne $t7, $t4, END_CHECK_BALL_MOVE # if not black, no use movement
	sw $t4, 0($s0) # paint original location black
	sw $t3, 4($s0)	# paint $s0 ball
	addi $s0, $s0, 4
	j END_CHECK_BALL_MOVE



END_CHECK_BALL_MOVE:
	jr $ra



CHECK_BALL_DIRECTION_CHANGE:#use ! @ # $ to change with !(up-left) @(up-right) #(down-left) $(down-right)
	beq $a0, 0x21, change_to_up_left # ! is pressed
	beq $a0, 0x40, change_to_up_right # @ is pressed
	beq $a0, 0x23, change_to_down_left# # is pressed
	beq $a0, 0x24, change_to_down_right# $ is pressed
	jr $ra
	



CHECK_LOSE:
	
	bgt $s0, $s5, LOSE
	jr $ra
	
LOSE:
	sw $zero, 0($s0) #erase the ball
	addi $k0,$k0,-1 #minus one live
	blez $k0,END_GAME # check if has lives
	
	add $t8, $s1, $s2 # has live
        div $t8, $t8, 2
        mflo $s0	# get the centre of the paddle
        addi $s0, $s0, -254	#location is upper level
        
        li $t9, 0x00f5ff
        sw $t9, 0($s0)	#draw
	
	
	j REBORN
	
	
END_GAME:

	beq $t0, $s5, quit 	# clear screen
	li $t1, 0x000000 	# $t1 stores the black colour code
	sw $t1,0($t0)
	addi $t0,$t0,4
	j END_GAME

quit:
	li $v0, 10                      # Quit gracefully
 	syscall
	

					
    #5. Go back to 1
    b game_loop
