#include <opencv2/opencv.hpp>
#include <chrono>

using namespace cv;
using namespace std;

int main(int argc, char** argv) {
    // カメラを開く（デフォルトのカメラを使用）
    VideoCapture cap(0);
    if (!cap.isOpened()) {
        cerr << "Error: Could not open the camera." << endl;
        return -1;
    }

    // VGAサイズに設定
    cap.set(CAP_PROP_FRAME_WIDTH, 640);
    cap.set(CAP_PROP_FRAME_HEIGHT, 480);

    // ウィンドウの作成
    namedWindow("Webcam", WINDOW_AUTOSIZE);

    // フレームを格納するための変数
    Mat frame;
    // FPS計算のための変数
    auto start = chrono::high_resolution_clock::now();
    int frameCount = 0;
    double fps = 0.0;

    while (true) {
        // フレームをキャプチャ
        cap >> frame;
        if (frame.empty()) {
            cerr << "Error: Captured empty frame." << endl;
            break;
        }

        // フレームカウントを増加
        frameCount++;

        // 1秒毎にFPSを計算
        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> elapsed = end - start;
        if (elapsed.count() >= 1.0) {
            fps = frameCount / elapsed.count();
            start = chrono::high_resolution_clock::now();
            frameCount = 0;
        }

        // FPSを表示
        stringstream ss;
        ss << "FPS: " << fixed << setprecision(2) << fps;
        string fpsText = ss.str();
        putText(frame, fpsText, Point(10, 30), FONT_HERSHEY_SIMPLEX, 1.0, Scalar(255, 0, 0), 2);

        // フレームをウィンドウに表示
        imshow("Webcam", frame);

        // 'q'キーでループを終了
        if (waitKey(1) == 'q') {
            break;
        }
    }

    // リソースを解放
    cap.release();
    destroyAllWindows();

    return 0;
}

