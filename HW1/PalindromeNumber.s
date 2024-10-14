.data
    datas: .word 0x0F00000F, 0x0E000001, 0x0000001B, 0x00000002, 0x00000001
    ans:   .word 0x1, 0x0, 0x1, 0x0, 0x1
    str1:     .string "\ncheckPalindrome(" 
    str2:     .string ") is : " 
    strError: .string "\nthe answer is wrong!!!"
.text
main:
        # Load datas reference
        la s6, datas
        
        # Load ans reference
        la s7, ans
        
        # Load the loop count
        li s8, 5
        
print_numbers:
        # print "\ncheckPalindrome(" 
        la a0, str1
        li a7, 4
        ecall
        
        # print 'data'
        lw a0, 0(s6)
        li, a7, 34
        ecall
        
        # print ") is : " 
        la a0, str2
        li a7, 4
        ecall
        
        # print checkPalindrome(data)  
        lw a0, 0(s6)
        jal ra, checkPalindrome
        li, a7, 1
        ecall
     
validation:
        # check if fp16_to_fp32(data) == ans 
        lw t0, 0(s7)
        sub t0, t0, a0
        beqz t0, check_loop
        
        # print "\nthe answer is wrong!!!"
        la a0, strError
        li a7, 4
        ecall
        
check_loop:
        # next data, ans
        addi s6, s6, 4
        addi s7, s7, 4
        addi s8, s8, -1
        bnez s8, print_numbers
        
exit:
        # Exit the program
        li a7, 10                  # System call code for exiting the program
        ecall                      # Make the exit system call
        ret

checkPalindrome:
        # t0 is the input parameter N
        
        mv t0, a0
        
my_clz:
        # t0 is the input parameter x
        # t1 is c
        # t2 is r
        
        # int r = 0, c;    
        li t2, 0
        
        # c = (x < 0x00010000) << 4;
        li t1 0x00010000
        sltu t1, t0, t1
        slli t1, t1, 4
        # r += c;           
        add t2, t2, t1
        # x <<= c       
        sll t0, t0, t1
        
        # c = (x < 0x01000000) << 3;    
        li t1 0x01000000
        sltu t1, t0, t1
        slli t1, t1, 3
        # r += c;         
        add t2, t2, t1
        # x <<= c          
        sll t0, t0, t1
          
        # c = (x < 0x10000000) << 2;   
        li t1 0x10000000
        sltu t1, t0, t1
        slli t1, t1, 2
        # r += c;         
        add t2, t2, t1
        # x <<= c         
        sll t0, t0, t1
        
        # c = (x < 0x40000000) << 1;
        li t1 0x40000000
        sltu t1, t0, t1
        slli t1, t1, 1
        # r += c;         
        add t2, t2, t1
        # x <<= c       
        sll t0, t0, t1
        
        # c = x < 0x80000000;
        li t1 0x80000000
        sltu t1, t0, t1
        # r += c; 
        add t2, t2, t1
        # x <<= c               
        sll t0, t0, t1
        
        # r += x == 0;
        seqz t0, t0
        add t2, t2, t0
        
        
back_to_checkPalindrome:
        # t0 is N
        # t1 is rev
        # t2 is num
        # t3 is move
        # t4 is additional_move
        # t5 is i
        mv t0, a0
        
        # uint32_t rev = 0;
        li t1, 0
        
        # uint32_t num = 32 - my_clz(N);
        li t6, 32
        sub t2, t6, t2
        
        # uint32_t move = num >> 1;
        srli t3, t2, 1
        
        # uint32_t additional_move = num & 1;
        andi t4, t2, 1
        
        li t5, 0
        
loop_start:
        # if (i >= move) break
        bge t5, t3, loop_end    
        
        # rev = (rev << 1) + (N & 1);
        slli t1, t1, 1
        andi t6, t0, 1
        add t1, t1, t6
        
        # N = N >> 1;
        srli t0, t0, 1
        
        # i++
        addi t5, t5, 1
        
        # jump to loop start   
        j loop_start 

loop_end:
        # N = N >> additional_move;
        srl t0, t0, t4
        
        # return N == rev;
        sub t6, t0, t1
        sltiu a0, t6, 1
        ret
        