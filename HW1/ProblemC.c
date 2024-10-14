#include <stdio.h>
#include <stdint.h>

static inline int my_clz(uint32_t x) {
    int r = 0, c;
    c = (x < 0x00010000) << 4;  //If the first 16 bits are all 0, c = 16 | If the first 16 bits are not all 0, c = 0
    r += c;                     // r += 16 | r += 0
    x <<= c;                    // x <<= 16 | x <<= 0
    c = (x < 0x01000000) << 3;  //If the first 8 bits are all 0, c = 8 | If the first 16 bits are not all 0, c = 0
    r += c;                     // r += 8 | r += 0
    x <<= c;                    // x <<= 8 | x <<= 0
    c = (x < 0x10000000) << 2;  //If the first 4 bits are all 0, c = 4 | If the first 16 bits are not all 0, c = 0
    r += c;                     // r += 4 | r += 0
    x <<= c;                    // x <<= 4 | x <<= 0
    c = (x < 0x40000000) << 1;  //If the first 2 bits are all 0, c = 2 | If the first 16 bits are not all 0, c = 0
    r += c;                     // r += 2 | r += 0
    x <<= c;                    // x <<= 2 | x <<= 0
    c = x < 0x80000000;         //If the first 1 bits are all 0, c = 1 | If the first 16 bits are not all 0, c = 0
    r += c;                     // r += 1 | r += 0
    x <<= c;                    // x <<= 1 | x <<= 0
    r += x == 0;
    return r;
}

static inline uint32_t fp16_to_fp32(uint16_t h) {

    const uint32_t w = (uint32_t) h << 16;
    
    const uint32_t sign = w & UINT32_C(0x80000000);
    
    const uint32_t nonsign = w & UINT32_C(0x7FFFFFFF);
    
    uint32_t renorm_shift = my_clz(nonsign);
    renorm_shift = renorm_shift > 5 ? renorm_shift - 5 : 0;
    
    const int32_t inf_nan_mask = ((int32_t)(nonsign + 0x04000000) >> 8) &
                                 INT32_C(0x7F800000);
    
    const int32_t zero_mask = (int32_t)(nonsign - 1) >> 31;
    
    return sign | ((((nonsign << renorm_shift >> 3) +
            ((0x70 - renorm_shift) << 23)) | inf_nan_mask) & ~zero_mask);
}

int main()
{
    printf("fp16_to_fp32(0x0618) is : 0x%x\n", fp16_to_fp32(0x0618));  // normalized number
    printf("fp16_to_fp32(0x000F) is : 0x%x\n", fp16_to_fp32(0x000F));  // denormalized number
    printf("fp16_to_fp32(0x0000) is : 0x%x\n", fp16_to_fp32(0x0000));  // positive zero
    printf("fp16_to_fp32(0x8000) is : 0x%x\n", fp16_to_fp32(0x8000));  // negative zero
    printf("fp16_to_fp32(0x7C00) is : 0x%x\n", fp16_to_fp32(0x7C00));  //positive infinity
    printf("fp16_to_fp32(0xFC00) is : 0x%x\n", fp16_to_fp32(0xFC00));  //negative infinity
    printf("fp16_to_fp32(0x7CFF) is : 0x%x\n", fp16_to_fp32(0x7CFF));  // NaN, Not a Number
}