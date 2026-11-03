# Hardware & Library Specs

## Hardware

### Raspberry Pi RP2040-Zero

- MCU: RP2040, dual-core ARM Cortex-M0+
- Flash: 2 MB per project hardware note
- USB powers the board and provides USB CDC Serial for the Windows host app
- Onboard WS2812 RGB LED: GP16; unused by this firmware
- I²C pins: GP4 (SDA), GP5 (SCL), Raspberry Pi Pico Arduino core default Wire pins

### OLED 0.96-inch I²C

- Connector: GND, VCC, SCL, SDA
- Assumed controller: SSD1306, 128x64
- Assumed I²C address: `0x3C` (some modules use `0x3D`)
- Supply: 3.3 V recommended; do not allow I²C pull-ups to raise GPIO signals to 5 V
- If the screen is blank, verify controller, resolution, address and wiring; SH1106 needs its corresponding U8g2 driver.

## Libraries

- U8g2: SSD1306 128x64 hardware-I²C driver
- Python `pyserial`: USB Serial link from Windows host app to the board

## Host App Behavior

- Reads the keyboard layout of the currently focused Windows application using `GetKeyboardLayout`
- Sends `EN`, `TH`, or `--` over USB Serial when the detected state changes
- Requires the host app to remain running for live status updates

## Datasheet / References

- RP2040-Zero hardware setup notes in the user's MCU vault
- U8g2 documentation: https://github.com/olikraus/u8g2

## Hardware Issues

- Exact OLED controller and address are not confirmed; current firmware assumes SSD1306/`0x3C`.
- Confirm board silkscreen and pin orientation before wiring.

## Test Notes

- Build ผ่านด้วย `pio run` บน PlatformIO Raspberry Pi platform / Arduino Mbed core
- ยังไม่ได้ทดสอบบนบอร์ดจริง
