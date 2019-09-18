#include <stdio.h>

int main()
{
	FILE *tst3_dac_in_32x32_ch1;
	FILE *tst3_dac_in_32x32_ch2;
	FILE *tst3_dac_in_32x32_ch3;
	FILE *tst3_dac_in_32x32_ch4;
	FILE *tst3_dac_in_32x32_ch5;
	FILE *tst3_dac_in_32x32_ch6;
	FILE *tst3_dac_in_32x32_ch7;
	FILE *tst3_dac_in_32x32_ch8;
    FILE *tst3_dac_coe_32x2048;
	FILE *tst3_dac_out_32x2048_ch1;
	FILE *tst3_dac_out_32x2048_ch2;
	FILE *tst3_dac_out_32x2048_ch3;
	FILE *tst3_dac_out_32x2048_ch4;
	FILE *tst3_dac_out_32x2048_ch5;
	FILE *tst3_dac_out_32x2048_ch6;
	FILE *tst3_dac_out_32x2048_ch7;
	FILE *tst3_dac_out_32x2048_ch8;
    FILE *tst3_adc_coe_2048x64;
	FILE *tst3_adc_out_32x64_ch1;
	FILE *tst3_adc_out_32x64_ch2;
	FILE *tst3_adc_out_32x64_ch3;
	FILE *tst3_adc_out_32x64_ch4;
	FILE *tst3_adc_out_32x64_ch5;
	FILE *tst3_adc_out_32x64_ch6;
	FILE *tst3_adc_out_32x64_ch7;
	FILE *tst3_adc_out_32x64_ch8;

    tst3_dac_in_32x32_ch1    = fopen("tst3_dac_in_32x32_ch1.csv", "w");
    tst3_dac_in_32x32_ch2    = fopen("tst3_dac_in_32x32_ch2.csv", "w");
    tst3_dac_in_32x32_ch3    = fopen("tst3_dac_in_32x32_ch3.csv", "w");
    tst3_dac_in_32x32_ch4    = fopen("tst3_dac_in_32x32_ch4.csv", "w");
    tst3_dac_in_32x32_ch5    = fopen("tst3_dac_in_32x32_ch5.csv", "w");
    tst3_dac_in_32x32_ch6    = fopen("tst3_dac_in_32x32_ch6.csv", "w");
    tst3_dac_in_32x32_ch7    = fopen("tst3_dac_in_32x32_ch7.csv", "w");
    tst3_dac_in_32x32_ch8    = fopen("tst3_dac_in_32x32_ch8.csv", "w");
    tst3_dac_coe_32x2048     = fopen("tst3_dac_coe_32x2048.csv",  "w");
    tst3_dac_out_32x2048_ch1 = fopen("tst3_dac_out_32x2048_ch1.csv", "w");
    tst3_dac_out_32x2048_ch2 = fopen("tst3_dac_out_32x2048_ch2.csv", "w");
    tst3_dac_out_32x2048_ch3 = fopen("tst3_dac_out_32x2048_ch3.csv", "w");
    tst3_dac_out_32x2048_ch4 = fopen("tst3_dac_out_32x2048_ch4.csv", "w");
    tst3_dac_out_32x2048_ch5 = fopen("tst3_dac_out_32x2048_ch5.csv", "w");
    tst3_dac_out_32x2048_ch6 = fopen("tst3_dac_out_32x2048_ch6.csv", "w");
    tst3_dac_out_32x2048_ch7 = fopen("tst3_dac_out_32x2048_ch7.csv", "w");
    tst3_dac_out_32x2048_ch8 = fopen("tst3_dac_out_32x2048_ch8.csv", "w");
    tst3_adc_coe_2048x64    = fopen("tst3_adc_coe_2048x64.csv", "w");
    tst3_adc_out_32x64_ch1  = fopen("tst3_adc_out_32x64_ch1.csv", "w");
    tst3_adc_out_32x64_ch2  = fopen("tst3_adc_out_32x64_ch2.csv", "w");
    tst3_adc_out_32x64_ch3  = fopen("tst3_adc_out_32x64_ch3.csv", "w");
    tst3_adc_out_32x64_ch4  = fopen("tst3_adc_out_32x64_ch4.csv", "w");
    tst3_adc_out_32x64_ch5  = fopen("tst3_adc_out_32x64_ch5.csv", "w");
    tst3_adc_out_32x64_ch6  = fopen("tst3_adc_out_32x64_ch6.csv", "w");
    tst3_adc_out_32x64_ch7  = fopen("tst3_adc_out_32x64_ch7.csv", "w");
    tst3_adc_out_32x64_ch8  = fopen("tst3_adc_out_32x64_ch8.csv", "w");

    if(tst3_dac_in_32x32_ch1    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch2    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch3    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch4    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch5    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch6    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch7    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_in_32x32_ch8    == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_coe_32x2048     == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch1 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch2 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch3 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch4 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch5 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch6 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch7 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_dac_out_32x2048_ch8 == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch1  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch2  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch3  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch4  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch5  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch6  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch7  == NULL) {printf("cannot open\n"); return 0;}
    if(tst3_adc_out_32x64_ch8  == NULL) {printf("cannot open\n"); return 0;}

	unsigned int in_data_ch1[32][32];
	unsigned int in_data_ch2[32][32];
	unsigned int in_data_ch3[32][32];
	unsigned int in_data_ch4[32][32];
	unsigned int in_data_ch5[32][32];
	unsigned int in_data_ch6[32][32];
	unsigned int in_data_ch7[32][32];
	unsigned int in_data_ch8[32][32];

	unsigned int coe_in_data[32][2048];

	unsigned int dac_data_ch1[32][2048];
	unsigned int dac_data_ch2[32][2048];
	unsigned int dac_data_ch3[32][2048];
	unsigned int dac_data_ch4[32][2048];
	unsigned int dac_data_ch5[32][2048];
	unsigned int dac_data_ch6[32][2048];
	unsigned int dac_data_ch7[32][2048];
	unsigned int dac_data_ch8[32][2048];

	unsigned int coe_out_data[2048][64];

	unsigned int adc_data_ch1[32][64];
	unsigned int adc_data_ch2[32][64];
	unsigned int adc_data_ch3[32][64];
	unsigned int adc_data_ch4[32][64];
	unsigned int adc_data_ch5[32][64];
	unsigned int adc_data_ch6[32][64];
	unsigned int adc_data_ch7[32][64];
	unsigned int adc_data_ch8[32][64];



    // INFILE 作成
	for(int i = 0; i < 32; i++) {
		for(int j = 0; j < 32; j++) {
			in_data_ch1[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf));
			in_data_ch2[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 1);
			in_data_ch3[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 2);
			in_data_ch4[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 3);
			in_data_ch5[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 4);
			in_data_ch6[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 5);
			in_data_ch7[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 6);
			in_data_ch8[i][j] = (unsigned int)(((i&0x0f)<<4) + (j&0xf) + 7);
            if(j == 31) {
			    fprintf(tst3_dac_in_32x32_ch1, "%d\r\n",in_data_ch1[i][j]);
			    fprintf(tst3_dac_in_32x32_ch2, "%d\r\n",in_data_ch2[i][j]);
			    fprintf(tst3_dac_in_32x32_ch3, "%d\r\n",in_data_ch3[i][j]);
			    fprintf(tst3_dac_in_32x32_ch4, "%d\r\n",in_data_ch4[i][j]);
			    fprintf(tst3_dac_in_32x32_ch5, "%d\r\n",in_data_ch5[i][j]);
			    fprintf(tst3_dac_in_32x32_ch6, "%d\r\n",in_data_ch6[i][j]);
			    fprintf(tst3_dac_in_32x32_ch7, "%d\r\n",in_data_ch7[i][j]);
			    fprintf(tst3_dac_in_32x32_ch8, "%d\r\n",in_data_ch8[i][j]);
			} else {
			    fprintf(tst3_dac_in_32x32_ch1, "%d,",in_data_ch1[i][j]);
			    fprintf(tst3_dac_in_32x32_ch2, "%d,",in_data_ch2[i][j]);
			    fprintf(tst3_dac_in_32x32_ch3, "%d,",in_data_ch3[i][j]);
			    fprintf(tst3_dac_in_32x32_ch4, "%d,",in_data_ch4[i][j]);
			    fprintf(tst3_dac_in_32x32_ch5, "%d,",in_data_ch5[i][j]);
			    fprintf(tst3_dac_in_32x32_ch6, "%d,",in_data_ch6[i][j]);
			    fprintf(tst3_dac_in_32x32_ch7, "%d,",in_data_ch7[i][j]);
			    fprintf(tst3_dac_in_32x32_ch8, "%d,",in_data_ch8[i][j]);				
			}
		}
    }
    // COEFILE 入力作成 転値でファイル出力
	for(int j = 0; j < 2048; j++) {
        for(int i = 0; i < 32; i++) {
			coe_in_data[i][j] = ((unsigned int)(((i&0x3)<<8) + ((j&0xf)<<4)))/10;
			if(i == 31) {
				fprintf(tst3_dac_coe_32x2048, "%d\r\n",coe_in_data[i][j]);
			} else {
				fprintf(tst3_dac_coe_32x2048, "%d,",coe_in_data[i][j]);				
			}
			
			
		}
	}

	for (int ia = 0; ia < 32; ++ia) {
		for (int ib = 0; ib < 2048; ++ib) {
			int sum_ch1 = 0;
			int sum_ch2 = 0;
			int sum_ch3 = 0;
			int sum_ch4 = 0;
			int sum_ch5 = 0;
			int sum_ch6 = 0;
			int sum_ch7 = 0;
			int sum_ch8 = 0;
			for (int id = 0; id < 32; ++id) {
				sum_ch1 += in_data_ch1[ia][id] * coe_in_data[id][ib];
				sum_ch2 += in_data_ch2[ia][id] * coe_in_data[id][ib];
				sum_ch3 += in_data_ch3[ia][id] * coe_in_data[id][ib];
				sum_ch4 += in_data_ch4[ia][id] * coe_in_data[id][ib];
				sum_ch5 += in_data_ch5[ia][id] * coe_in_data[id][ib];
				sum_ch6 += in_data_ch6[ia][id] * coe_in_data[id][ib];
				sum_ch7 += in_data_ch7[ia][id] * coe_in_data[id][ib];
				sum_ch8 += in_data_ch8[ia][id] * coe_in_data[id][ib];
			}
//			printf("%d,%d,%d,%d,%d,%d,%d,%d\n", sum_ch1/1024,sum_ch2/1024,sum_ch3/1024,sum_ch4/1024,sum_ch5/1024,sum_ch6/1024,sum_ch7/1024,sum_ch8/1024);
			
			dac_data_ch1[ia][ib] = sum_ch1 / (7 * 1024);
			dac_data_ch2[ia][ib] = sum_ch2 / (7 * 1024);
			dac_data_ch3[ia][ib] = sum_ch3 / (7 * 1024);
			dac_data_ch4[ia][ib] = sum_ch4 / (7 * 1024);
			dac_data_ch5[ia][ib] = sum_ch5 / (7 * 1024);
			dac_data_ch6[ia][ib] = sum_ch6 / (7 * 1024);
			dac_data_ch7[ia][ib] = sum_ch7 / (7 * 1024);
			dac_data_ch8[ia][ib] = sum_ch8 / (7 * 1024);
		}
	}


    // DACファイル作成
	for(int i = 0; i < 32; i++) { // row
		for(int j = 0; j < 2048; j++) { // column
		    if(j==2047) {
				fprintf(tst3_dac_out_32x2048_ch1, "%d\r\n", (unsigned int)dac_data_ch1[i][j]);
				fprintf(tst3_dac_out_32x2048_ch2, "%d\r\n", (unsigned int)dac_data_ch2[i][j]);
				fprintf(tst3_dac_out_32x2048_ch3, "%d\r\n", (unsigned int)dac_data_ch3[i][j]);
				fprintf(tst3_dac_out_32x2048_ch4, "%d\r\n", (unsigned int)dac_data_ch4[i][j]);
				fprintf(tst3_dac_out_32x2048_ch5, "%d\r\n", (unsigned int)dac_data_ch5[i][j]);
				fprintf(tst3_dac_out_32x2048_ch6, "%d\r\n", (unsigned int)dac_data_ch6[i][j]);
				fprintf(tst3_dac_out_32x2048_ch7, "%d\r\n", (unsigned int)dac_data_ch7[i][j]);
				fprintf(tst3_dac_out_32x2048_ch8, "%d\r\n", (unsigned int)dac_data_ch8[i][j]);
			} else {
				fprintf(tst3_dac_out_32x2048_ch1, "%d,",    (unsigned int)dac_data_ch1[i][j]);
				fprintf(tst3_dac_out_32x2048_ch2, "%d,",    (unsigned int)dac_data_ch2[i][j]);
				fprintf(tst3_dac_out_32x2048_ch3, "%d,",    (unsigned int)dac_data_ch3[i][j]);
				fprintf(tst3_dac_out_32x2048_ch4, "%d,",    (unsigned int)dac_data_ch4[i][j]);
				fprintf(tst3_dac_out_32x2048_ch5, "%d,",    (unsigned int)dac_data_ch5[i][j]);
				fprintf(tst3_dac_out_32x2048_ch6, "%d,",    (unsigned int)dac_data_ch6[i][j]);
				fprintf(tst3_dac_out_32x2048_ch7, "%d,",    (unsigned int)dac_data_ch7[i][j]);
				fprintf(tst3_dac_out_32x2048_ch8, "%d,",    (unsigned int)dac_data_ch8[i][j]);
			}
		}
	}


    // COEFILE 出力作成 転値でファイル出力
	for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 2048; i++) {
			coe_out_data[i][j] = ((unsigned int)(((i&0x3)<<8) + ((j&0xf)<<4))) / 20 ;
			if(i == 2047) {
				fprintf(tst3_adc_coe_2048x64, "%d\r\n",(unsigned int)coe_out_data[i][j]);
			} else {
				fprintf(tst3_adc_coe_2048x64, "%d,",(unsigned int)coe_out_data[i][j]);				
			}
		}
	}

	for (int ia = 0; ia < 32; ++ia) {
		for (int ib = 0; ib < 64; ++ib) {
			#pragma HLS PIPELINE II=1
			int sum_ch1 = 0;
			int sum_ch2 = 0;
			int sum_ch3 = 0;
			int sum_ch4 = 0;
			int sum_ch5 = 0;
			int sum_ch6 = 0;
			int sum_ch7 = 0;
			int sum_ch8 = 0;
			for (int id = 0; id < 2048; ++id) {
				sum_ch1 += dac_data_ch1[ia][id] * coe_out_data[id][ib];
				sum_ch2 += dac_data_ch2[ia][id] * coe_out_data[id][ib];
				sum_ch3 += dac_data_ch3[ia][id] * coe_out_data[id][ib];
				sum_ch4 += dac_data_ch4[ia][id] * coe_out_data[id][ib];
				sum_ch5 += dac_data_ch5[ia][id] * coe_out_data[id][ib];
				sum_ch6 += dac_data_ch6[ia][id] * coe_out_data[id][ib];
				sum_ch7 += dac_data_ch7[ia][id] * coe_out_data[id][ib];
				sum_ch8 += dac_data_ch8[ia][id] * coe_out_data[id][ib];
			}
			adc_data_ch1[ia][ib] = sum_ch1 / (7 * 1024);
			adc_data_ch2[ia][ib] = sum_ch2 / (7 * 1024);
			adc_data_ch3[ia][ib] = sum_ch3 / (7 * 1024);
			adc_data_ch4[ia][ib] = sum_ch4 / (7 * 1024);
			adc_data_ch5[ia][ib] = sum_ch5 / (7 * 1024);
			adc_data_ch6[ia][ib] = sum_ch6 / (7 * 1024);
			adc_data_ch7[ia][ib] = sum_ch7 / (7 * 1024);
			adc_data_ch8[ia][ib] = sum_ch8 / (7 * 1024);
		}
	}


    // ADCファイル作成
	for(int i = 0; i < 32; i++) { // row
		for(int j = 0; j < 64; j++) { // column
		    if(j==63) {
				fprintf(tst3_adc_out_32x64_ch1, "%d\r\n", (unsigned int)adc_data_ch1[i][j]);
				fprintf(tst3_adc_out_32x64_ch2, "%d\r\n", (unsigned int)adc_data_ch2[i][j]);
				fprintf(tst3_adc_out_32x64_ch3, "%d\r\n", (unsigned int)adc_data_ch3[i][j]);
				fprintf(tst3_adc_out_32x64_ch4, "%d\r\n", (unsigned int)adc_data_ch4[i][j]);
				fprintf(tst3_adc_out_32x64_ch5, "%d\r\n", (unsigned int)adc_data_ch5[i][j]);
				fprintf(tst3_adc_out_32x64_ch6, "%d\r\n", (unsigned int)adc_data_ch6[i][j]);
				fprintf(tst3_adc_out_32x64_ch7, "%d\r\n", (unsigned int)adc_data_ch7[i][j]);
				fprintf(tst3_adc_out_32x64_ch8, "%d\r\n", (unsigned int)adc_data_ch8[i][j]);
			} else {
				fprintf(tst3_adc_out_32x64_ch1, "%d,",    (unsigned int)adc_data_ch1[i][j]);
				fprintf(tst3_adc_out_32x64_ch2, "%d,",    (unsigned int)adc_data_ch2[i][j]);
				fprintf(tst3_adc_out_32x64_ch3, "%d,",    (unsigned int)adc_data_ch3[i][j]);
				fprintf(tst3_adc_out_32x64_ch4, "%d,",    (unsigned int)adc_data_ch4[i][j]);
				fprintf(tst3_adc_out_32x64_ch5, "%d,",    (unsigned int)adc_data_ch5[i][j]);
				fprintf(tst3_adc_out_32x64_ch6, "%d,",    (unsigned int)adc_data_ch6[i][j]);
				fprintf(tst3_adc_out_32x64_ch7, "%d,",    (unsigned int)adc_data_ch7[i][j]);
				fprintf(tst3_adc_out_32x64_ch8, "%d,",    (unsigned int)adc_data_ch8[i][j]);
			}
		}
	}

	fclose(tst3_dac_in_32x32_ch1   );
	fclose(tst3_dac_in_32x32_ch2   );
	fclose(tst3_dac_in_32x32_ch3   );
	fclose(tst3_dac_in_32x32_ch4   );
	fclose(tst3_dac_in_32x32_ch5   );
	fclose(tst3_dac_in_32x32_ch6   );
	fclose(tst3_dac_in_32x32_ch7   );
	fclose(tst3_dac_in_32x32_ch8   );
	fclose(tst3_dac_coe_32x2048    );
	fclose(tst3_dac_out_32x2048_ch1);
	fclose(tst3_dac_out_32x2048_ch2);
	fclose(tst3_dac_out_32x2048_ch3);
	fclose(tst3_dac_out_32x2048_ch4);
	fclose(tst3_dac_out_32x2048_ch5);
	fclose(tst3_dac_out_32x2048_ch6);
	fclose(tst3_dac_out_32x2048_ch7);
	fclose(tst3_dac_out_32x2048_ch8);
	fclose(tst3_adc_coe_2048x64   );
	fclose(tst3_adc_out_32x64_ch1 );
	fclose(tst3_adc_out_32x64_ch2 );
	fclose(tst3_adc_out_32x64_ch3 );
	fclose(tst3_adc_out_32x64_ch4 );
	fclose(tst3_adc_out_32x64_ch5 );
	fclose(tst3_adc_out_32x64_ch6 );
	fclose(tst3_adc_out_32x64_ch7 );
	fclose(tst3_adc_out_32x64_ch8 );

    return 0;
}
