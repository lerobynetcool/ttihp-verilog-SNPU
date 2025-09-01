# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    OP_RSET = 0<<5
    OP_PLRS = 1<<5
    OP_PLGT = 2<<5
    OP_SHFF = 3<<5
    OP_HDSP = 4<<5
    OP_HDSC = 5<<5
    OP_HPLY = 6<<5
    OP_BDSP = 7<<5

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1

    dut.uio_in.value = 0
    for i in range(30):
        await ClockCycles(dut.clk, 1)
        print(dut.ui_in.value,dut.uo_out.value,dut.uio_out.value)

    dut.uio_in.value = 255
    for i in range(30):
        await ClockCycles(dut.clk, 1)
        print(dut.ui_in.value,dut.uo_out.value,dut.uio_out.value)



    # dut.rst_n.value = 1
    # await ClockCycles(dut.clk, 1)
    # async def hello(OP_CODE):
    #     dut.ui_in.value = OP_CODE
    #     await ClockCycles(dut.clk, 1)
    #     print(dut.uo_out.value,dut.ui_in.value,OP_CODE)
    #     await ClockCycles(dut.clk, 1)
    #     print(dut.uo_out.value,dut.ui_in.value,OP_CODE)


    # await hello(OP_RSET)
    # await hello(OP_PLRS)
    # await hello(OP_PLGT)
    # await hello(OP_SHFF)
    # await hello(OP_HDSP)
    # await hello(OP_HDSC)
    # await hello(OP_HPLY)
    # await hello(OP_BDSP)


    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
