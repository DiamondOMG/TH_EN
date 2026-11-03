---
type: project
title: OLED EN TH
status: prototype
platform:
  - raspberry-pi-rp2040-zero
  - platformio
  - arduino
tags:
  - rp2040-zero
  - oled
  - i2c
  - platformio
related:
  - README.md
  - hardware_lib.md
---

# OLED EN TH

## Overview

ระบบแสดงภาษาคีย์บอร์ด Windows ที่กำลังใช้งานเป็น `EN` หรือ `TH` ตัวใหญ่บน OLED 0.96 นิ้ว โปรแกรมบนคอมอ่าน layout ของหน้าต่างที่กำลังใช้งานและส่งให้ RP2040-Zero ผ่าน USB Serial

## Goals

- แสดง `EN` หรือ `TH` ตัวใหญ่ตาม keyboard layout ของหน้าต่าง foreground บน Windows
- ใช้ OLED I²C 0.96 นิ้ว
- ใช้โปรแกรม host บน Windows ส่งสถานะผ่าน USB Serial
- พัฒนาและอัปโหลดด้วย PlatformIO + Arduino

## Hardware

- บอร์ด: Raspberry Pi RP2040-Zero, Flash 2 MB
- จอ: OLED 0.96 นิ้ว I²C, ขา GND/VCC/SCL/SDA
- คอนโทรลเลอร์จอ: ตั้งต้นเป็น SSD1306 128x64; ยืนยันรุ่นจริงภายหลัง
- Address: ตั้งต้น `0x3C`; หากจอไม่ตอบสนองให้ตรวจ `0x3D`
- ไฟเลี้ยงจอ: VCC ต่อ 3V3 เพื่อความเข้ากันได้กับระดับสัญญาณ GPIO 3.3V

## Pin Map

| Function | Pin | Device | Direction | Notes |
|---|---|---|---|---|
| SDA | GP4 | OLED SDA | I/O | Wire default SDA on Raspberry Pi Pico Arduino core |
| SCL | GP5 | OLED SCL | Output | Wire default SCL on Raspberry Pi Pico Arduino core |
| 3.3 V | 3V3_OUT | OLED VCC | Power | ใช้กับโมดูลที่รองรับ 3.3 V |
| Ground | GND | OLED GND | Power | Ground ร่วม |

ต่อโดยยึดชื่อขาที่พิมพ์บนบอร์ด ไม่ใช้เลข physical pin เนื่องจากการนับอาจต่างกันตามภาพ/ด้านที่มอง

## Electrical / Safety Notes

- ห้ามป้อนสัญญาณ I²C 5 V เข้า GPIO ของ RP2040; ใช้ VCC 3.3 V กับจอ
- ถ้าจอมี pull-up I²C ไปยัง VCC ให้แน่ใจว่า VCC เป็น 3.3 V

## Firmware Architecture

- `src/main.cpp`: อ่านคำสั่ง `EN`/`TH` ผ่าน USB Serial และแสดงคำย่อภาษาขนาดใหญ่บน OLED
- `host-app/keyboard_language.py`: อ่าน keyboard layout ของหน้าต่างที่กำลังใช้งานบน Windows แล้วส่งสถานะผ่าน Serial

## Libraries

- U8g2; ใช้ driver SSD1306 I²C เป็นค่าเริ่มต้น

## Build & Upload

- Build: `pio run`
- Upload: `pio run -t upload` (หาก auto upload ไม่ทำงาน ให้เข้า BOOTSEL และใช้ไฟล์ UF2)
- PlatformIO target ใช้ `board = pico` สำหรับ RP2040-Zero ที่เข้ากันได้กับ RP2040 Pico; ใช้ Arduino Mbed core แทน Earle core
- หลังแฟลชแล้ว firmware ทำงานเมื่อจ่ายไฟ USB โดยไม่ต้องเปิด Serial Monitor

## Current State

- `pio run` ผ่านแล้วโดยใช้ PlatformIO Raspberry Pi platform / Arduino Mbed core กับ board target `pico`
- Firmware แสดง `--` จนกว่า host app จะส่งสถานะภาษา
- ยังไม่ได้ทดสอบ host app กับบอร์ดจริง
- รุ่นคอนโทรลเลอร์ OLED และ I²C address จริงยังไม่ยืนยัน

## Open Questions

- ตรวจว่า OLED เป็น SSD1306 128x64 หรือ SH1106 และ address เป็น `0x3C` หรือ `0x3D`
- ตรวจป้ายขา GP4/GP5 บนบอร์ดก่อนต่อสาย

## Issue Log

- TBD
