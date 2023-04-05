#include <math.h>
#include <stdio.h>
#include <stdlib.h>

// #define SDS
// image file out function
void image_out(char *file_name, int file_size, unsigned char *img_ptr, unsigned char gray);

// Function(for Hardware)
#ifdef SDS
  #pragma SDS data copy (img_in[0:1105920], img_out[0:1105920])
  #pragma SDS data access_pattern(img_in:SEQUENTIAL, img_out:SEQUENTIAL)
#endif
void img_blgt(unsigned char *img_in, unsigned char *img_out, short blgt_ofst);
//void img_blgt(int file_size, unsigned char *img_in, unsigned char *img_out, short blgt_ofst);

#ifdef SDS
  #pragma SDS data copy (img_in[0:1105920], img_out[0:1105920])
  #pragma SDS data access_pattern(img_in:SEQUENTIAL, img_out:SEQUENTIAL)
#endif
void img_flip(int file_size, unsigned char *img_in, unsigned char *img_out) ;

#ifdef SDS
  #pragma SDS data copy (img_in[0:1105920], img_out_gray[0:368640])
  #pragma SDS data access_pattern(img_in:SEQUENTIAL, img_out_gray:SEQUENTIAL)
#endif
void img_gray(int file_size, unsigned char *img_in, unsigned char *img_out_gray);

#ifdef SDS
  #pragma SDS data copy (img_in_gray[0:368640], img_out_gray[0:368640])
  #pragma SDS data access_pattern(img_in_gray:SEQUENTIAL, img_out_gray:SEQUENTIAL)
#endif
void img_noise(int file_size, unsigned char *img_in_gray, unsigned char *img_out_gray);

#ifdef SDS
  #pragma SDS data copy (img_in_gray[0:368640], img_out_gray[0:368640])
  #pragma SDS data access_pattern(img_in_gray:SEQUENTIAL, img_out_gray:SEQUENTIAL)
#endif
void img_edge(unsigned char *img_in_gray, unsigned char *img_out_gray);


int main (int argc, char *argv[]) {
	FILE *fp ;
    unsigned char *img_ptrA, *img_ptrB ;
    int size, i;

    // image file input(binary ppm) "xxx.bin"
    fp = fopen( argv[1], "rb" );
    if( fp == NULL ){
       printf( "%s is not open!\n", argv[1]);
       return 0;
    }

    // malloc - ensure memory "image"
    img_ptrA = (unsigned char *) malloc(768*480*3);
    if(img_ptrA == NULL){
        printf("Can not malloc.");
        exit(EXIT_FAILURE);
    }
    img_ptrB = (unsigned char *) malloc(768*480*3);
    if(img_ptrB == NULL){
        printf("Can not malloc.");
        exit(EXIT_FAILURE);
    }
    size = fread(img_ptrA, sizeof(unsigned char), 768*480*3,fp);

    // Original Image Out
    image_out("0_out_image.ppm", size, img_ptrA, 0) ;

    /********************/
    // 1.輝度を上げるよ
    // img_blgt();
    /********************/
    //img_blgt(size, img_ptrA, img_ptrB, 40) ;
    img_blgt(img_ptrA, img_ptrB, 40) ;

    // Write Out
    image_out("1_out_image_kido.ppm", size, img_ptrB, 0) ;


    /********************/
    // 2.左右反転するよ。
    // img_flip();
    /********************/
    img_flip(size, img_ptrB, img_ptrA) ;

    // Write Out
    image_out("2_out_image_flip.ppm", size, img_ptrA, 0) ;

    /********************/
    // 3.グレースケール化するよ。
    // img_gray();
    /********************/
    unsigned char *img_ptr_grayA, *img_ptr_grayB ;
    // malloc
    img_ptr_grayA = (unsigned char *) malloc(768*480);
    if(img_ptr_grayA == NULL){
        printf("Can not malloc.");
        exit(EXIT_FAILURE);
    }
    img_ptr_grayB = (unsigned char *) malloc(768*480);
    if(img_ptr_grayB == NULL){
        printf("Can not malloc.");
        exit(EXIT_FAILURE);
    }

    img_gray(768*480, img_ptrA, img_ptr_grayA) ;

    free(img_ptrA);
    free(img_ptrB);

    // Write Out
    image_out("3_out_image_gray.ppm", 768*480, img_ptr_grayA, 1);


    /********************/
    // 4.ノイズリダクションするよ。
    //   (Median Filter)
    // img_noise();
    //
    // sort_list[8]
    //  0 1 2
    //  3 X 4
    //  5 6 7
    /********************/
    img_noise(768*480, img_ptr_grayA, img_ptr_grayB) ;

    // Write out
    image_out("4_out_image_noise.ppm", 768*480, img_ptr_grayB, 1);


    /********************/
    // 5.エッジ抽出するよ。
    // img_edge();
    //
    // sort_list[8]
    //  0 1 2
    //  3 X 4
    //  5 6 7
    /********************/
    img_edge(img_ptr_grayB, img_ptr_grayA);

    //Write out
    image_out("5_out_image_edge.ppm", 768*480, img_ptr_grayA, 1);

    free(img_ptr_grayA);
    free(img_ptr_grayB);
    fclose(fp);
    return 0;
}

void image_out (char *file_name, int file_size, unsigned char *img_ptr, unsigned char gray) {
    FILE *fp_out ;
    unsigned char rgb_num ;
    int i ;

    fp_out = fopen( file_name, "w") ;
    if(fp_out==NULL) {
        printf("%s ファイルが開けません\n", file_name) ;
        exit ;
    }
    rgb_num = 0 ;
    fprintf(fp_out, "P3\n# Created by IrfanView\n768 480\n255\n");

    if(gray == 1) {
        for( i=0; i<file_size; i++ ){
                fprintf(fp_out, "%2d ",  *(img_ptr+i));
                fprintf(fp_out, "%2d ",  *(img_ptr+i));
                fprintf(fp_out, "%2d\n", *(img_ptr+i));
        }
    } else {
        for( i=0; i<file_size; i++ ){
            if(rgb_num==2){
                fprintf(fp_out, "%2d\n", *(img_ptr+i) );
                rgb_num = 0 ;
            } else {
                fprintf(fp_out, "%2d ", *(img_ptr+i) );
                rgb_num++ ;
            }
        }
    }

    fclose(fp_out);
}

//void img_blgt(int file_size, unsigned char *img_in, unsigned char *img_out, short blgt_ofst) {
void img_blgt(unsigned char *img_in, unsigned char *img_out, short blgt_ofst) {
    short tmp_val ;
    int i ;

    //    for( i=0; i<file_size; i++ ){
    for( i=0; i<1105920; i++ ){
        tmp_val = (short)(*(img_in+i)) + blgt_ofst ;
        if(tmp_val > 255) {
            tmp_val = 255 ;
        } else if(tmp_val < 0) {
            tmp_val = 0 ;
        }
        *(img_out+i) = (unsigned char) tmp_val ;
    }
}

void img_flip (int file_size, unsigned char *img_in, unsigned char *img_out) {
    unsigned char line_buff[2304] ;
    short v_cnt, h_cnt;
    int hv_ptr;

    hv_ptr=0;

    for(v_cnt=0; v_cnt<480; v_cnt++){
        for(h_cnt=0; h_cnt<768*3; h_cnt++){
            line_buff[h_cnt] = *(img_in + hv_ptr + h_cnt) ;
        }
        for(h_cnt=0; h_cnt<768; h_cnt++){
            *(img_out + hv_ptr + (h_cnt*3))   = line_buff[(768*3-1) - (h_cnt*3) - 2] ; // R
            *(img_out + hv_ptr + (h_cnt*3)+1) = line_buff[(768*3-1) - (h_cnt*3) - 1] ; // G
            *(img_out + hv_ptr + (h_cnt*3)+2) = line_buff[(768*3-1) - (h_cnt*3)] ;     // B
        }

        hv_ptr += 768*3 ;
    }
}

void img_gray (int file_size, unsigned char *img_in, unsigned char *img_out_gray) {

    short v_cnt, h_cnt;
    int hv_ptr;
    float val_y, tmp_r, tmp_g, tmp_b, val_gray ;
    hv_ptr = 0 ;
    for(v_cnt=0; v_cnt<480; v_cnt++) {
        for(h_cnt=0; h_cnt<768; h_cnt++) {
           // RGB->YUV
           tmp_r = (float)(*(img_in+(h_cnt*3)+hv_ptr  )) * 0.257 ;
           tmp_g = (float)(*(img_in+(h_cnt*3)+hv_ptr+1)) * 0.504 ;
           tmp_b = (float)(*(img_in+(h_cnt*3)+hv_ptr+2)) * 0.098 ;
           val_y = tmp_r + tmp_g + tmp_b + 16 ;
           if(val_y > 255) {
               val_y = 255 ;
           } else if(val_y < 0) {
               val_y = 0 ;
           }
           // YUV->RGB
           val_gray = (val_y-16) * 1.164 ;
           if(val_gray > 255) {
               val_gray = 255 ;
           } else if(val_gray < 0) {
               val_gray = 0 ;
           }
           *(img_out_gray + hv_ptr/3 + h_cnt) = (unsigned char)val_gray ;
        }

        hv_ptr += 768*3 ;
    }
}

void img_noise (int file_size, unsigned char *img_in_gray, unsigned char *img_out_gray) {

    short v_cnt, h_cnt;
    int hv_ptr;
    unsigned char sort_list[8], tmp_data ;
    char b_cnt1, b_cnt2 ;
    hv_ptr = 0 ;
    for(v_cnt=0; v_cnt<480; v_cnt++) {
        for(h_cnt=0; h_cnt<768; h_cnt++) {
            if((v_cnt != 0  )&&(h_cnt !=0 )&&
               (v_cnt != 479)&&(h_cnt!=767)) { // 8cell pattern
               sort_list[0] = *(img_in_gray + hv_ptr + h_cnt - 768 - 1);
               sort_list[1] = *(img_in_gray + hv_ptr + h_cnt - 768    );
               sort_list[2] = *(img_in_gray + hv_ptr + h_cnt - 768 + 1);
               sort_list[3] = *(img_in_gray + hv_ptr + h_cnt - 1      );
               sort_list[4] = *(img_in_gray + hv_ptr + h_cnt + 1      );
               sort_list[5] = *(img_in_gray + hv_ptr + h_cnt + 768 - 1);
               sort_list[6] = *(img_in_gray + hv_ptr + h_cnt + 768    );
               sort_list[7] = *(img_in_gray + hv_ptr + h_cnt + 768 + 1);
               tmp_data = 0 ;

               for(b_cnt1=0; b_cnt1<7; b_cnt1++){
                   for(b_cnt2=7; b_cnt2>b_cnt1; b_cnt2--){
                       if(sort_list[b_cnt2] < sort_list[b_cnt2-1]){
                           tmp_data            = sort_list[b_cnt2];
                           sort_list[b_cnt2]   = sort_list[b_cnt2-1];
                           sort_list[b_cnt2-1] = tmp_data;
                       }
                   }
               }
               *(img_out_gray + hv_ptr + h_cnt) = sort_list[3] ;
            }
        }
        hv_ptr += 768 ;
    }
}

void img_edge(unsigned char *img_in_gray, unsigned char *img_out_gray) {
    short v_cnt, h_cnt;
    int hv_ptr;
    double val_lx, val_ly ;
    double deg ;
    unsigned char sort_list[8];

    hv_ptr = 0 ;
    for(v_cnt=0; v_cnt<480; v_cnt++) {
        for(h_cnt=0; h_cnt<768; h_cnt++) {
            if((v_cnt != 0  )&&(h_cnt !=0 )&&
               (v_cnt != 479)&&(h_cnt!=767)) { // 8cell pattern
               sort_list[0] = *(img_in_gray + hv_ptr + h_cnt - 768 - 1);
               sort_list[1] = *(img_in_gray + hv_ptr + h_cnt - 768    );
               sort_list[2] = *(img_in_gray + hv_ptr + h_cnt - 768 + 1);
               sort_list[3] = *(img_in_gray + hv_ptr + h_cnt - 1      );
               sort_list[4] = *(img_in_gray + hv_ptr + h_cnt + 1      );
               sort_list[5] = *(img_in_gray + hv_ptr + h_cnt + 768 - 1);
               sort_list[6] = *(img_in_gray + hv_ptr + h_cnt + 768    );
               sort_list[7] = *(img_in_gray + hv_ptr + h_cnt + 768 + 1);

               val_lx = sort_list[4]/2 - sort_list[3]/2 ;
               val_ly = sort_list[6]/2 - sort_list[1]/2 ;
               deg = atan2(val_ly, val_lx) ;
               deg = deg / M_PI * 255 ;
               deg = abs(deg);
               if(deg<0){
                   deg=0;
               } else if(deg>255){
                   deg=255;
               }

               *(img_out_gray + hv_ptr + h_cnt) = (unsigned char) deg ;
            } else {
               *(img_out_gray + hv_ptr + h_cnt) = *(img_in_gray + hv_ptr + h_cnt) ;
            }
        }
        hv_ptr += 768 ;
    }
}
