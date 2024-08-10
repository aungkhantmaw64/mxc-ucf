FROM debian:11-slim

RUN apt-get update && apt-get install -y git curl wget build-essential unzip tar xxd

ENV MXC_TOOLCHAIN_PATH=/opt/mxc-ucf/gcc-arm-none-eabi
ENV MXC_TOOLCHAIN_BIN_PATH=${MXC_TOOLCHAIN_PATH}/bin

RUN  mkdir -p ${MXC_TOOLCHAIN_PATH} && \
  cd ${MXC_TOOLCHAIN_PATH} && \
  wget -O gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz" && \
  ls -l gcc-arm-none-eabi.tar.xz && \
  tar -xf gcc-arm-none-eabi.tar.xz --strip-components 1 && \
  rm gcc-arm-none-eabi.tar.xz

ENV PATH=$PATH:${MXC_TOOLCHAIN_BIN_PATH}

WORKDIR /mxc-ucf
