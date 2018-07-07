#!/bin/bash
set -e

function init_install {
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    echo "Waiting for other software managers to stop ..."
    sudo killall aptd
    sudo killall apt-get
    sudo killall apt
    sleep 0.5
  done 
}

function install_ros {
if [ -f "/etc/apt/sources.list.d/ros-latest.list" ] 
then
  echo "ROS is already installed, skipping installation"
else
  sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
  sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
  sudo apt-get update
  sudo apt-get -y install ros-kinetic-catkin python-wstool python-rosdep build-essential
  sudo rosdep init
  rosdep update
  echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
fi
}

function install_source {
  cd
  if [ ! -d "~/catkin_robot" ] 
  then
    mkdir ~/catkin_robot
    cd ~/catkin_robot
    wstool init src

    # Note: There is a '?' in the path to force/invalidate any transparent proxy @ Github that prevents us from fetching the latest version
    wstool merge -y -t src https://raw.githubusercontent.com/shinselrobots/tb2s_setup/master/robot.rosinstall?
    echo "source ~/catkin_robot/devel/setup.bash" >> ~/.bashrc
  fi

  cd ~/catkin_robot
  wstool update -t src
  rosdep install --from-paths `pwd`/src --ignore-src --rosdistro=kinetic -y
  source /opt/ros/kinetic/setup.bash
  catkin_make
}

cd
init_install
install_ros
install_source

# After everything has installed correctly with dependencies, install 
# the remaining ROS full desktop environment
sudo apt-install ros-kinetic-desktop-full

echo "Don't forget to run 'source ~./bashrc' to load ROS environment"
