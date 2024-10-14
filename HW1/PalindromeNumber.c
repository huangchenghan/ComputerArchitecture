#include <stdio.h>
#include <stdint.h>

uint32_t my_clz(uint32_t x) {
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

int checkPalindrome(uint32_t N)
{
    // Stores the reverse of N
    uint32_t rev = 0;

    uint32_t num = 32 - my_clz(N);
    uint32_t move = num >> 1;
    uint32_t additional_move = num & 1;
 
    for(int i = 0; i < move; i++)
    {
        rev = (rev << 1) + (N & 1);
        N = N >> 1;
    }
    N = N >> additional_move;
 
    return N == rev;
}

int main()
{
    uint32_t N1 = 0x0F00000F;
    printf("result1 is : %d\n", checkPalindrome(N1));
    uint32_t N2 = 0x0000001B;
    printf("result2 is : %d\n", checkPalindrome(N2));
    uint32_t N3 = 0x00000002;
    printf("result3 is : %d\n", checkPalindrome(N3));
}