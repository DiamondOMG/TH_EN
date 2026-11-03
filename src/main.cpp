#include <Arduino.h>
#include <Wire.h>
#include <U8g2lib.h>

namespace {
constexpr uint8_t OLED_I2C_ADDRESS = 0x3C;
constexpr size_t INPUT_BUFFER_SIZE = 8;

U8G2_SSD1306_128X64_NONAME_F_HW_I2C display(U8G2_R0, U8X8_PIN_NONE);
char input_buffer[INPUT_BUFFER_SIZE];
size_t input_length = 0;
char current_language[3] = "";

void draw_language(const char* language) {
  display.clearBuffer();
  display.setFont(u8g2_font_logisoso32_tr);

  const uint8_t text_width = display.getStrWidth(language);
  const int16_t x = (display.getDisplayWidth() - text_width) / 2;
  const int16_t y = (display.getDisplayHeight() + display.getAscent() - display.getDescent()) / 2;
  display.drawStr(x, y, language);
  display.sendBuffer();

  strncpy(current_language, language, sizeof(current_language) - 1);
  current_language[sizeof(current_language) - 1] = '\0';
}

void handle_serial_input() {
  while (Serial.available() > 0) {
    const char incoming = static_cast<char>(Serial.read());
    if (incoming == '\r') {
      continue;
    }
    if (incoming == '\n') {
      input_buffer[input_length] = '\0';
      if ((strcmp(input_buffer, "EN") == 0 || strcmp(input_buffer, "TH") == 0 || strcmp(input_buffer, "--") == 0) &&
          strcmp(input_buffer, current_language) != 0) {
        draw_language(input_buffer);
      }
      input_length = 0;
      continue;
    }
    if (input_length < INPUT_BUFFER_SIZE - 1) {
      input_buffer[input_length++] = incoming;
    } else {
      input_length = 0;
    }
  }
}
}

void setup() {
  Serial.begin(115200);
  Wire.begin();

  display.setI2CAddress(OLED_I2C_ADDRESS << 1);
  display.begin();
  draw_language("--");
}

void loop() {
  handle_serial_input();
}
