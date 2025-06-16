#include <stdio.h>

int main() { 
    int a = 10;
    int b = 20;

    int *p1 = &a;
    int *p2 = &b;

    // NON-COMPLIANT: Adding pointers
    int *p3 = p1 + p2;
    
    printf("Hello, TICS!\n");
    return 0;
}
