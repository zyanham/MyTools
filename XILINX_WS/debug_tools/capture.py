import cv2
import time

# VideoCapture オブジェクトを取得します
capture = cv2.VideoCapture(0)

start = time.time()

while(True):
    ret, frame = capture.read()
    end = time.time()
    seconds = end - start
    fps = int((1 / seconds)*100) / 100
    start = time.time()
    cv2.putText(frame, str(fps), (30,60), cv2.FONT_HERSHEY_SIMPLEX, 2.0, (0,255,0), 8)
    cv2.imshow('frame',frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

capture.release()
cv2.destroyAllWindows()
