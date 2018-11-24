/*
 * GF-Complete: A Comprehensive Open Source Library for Galois Field Arithmetic
 * James S. Plank, Ethan L. Miller, Kevin M. Greenan,
 * Benjamin A. Arnold, John A. Burnum, Adam W. Disney, Allen C. McBride.
 *
 * gf_example_1.c
 *
 * Demonstrates using the procedures for examples in GF(2^w) for w <= 32.
 */

#include <stdio.h>
#include <getopt.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "gf_complete.h"
#include "gf_rand.h"
#include "gf_method.h"

void usage(char *s)
{
  fprintf(stderr, "usage: gf_example_1 w - w must be between 1 and 32\n");
  exit(1);
}

int main(int argc, char **argv)
{
  uint32_t a, b, c;
  int w = 16;
  gf_t gf;
  //printf("%d\n",argc);
  gf_init_easy(&gf, w);
  //create_gf_from_argv(&gf, w, argc, argv, 1);

  uint16_t* log_table = malloc(1<<w);
  log_table = gf_w16_get_log_table(&gf);
  int i = 0;
  for(i = 0;i < (1<<w) *2;i++){
    printf("%u\n",log_table[i]);
  }
  return 0;
  
  uint16_t* ilog_table = malloc(1<<w);
  ilog_table = gf_w16_get_mult_alog_table(&gf);
  printf("%u\n",sizeof(ilog_table));

  /* And multiply a and b using the galois field: */

  //a = atoi(argv[1]);
  //b = atoi(argv[2]);
  int count = 0; 
  for(a = 1;a < 65536;a++){
    printf("%u\n",a);
    for(b = 1;b < 65536;b++){
    uint32_t loga = log_table[a];
    uint32_t logb = log_table[b];
    uint32_t logc = loga + logb;
    c = gf.multiply.w32(&gf, a, b);
  //c = GF_W16_INLINE_MULT(log, alog, a, b );
    //printf("c = %u\n",c);
  
  
  //if(logc > 65536) printf("overflow?");
  uint16_t i_c = ilog_table[logc]; 
  //printf("i_c = %u\n",i_c);

  uint16_t macro_c = GF_W16_INLINE_MULT(log_table, ilog_table, a, b );
  //printf("macro c = %u\n",macro_c);
    if(c != i_c || i_c != macro_c){
      printf("warning, count = %d\n",count++);
      printf("c = %u\n",c);
      printf("i_c = %u\n",i_c);
      printf("macro_c = %u\n",macro_c);
    }
    }
  }
  /*
  int i = 0;
  for(i = 0;i < 1<<w ;i++){
    printf("%u\n",ilog_table[i]);
  }
  */


  
  exit(0);
}
