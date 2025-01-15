.section .start
.globl start

start:
    li t0, 0x8      
    li t1, 0x7    
    li t2, 0         # compteur    
    li t3, 0         # résultat
    li t4, 16        # limite du compteur

loop_start:
    andi t5, t1, 1    # t5 = t1 & 1 (recupère le LSB de t1)
    beqz t5, skip_add # Si t5 == 0 (LSB est 0), sauter l'addition

    # Si t1[0] == 1 :
    add t3, t3, t0    # t3 = t3 + t0

skip_add:
    slli t0, t0, 1    # t0 = t0 << 1 (décalage à gauche de t0)
    srli t1, t1, 1    # t1 = t1 >> 1 (décalage à droite de t1)
    addi t2, t2, 1    # t2 = t2 + 1 (incrémenter le compteur)
    bne t2, t4, loop_start # Si t2 != 16, reboucle

lab:
    j lab

.end start