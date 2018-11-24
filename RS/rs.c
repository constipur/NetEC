#include "stdio.h"
#include "stdlib.h"
unsigned int prim_poly_4 = 023;
unsigned int prim_poly_8 = 0435;
unsigned int prim_poly_16 = 0210013;
unsigned short *gflog, *gfilog;
int setup_tables(int w)
{
    unsigned int b, log, x_to_w, prim_poly;
    switch(w) {
        case 4: prim_poly = prim_poly_4; break;
        case 8: prim_poly = prim_poly_8; break;
        case 16: prim_poly = prim_poly_16; break;
        default: return -1;
    }
    x_to_w = 1 << w;
    gflog = (unsigned short *) malloc (sizeof(unsigned short) * x_to_w);
    gfilog = (unsigned short *) malloc (sizeof(unsigned short) * x_to_w);
    b = 1;
    for (log = 0; log < x_to_w-1; log++) {
        gflog[b] = (unsigned short) log;
        gfilog[log] = (unsigned short) b;
        b = b << 1;
        if (b & x_to_w) b = b ^ prim_poly;
    }
    return 0;
}

int main()
{
    int w = 8;
    setup_tables(w);
    int i = 0;
    for(i = 0;i < (1 << w);i++){
        printf("%d ",gflog[i]);
    }
    printf("\n");
    i = 0;
    for(i = 0;i < (1 << w);i++){
        printf("%d ",gfilog[i]);
    }
    printf("\n");
}