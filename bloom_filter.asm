	#+ BITTE NICHT MODIFIZIEREN: Vorgabeabschnitt
	#+ ------------------------------------------

.data

str_ergebnisse: .asciiz "Ergebnisse der Auswertefunktion für Testwoerter:\n"
str_dots: .asciiz "......................."
str_true: .asciiz "True\n"
str_false: .asciiz "False\n"

animal_example_bitmap: .word 0x48090285, 0x14419124, 0x12410413, 0x4103d029, 0x228a3101, 0x2016008, 0x04000e14, 0x0115906d

.text

.eqv SYS_PUTSTR 4
.eqv SYS_PUTCHAR 11
.eqv SYS_PUTINT 1
.eqv SYS_EXIT 10

.globl main
main:
	# Fehlendes Element zur Auswertefunktion hinzufuegen:
	la $a0, str_missing_word_to_add
	la $a1, animal_example_bitmap
	li $a2, 4
	jal bf_add

	# Auswertefunktion fuer alle Testwoerter aufrufen:
	li $v0, SYS_PUTSTR
	la $a0, str_ergebnisse
	syscall

	la $s0, test_words
_main_test_loop:
	lb $t0, 0($s0)
	beqz $t0, _main_test_endloop
	
	move $a0, $s0
	li $v0, SYS_PUTSTR
	syscall
	
	move $a0, $s0
	la $a1, animal_example_bitmap
	li $a2, 4
	jal bf_evaluate
	move $t2, $v0
	
	la $a0, str_dots
_main_next_str_loop:
	lb $t0, 0($s0)
	addi $s0, $s0, 1
	addi $a0, $a0, 1
	beqz $t0, _main_next_str_endloop
	j _main_next_str_loop
_main_next_str_endloop:

	li $v0, SYS_PUTSTR
	syscall
	
	la $a0, str_false
	beqz $t2, _main_result_false
	la $a0, str_true
_main_result_false:
	syscall
	
	j _main_test_loop
_main_test_endloop:

	# Programmende
	li $v0, SYS_EXIT
	syscall

# int hash_str(char *str_in, int seed):
hash_str:
	li $t0, 1 # $t0: longhash
_hash_str_seed_shift_loop:
	beqz $a1, _hash_str_seed_shift_endloop
	sll $t0, $t0, 1
	subi $a1, $a1, 1
	j _hash_str_seed_shift_loop
_hash_str_seed_shift_endloop:
	
	addi $t0, $t0, 5380
	
_hash_str_loop:
	lbu $t1, 0($a0)
	beqz $t1, _hash_str_endloop
	
	sll $t2, $t0, 5
	addu $t0, $t0, $t2
	xor $t0, $t0, $t1
	
	addi $a0, $a0, 1
	j _hash_str_loop
_hash_str_endloop:

	move $v0, $t0
	srl $t0, $t0, 8
	xor $v0, $v0, $t0
	srl $t0, $t0, 8
	xor $v0, $v0, $t0
	srl $t0, $t0, 8
	xor $v0, $v0, $t0
	andi $v0, $v0, 0xff

	jr $ra

# int bitmap_getbit(char *bitmap, int index):
bitmap_getbit:
	srl $v0, $a1, 5 # $v0: word index
	sll $v0, $v0, 2
	add $v0, $v0, $a0
	lw $v0, 0($v0) # $v0: word from bitmap
	
	andi $t0, $a1, 0x1f  # $t0: bit index
_bitmap_getbit_shift_loop:
	beqz $t0, _bitmap_getbit_shift_endloop
	srl $v0, $v0, 1
	subi $t0, $t0, 1
	j _bitmap_getbit_shift_loop
_bitmap_getbit_shift_endloop: # $v0: (word from bitmap >> bit index)
	
	andi $v0, $v0, 1 
	jr $ra
	
# void bitmap_setbit(char *bitmap, int index):
bitmap_setbit:
	srl $t1, $a1, 5 # $t1: word index
	sll $t1, $t1, 2
	add $t1, $t1, $a0
	lw $t2, 0($t1) # $t2: word from bitmap
	
	andi $t0, $a1, 0x1f  # $t0: bit index
	li $t3, 1 
_bitmap_setbit_shift_loop:
	beqz $t0, _bitmap_setbit_shift_endloop
	sll $t3, $t3, 1
	subi $t0, $t0, 1
	j _bitmap_setbit_shift_loop
_bitmap_setbit_shift_endloop: # $t3: (1 << bit index)

	or $t2, $t2, $t3
	sw $t2, 0($t1)

	jr $ra
		
	#+ BITTE VERVOLLSTAENDIGEN: Persoenliche Angaben zur Hausaufgabe 
	#+ -------------------------------------------------------------

	# Vorname: Fjoni	
	# Nachname: Yzeiri
	# Matrikelnummer: 461396
	
	#+ Loesungsabschnitt
	#+ -----------------
.data

test_words:
	.asciiz "Katze"
	.asciiz "Baum"
	.asciiz "Hund"
	.asciiz "Lampe"
	.asciiz "See"
	.asciiz "Maulwurf"
	.asciiz "Maus"
	.asciiz "Goldfisch"
	.asciiz "Boot"
	.asciiz "Regenwurm"
	.asciiz "Loewe"
	.asciiz "Kuh"
	.asciiz "Auto"
	.asciiz "Adler"
	.asciiz "Ziegen"
	.asciiz "Huhn"
	.asciiz "Fisch"
	.byte 0x00
	
str_missing_word_to_add: .asciiz "Regenwurm"

.text

#bf_evaluate(str_in, bitmap, k):
#    int final                               
#    int index                               
#    int seed = 0                            
#    while seed < k:                         
#        index = hash_str(str_in, seed)      
#        if bitmap_getbit(bitmap, index):    
#            final = 1                       
#        else:
#            final = 0                       
#            break                           
#        seed++     

bf_evaluate:
	# Funktion bf_evaluate bitte hier implementieren.
	addi $sp, $sp, -24
	sw	 $ra, 20($sp)
	sw	 $s0, 16($sp)	#final
	sw	 $s1, 12($sp)	#index
	sw	 $s2, 8($sp)	#seed
	sw	 $s3, 4($sp)	#Speicherplatz fuer Bitmap
	sw   $s4, 0($sp)	#Speicherplatz fuer str_in
	move $s4, $a0		#str_in in $s4 speichern
	move $s3, $a1		#Bitmap in $s3 speichern
	li	 $s2, 0			#seed = 0
	li	 $s0, 1			#final = 1
while:
	bge	 $s2, $a2, exitWhile #while seed < k
	move $a1, $s2		#$a1 = seed
	move $a0, $s4		#$a0 = str_in 
	jal  hash_str		#ruf hash_str(str_in, seed) auf
	move $a1, $v0		#das Ergebnis von hash_str in $a1 als das Argument index
	move $a0, $s3		#$a0 = bitmap
	jal	 bitmap_getbit	#bitmap_getbit(bitmap, index)
if:
	beq  $v0, $zero, else	#if bitmap_getbit() == 1
	addi $s2, $s2, 1		#seed++
	j    while
else:
	move $s0, $zero  	#final = 1-1 = 0
	j    exitWhile		#break
exitWhile:
	move $v0, $s0		#final in $v0 kopieren
	lw	 $ra, 20($sp) 	#freien des Speichers
	lw	 $s0, 16($sp)
	lw	 $s1, 12($sp)
	lw	 $s2, 8($sp)
	lw	 $s3, 4($sp)
	lw   $s4, 0($sp)
	addi $sp, $sp, 24
	jr 	 $ra
	
#bf_add():
#    int final                               
#    int index                               
#    int seed                                
#    while seed < k:                         
#        index = hash_str(str_in, seed)      
#        bitmap_setbit(bitmap, index)        
#        seed++                              
	
bf_add:
	# Funktion bf_add bitte hier implementieren.
	addi $sp, $sp, -24	#Speicherplatz allozieren
	sw	 $ra, 20($sp)	#$ra speichern
	sw	 $s0, 16($sp)	#final
	sw	 $s1, 12($sp)	#index
	sw	 $s2, 8($sp)	#seed
	sw	 $s3, 4($sp)	#Speicherplatz fuer bitmap, muss gespeichert werden da nicht-Blatt Funktion
	sw   $s4, 0($sp)	#Speicherplatz fuer str_in, muss gespeichert werden da nicht-Blatt Funktion
	move $s4, $a0		#str_in in $s4
	move $s3, $a1		#bitmap in $s3
	li 	 $s2, 0			#final = 0: falls 0 -> false, falls 1 -> true
bf_While:
	bgt  $s2, $a2, exit_bf_While #while seed < k
	move $a0, $s4		#str_in in $a0	
	move $a1, $s2		#seed in $a1
	jal  hash_str		#hash_str aufrufen
	move $a1, $v0		#zurueckgegebenen Wert von hash_str in $a1 speichern
	move $a0, $s3		#Bitmap in $a0 speichern
	jal  bitmap_setbit	#bitmap_setbit aufrufen
	addi $s2, $s2, 1	#final = 1
	j    bf_While		#zurueckspringen
exit_bf_While:	
	lw	 $ra, 20($sp)	#lade $ra
	lw	 $s0, 16($sp)	#lade $s0
	lw	 $s1, 12($sp)	#lade $s1
	lw	 $s2, 8($sp)	#lade $s2
	lw   $s3, 4($sp)	#lade $s3
	lw   $s4, 0($sp)	#lade $s4
	addi $sp, $sp, 24   #Befreiung von Speicherplatz
	jr 	 $ra
