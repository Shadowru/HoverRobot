#Script is intended for https://developer.nvidia.com/jetson-nano-sd-card-image

sudo systemctl set-default multi-user.target

sudo apt-get update
sudo apt-get upgrade

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt-get update
sudo apt-get --yes install ros-melodic-desktop

#ROS catkin

echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
source /opt/ros/melodic/setup.bash

sudo apt-get --yes install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
sudo rosdep init
rosdep update

mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/
catkin_make
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc

#ROS package install

sudo apt-get --yes install ros-melodic-cv-bridge ros-melodic-rosbridge-server ros-melodic-web-video-server libuvc-dev ros-melodic-uvc-camera ros-melodic-libuvc-camera ros-melodic-move-base ros-melodic-gmapping ros-melodic-robot-localization

sudo apt-get --yes install python-future

cd ~/catkin_ws/src/
git clone https://github.com/robopeak/rplidar_ros.git
git clone https://github.com/Shadowru/hoverboard_driver.git
git clone https://github.com/Shadowru/rosgolf_web_interface.git

sudo ln -s /usr/include/opencv4 /usr/include/opencv

cd ~/catkin_ws/
catkin_make

#Web server installation

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install --yes nodejs

cd ~/catkin_ws/src/rosgolf_web_interface/web_interface/
npm install rosnodejs express socket.io yargs
npm install

# Configure

sudo systemctl stop nvgetty
sudo systemctl disable nvgetty
sudo udevadm trigger
sudo gpasswd --add rosgolf dialout

sudo ~/catkin_ws/src/rosgolf_web_interface/script/setup_udev.sh

#Launch web interface
roslaunch rosgolf_web_interface rosgolf_interface.launch
