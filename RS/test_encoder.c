#include <stdio.h>
#include <stdlib.h>
#include "jerasure.h"
#include "reed_sol.h"

#include "gf_complete.h"
#include "gf_rand.h"
#include "gf_method.h"

int k,m,w;
FILE* fp_blue,*fp_orange,*fp_pink,*fp_coding1,*fp_coding2,*fp_coding3;
int size = 998574;
char* blue,*orange,*pink;
char** data;
char** coding;
char** recon;
int* matrix;

int* erasures;
int* erased;
uint16_t char2short(char a, char b){
    return (((uint16_t)a) << 8) + (uint8_t)b;
}
void open_files(){
    fp_blue = fopen("blue.bmp","rb");
    fp_orange = fopen("orange.bmp","rb");
    fp_pink = fopen("pink.bmp","rb");
    fp_coding1 = fopen("coding1.bmp","wb");
    fp_coding2 = fopen("coding2.bmp","wb");
    fp_coding3 = fopen("coding3.bmp","wb");
}

void read_data(){
    blue = (char*)malloc(sizeof(char)*size);
    fgets(blue,size,fp_blue);
    printf("blue: %d ",blue[0]);
    printf("%d ",blue[1]);
    printf("%d \n\n",char2short(blue[0],blue[1]));
    orange = (char*)malloc(sizeof(char)*size);
    fgets(orange,size,fp_orange);
    printf("orange: %d ",orange[0]);
    printf("%d ",orange[1]);
    printf("%d \n\n",char2short(orange[0],orange[1]));

    pink = (char*)malloc(sizeof(char)*size);
    fgets(pink,size,fp_pink);
    printf("pink: %d ",pink[0]);
    printf("%d ",pink[1]);
    printf("%d \n\n",char2short(pink[0],pink[1]));
}
void prepare_ec(){
    matrix = reed_sol_vandermonde_coding_matrix(k,m,w);

    data = (char **)malloc(sizeof(char*)*k);
	coding = (char **)malloc(sizeof(char*)*m);
	recon = (char **)malloc(sizeof(char*)*k);
    data[0] = blue;
    data[1] = orange;
    data[2] = pink;
    int i = 0;
    for(i = 0;i < m;i++){
        coding[i] = (char*)malloc(sizeof(char)*size);
    }
    for(i = 0;i < m;i++){
        recon[i] = (char*)malloc(sizeof(char)*size);
    }
    erasures = malloc(sizeof(int)*k);
    erasures[0] = 0;
    erasures[1] = 1;
    erasures[2] = 2;
    erased = malloc(sizeof(int)*(k+m));
    erased[0] = 1;
    erased[1] = 1;
    erased[2] = 1;
    erased[3] = 0;
    erased[4] = 0;
    erased[5] = 0;
}
void write_files(){
    fwrite(coding[0],sizeof(char),size,fp_coding1);
    fwrite(coding[1],sizeof(char),size,fp_coding2);
    fwrite(coding[2],sizeof(char),size,fp_coding3);
}
void close_files(){
    fclose(fp_coding1);
    fclose(fp_coding2);
    fclose(fp_coding3);
    fclose(fp_blue);
    fclose(fp_orange);
    fclose(fp_pink);
}
uint16_t* log_table;
uint16_t* ilog_table;
uint16_t mult(uint16_t a, uint16_t b){
    if( a ==0 || b == 0) return 0;
    uint32_t loga = log_table[a];
    uint32_t logb = log_table[b];
    uint32_t logc = loga + logb;
    return ilog_table[logc];
}



int main(int argc, char **argv){
    k = 3;m = 3;w = 16;int i;
    gf_t gf;
    printf("%d\n",argc);
    gf_init_easy(&gf, w);
    galois_change_technique(&gf, w); 

    log_table = gf_w16_get_log_table(&gf);
    ilog_table = gf_w16_get_mult_alog_table(&gf);


    open_files();
    read_data();
    prepare_ec();


    //jerasure_matrix_encode(k, m, w, matrix, data, coding, size);

    /*
    int* src_id = malloc(sizeof(int)*k);
    src_id[0] = 0;
    src_id[1] = 1;
    src_id[2] = 2;
    jerasure_matrix_dotprod(k,w,matrix,src_id,3,data,coding,size);
    jerasure_matrix_dotprod(k,w,matrix+3,src_id,4,data,coding,size);
    jerasure_matrix_dotprod(k,w,matrix+6,src_id,5,data,coding,size);
    // fwrite(coding[0],sizeof(char),size,fp_coding1); 
    // fwrite(coding[1],sizeof(char),size,fp_coding2); 
    // fwrite(coding[2],sizeof(char),size,fp_coding3); 
    */
    //manual encode
    
    
    for(i = 0;i < size;i+=2){
        uint16_t res = mult(matrix[0],char2short(blue[i],blue[i+1])) ^ 
        mult(matrix[1],char2short(orange[i],orange[i+1])) ^ 
        mult(matrix[2],char2short(pink[i],pink[i+1]));
        coding[0][i] = (char)(res >> 8);
        coding[0][i+1] = (char)(res & 0xFF);
    }
    for(i = 0;i < size;i+=2){
        uint16_t res = mult(matrix[3],char2short(blue[i],blue[i+1])) ^ 
        mult(matrix[4],char2short(orange[i],orange[i+1])) ^ 
        mult(matrix[5],char2short(pink[i],pink[i+1]));
        coding[1][i] = (char)(res >> 8);
        coding[1][i+1] = (char)(res & 0xFF);
    }
    for(i = 0;i < size;i+=2){
        uint16_t res = mult(matrix[6],char2short(blue[i],blue[i+1])) ^ 
        mult(matrix[7],char2short(orange[i],orange[i+1])) ^ 
        mult(matrix[8],char2short(pink[i],pink[i+1]));
        coding[2][i] = (char)(res >> 8);
        coding[2][i+1] = (char)(res & 0xFF);
    }
    fwrite(coding[0],sizeof(char),size,fp_coding1); 
    fwrite(coding[1],sizeof(char),size,fp_coding2); 
    fwrite(coding[2],sizeof(char),size,fp_coding3); 
    
   



    jerasure_print_matrix(matrix,k,k,w);
    int* decoding_matrix = malloc(sizeof(int)*k*k);
    int* dm_ids = malloc(sizeof(int)*k);
    //jerasure_invert_matrix(matrix,decoding_matrix,k,w);
    jerasure_make_decoding_matrix(k,m,w,matrix,erased,decoding_matrix,dm_ids);
    jerasure_print_matrix(decoding_matrix,k,k,w);
    /*
    int* src_id = malloc(sizeof(int)*k);
    src_id[0] = 3;
    src_id[1] = 4;
    src_id[2] = 5;
    jerasure_matrix_dotprod(k,w,decoding_matrix,src_id,0,recon,coding,size);
    */
    //manual decode
    for(i = 0;i < size;i+=2){
        /* 
        printf("%d ", coding[0][i]);
        printf("%d ", coding[0][i+1]);
        printf("%d \n",char2short(coding[0][i],coding[0][i+1]));
        printf("%d ", coding[1][i]);
        printf("%d ", coding[1][i+1]);
        printf("%d \n",char2short(coding[1][i],coding[1][i+1]));
        printf("%d ", coding[2][i]);
        printf("%d ", coding[2][i+1]);
        
        printf("%d \n\n",char2short(coding[2][i],coding[2][i+1]));
        */ 
        uint16_t res = mult(decoding_matrix[0],char2short(coding[0][i],coding[0][i+1])) ^ 
        mult(decoding_matrix[1],char2short(coding[1][i],coding[1][i+1])) ^ 
        mult(decoding_matrix[2],char2short(coding[2][i],coding[2][i+1])); 
        recon[0][i] = (char)(res >> 8);
        recon[0][i+1] =  (char)(res & 0xFF);
        /* 
        printf("%d ", recon[0][i]);
        printf("%d \n", blue[i]);
        printf("%d ", recon[0][i+1]);
        printf("%d \n\n", blue[i+1]);
        */
        
        
    }
    fwrite(recon[0],sizeof(char),size,fp_coding1);


    uint16_t res = mult(1,16973) ^ mult(24578,16973) ^ mult(40964,16973);
    //res = mult(48563,16973) ^ mult(48564,42509) ^ mult(6,0);
    printf("res: %d\n",(char)(res >> 8));
    printf("res: %d\n",(char)(res & 0xFF));
    char a = 12;
    char b = 167;
    printf("res: %d\n",char2short(a,b));

    //write_files();
    close_files();
    return 0;
}