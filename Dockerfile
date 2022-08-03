FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

# Install common dependencies
RUN apt-get -y update && \
	apt-get -y upgrade && \
    apt-get install -y apt-utils && \
    apt-get install -y tzdata && \
    echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections && \
    echo 'tzdata tzdata/Zones/Europe select Paris' | debconf-set-selections

# Packages installed for minimal installation
RUN apt-get install -y build-essential gcc make git wget mosquitto-clients

# If you are using this container for debugging uncomment the line below
RUN apt-get -y install curl wget vim tmux net-tools host iputils-ping

# Install ASan
RUN apt-get install -y libasan4

WORKDIR /root

# Clone mqtt-fuzz
RUN git clone https://github.com/F-Secure/mqtt_fuzz.git 

# Install compile Radamsa
RUN git clone https://gitlab.com/akihe/radamsa.git && \
    cd radamsa && make && make install

# Install python, pip and python dependencies
RUN apt-get -y install python3-pip
RUN python3 -m pip install -r mqtt_fuzz/requirements.txt

# Start fuzzing (black-box), all packages are fuzzed
CMD cd mqtt_fuzz && python3 mqtt_fuzz.py -ratio 10 mosquitto 1883
