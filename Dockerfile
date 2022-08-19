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

# RUN git clone https://github.com/edoborgiani/PhysiCell_COMMBINI.git

# Download and install paraview

RUN wget "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.1-osmesa-MPI-Linux-Python3.9-x86_64.tar.gz"
RUN tar xvfz "download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.1-osmesa-MPI-Linux-Python3.9-x86_64.tar.gz"