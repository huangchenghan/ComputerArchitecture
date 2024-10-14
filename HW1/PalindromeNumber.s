.data
    test_1:   .word 0x0F00000F
    test_2:   .word 0x0000001B
    test_3:   .word 0x00000002      
    str1:     .string "\nresult1 is  " 
    str2:     .string "\nresult2 is  " 
    str3:     .string "\nresult3 is  "  
    
.text
main:
        # print "result1 is  " 
        la a0, str1
        li a7, 4
        ecall
        # print fp16_to_fp32(test1)  
        lw  a0, test_1           
        jal ra, my_clz
        li a7, 1
        ecall
        
        # print "result2 is  " 
        la a0, str2
        li a7, 4
        ecall
        # print fp16_to_fp32(test2)  
        lw  a0, test_2           
        jal ra, my_clz   
        li a7, 1
        ecall
        
        # print "result3 is  " 
        la a0, str3
        li a7, 4
        ecall
        # print fp16_to_fp32(test3)  
        lw  a0, test_3           
        jal ra, my_clz
        li a7, 1
        ecall
        
        # Exit the program
        li a7, 10                  # System call code for exiting the program
        ecall                      # Make the exit system call

my_clz:
        # t0 is the input parameter x
        # t1 is c
        # t2 is r
        mv t0, a0
        
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
        
        
checkPalindrome:
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
        