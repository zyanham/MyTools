#include <iostream>
#include <string>
using namespace std;

#include "opencv2/opencv.hpp"

int main() {
  string rightImg = "/home/koichi/data/tsukuba/scene1.row3.col4.ppm";
  string leftImg = "/home/koichi/data/tsukuba/scene1.row3.col2.ppm";

  cv::Mat imgR = cv::imread(rightImg, CV_8UC1);
  cv::Mat imgL = cv::imread(leftImg, CV_8UC1);
  cv::Mat dispMat(imgR.rows, imgR.cols, CV_8UC1);

  int disp = 32;
  int minDisparity = 0;
  int numDisparities = 32;
  int SADWindowSize = 3;
  int P1 = 0;
  int P2 = 0;
  int disp12MaxDiff = 0;
  int preFilterCap = 0;
  int uniquenessRatio = 0;
  int speckleWindowSize = 0;
  int speckleRange = 0;
  bool fullDp = false;

  cv::StereoSGBM sgbm(minDisparity, numDisparities, SADWindowSize, P1, P2,
                      disp12MaxDiff, preFilterCap, uniquenessRatio,
                      speckleWindowSize, speckleRange, fullDp);

  {
    cv::TickMeter meter;
    meter.start();

    for (int i = 0; i < 100; i++) {
      sgbm(imgL, imgR, dispMat);
    }

    meter.stop();
    std::cout << "Average Time for Calculation : "
              << meter.getTimeMilli() / 100.0 << std::endl;
  }

  double min, max;
  cv::minMaxLoc(dispMat, &min, &max);
  cv::convertScaleAbs(dispMat, dispMat, 255 / (max - min), 255 / min);

  cv::namedWindow("Right Image", CV_WINDOW_AUTOSIZE);
  cv::namedWindow("Left Image", CV_WINDOW_AUTOSIZE);
  cv::namedWindow("Disparity", CV_WINDOW_AUTOSIZE);

  cv::imshow("Right Image", imgR);
  cv::imshow("Left Image", imgL);
  cv::imshow("Disparity", dispMat);

  cvWaitKey(0);
  cvDestroyAllWindows();

  return 0;
}