.section .text
.globl main
.type main, @function

main:
    # Opération 1 : t0 = 0x3
    li t0, 0x3
    # Opération 2 : t1 = 0x8
    li t1, 0x8
    # Opération 3 : t2 = t1 + t0
    add t2, t1, t0
    # Opération 4 : t3 = 0x10
    li t3, 0x10
    # Opération 5 : t4 = 0x11
    li t4, 0x11
    # Opération 6 : t5 = t3 - t4
    sub t5, t3, t4
    # Boucle infinie pour arrêter le programme
1:  j 1b

.end