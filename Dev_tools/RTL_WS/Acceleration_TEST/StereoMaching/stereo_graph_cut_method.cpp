#include <iostream>
using namespace std;

#include "opencv2/opencv.hpp"

int main() {
  const char *rightImg = "/home/koichi/data/tsukuba/scene1.row3.col4.ppm";
  const char *leftImg = "/home/koichi/data/tsukuba/scene1.row3.col2.ppm";

  // const char *rightImg = "/home/koichi/Desktop/Stereo Pair/pentR.bmp";
  // const char *leftImg = "/home/koichi/Desktop/Stereo Pair/pentL.bmp";

  IplImage *imgR, *imgL, *dst;
  IplImage *dispLeft, *dispRight;
  int disp = 32;
  CvStereoGCState *state = cvCreateStereoGCState(disp, 4);

  // . Load Image.
  imgR = cvLoadImage(rightImg, CV_LOAD_IMAGE_GRAYSCALE);
  imgL = cvLoadImage(leftImg, CV_LOAD_IMAGE_GRAYSCALE);

  CvSize size;
  size.width = imgR->width;
  size.height = imgR->height;

  // . Allocate Memory
  dispLeft = cvCreateImage(size, IPL_DEPTH_16S, 1);
  dispRight = cvCreateImage(size, IPL_DEPTH_16S, 1);
  dst = cvCreateImage(size, IPL_DEPTH_8U, 1);

  // Calcuate Disparity
  {
    cv::TickMeter meter;
    meter.start();
    int repeat = 10;

    for (int i = 0; i < repeat; i++) {
      cvFindStereoCorrespondenceGC(imgL, imgR, dispLeft, dispRight, state, 0);
    }

    meter.stop();
    std::cout << "Average Time for Calculation : "
              << meter.getTimeMilli() / repeat << std::endl;
  }

  cvConvertScale(dispLeft, dst, -256 / disp);

  const char *winName = "Stereo Correspondence";

  cvNamedWindow("Right Image", CV_WINDOW_AUTOSIZE);
  cvNamedWindow("Left Image", CV_WINDOW_AUTOSIZE);
  cvNamedWindow("Disparity", CV_WINDOW_AUTOSIZE);

  cvShowImage("Right Image", imgR);
  cvShowImage("Left Image", imgL);
  cvShowImage("Disparity", dst);

  cvWaitKey(0);

  // cvReleaseStereoGCState(&state);
  cvDestroyAllWindows();

  cvReleaseImage(&imgR);
  cvReleaseImage(&imgL);

  return 0;
}