# OLED EN TH

แสดงภาษาคีย์บอร์ด Windows ที่กำลังใช้งานเป็น `EN` หรือ `TH` ตัวใหญ่บน OLED 0.96 นิ้ว โดยโปรแกรมบนคอมอ่าน layout ของหน้าต่างที่กำลังใช้งานแล้วส่งให้ Raspberry Pi RP2040-Zero ผ่าน USB Serial

## Hardware

- Raspberry Pi RP2040-Zero
- OLED 0.96 นิ้ว I²C (ค่าเริ่มต้นใน firmware: SSD1306 128x64, address `0x3C`)
- ต่อไฟจอที่ 3V3 เพื่อให้ระดับสัญญาณ I²C เป็น 3.3 V

## Pin Map

มองจากด้านบน โดยให้ USB อยู่ด้านบน (ตรวจป้ายบนบอร์ดของคุณก่อนต่อสาย):

```text
                    USB
              ┌────────────┐
       GP0 ───┤            ├─── 5V (ไม่ต่อ)
       GP1 ───┤            ├─── GND ─── OLED GND
       GND ───┤ RP2040-Zero├─── 3V3 ─── OLED VCC
       GP2 ───┤            ├─── GP29
       GP3 ───┤            ├─── GP28
OLED SDA GP4 ─┤            ├─── GP27
OLED SCL GP5 ─┤            ├─── GP26
              └────────────┘
```

- OLED SDA → GP4 (Wire default SDA)
- OLED SCL → GP5 (Wire default SCL)
- OLED GND → GND
- OLED VCC → 3V3

ผังเป็นภาพย่อและแสดงเฉพาะบริเวณขาที่เกี่ยวข้อง ไม่ใช่สเกลจริง ให้ยึดชื่อขาที่พิมพ์บนบอร์ดและตรวจ revision ก่อนต่อสาย

## Build & Upload

ติดตั้ง PlatformIO แล้วรันใน Git Bash ที่โฟลเดอร์โปรเจกต์:

```bash
pio run
pio run -t upload
```

อัปโหลดครั้งแรก: กด BOOT ค้างไว้ เสียบ USB แล้วปล่อย BOOT จากนั้นอัปโหลด firmware ตามขั้นตอน PlatformIO/BOOTSEL ที่รองรับบอร์ด หากอัปโหลดอัตโนมัติไม่พบพอร์ต ให้เข้า BOOTSEL แล้วอัปโหลดไฟล์ UF2 จาก `.pio/build/rp2040-zero/` ด้วยตนเอง

## ติดตั้ง Windows แบบ Auto-start

ต้องใช้ Windows และ Python 3.10+; การติดตั้งครั้งแรกต้องต่ออินเทอร์เน็ตเพื่อ build แอปและดาวน์โหลด dependencies จากนั้นแอปจะเปิดเองหลัง sign in โดยไม่แสดงหน้าต่าง console

เปิด Git Bash ในโฟลเดอร์โปรเจกต์ แล้วรัน:

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./host-app/setup_windows.ps1
```

ตัวติดตั้งข้างต้นลงแอปบนเครื่องนี้ สำหรับสร้างไฟล์ติดตั้งเพื่อแชร์ หลังมี `host-app/dist/OledLanguageIndicator.exe` แล้วรัน:

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./host-app/build_shareable_installer.ps1
```

ได้ไฟล์แชร์ให้ผู้ใช้กดติดตั้งที่ `host-app/dist/OledLanguageIndicatorSetup.exe` แอปจะรอหา RP2040-Zero และเชื่อมต่อใหม่อัตโนมัติเมื่อบอร์ดเสียบทีหลัง ถ้าต้องการถอนการติดตั้ง ให้รัน `uninstall_windows.ps1` ในโฟลเดอร์ติดตั้งใต้ `%LOCALAPPDATA%/Programs/OledLanguageIndicator`

## Firmware Status

ต้นแบบ; `pio run` ผ่านแล้ว รุ่น OLED และ address ยังต้องตรวจยืนยัน
