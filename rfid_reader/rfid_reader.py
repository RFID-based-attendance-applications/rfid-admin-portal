import serial
import time
import sys

# Ganti 'COM3' dengan port yang sesuai di komputer Anda
# Untuk Linux/Mac, biasanya '/dev/ttyUSB0' atau '/dev/ttyACM0'
SERIAL_PORT = 'COM3'
BAUD_RATE = 9600

def main():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        print("RFID Reader connected.", file=sys.stderr) # Log ke stderr
        while True:
            if ser.in_waiting > 0:
                raw_data = ser.readline().decode('utf-8').strip()
                if raw_data and raw_data.startswith('ID:'): 
                    rfid_id = raw_data[3:] 
                    print(rfid_id) 
                    sys.stdout.flush()
    except serial.SerialException as e:
        print(f"Serial error: {e}", file=sys.stderr)
    except KeyboardInterrupt:
        print("\nExiting...", file=sys.stderr)
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()

if __name__ == "__main__":
    main()