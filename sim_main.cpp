#include <ios>
#include <string>
// #include "Vour.h"
#include "Vabc.h"
#include <verilated.h>

using std::string;

#if VM_TRACE
#include <verilated_vcd_c.h>
#endif

#define FSC (4433618.75 * 4) // 225.549389ns / 4
// #define FSC (5000000 * 4) // 225.549389ns / 4
// #define FSC (250000 * 4) // 1 MHz
// 56380 picoseconds
// #define FSC 1000000 // 1us

// Current simulation time (64-bit unsigned)
vluint64_t* time_stamp_ptr;

// Called by $time in Verilog
double sc_time_stamp() {
    assert(time_stamp_ptr != nullptr);
    return *time_stamp_ptr; // Note does conversion to real, to match SystemC
}

template <class Vmodule>
class TestBench {
protected:
    vluint64_t m_tickcount;
    Vmodule*   m_core;

    // Need to add a new class variable
    VerilatedVcdC* m_trace;

public:
    TestBench(void) {
        m_core           = new Vmodule;
        m_tickcount      = 0l;
        ::time_stamp_ptr = &m_tickcount;

        // According to the Verilator spec, you *must* call
        // traceEverOn before calling any of the tracing functions
        // within Verilator.
#if VM_TRACE // If verilator was invoked with --trace argument,
        Verilated::traceEverOn(true);
#endif
    }

protected:
    virtual ~TestBench(void) {
        ::time_stamp_ptr = nullptr;
        delete m_core;
        m_core = NULL;
    }

public:
    // Open/create a trace file
    virtual void opentrace(const char* vcdname) {
#if VM_TRACE // If verilator was invoked with --trace argument,
        if (!m_trace) {
            m_trace = new VerilatedVcdC;
            m_core->trace(m_trace, 99);
            // m_trace->set_time_unit("s");
            char x[256];
            // 68040
            sprintf(x, "%.3lfps", 1000000000000.0 / 10.0 / FSC);

            VL_PRINTF("Enabling waves into %s... %s\n", vcdname, x);
            m_trace->set_time_unit("s");
            m_trace->set_time_resolution(x); // 10us = 10 kHz, 1us = 100 kHz, 0.1us = 1 MHz
            m_trace->open(vcdname);
        }
#endif
    }

    // Close a trace file
    virtual void closetrace(void) {
#if VM_TRACE // If verilator was invoked with --trace argument,
        if (m_trace) {
            m_trace->close();
            m_trace = NULL;
        }
#endif
    }

    virtual void reset(void) {
    }

    virtual void tick(void) {
        // combinatorial logic
        m_core->clk = 0;
        m_core->eval();
        if (m_trace != nullptr && m_tickcount != 0) {
            m_trace->dump(10 * m_tickcount - 2);
        }

        // positive edge of the clock
        m_core->clk = 1;
        m_core->eval();
        if (m_trace != nullptr) {
            m_trace->dump(10 * m_tickcount);
        }

        // negative edge of the clock
        m_core->clk = 0;
        m_core->eval();
        if (m_trace != nullptr) {
            m_trace->dump(10 * m_tickcount + 5);
            m_trace->flush(); // can use the assert() function between now and the next tick
        }

        m_tickcount++;
    }

    virtual bool done(void) {
        return (Verilated::gotFinish());
    }
};

class TestBench_ABC : public TestBench<Vabc> {
public:
    virtual void reset(void) {
        m_core->clk = 0;
        m_core->rst = 1;
        m_core->a   = 0;
        this->tick();
        m_core->rst = 0;

        m_tickcount = 0;
    }

    virtual void tick(void) {
        // Request that the testbench toggle the clock within
        // Verilator
        TestBench<Vabc>::tick();

        // if (m_core->b == 0) {
        //     VL_PRINTF("[%" VL_PRI64 "d] clk=%x a=%x b=%x\n", m_tickcount, m_core->clk, m_core->a, m_core->b);
        // }

        // bool writeout;
        // Check for debugging conditions
        //
        // For example:
        //
        //   1. We might be interested any time a wishbone master
        //	command is accepted
        //
        // if ((m_core->v__DOT__wb_stb) && (!m_core->v__DOT__wb_stall)) {
        //     writeout = true;
        // }
        //
        //   2. as well as when the slave finally responds
        //
        // if (m_core->v__DOT__wb_ack) {
        //     writeout = true;
        // }

        // if (writeout) {
        //     // Now we'll debug by printf's and examine the
        //     // internals of m_core
        //     printf("%8ld: %s %s ...\n", m_tickcount, (m_core->v__DOT__wb_cyc) ? "CYC" : "   ", (m_core->v__DOT__wb_stb) ? "STB" : "   ", ...);
        // }
    }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);

    // Set debug level, 0 is off, 9 is highest presently used
    Verilated::debug(0);

    // Randomization reset policy
    Verilated::randReset(2);

    // General logfile
    std::ios::sync_with_stdio();

    Verilated::commandArgs(argc, argv);

    TestBench_ABC* tb = new TestBench_ABC();

    tb->reset();

    tb->opentrace("vlt_dump.vcd");

    while (!tb->done()) {
        tb->tick();
    }

    tb->closetrace();

    exit(EXIT_SUCCESS);

    /*
    while (!Verilated::gotFinish() && main_time < 1000000) {
        main_time++;

        top->clk = main_time & 1;

        top->eval();

#if VM_TRACE
        // Dump trace data for this cycle
        if (tfp)
            tfp->dump(main_time);
#endif

        // VL_PRINTF("[%" VL_PRI64 "d] clk=%x a=%" VL_PRI64 "x b=%" VL_PRI64 "x\n", t, top->clk, top->a, top->b);
        VL_PRINTF("[%" VL_PRI64 "d] clk=%x a=%x b=%x\n", main_time, top->clk, top->a, top->b);

        top->rst = 0; //main_time == 1;
    }

    top->final();

    // Close trace if opened
#if VM_TRACE
    if (tfp) {
        tfp->close();
        tfp = NULL;
    }
#endif

    delete top;
    top = NULL;
*/

    delete tb;
    tb = nullptr;

    exit(0);
}
