
_picam2_libcamera_set() {
cd ~/libcamera
meson setup build --reconfigure -Dpycamera=enabled
ninja -C build
}


#export PYTHONPATH=$PYTHONPATH:$HOME/libcamera/build/src/py

_picam2_build() {
git clone https://github.com/raspberrypi/picamera2.git
cd picamera2
git checkout next
pip3 install -e . --break-system-packages
}

_picam2_kms() {

git clone https://github.com/tomba/kmsxx.git
cd kmsxx
git checkout bfb041620d8ee5fbbc2f2432edc658389e5635da

rm -rf build
sudo apt install -y libdrm-dev libevdev-dev libfmt-dev pybind11-dev python3-dev meson
meson setup build -Dbuildtype=debug -Dpykms=enabled
ninja -C build
sudo ninja -C build install
sudo ldconfig

python3 -c "import pykms; print(pykms.__version__)"

#export PYTHONPATH="$PYTHONPATH:$HOME/kmsxx/build/py/pykms"
}
