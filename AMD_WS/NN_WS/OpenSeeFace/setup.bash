python3 -m venv openseeface_env
source openseeface_env/bin/activate

pip install -r req.txt

git clone https://github.com/emilianavt/OpenSeeFace.git
cd OpenSeeFace

echo "python3 facetracker.py -c 0 --visualize 4"
