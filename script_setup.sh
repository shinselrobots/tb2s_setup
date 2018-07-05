#!/bin/bash
#
# Run script as root, unless permissions are dropped elsewhere.  This allows root password to be provided once at start of script
#
   
if [ ! -z "$USER" ]
then
  echo "ERROR: USER variable not set"
#  exit -1
fi
export USER=test_user
export _DEFAULT_USER="-u $USER"


sudo -E bash <<"EOF"
export NPROCS=`grep -c ^processor /proc/cpuinfo`

function init_install {
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    echo "Waiting for other software managers to stop ..."
    killall aptd
    killall apt-get
    killall apt
    sleep 0.5
  done 
}

function install_ros {
if [ -f "/etc/apt/sources.list.d/ros-latest.list" ] 
then
  echo "ROS is already installed, skipping installation"
else
  apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
  sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
  apt-get update
  apt-get -y install ssh git ros-kinetic-ros-base python-wstool python-rosdep 
  rosdep init

sudo -E $_DEFAULT_USER bash <<"EOF2"
  echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
  rosdep update
EOF2
fi
}



function install_speech {
  # Cloud based speech recognition support
  apt-get update
  apt-get -y install libatlas3-base python-pyaudio
}


function install_source {
# Perform the following with normal user permissions (e.g. drop root)
sudo -E $_DEFAULT_USER bash <<"EOF2"
  source /opt/ros/kinetic/setup.bash
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
  rm -rf *isolated 
  wstool update -t src
  rosdep install --from-paths `pwd`/src --ignore-src --rosdistro=kinetic -y
  catkin_make
EOF2
}

init_install
install_ros
install_speech
install_source

echo "Please complete the following manual steps:"
echo "  $ source ~/.bashrc"
echo "  $ rosrun kobuki_ftdi create_udev_rules"
echo "  $ sudo cp catkin_robot/src/tb2s/tb2s_pantilt/udev/* /etc/udev/rules.d"
echo "     then reboot your device."

ldconfig

EOF

