.data
    test_1:   .word 0x0000FFFF
    test_2:   .word 0x00000710
    test_3:   .word 0x000080F3        
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
        jal ra, fp16_to_fp32
        li a7, 1
        ecall
        
        # print "result2 is  " 
        la a0, str2
        li a7, 4
        ecall
        # print fp16_to_fp32(test2)  
        lw  a0, test_2           
        jal ra, fp16_to_fp32   
        li a7, 1
        ecall
        
        # print "result3 is  " 
        la a0, str3
        li a7, 4
        ecall
        # print fp16_to_fp32(test3)  
        lw  a0, test_3           
        jal ra, fp16_to_fp32
        li a7, 1
        ecall
        
        # Exit the program
        li a7, 10                  # System call code for exiting the program
        ecall                      # Make the exit system call

fp16_to_fp32:
        # a0 is the input parameter h
        # t0 is w
        # t1 is sign
        # t2 is nosign
        
        # const uint32_t w = (uint32_t) h << 16; 
        slli t0, a0, 16
        # const uint32_t sign = w & UINT32_C(0x80000000);     
        li t1, 0x80000000
        and t1, t0, t1
        # const uint32_t nonsign = w & UINT32_C(0x7FFFFFFF);     
        li t2, 0x7FFFFFFF
        and t2, t0, t2

my_clz:
        # t3 is the input parameter x   
        # t4 is c
        # t5 is r  
        mv t3, t2
        
        # int r = 0, c;    
        li t5, 0
        
        # c = (x < 0x00010000) << 4;
        li t4 0x00010000
        sltu t4, t3, t4
        slli t4, t4, 4
        # r += c;           
        add t5, t5, t4
        # x <<= c       
        sll t3, t3, t4
        
        # c = (x < 0x01000000) << 3;    
        li t4 0x01000000
        sltu t4, t3, t4
        slli t4, t4, 3
        # r += c;         
        add t5, t5, t4
        # x <<= c          
        sll t3, t3, t4
          
        # c = (x < 0x10000000) << 2;   
        li t4 0x10000000
        sltu t4, t3, t4
        slli t4, t4, 2
        # r += c;         
        add t5, t5, t4
        # x <<= c         
        sll t3, t3, t4
        
        # c = (x < 0x40000000) << 1;
        li t4 0x40000000
        sltu t4, t3, t4
        slli t4, t4, 1
        # r += c;         
        add t5, t5, t4
        # x <<= c       
        sll t3, t3, t4
        
        # c = x < 0x80000000;
        li t4 0x80000000
        sltu t4, t3, t4
        # r += c; 
        add t5, t5, t4
        # x <<= c               
        sll t3, t3, t4
        
        # r += x == 0;
        seqz t3, t3
        add t5, t5, t3
        
back_to_fp16_to_fp32:
        # t0, t3, t4 can be reused
        # t5 is renorm_shift
        
        # renorm_shift = renorm_shift > 5 ? renorm_shift - 5 : 0;
        li t0, 5
        bgtu t5, t0, renorm_shift_minus_five
        j renorm_shift_is_zero

renorm_shift_minus_five:
        sub t5, t5, t0
        j continue_fp16_to_fp32

renorm_shift_is_zero:
        li t5, 0
        
continue_fp16_to_fp32:
        # t3 is inf_nan_mask
        # t4 is zero_mask
        # t0 is temp1
        # t6 is temp2
        
        # const int32_t inf_nan_mask = ((int32_t)(nonsign + 0x04000000) >> 8) & INT32_C(0x7F800000);
        li t0, 0x04000000
        add t3, t2, t0
        srai t3, t3, 8
        li t0, 0x7F800000
        and t3, t3, t0
        
        # const int32_t zero_mask = (int32_t)(nonsign - 1) >> 31;
        addi t4, t2, -1
        srai t4, t4, 31
        
        # return sign | ((((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)) | inf_nan_mask) & ~zero_mask);
        # temp1 = (nonsign << renorm_shift >> 3)
        sll t0, t2, t5
        srli t0, t0, 3
        # temp2 = ((0x70 - renorm_shift) << 23)
        li t6, 0x70
        sub t6, t6, t5
        slli t6, t6, 23
        # temp1 = temp1 + temp2
        add t0, t0, t6
        # temp1 = temp1 | inf_nan_mask
        or t0, t0, t3
        # temp1 = temp1 & ~zero_mask
        not t4, t4
        and t0, t0, t4
        # temp1 = sign | temp1
        or t0, t1, t0         
        # return temp1
        mv a0, t0
        
        ret