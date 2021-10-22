; Vernamova sifra na architekture DLX
; Lucie Svobodová xsvobo1x

			    ; REGISTRY: xsvobo1x-r3-r10-r11-r22-r27-r0
        .data 0x04          ; zacatek data segmentu v pameti
login:  .asciiz "xsvobo1x"  ; <-- nahradte vasim loginem
cipher: .space 9 ; sem ukladejte sifrovane znaky (za posledni nezapomente dat 0)

        .align 2            ; dale zarovnavej na ctverice (2^2) bajtu
laddr:  .word login         ; 4B adresa vstupniho textu (pro vypis)
caddr:  .word cipher        ; 4B adresa sifrovaneho retezce (pro vypis)

        .text 0x40          ; adresa zacatku programu v pameti
        .global main        ; 

main:   ; sem doplnte reseni Vernamovy sifry dle specifikace v zadani
	; a...97, z...122, s...posun +19, v... posun -22
	; xsvobo1x -> qwosus

	; vložení počáteční hodnoty do r11
	; registr obsahuje 0/1 podle toho, zda se má přičítat 19/odčítat 22
	add r11, r0, r0		; r11 = 0

loop:
	lb r3, login(r10)	; jeden byte z loginu je načten do registru r3

	; test, zda není právě načtený znak číslo
	add r22, r0, r0		; r22 = 0 (v r22 bude výsledek porovnání)
	addi r27, r0, 97	; r27 = 97 (ASCII hodnota 'a')
	slt r22, r3, r27	; r3 < r27 ? r22 = 1 : r22 = 0
	bnez r22, end		; if (r22 != 0) goto end
	nop

	; přičítání čísla 19 (r11 == 1)/odečítání čísla 22 (r11 == 0)
	add r22, r0, r0		; r22 = 0
	sgt r22, r11, r0	; r11 > 0 ? r22 = 1 : r22 = 0
	xori r11, r11, 1	; ~r11 (signalizace, zda se příště odčítá/přičítá)
	bnez r22, subs		; if (r22 != 0) goto subs
	nop

	addi r27, r0, 19	; r27 = 19
	j addit
	nop

subs:	subi r27, r0, 22	; r27 = -22

addit:	add r3, r3, r27

	; porovnání r3 > 122 + případná úprava kódu
	add r22, r0, r0		; r22 = 0
	addi r27, r0, 122	; r27 = 122
	slt r22, r27, r3	; r27 < r3 ? r22 = 1 : r22 = 0
	beqz r22, lower		; if r22 == 0 goto lower
	nop

	subi r3, r3, 123	; r3 = r3 - 123
	addi r3, r3, 97		; r3 = r3 + 97

lower:	add r22, r0, r0		; r22 = 0
	addi r27, r0, 97	; r27 = 97
	sgt r22, r27, r3	; r27 > r3 ? r22 = 1 : r22 = 0
	beqz r22, next		; if (r22 == 0) goto next
	nop
	
	subi r3, r3, 96		; r3 = r3 - 97
	addi r3, r3, 122	; r3 = r3 + 123

next:	sb cipher(r10), r3	; uloží jeden byte do cipher
	addi r3, r3, 1		; r3++ (posun pointeru read)
	addi r10, r10, 1	; r10++ (posun pointeru write)

	j loop
	nop

end:	addi r14, r0, caddr ; <-- pro vypis sifry nahradte laddr adresou caddr
        trap 5  ; vypis textoveho retezce (jeho adresa se ocekava v r14)
        trap 0  ; ukonceni simulace
