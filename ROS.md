Установка ROS велась с [чистого образа](https://developer.nvidia.com/jetson-nano-sd-card-image)

Все действия далее оформлены в отдельный скрипт : [install.sh](./scripts/install.sh)

###Убираем графику

```shell
sudo systemctl set-default multi-user.target
```

###Обновляем репозитории

```shell
sudo apt-get update
sudo apt-get upgrade
```

###Установка типовой 
```shell
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt-get update
sudo apt-get --yes install ros-melodic-desktop
```

###Создание ROS catkin среды

```shell
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
```

###Установка необходимых пакетов

```shell
sudo apt-get --yes install ros-melodic-cv-bridge ros-melodic-rosbridge-server ros-melodic-web-video-server libuvc-dev ros-melodic-uvc-camera ros-melodic-libuvc-camera ros-melodic-move-base ros-melodic-gmapping ros-melodic-robot-localization

sudo apt-get --yes install python-future

cd ~/catkin_ws/src/
git clone https://github.com/robopeak/rplidar_ros.git
git clone https://github.com/Shadowru/hoverboard_driver.git
git clone https://github.com/Shadowru/rosgolf_web_interface.git

sudo ln -s /usr/include/opencv4 /usr/include/opencv

cd ~/catkin_ws/
catkin_make
```

###Установка веб сервера

```shell
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install --yes nodejs

cd ~/catkin_ws/src/rosgolf_web_interface/web_interface/
npm install rosnodejs express socket.io yargs
npm install
```

###Конфигурация

Заменить имя СОМ порта для связи с платой на текущий в параметре <param name="uart" value="{имя СОМ порта}"/>
Пользователю под которым запускается ROS пакет должен быть доступен порт.
Если используется Jetson Nano аппаратный /dev/ttyTHS1, то надо освободить его от системных служб

```shell
sudo systemctl stop nvgetty
sudo systemctl disable nvgetty
sudo udevadm trigger
sudo gpasswd --add rosgolf dialout
```

Отредактировать  ```~/catkin_ws/src/rosgolf_web_interface/launch/rosgolf_interface.launch```

Заменить VID/PID в настройках камеры :
```xml
<param name="vendor" value="{VID}"/>
<param name="product" value="{PID}"/>
<param name="width" value="800"/>
<param name="height" value="600"/>
<param name="video_mode" value="mjpeg "/> <!-- or yuyv/nv12/mjpeg -->
<param name="frame_rate" value="30"/>
```
TODO: добавить скрипт для настройки камеры из режимов

###Запуск ROS сборки

roslaunch rosgolf_web_interface rosgolf_interface.launch

В браузере по адресу http://{IP адрес Jetson NANO}:8000/ должна быть страница с управлением роботом и видеопотоком

