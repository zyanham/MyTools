mkdir -p ~/.config/pip
echo "[global]" >> ~/.config/pip/pip.conf
echo "break-system-packages = true" >> ~/.config/pip/pip.conf

pip install opencv-python

