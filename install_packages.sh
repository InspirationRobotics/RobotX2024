git submodule init
git submodule update --recursive

# Intall comms_core
cd RX24-COMMS
git checkout main
pip3 install -e .

# Install perception packages
cd ../RX24-perception
git checkout main
cd camera
pip3 install -e .
cd ../lidar
pip3 install -e .

# Setup control packages
cd ../../RX24-GNC
git checkout main