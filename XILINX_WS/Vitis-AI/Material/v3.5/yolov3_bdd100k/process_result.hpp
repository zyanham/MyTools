/*
 * Copyright 2022-2023 Advanced Micro Devices Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#pragma once
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
/*
 *   The color loops every 27 times,
 *    because each channel of RGB loop in sequence of "0, 127, 254"
 */
static cv::Scalar getColor(int label) {
  int c[3];
  for (int i = 1, j = 0; i <= 9; i *= 3, j++) {
    c[j] = ((label / i) % 3) * 127;
  }
  return cv::Scalar(c[2], c[1], c[0]);
}

/*
   1: pedestrian
   2: rider
   3: car
   4: truck
   5: bus
   6: train
   7: motorcycle
   8: bicycle
   9: traffic light
  10: traffic sign  
*/

static std::vector<std::string> bdd100k_map {
    "car", "rider", "pedestrian", "truck", "bus", "train",
    "motorcycle", "bicycle", "traffic light", "traffic sign"};

static cv::Mat process_result(cv::Mat &image,
                              const vitis::ai::YOLOv3Result &result,
                              bool is_jpeg) {
  for (const auto bbox : result.bboxes) {
    int label = bbox.label;
    std::string label_name = bdd100k_map[bbox.label];
    float xmin = bbox.x * image.cols + 1;
    float ymin = bbox.y * image.rows + 1;
    float xmax = xmin + bbox.width * image.cols;
    float ymax = ymin + bbox.height * image.rows;
    float confidence = bbox.score;
    if (xmax > image.cols) xmax = image.cols;
    if (ymax > image.rows) ymax = image.rows;
    LOG_IF(INFO, is_jpeg) << "RESULT: " << label << "\t" << xmin << "\t" << ymin
                          << "\t" << xmax << "\t" << ymax << "\t" << confidence
                          << "\n";
    cv::putText(image, label_name, cv::Point(xmin, ymin-5), cv::FONT_HERSHEY_SIMPLEX, 0.7, getColor(label), 2, cv::LINE_AA);
    cv::rectangle(image, cv::Point(xmin, ymin), cv::Point(xmax, ymax),
                  getColor(label), 2, 1, 0);
  }

  cv::imwrite("result.jpg", image);
  return image;
}
