DOCKER_IMAGE_NAME=mxc-ucf
APP_PATH=$(shell pwd)
STARTUP_PATH=${APP_PATH}/startup
INCLUDE_PATH=${APP_PATH}/include
LIB_PATH=${APP_PATH}/lib
LD_PATH=${APP_PATH}/ld
BUILD_PATH=${APP_PATH}/build
SRC_FILE=
APP_NAME=blinky
LD_SCRIPT_NAME=
all: clean build

build: clean
	mkdir build
	arm-none-eabi-gcc -mcpu=cortex-m3 -g3 \
		-DDEBUG -c \
		-x assembler-with-cpp \
		-MMD -MP \
		-MF"${BUILD_PATH}/startup_stm32l152retx.d" \
		-MT"${BUILD_PATH}/startup_stm32l152retx.o" \
		--specs=nano.specs \
		-mfloat-abi=soft \
		-mthumb \
		-o "${BUILD_PATH}/startup_stm32l152retx.o" "${STARTUP_PATH}/startup_stm32l152retx.s"
	SRC_FILE_PATH=${APP_PATH} SRC_FILE_NAME=main make _build
	SRC_FILE_PATH=${APP_PATH}/lib/stm32/l1 SRC_FILE_NAME=syscalls make _build
	SRC_FILE_PATH=${APP_PATH}/lib/stm32/l1 SRC_FILE_NAME=sysmem make _build
	make _elf LD_SCRIPT_NAME=stm32l152retx_flash
	make _size _objdump _objcpy
	
_build:
	arm-none-eabi-gcc "${SRC_FILE_PATH}/${SRC_FILE_NAME}.c" \
		-mcpu=cortex-m3 -std=gnu11 \
		-g3 -DDEBUG -DSTM32L1 -DSTM32 \
		-DSTM32L152RETx -c \
		-I${INCLUDE_PATH}/cmsis \
		-I${INCLUDE_PATH}/mxc/stm32 \
		-O0 -ffunction-sections \
		-fdata-sections \
		-Wall \
		-fstack-usage \
		-MMD -MP \
		-MF"${BUILD_PATH}/${SRC_FILE_NAME}.d" \
		-MT"${BUILD_PATH}/${SRC_FILE_NAME}.o" \
		--specs=nano.specs \
		-mfloat-abi=soft \
		-mthumb -o "${BUILD_PATH}/${SRC_FILE_NAME}.o"

_elf:
	@find ${BUILD_PATH} -name "*.o" > ${BUILD_PATH}/objects.list
	arm-none-eabi-gcc -o "${BUILD_PATH}/${APP_NAME}.elf" @"${BUILD_PATH}/objects.list" \
		-mcpu=cortex-m3 \
		-T"${LD_PATH}/${LD_SCRIPT_NAME}.ld" \
		--specs=nosys.specs \
		-Wl,-Map="${BUILD_PATH}/${APP_NAME}.map" \
		-Wl,--gc-sections \
		-static \
		--specs=nano.specs \
		-mfloat-abi=soft \
		-mthumb \
		-Wl,--start-group \
		-lc -lm \
		-Wl,--end-group

_size:
	arm-none-eabi-size ${BUILD_PATH}/${APP_NAME}.elf

_objdump:
	arm-none-eabi-objdump -h -S  ${BUILD_PATH}/${APP_NAME}.elf  > "${BUILD_PATH}/${APP_NAME}.list"

_objcpy:
	arm-none-eabi-objcopy -O binary ${BUILD_PATH}/${APP_NAME}.elf ${BUILD_PATH}/${APP_NAME}.bin

clean:
	rm -rf build

docker-image-builder:
	docker build -t ${DOCKER_IMAGE_NAME} --progress tty .

docker-container-run:
	docker container run --rm -it -v ${PWD}:/app -w /app ${DOCKER_IMAGE_NAME} bash

.PHONY: build
