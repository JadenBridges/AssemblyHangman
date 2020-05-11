################################################################################################
############################# FINAL PROJECT: WESTERN HANGMAN ###################################
############################# Creator: Jaden Bridges         ###################################
############################# Course: CMPEN 351              ###################################
###### NOTES: Only upper case letters can be used for guesses for the current build ############
################################################################################################



.data
intro:		.asciiz "Welcome to Hangman!\nTo win, you must guess the letters that make up a certain word.\nThe only given information will be the amount of letters in the word.\nLet's Start!"
prompt:		.asciiz "\nEnter a letter: \n"
WinMessage:	.asciiz "\nCongratulations! You guessed the word! You Win!\n"
LoseMessage:	.asciiz "\nToo Bad! You lost and did not guess the word!\n"
RepeatMessage:	.asciiz "Letter already used. Try another!\n"
YouLose:	.asciiz "YOU LOSE"
YouWin:		.asciiz "YOU WIN"
Welcome:	.asciiz "WELCOME"
To:		.asciiz "TO"
Western:	.asciiz "WESTERN"
Hangman:	.asciiz "HANGMAN"
space:		.asciiz " "
newLine:	.asciiz "\n"
file:		.asciiz "WordList.txt"
words:		.asciiz "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
answer:		.asciiz "00000"
guess:		.asciiz "0"
guessword:	.asciiz "*****"
usedletters:	.asciiz "              "

number:		.byte 0
bodypartcount:	.byte 0
usedcount:	.byte 0

StackBeg:
		.word 0 : 60
StackEnd:

ColorTable:
		.word 0x000000		#0 black
		.word 0xff0000		#1 red
		.word 0xffffff		#2 white
		.word 0x40284a		#3 Darkest Parts
		.word 0x73434b		#4 Warm Brown
		.word 0xb34d25		#5 Dark Orange
		.word 0xf07e07		#6 Sunset Glory
		.word 0xf7de55		#7 Sun
CircleSize:
		.byte 4, 6, 8, 10, 11, 12, 13, 13, 14, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 15, 15, 14, 14, 13, 13, 12, 11, 10, 8, 6, 4
.text
########## Main: Contains all of the major base functions for the game ##########
########## needs no input variables and exits once run through         ##########
Main:
	jal ClearDisp			#clears the screen
	
	li $a0, 230			#x coordinate
	li $a1, 100			#y coordinate
	la $a2, Welcome			#string to print on bitmap display
	jal OutText			#prints string on bitmap display
	
	li $a0, 255			#x coordinate
	li $a1, 120			#y coordinate
	la $a2, To			#string to print on bitmap display
	jal OutText			#prints string on bitmap display
	
	li $a0, 230			#x coordinate
	li $a1, 140			#y coordinate
	la $a2, Western			#string to print on bitmap display
	jal OutText			#prints string on bitmap display
	
	li $a0, 230			#x coordinate
	li $a1, 160			#y coordinate
	la $a2, Hangman			#string to print on bitmap display
	jal OutText			#prints string on bitmap display
	
	jal ClearDisp			#clears bitmap display
	
	jal DrawSetting			#draws the setting, stand, letter boxes
	jal ChooseWord			#chooses the word that the user has to guess
	jal StartGame			#contains intro and intro song
	jal Game			#the actual game that the user can play
	
	li $v0, 10		#cleanly exits the program if needed
	syscall
	
########## Game: contains functions of inputting a character, checking the word for that letter, and outputting the correct letters ##########
########## needs no input variables and exits program if the user wins or loses.                                                    ##########
Game:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $t0, 0				#sets $t0 as 0.
	sb $t0, bodypartcount			#stores $t0 into bodypartcount
	sb $t0, usedcount			#stores $t0 into usedcount
	
	li $t5, 0				#sets $t5 as 0.
GCloop:						#loop for Game that takes a guessed letter and checks it with the word
	jal GuessLetter				#jumps and links to GuessLetter
	jal CheckWord				#jumps and links to CheckWord
	
	la $a0, newLine				#prints a new line to make things neat
	li $v0, 4
	syscall
	
	la $a0, guessword			#loads the address of guessword, which contains only the correct letters guessed, into $a0
	li $v0, 4				#prints guessword
	syscall
	
	lb $t0, bodypartcount			#loads bodypartcount into $t0
	blt $t0, 6, GCloop			#branches to GCloop if $t0, bodypartcount, is less than 6
	
	li $a0, 260				#loads 245 in $a0
	li $a1, 200				#loads 210 in $a1
	la $a2, answer				#loads address of answer into $a2
	jal OutText				#jumps and links to OutText, prints the correct answer if a user loses
	
	la $a0, LoseMessage			#loads the address of LoseMessage, which contains a message about the user losing, into $a0
	li $v0, 4				#prints LoseMessage
	syscall
	
	li $a0, 40				#pitch
	li $a1, 300				#duration in milliseconds
	li $a2, 90				#instrument
	li $a3, 127				#volume
	li $v0, 33				#MIDI out synchronous
	syscall
	
	li $a0, 38				#pitch
	syscall
	
	li $a0, 36				#pitch
	syscall
	
	li $a0, 32				#pitch
	li $a1, 800				#duration in milliseconds
	syscall
	
	li $a0, 50				#pitch
	li $a1, 500				#duration in milliseconds
	li $a2, 127				#instrument
	syscall
	
	jal ClearDisp				#clears bitmap display
	
	li $a0, 225				#x coordinate
	li $a1, 128				#y coordinate
	la $a2, YouLose				#address of string to print on bitmap display
	jal OutText				#prints string to bitmap display
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back

########## CheckWord: Checks if letter is in word.                               ##########
########## $t1 = guess, $t7 = wrong letter flag, $t2 = loop counter              ##########
CheckWord:
	addiu $sp, $sp, -4			#makes room in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	lbu $t1, guess				#loads unsigned byte guess into $t1, which is the letter that the user guesses
	li $t7, 0				#loads 0 into $t7, flag for if letter is wrong
	li $t2, 0				#loads 0 into $t2
CWloop:						#loop that checks if letter is in word
	lbu $t1, guess				#loads unsigned byte guess into $t1, which is the letter that the user guesses
	jal CheckLetter				#jumps and links to CheckLetter
	addiu $t2, $t2, 1			#increments $t2 by 1. $t2 is a counter.
	blt $t2, 5, CWloop			#branches to CWloop if $t2 is less than 5
	
	beqz $t7, wrongLetter			#branches to wrongLetter if $t7 is equal to zero.
CWcont:
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back
	
########## wrongLetter: draws a body part depending on amount of wrong letters          ##########
########## $t0 = bodypartcount                                                          ##########
wrongLetter:
	lb $t0, bodypartcount			#loads bodypartcount into $t0
	
	addiu $t0, $t0, 1			#increments $t0, bodypartcount, by 1
	
	sb $t0, bodypartcount			#stores $t0 into bodypartcount
	
	li $a0, 40				#pitch
	li $a1, 300				#duration in milliseconds
	li $a2, 90				#instrument
	li $a3, 127				#volume
	li $v0, 31				#MIDI out
	syscall
	
	beq $t0, 1, DrawHead			#branches to DrawHead if $t0 is equal to 1
	beq $t0, 2, DrawBody			#branches to DrawBody if $t0 is equal to 2
	beq $t0, 3, DrawLeftArm			#branches to DrawLeftArm if $t0 is equal to 3
	beq $t0, 4, DrawRightArm		#branches to DrawRightArm if $t0 is equal to 4
	beq $t0, 5, DrawLeftLeg			#branches to DrawLeftLeg if $t0 is equal to 5
	beq $t0, 6, DrawRightLeg		#branches to DrawRightLeg if $t0 is equal to 6
	
	b CWcont				#branches to CWcont
	
########## CheckLetter: checks if a letter in the word matches the guessed letter         ##########
########## $t3 = letter from randomly generated word, $t1 = letter guessed                ##########
CheckLetter:
	
	lb $t3, answer($t2)			#loads character from answer($t2) into $t3
	
	beq $t3, $t1, AddLetters		#branches to AddLetters if $t3, answer($t2), is equal to $t1, guess.
	
	jr $ra					#jumps back
	
########## AddLetters: if guessed letter is in word, it will be added to the display                               ##########
########## $t1 = guessed letter, $t2 = counter, $t5 = # of correctly guessed letters, $t7 = flag for wrong letters ##########
AddLetters:

	li $a0, 80				#pitch
	li $a1, 300				#duration in milliseconds
	li $a2, 90				#instrument
	li $a3, 127				#volume
	li $v0, 31				#MIDI out
	syscall
	
	lbu $t1, guess				#loads guess into $t1
	sb $t1, guessword($t2)			#stores guess into guessword($t2), the location of the correct letter
	
	addiu $t5, $t5, 1			#increments $t5 by 1
	addiu $t7, $t7, 1			#increments $t7 by 1
	
	addiu $sp, $sp, -20			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	sw $t5, 4($sp)				#stores $t5 in stack
	sw $t0, 8($sp)				#stores $t0 in stack
	sw $t2, 12($sp)				#stores $t2 in stack
	sw $t7, 16($sp)				#stores $t7 in stack
	
	li $a0, 260				#loads 245 in $a0
	li $a1, 200				#loads 210 in $a1
	la $a2, guessword			#loads address of guessword into $a2
	jal OutText				#jumps and links to OutText
	
	lw $ra, 0($sp)				#loads $ra from stack
	lw $t5, 4($sp)				#loads $t5 from stack
	lw $t0, 8($sp)				#loads $t0 from stack
	lw $t2, 12($sp)				#loads $t2 from stack
	lw $t7, 16($sp)				#loads $t7 from stack
	addiu $sp, $sp, 20			#resets stack pointer
	
	beq $t5, 5, SlotsFilled			#branches to SlotsFilled if $t5 is equal to 5, the max number of correctly guessed letters
	
	jr $ra					#jumps back
	
########## SlotsFilled: branched to if all letters are guessed. Victory message is given and program safely exits. ##########
SlotsFilled:
	la $a0, WinMessage			#loads address of WinMessage to $a0
	li $v0, 4				#prints WinMessage which tells the user they won
	syscall
	
	li $a0, 80				#pitch
	li $a1, 300				#duration in milliseconds
	li $a2, 90				#instrument
	li $a3, 127				#volume
	li $v0, 33				#MIDI out synchronous
	syscall
	
	li $a0, 78				#pitch
	syscall
	
	li $a0, 80				#pitch
	syscall
			
	li $a0, 84				#pitch
	li $a1, 800				#duration in milliseconds
	syscall
	
	jal ClearDisp				#clears the bitmap display
	
	li $a0, 225				#x coordinate
	li $a1, 128				#y coordinate
	la $a2, YouWin				#address of string to print in bitmap display
	jal OutText				#prints string to bitmap display
	
	li $v0, 10				#cleanly exits the program
	syscall
	
########## GuessLetter: allows for user to input a guess and stores into data memory    ##########
GuessLetter:	
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack

	la $a0, prompt				#loads address of prompt into $a0, which prompts for a character
	li $v0, 4				#prints prompt message
	syscall
	
	li $v0, 12				#allows input for character
	syscall
	
	sb $v0, guess				#stores input into guess
	
	jal AddToList				#jumps and links to AddToList
	
	jal GuessCheck				#jumps and links to GuessCheck
GLcont:	
	lw $ra, 0($sp)				#loads $ra into stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back
	
########## AddToList: For all guessed letters, adds to the usedletters list       ##########
########## $t0 = usedcount (amount of letters guessed), $t1 = guess               ##########
AddToList:
	addiu $sp, $sp, -24			#reserves space in stack
	sw $t0, 0($sp)				#stores $t0 in stack
	sw $ra, 4($sp)				#stores $ra in stack
	sw $t1, 8($sp)				#stores $t1 in stack
	sw $t5, 12($sp)				#stores $t5 in stack
	sw $t2, 16($sp)				#stores $t2 in stack
	sw $t7, 20($sp)				#stores $t7 in stack
	
	lb $t1, guess				#loads guess into $t1
	lb $t0, usedcount			#loads usedcount into $t0
	sb $t1, usedletters($t0)		#stores $t1, guess, into usedletters($t0)
	
	li $a0, 345				#x coordinate
	li $a1, 50				#y coordinate
	la $a2, usedletters			#address of string to print in bitmap display
	jal OutText				#prints string to bitmap display
	
	lb $t0, usedcount			#loads usedcount into $t0
	addiu $t0, $t0, 1			#increments $t0 by 1
	sb $t0, usedcount			#stores $t0 into usedcount
	
	lw $t0, 0($sp)				#loads $t0 from stack
	lw $ra, 4($sp)				#loads $ra from stack
	lw $t1, 8($sp)				#loads $t1 from stack
	lw $t5, 12($sp)				#loads $t5 from stack
	lw $t2, 16($sp)				#loads $t2 from stack
	lw $t7, 20($sp)				#loads $t7 from stack
	addiu $sp, $sp, 24			#resets stack pointer
	
	jr $ra
	
########## GuessCheck: checks to see if the guessed letter has already been guessed.     ##########
########## $t1 = guess, $t2 = loop counter, $t6 = location of correctly guessed letter   ##########
GuessCheck:
	lbu $t1, guess				#loads guess into $t1
	li $t2, 0				#sets $t2 as 0
GuessLoop:					#loop that
	lbu $t6, guessword($t2)			#loads guessword($t2), the proper location of the guessed correct letter, into $t6
	addiu $t2, $t2, 1			#increments $t2 by 1
	beq $t1, $t6, gccont			#branches to gccont if $t1, guess, is equal to $t6, the location of the correctly guessed letter in the word. This checks if it was guessed already
	
	blt $t2, 5, GuessLoop			#branches to GuessLoop if $t2, counter, is less than 5
	b GLcont				#branch to GLcont
gccont:	
	la $a0, RepeatMessage			#loads address of RepeatMessage into $a0, it notifies the user that the guessed letter has been used previously
	li $v0, 4				#prints the message
	syscall
	
	b GuessLetter				#branches to GuessLetter

########## DrawHead: draws the head with DrawCircle                       ##########
DrawHead:
	addiu $sp, $sp, -4			#reserve space in stack
	sw $ra, 0($sp)				#stores $ra in stack

	li $a0, 75				#x coordinate of head
	li $a1, 90				#y coordinate of head
	li $a2, 0				#color black
	jal DrawCircle				#jumps and links to DrawCircle
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	b CWcont				#branches to CWcont

########## DrawBody: draws the body with VertLine
DrawBody:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $a0, 90				#x coordinate of body
	li $a1, 90				#y coordinate of body
	li $a2, 0				#color black
	li $a3, 50				#length of body
	jal VertLine				#jumps and links to DrawBody
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	b CWcont				#branches to CWcont

########## DrawLeftArm: draws the left arm with DrawDiagonalL
DrawLeftArm:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $a0, 70				#x coordinate of arm
	li $a1, 125				#y coordinate of arm
	li $a2, 0				#color black
	li $a3, 20				#length of arm
	jal DrawDiagonalL			#jumps and links to DrawDiagonalL
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	b CWcont				#branch to CWcont
	
########## DrawRightArm: draws the right arm with DrawDiagonalR
DrawRightArm:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $a0, 90				#x coordinate of arm
	li $a1, 105				#y coordinate of arm
	li $a2, 0				#color black
	li $a3, 20				#length of arm
	jal DrawDiagonalR			#jumps and links to DrawDiagonalR
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	b CWcont				#branches to CWcont
	
########## DrawLeftLeg: draws left leg with DrawDiagonalL
DrawLeftLeg:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $a0, 70				#x coordinate of leg
	li $a1, 160				#y coordinate of leg
	li $a2, 0				#color black
	li $a3, 20				#length of leg
	jal DrawDiagonalL			#jumps and links to DrawDiagonalL
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	b CWcont				#branches to CWcont
	
########## DrawRightLeg: draw right leg with DrawDiagonalR
DrawRightLeg:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $a0, 90				#x coordinate
	li $a1, 140				#y coordinate
	li $a2, 0				#color black
	li $a3, 20				#length of leg
	jal DrawDiagonalR			#jumps and links to DrawDiagonalR
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	b CWcont				#branches to CWcont
	
########## StartGame: prints an intro for the user, plays an intro song, and prints a new line
StartGame:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	la $a0, intro				#loads address of intro into $a0, message introducing the game
	li $v0, 4				#prints string
	syscall
	
	jal PlayIntroSong			#plays the intro song
	
	la $a0, newLine				#prints a new line
	li $v0, 4				#syscall 4 for printing a string
	syscall
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back
	
########## PlayIntroSong: plays the intro song for the game
PlayIntroSong:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	jal NoteRepeat				#repeats a set of notes so code isn't repeated
	
	li $a0, 60				#pitch
	li $a1, 500				#duration in milliseconds
	syscall
	
	li $a0, 57				#pitch
	li $a1, 300				#duration in milliseconds
	syscall
	
	li $a0, 59				#pitch
	syscall
	
	li $a0, 53				#pitch
	li $a1, 500				#duration in milliseconds
	syscall
	
	jal NoteRepeat				#plays notes
	
	li $a0, 60				#pitch
	li $a1, 500				#duration in milliseconds
	syscall
	
	li $a0, 57				#pitch
	li $a1, 300				#duration in milliseconds
	syscall
	
	li $a0, 59				#pitch
	syscall
	
	li $a0, 64				#pitch
	li $a1, 500				#duration in milliseconds
	syscall
	
	jal NoteRepeat				#plays notes
	
	li $a0, 65				#pitch
	li $a1, 500				#duration in milliseconds
	syscall
	
	li $a0, 57				#pitch
	li $a1, 100				#duration in milliseconds
	syscall
	
	li $a0, 55				#pitch
	li $a1, 50				#duration in milliseconds
	syscall
	
	li $a0, 53				#pitch
	syscall
	
	li $a0, 52				#pitch
	li $a1, 300				#duration in milliseconds
	syscall
	
	jal NoteRepeat				#plays notes
	
	li $a0, 60				#pitch
	syscall
	
	li $a0, 59				#pitch
	syscall
	
	li $a0, 53				#pitch
	li $a1, 500				#duration in milliseconds
	syscall
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back
	
########## NoteRepeat: a set of notes is played. These notes are repeated often so they are in a separate procedure.
NoteRepeat:
	addiu $sp, $sp, -4			#reserve space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	li $a0, 60				#pitch
	li $a1, 100				#length
	li $a2, 25				#sound
	li $a3, 127				#volume
	li $v0, 33				#sound out syscall
	syscall
	
	li $a0, 65				#pitch
	syscall
	
	li $a0, 60				#pitch
	syscall
	
	li $a0, 65				#pitch
	syscall
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back
	
########## ChooseWord: Chooses a word from a list located in a text file using a randomly generated number
ChooseWord:
	addiu $sp, $sp, -4			#reserves space in stack
	sw $ra, 0($sp)				#stores $ra in stack
	
	jal InitRand				#chooses a random number from 0 to 49
	jal WordPicker				#picks a word from the list based on the random number
	
	lw $ra, 0($sp)				#loads $ra from stack
	addiu $sp, $sp, 4			#resets stack pointer
	
	jr $ra					#jumps back
	
########## InitRand: generates a random number from 0 to 49 and stores to data memory
InitRand:	
	li $v0, 30			#generates time
	syscall
	
	add $a1, $a0, $0		#uses lowerbound of time to generate random numbers
	li $a0, 0
	li $v0, 40			#sets seed of number generator with time
	syscall
	
	li $a1, 49
	li $v0, 42			#generates a random number that could be from 0 to 49
	syscall
	
	sb $a0, number			#stores byte $a0 into number
	
	jr $ra				#jumps back
	
########## WordPicker: Chooses a word based on the randomly generated number              ##########
########## $t3 = counter for loop, $t0 = randomly generated number, $t2 = counter         ##########
WordPicker:
	li $v0, 13			#open a file
	la, $a0, file			#loads address of file which contains file name
	li $a1, 0			#flag set to 0
	li $a2, 0			#mode set to 0, read
	syscall
	move $s6, $v0			#sets $s6 to $v0
	
	li $v0, 14			#reads from file
	move $a0, $s6			#sets $a0 to $s6
	la $a1, words			#loads address of words to $a1
	li $a2, 299			#max number of characters to read
	syscall
	
	li $v0, 16			#closes file
	move $a0, $s6			#sets $a0 to $s6
	syscall
	
	addiu $sp, $sp, -4		#reserves space in stack
	sw $t3, 0($sp)			#stores $t3 in stack
	
	li $t3, 0			#makes $t3 0
	lbu $t0, number			#loads number into $t0
	add $t2, $0, $0			#sets $t2 to 0
	mul $t0, $t0, 6			#multiplies $t0 by 6
WPloop:
	lbu $t1, words($t0)		#loads words($t0) to $t1
	sb $t1, answer($t2)		#stores $t1 to answer($t2)
	addiu $t0, $t0, 1		#increments $t0 by 1
	addiu $t2, $t2, 1		#increments $t2 by 1
	addiu $t3, $t3, 1		#increments $t3 by 1
	blt $t3, 5, WPloop		#branches to WPloop if $t3 is less than 5
	
	lw $t3, 0($sp)			#loads $t3 from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	li $v0, 4			#prints a new line to be neat
	la $a0, newLine
	syscall
	
	li $v0, 4			#prints answer string
	la $a0, answer
	syscall
	
	li $v0, 4			#prints a new line to be neat
	la $a0, newLine
	syscall

	jr $ra				#jumps back
	
########## DrawSetting: draws all of the objects on the bitmap display                  ##########
DrawSetting:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
	
	jal DrawSun			#draws the sun
	jal DrawLand			#draws the land
	jal DrawSet			#draws the set, stand, noose
	jal DrawLetterBoxes		#draws the letter boxes spaces
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back
	
########## DrawSun: draws the sun on the bitmap display                       ##########
DrawSun:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
	
	li $a0, 280			#x coordinate
	li $a1, 150			#y coordinate
	li $a2, 7			#color for sun
	jal DrawCircle			#draws a circle for the sun
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back
	
########## DrawLand: draws the land on the bitmap display            ###########
DrawLand:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	
	li $a0, 0			#x coordinate
	li $a1, 156			#y coordinate
	li $a2, 4			#color for land
	li $a3, 512			#length of rectangle
	li $t0, 100			#height of rectangle
	jal DrawRectangle		#draws a rectangle
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back
	
########## DrawSet: draws the set, including the platform, stand, top, and noose     ##########
DrawSet:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	
	jal DrawPlatform		#draws the platform
	jal DrawStand			#draws the stand
	jal DrawTop			#draws the top
	jal DrawNoose			#draws the noose
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back

########## DrawPlatform: draws the platform for the set         ##########
DrawPlatform:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
	
	li $a0, 20			#x coordinate
	li $a1, 200			#y coordinate
	li $a2, 3			#color for platform
	li $a3, 150			#length of rectangle
	li $t0, 5			#height of rectangle
	jal DrawRectangle		#draws a rectangle for the platform
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back

########## DrawStand: draws the stand with a rectangle             ##########
DrawStand:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
	
	li $a0, 30			#x coordinate
	li $a1, 50			#y coordinate
	li $a2, 3			#color of stand
	li $a3, 5			#length of rectangle
	li $t0, 150			#height of rectangle
	jal DrawRectangle		#draws the rectangle for the stand
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back
	
########## DrawTop: draws the top of the set                 ##########
DrawTop:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	
	li $a0, 30			#x coordinate
	li $a1, 50			#y coordinate
	li $a2, 3			#color of top of set
	li $a3, 70			#length of rectangle
	li $t0, 5			#height of rectangle
	jal DrawRectangle		#draw a rectangle for DrawTop
	
	lw $ra, 0($sp)			#loads $ra in stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back

########## DrawNoose: draws the noose for the set                  ##########
DrawNoose:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	
	li $a0, 90			#x coordinate
	li $a1, 50			#y coordinate
	li $a2, 3			#color of noose of set
	li $a3, 30			#length of line
	jal VertLine			#draws a vertical line
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back
	
########## DrawLetterBoxes: draws the letter boxes for the five letters for the words             ##########
########## $t1 = x coordinate, $t2 = counter                                                      ##########
DrawLetterBoxes:
	addiu $sp, $sp, -12		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	li $t1, 260			#loads 260 into $t1
	li $t2, 0			#loads 0 into $t2
LBLoop:					#loop that draws a rectangle and increments the x coordinate to the right to draw another rectangle until five are drawn
	move $a0, $t1			#copies $t1 into $a0, the x coordinate
	li $a1, 215			#y coordinate
	li $a2, 2			#color
	li $a3, 7			#length of rectangle
	li $t0, 3			#height of rectangle
	sw $t1, 4($sp)			#stores $t1 into stack
	sw $t2, 8($sp)			#stores $t2 into stack
	jal DrawRectangle		#draws a rectangle for letter boxes lines
	lw $t1, 4($sp)			#loads $t1 from stack
	lw $t2, 8($sp)			#loads $t2 from stack
	
	addiu $t1, $t1, 10		#increments $t1, x coordinate, by 10
	addiu $t2, $t2, 1		#increments $t2, counter, by 1
	
	bne $t2, 5, LBLoop		#branches to LBLoop if $t2 is not equal to 5
	
	lw $ra, 0($sp)			#loads $ra from stack
	addiu $sp, $sp, 12		#resets stack pointer
	
	jr $ra				#jumps back
	
########## ClearDisp: clears display                             ##########
ClearDisp:
	addiu $sp, $sp, -4		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
	
	li $a0, 0			#loads x coordinate 0 into $a0
	li $a1, 0			#loads y coordinate 0 into $a1
	li $a2, 5			#loads color number 5 (Dark Orange) into $a2
	li $a3, 512			#loads box size 32 into $a3
	li $t0, 256
	jal DrawRectangle			#jumps and links to DrawBox
	
	lw $ra, 0($sp)			#loads word from stack into $ra
	addiu $sp, $sp, 4		#resets stack pointer
	
	jr $ra				#jumps back

########## CalcAddr: calculates the address of the dots to be drawn           ##########
CalcAddr:
	mul $a0, $a0, 4			#multpilies $a0 by 4
	mul $a1, $a1, 256		#multiplies $a1 by 256
	mul $a1, $a1, 8			#multiplies $a1 by 4
	add $v0, $a0, $a1		#adds $a1 with $a0 and stores into $v0
	addi $v0, $v0, 0x10040000	#adds base address to $v0
					#$v0 is now address of pixel on display
	jr $ra				#jumps back
#GetColor:	Uses color number to pick color hex value from ColorTable
	# $a2 = color
GetColor:
	la $t0, ColorTable		#loads address of ColorTable into $t0
	sll $a2, $a2, 2			#multplies $a2 by 4
	add $a2, $t0, $a2		#adds $t0 to $a2
	lw $v1, 0($a2)			#loads word from whereever $a2 is pointing into $v1
	
	jr $ra				#jumps back
#DrawDot:	Draws a dot on the bitmap display
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
DrawDot:
	addiu $sp, $sp, -8		#reserves space in stack
	sw $ra, 4($sp)			#stores $ra in stack
	sw $a2, 0($sp)			#stores $a2 in stack
	jal CalcAddr			#jumps and links to CalcAddr
	lw $a2, 0($sp)			#loads word from stack into $a2
	sw $v0, 0($sp)			#stores $v0 in stack
	jal GetColor			#jumps and links to GetColor
	lw $v0, 0($sp)			#loads word from stack into $v0
	sw $v1, 0($v0)			#stores $v1 in stack
	lw $ra, 4($sp)			#loads word from stack into $ra
	addiu $sp, $sp, 8		#resets stack pointer
	
	jr $ra				#jumps back
	
#HorzLine:	Creates a horizontal line using dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
	# $a3 = length
HorzLine:
	#creat stack frame / save $ra
	addiu $sp, $sp, -20		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	sw $a1, 8($sp)			#stores $a1 in stack
	sw $a2, 12($sp)			#stores $a2 in stack
HorzLoop:
	sw $a0, 4($sp)			#stores $a0 in stack
	sw $a3, 16($sp)			#stores $a3 in stack
	jal DrawDot			#jumps and links to DrawDot
	lw $a0, 4($sp)			#loads word from stack into $a0
	lw $a1, 8($sp)			#loads word from stack into $a1
	lw $a2, 12($sp)			#loads word from stack into $a2
	lw $a3, 16($sp)			#loads word from stack into $a3
	addi $a0, $a0, 1		#adds 1 to $a0
	subi $a3, $a3, 1		#subtracts 1 from $a3
	
	bne $a3, $0, HorzLoop		#branches to HorzLoop if $a3 is not equal to $0
	
	lw $ra, 0($sp)			#loads word from stack into $ra
	
	addiu $sp, $sp, 20		#resets stack pointer
	
	jr $ra				#jumps back
	
#VertLine:	Creates a vertical line using dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
	# $a3 = length
VertLine:
	#create stack frame / save $ra
	addiu $sp, $sp, -20		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	sw $a0, 4($sp)			#stores $a0 in stack
	sw $a2, 12($sp)			#stores $a2 in stack
VertLoop:
	sw $a1, 8($sp)			#stores $a1 in stack
	sw $a3, 16($sp)			#stores $a3 in stack
	jal DrawDot			#jumps and links to DrawDot
	lw $a0, 4($sp)			#loads word from stack into $a0
	lw $a1, 8($sp)			#loads word from stack into $a1
	lw $a2, 12($sp)			#loads word from stack into $a2
	lw $a3, 16($sp)			#loads word from stack into $a3
	addi $a1, $a1, 1		#adds 1 to $a1
	subi $a3, $a3, 1		#subtracts 1 from $a3
	
	bne $a3, $0, VertLoop		#branches to VertLoop if $a3 is not equal to $0
	
	lw $ra, 0($sp)			#loads word from stack into $ra
	
	addiu $sp, $sp, 20		#resets stack pointer
		
	jr $ra				#jumps back
	
#DrawBox:	Draws a box using horizontal lines made up of dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
	# $a3 = size
DrawBox:
	#create stack frame / save $ra
	#copy $a3 -> temp register $t0
	addiu $sp, $sp, -24		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
	move $t0, $a3			#copies $a3 into $t0
BoxLoop:
	sw $a0, 4($sp)			#stores $a0 into stack
	sw $a1, 8($sp)			#stores $a1 into stack
	sw $a2, 12($sp)			#stores $a2 into stack
	sw $a3, 16($sp)			#stores $a3 into stack
	sw $t0, 20($sp)			#stores $t0 into stack
	jal HorzLine			#jumps and links to HorzLine
	lw $a0, 4($sp)			#loads word from stack into $a0
	lw $a1, 8($sp)			#loads word from stack into $a1
	lw $a2, 12($sp)			#loads word from stack into $a2
	lw $a3, 16($sp)			#loads word from stack into $a3
	lw $t0, 20($sp)			#loads word from stack into $t0
	addi $a1, $a1, 1		#adds 1 to $a1
	subi $t0, $t0, 1		#subtracts 1 from $t0
	
	bne $t0, $0, BoxLoop		#branches to BoxLoop if $t0 is not equal to $0
	
	lw $ra, 0($sp)			#loads word from stack into $ra
	
	addiu $sp, $sp, 24		#resets stack pointer
	
	jr $ra				#jumps back
	
#DrawCircle:	Draws a circle based on lines of dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
DrawCircle:
	addiu $sp, $sp, -24		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	add $t0, $0, $0			#makes $t0 into 0
CircleLoop:
	lb $a3, CircleSize($t0)		#loads byte that controls how tall the first vertical line will be in the circle
	sw $a0, 4($sp)			#stores $a0 in stack
	sw $a1, 8($sp)			#stores $a1 in stack
	sw $a2, 12($sp)			#stores $a2 in stack
	sw $a3, 16($sp)			#stores $a3 in stack
	sw $t0, 20($sp)			#stores $t0 in stack
	sub $a1, $a1, $a3		#subtracts $a3 from $a1
	mul $a3, $a3, 2			#multiplies $a3 by 2
	jal VertLine			#jumps and links to VertLine
	lw $a0, 4($sp)			#loads $a0 back
	lw $a1, 8($sp)			#loads $a1 back
	lw $a2, 12($sp)			#loads $a2 back
	lw $a3, 16($sp)			#loads $a3 back
	lw $t0, 20($sp)			#loads $t0 back
	addi $a0, $a0, 1		#adds 1 to $a0
	addi $t0, $t0, 1		#adds 1 to $t0
	bne $t0, 33, CircleLoop		#branches to CircleLoop if $t0 is not equal to 7
	lw $ra, 0($sp)			#loads $ra back
	addiu $sp, $sp, 24		#resets stack pointer
	jr $ra				#jumps back

#DrawRectangle:	Draws a rectangle based on lines of dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
	# $a3 = length
	# $t0 = height
DrawRectangle:
	#create stack frame / save $ra
	addiu $sp, $sp, -24		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra into stack
RecLoop:
	sw $a0, 4($sp)			#stores $a0 into stack
	sw $a1, 8($sp)			#stores $a1 into stack
	sw $a2, 12($sp)			#stores $a2 into stack
	sw $a3, 16($sp)			#stores $a3 into stack
	sw $t0, 20($sp)			#stores $t0 into stack
	jal HorzLine			#jumps and links to HorzLine
	lw $a0, 4($sp)			#loads word from stack into $a0
	lw $a1, 8($sp)			#loads word from stack into $a1
	lw $a2, 12($sp)			#loads word from stack into $a2
	lw $a3, 16($sp)			#loads word from stack into $a3
	lw $t0, 20($sp)			#loads word from stack into $t0
	addi $a1, $a1, 1		#adds 1 to $a1
	subi $t0, $t0, 1		#subtracts 1 from $t0
	
	bne $t0, $0, RecLoop		#branches to BoxLoop if $t0 is not equal to $0
	
	lw $ra, 0($sp)			#loads word from stack into $ra
	
	addiu $sp, $sp, 24		#resets stack pointer
	
	jr $ra				#jumps back
	
#DrawDiagonalL:	Draws a rectangle based on lines of dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
	# $a3 = length
DrawDiagonalR:
	addiu $sp, $sp, -20		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	sw $a2, 12($sp)			#stores $a2 in stack
DiagonalLoopR:
	sw $a0, 4($sp)			#stores $a0 in stack
	sw $a1, 8($sp)			#stores $a1 in stack
	sw $a3, 16($sp)			#stores $a3 in stack
	jal DrawDot			#jumps and links to DrawDot
	lw $a0, 4($sp)			#loads word from stack into $a0
	lw $a1, 8($sp)			#loads word from stack into $a1
	lw $a2, 12($sp)			#loads word from stack into $a2
	lw $a3, 16($sp)			#loads word from stack into $a3
	addi $a0, $a0, 1		#adds 1 to $a0
	addi $a1, $a1, 1		#adds 1 to $a1
	subi $a3, $a3, 1		#subtracts 1 from $a3
	bne $a3, $0, DiagonalLoopR	#branches to DiagonalLoop1 if $a3 is not equal to 0
	lw $ra, 0($sp)			#loads word from stack into $ra
	addiu $sp, $sp, 20		#resets stack pointer
	
	jr $ra				#jumps back
	
#DrawDiagonalR:	Draws a rectangle based on lines of dots
	# $a0 = x coordinate
	# $a1 = y coordinate
	# $a2 = color
	# $a3 = length
DrawDiagonalL:
	addiu $sp, $sp, -20		#reserves space in stack
	sw $ra, 0($sp)			#stores $ra in stack
	sw $a2, 12($sp)			#stores $a2 in stack
DiagonalLoopL:
	sw $a0, 4($sp)			#stores $a0 in stack
	sw $a1, 8($sp)			#stores $a1 in stack
	sw $a3, 16($sp)			#stores $a3 in stack
	jal DrawDot			#jumps and links to DrawDot
	lw $a0, 4($sp)			#loads word from stack into $a0
	lw $a1, 8($sp)			#loads word from stack into $a1
	lw $a2, 12($sp)			#loads word from stack into $a2
	lw $a3, 16($sp)			#loads word from stack into $a3
	subi $a1, $a1, 1		#subtracts 1 from $a1
	subi $a3, $a3, 1		#subtracts 1 from $a3
	addi $a0, $a0, 1		#adds 1 to $a0
	bne $a3, $0, DiagonalLoopL	#branches to DiagonalLoop2 if $a3 is not equal to 0
	lw $ra, 0($sp)			#loads word from stack into $ra
	addiu $sp, $sp, 20		#resets stack pointer
	
	jr $ra				#jumps back

####################################################################################################
#### Alphabet for printing ASCII characters in bitmap display ######################################
####################################################################################################
.data

Colors: .word   0xb34d25	 # background Dark Orange
        .word   0xffffff        # foreground color (white)

DigitTable:
        .byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0
        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e
        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e
        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '5', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0x7f,0x03,0x03,0x83,0xff,0x7f
        .byte   '6', 0xc0,0xc0,0xc0,0xc0,0xc0,0xfe,0xfe,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '7', 0x7e,0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60
        .byte   '8', 0x7e,0xff,0xc3,0xc3,0xc3,0x7e,0x7e,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '9', 0x7e,0xff,0xc3,0xc3,0xc3,0x7f,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '+', 0x00,0x00,0x00,0x18,0x18,0x7e,0x7e,0x18,0x18,0x00,0x00,0x00
        .byte   '-', 0x00,0x00,0x00,0x00,0x00,0x7e,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   '*', 0x00,0x00,0x00,0x66,0x3c,0x18,0x18,0x3c,0x66,0x00,0x00,0x00
        .byte   '/', 0x00,0x00,0x18,0x18,0x00,0x7e,0x7e,0x00,0x18,0x18,0x00,0x00
        .byte   '=', 0x00,0x00,0x00,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   'A', 0x18,0x3c,0x66,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3
        .byte   'B', 0xfc,0xfe,0xc3,0xc3,0xc3,0xfe,0xfe,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'C', 0x7e,0xff,0xc1,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc1,0xff,0x7e
        .byte   'D', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'E', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'F', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'G', 0xff,0xff,0xc0,0xc0,0xc0,0xcf,0xcf,0xc3,0xc3,0xc3,0x3f,0x3f
        .byte   'H', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'I', 0x7e,0x7e,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x7e,0x7e
        .byte   'J', 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0xc3,0xc3,0xc3,0xff,0xff
        .byte   'K', 0xc3,0xc6,0xcc,0xd8,0xf0,0xf0,0xd8,0xcc,0xcc,0xc6,0xc6,0xc3
        .byte   'L', 0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'M', 0xc3,0xc3,0xe7,0xe7,0xff,0x99,0x99,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'N', 0xf3,0xf3,0xf3,0xf3,0xdb,0xdb,0xdb,0xdb,0xcf,0xcf,0xcf,0xcf
        .byte   'O', 0x7e,0x7e,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0x7e,0x7e
        .byte   'P', 0xfc,0xfc,0xc3,0xc3,0xc3,0xfc,0xfc,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'Q', 0x3c,0x3c,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xcc,0xcc,0x33,0x33
        .byte   'R', 0xfc,0xfc,0xc3,0xc3,0xc3,0xfc,0xfc,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'S', 0xff,0xff,0xc0,0xc0,0xc0,0xff,0xff,0x03,0x03,0x03,0xff,0xff
        .byte   'T', 0xff,0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   'U', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0x3c,0x3c
        .byte   'V', 0xc3,0xc3,0xc3,0xc3,0x66,0x66,0x66,0x66,0x3c,0x3c,0x18,0x18
        .byte   'W', 0xdb,0xdb,0xdb,0xdb,0xdb,0xdb,0xdb,0xdb,0xdb,0xdb,0x66,0x66
        .byte   'X', 0xc3,0xc3,0xc3,0x66,0x3c,0x18,0x18,0x3c,0x66,0xc3,0xc3,0xc3
        .byte   'Y', 0xc3,0xc3,0xc3,0x66,0x3c,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   'Z', 0xff,0xff,0x03,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc0,0xff,0xff
# first byte is the ascii character
# next 12 bytes are the pixels that are "on" for each of the 12 lines
        .byte    0, 0,0,0,0,0,0,0,0,0,0,0,0

.text

# OutText: display ascii characters on the bit mapped display
# $a0 = horizontal pixel co-ordinate (0-255)
# $a1 = vertical pixel co-ordinate (0-255)
# $a2 = pointer to asciiz text (to be displayed)
OutText:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)

        li      $t8, 1          # line number in the digit array (1-12)
_text1:
        la      $t9, 0x10040000 # get the memory start address
        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height
        sll     $t0, $a1, 11    # (a0 * 4) + (a1 * 4 * 256)
        addu    $t9, $t9, $t0   # t9 = memory address for this pixel

        move    $t2, $a2        # t2 = pointer to the text string
_text2:
        lb      $t0, 0($t2)     # character to be displayed
        addiu   $t2, $t2, 1     # last character is a null
        beq     $t0, $zero, _text9

        la      $t3, DigitTable # find the character in the table
_text3:
        lb      $t4, 0($t3)     # get an entry from the table
        beq     $t4, $t0, _text4
        beq     $t4, $zero, _text4
        addiu   $t3, $t3, 13    # go to the next entry in the table
        j       _text3
_text4:
        addu    $t3, $t3, $t8   # t8 is the line number
        lb      $t4, 0($t3)     # bit map to be displayed

        sw      $zero, 0($t9)   # first pixel is black
        addiu   $t9, $t9, 4

        li      $t5, 8          # 8 bits to go out
_text5:
        la      $t7, Colors
        lw      $t7, 0($t7)     # assume black
        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)
        beq     $t6, $zero, _text6
        la      $t7, Colors     # else it is white
        lw      $t7, 4($t7)
_text6:
        sw      $t7, 0($t9)     # write the pixel color
        addiu   $t9, $t9, 4     # go to the next memory position
        sll     $t4, $t4, 1     # and line number
        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)
        bne     $t5, $zero, _text5

        sw      $zero, 0($t9)   # last pixel is black
        addiu   $t9, $t9, 4
        j       _text2          # go get another character

_text9:
        addiu   $a1, $a1, 1     # advance to the next line
        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)
        bne     $t8, 13, _text1

        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra
