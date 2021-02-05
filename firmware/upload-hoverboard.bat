openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c flash "write_image erase firmware.bin 0x8000000"

