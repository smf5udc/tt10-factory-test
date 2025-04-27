import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.result import TestFailure
import random

async def reset_dut(dut):
    dut.rst_n.value = 1
    dut.key_in.value = 0
    dut.key_valid.value = 0
    dut.time_in.value = 0
    dut.time_tick.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)

@cocotb.test()
async def test_med_reminder_basic(dut):
    """Basic test of adding a medication and acknowledging it."""
    # Reset
    await reset_dut(dut)

    # Helper: Send a key press
    async def send_key(key_ascii):
        dut.key_in.value = key_ascii
        dut.key_valid.value = 1
        await RisingEdge(dut.clk)
        dut.key_valid.value = 0
        await RisingEdge(dut.clk)

    # Add a medication by pressing 'A'
    dut.time_in.value = 0x1200  # Suppose current time is 12:00 in BCD
    await send_key(ord('A'))

    # Check if LCD output valid with 'M' for med
    await RisingEdge(dut.clk)
    if not dut.lcd_valid.value:
        raise TestFailure("LCD should be valid after adding medication")
    if dut.lcd_out.value != ord('M'):
        raise TestFailure(f"Expected LCD output 'M', got {chr(dut.lcd_out.value)}")

    # Simulate time tick at medication time
    await Timer(1, units="us")
    dut.time_in.value = 0x1200  # Match scheduled time
    dut.time_tick.value = 1
    await RisingEdge(dut.clk)
    dut.time_tick.value = 0

    # Check if LCD output shows the medication
    await RisingEdge(dut.clk)
    if not dut.lcd_valid.value:
        raise TestFailure("LCD should be valid on medication alert")
    if dut.lcd_out.value != ord('M'):
        raise TestFailure(f"Expected LCD output 'M' during alert, got {chr(dut.lcd_out.value)}")

    # Acknowledge by pressing 'Y'
    await send_key(ord('Y'))
    await RisingEdge(dut.clk)

    # Dump the log by pressing 'D'
    await send_key(ord('D'))

    # Check if log output is valid
    for _ in range(3):
        await RisingEdge(dut.clk)
        if dut.log_valid.value:
            if dut.log_out.value != ord('M'):
                raise TestFailure(f"Expected log out 'M', got {chr(dut.log_out.value)}")
            break
    else:
        raise TestFailure("No valid log output found after dumping")

    cocotb.log.info("Basic medication reminder test passed!")
