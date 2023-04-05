#ifndef __BITMAP_H_INCLUDED__
#define __BITMAP_H_INCLUDED__

#define FILEHEADERSIZE 14					//�ե�����إå��Υ�����
#define INFOHEADERSIZE 40					//����إå��Υ�����
#define HEADERSIZE (FILEHEADERSIZE+INFOHEADERSIZE)

typedef struct{
	unsigned char b;
	unsigned char g;
	unsigned char r;
}Rgb;

typedef struct{
	unsigned int height;
	unsigned int width;
	Rgb *data;
}Image;

//��������������Хݥ��󥿤��Ԥ����NULL���֤�
Image *Read_Bmp(char *filename);

//�񤭹��ߤ����������0���Ԥ����1���֤�
int Write_Bmp(char *filename, Image *img);

//Image���������RGB�����width*heightʬ����ưŪ�˼������롣
//��������Хݥ��󥿤򡢼��Ԥ����NULL���֤�
Image *Create_Image(int width, int height);
//Image���ˡ����
void Free_Image(Image *img);

#endif /*__BITMAP_H_INCLUDED__*/
