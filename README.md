P4 Model Repository
========

This repository maintains the P4 programs and allows building P4 for the P4
Behavioral Model.

To install all the Ubuntu 14.04 dependencies, run ./install.sh

Before running the simulator, you need to create veth interfaces that the
simulator can connect to. To create them, you need to run:  
sudo p4factory/tools/veth_setup.sh


To validate you installation and test the simulator on a simple P4 target, do
the following:  

cd p4factory/targets/basic_bd_routing/  
make behavioral  
sudo ./behavioral_model  

To run a simple test, run this in a different terminal:  
cd p4factory/targets/basic_bd_routing/  
sudo python run_tests.py --test-dir of-tests/tests/  

