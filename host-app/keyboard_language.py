import argparse
import ctypes
import sys
import time
from ctypes import wintypes

import serial
from serial.tools import list_ports


LANG_ENGLISH = 0x0009
LANG_THAI = 0x001E
BAUD_RATE = 115200


user32 = ctypes.WinDLL("user32", use_last_error=True)
user32.GetForegroundWindow.restype = wintypes.HWND
user32.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
user32.GetWindowThreadProcessId.restype = wintypes.DWORD
user32.GetKeyboardLayout.argtypes = [wintypes.DWORD]
user32.GetKeyboardLayout.restype = ctypes.c_void_p


def get_keyboard_language() -> str:
    window = user32.GetForegroundWindow()
    if not window:
        return "--"

    process_id = wintypes.DWORD()
    thread_id = user32.GetWindowThreadProcessId(window, ctypes.byref(process_id))
    if not thread_id:
        return "--"

    layout = user32.GetKeyboardLayout(thread_id)
    language_id = int(layout or 0) & 0x03FF
    if language_id == LANG_ENGLISH:
        return "EN"
    if language_id == LANG_THAI:
        return "TH"
    return "--"


def find_device_port() -> str:
    for port in list_ports.comports():
        if port.vid == 0x2E8A and port.pid == 0x00C0:
            return port.device
    raise RuntimeError("ไม่พบ RP2040-Zero (USB VID:PID 2E8A:00C0)")


def main() -> int:
    parser = argparse.ArgumentParser(description="ส่งภาษา keyboard ของหน้าต่างที่ active ไปยัง OLED ผ่าน RP2040-Zero")
    parser.add_argument("--port", help="พอร์ต Serial เช่น COM6 (ถ้าไม่ระบุจะค้นหา RP2040 อัตโนมัติ)")
    args = parser.parse_args()

    if sys.platform != "win32":
        parser.error("โปรแกรมนี้ใช้ Windows API และทำงานบน Windows เท่านั้น")

    try:
        port_name = args.port or find_device_port()
        with serial.Serial(port_name, BAUD_RATE, timeout=0.1, write_timeout=1) as device:
            print(f"ส่งสถานะภาษาไปยัง {port_name}; กด Ctrl+C เพื่อหยุด")
            previous_language = None
            while True:
                language = get_keyboard_language()
                if language != previous_language:
                    device.write((language + "\n").encode("ascii"))
                    previous_language = language
                    print(f"Keyboard: {language}")
                time.sleep(0.2)
    except KeyboardInterrupt:
        print("\nหยุดโปรแกรมแล้ว")
    except (serial.SerialException, RuntimeError) as error:
        print(f"ผิดพลาด: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
