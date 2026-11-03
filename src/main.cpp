#include <Arduino.h>
#include <Wire.h>
#include <U8g2lib.h>

namespace {

constexpr uint8_t OLED_I2C_ADDRESS = 0x3C;

U8G2_SSD1306_128X64_NONAME_F_HW_I2C display(U8G2_R0, U8X8_PIN_NONE);
}

void setup() {
  Wire.begin();

  display.setI2CAddress(OLED_I2C_ADDRESS << 1);
  display.begin();
  display.clearBuffer();
  display.setFont(u8g2_font_ncenB14_tr);

  constexpr char message[] = "EN TH";
  const uint8_t text_width = display.getStrWidth(message);
  const uint8_t x = (display.getDisplayWidth() - text_width) / 2;
  const uint8_t y = (display.getDisplayHeight() + display.getAscent() - display.getDescent()) / 2;
  display.drawStr(x, y, message);
  display.sendBuffer();
}

void loop() {
}
