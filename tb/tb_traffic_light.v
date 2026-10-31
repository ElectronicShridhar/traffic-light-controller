// =====================================================================
// tb_traffic_light.v — testbench (works with Icarus Verilog: iverilog + vvp)
// =====================================================================
`timescale 1ns/1ps

module tb_traffic_light;

    reg clk = 0;
    reg rst = 1;
    reg ambulance_ns = 0;
    reg ambulance_ew = 0;
    wire [1:0] ns_light, ew_light;

    traffic_light_controller DUT (
        .clk(clk), .rst(rst),
        .ambulance_ns(ambulance_ns),
        .ambulance_ew(ambulance_ew),
        .ns_light(ns_light),
        .ew_light(ew_light)
    );

    // 10ns clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic.vcd");
        $dumpvars(0, tb_traffic_light);

        // reset
        #12 rst = 0;

        // let it run a normal cycle
        #300;

        // simulate ambulance arriving on EW road while NS is green
        ambulance_ew = 1;
        #100;
        ambulance_ew = 0;   // ambulance has passed

        #300;
        $finish;
    end

    initial
        $monitor("t=%0t state_ns=%b state_ew=%b amb_ns=%b amb_ew=%b",
                   $time, ns_light, ew_light, ambulance_ns, ambulance_ew);

endmodule
