# Adapted from Deepcell Dockerfile 

# Use tensorflow/tensorflow as the base image
# Change the build arg to edit the tensorflow version.
# Only supporting python3.
ARG TF_VERSION=2.8.0-gpu

FROM tensorflow/tensorflow:${TF_VERSION}

# https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation/212771
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

# System maintenance
RUN apt-get update && apt-get install -y  \
    graphviz wget && \
    rm -rf /var/lib/apt/lists/* && \
    /usr/bin/python3 -m pip install --no-cache-dir --upgrade pip

RUN mkdir deepcell-tf

RUN wget -O ./deepcell-tf/requirements.txt https://raw.githubusercontent.com/vanvalenlab/deepcell-tf/master/requirements.txt

# Prevent reinstallation of tensorflow and install all other requirements.
RUN sed -i "/tensorflow>/d" /deepcell-tf/requirements.txt && \
    pip install --no-cache-dir -r /deepcell-tf/requirements.txt

# Install deepcell via setup.py
RUN pip install deepcell

# packages added by Gabriele Nasello

# System packages 
RUN apt-get update && apt-get install -yq curl jq vim git unzip htop less nano emacs

# It is required to install java for python javabridge package
# From OpenJDK Java 7 JRE Dockerfile
# http://dockerfile.github.io/#/java
# https://github.com/dockerfile/java
# https://github.com/dockerfile/java/tree/master/openjdk-7-jre
RUN \
  apt-get update && \
  apt-get install -y openjdk-11-jdk && \
  rm -rf /var/lib/apt/lists/*
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

ADD requirements.txt .

RUN pip install -r requirements.txt

# Initialize conda in bash config fiiles:
RUN echo "alias jl='export SHELL=/bin/bash; jupyter lab --allow-root --port=7777 --ip=0.0.0.0'" >> ~/.bashrc

RUN pip freeze > ../package_versions_py.txt

#RUN git clone https://github.com/edoborgiani/PhysiCell_COMMBINI.git

#RUN wget -O paraview.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.1-MPI-Linux-Python3.9-x86_64.tar.gz"

#RUN tar -xf paraview.tar.gz

# The python compiler is located at:
# ParaView-5.10.1-MPI-Linux-Python3.9-x86_64/bin/pvpython
#RUN echo "alias pvpython='/ParaView-5.10.1-MPI-Linux-Python3.9-x86_64/bin/pvpython'" >> ~/.bashrc 


# Install CMake on Ubuntu
# [https://linuxhint.com/install-cmake-on-ubuntu/]

RUN apt-get update && \
    apt-get install libssl-dev build-essential

RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.0/cmake-3.24.0.tar.gz

RUN tar -zxvf cmake-3.24.0.tar.gz 
RUN rm cmake-3.24.0.tar.gz 

WORKDIR "/cmake-3.24.0"

RUN ./bootstrap

RUN make

RUN make install

WORKDIR "/"

#apt-get install -y ninja-build

#apt-get install -y git cmake build-essential libgl1-mesa-dev libxt-dev qt5-default libqt5x11extras5-dev libqt5help5 qttools5-dev qtxmlpatterns5-dev-tools libqt5svg5-dev python3-dev python3-numpy libopenmpi-dev libtbb-dev ninja-build

#cmake --version

# Build Paraview
# [https://gitlab.kitware.com/paraview/paraview/blob/master/Documentation/dev/build.md]

RUN apt-get install -y git \
                       build-essential \
                       libgl1-mesa-dev \
                       libxt-dev \
                       qt5-default \
                       libqt5x11extras5-dev \
                       libqt5help5 \
                       qttools5-dev \
                       qtxmlpatterns5-dev-tools \
                       libqt5svg5-dev \
                       python3-dev \
                       python3-numpy \
                       libopenmpi-dev \
                       libtbb-dev \
                       ninja-build

RUN git clone --recursive https://gitlab.kitware.com/paraview/paraview.git /paraview
RUN mkdir /paraview_build
#WORKDIR "/paraview_build"
#RUN "cmake -GNinja -DPARAVIEW_USE_PYTHON=ON -DPARAVIEW_USE_MPI=ON -DVTK_SMP_IMPLEMENTATION_TYPE=TBB -DCMAKE_BUILD_TYPE=Release /paraview"
#RUN ninja
#WORKDIR "/"