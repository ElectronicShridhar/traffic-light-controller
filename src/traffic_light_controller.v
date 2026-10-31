// =====================================================================
// traffic_light_controller.v
// 4-way traffic light controller with ambulance-priority override
// Simple 2-road (NS / EW) version — extend to 4-way by duplicating logic
// =====================================================================

module traffic_light_controller (
    input  wire clk,            // system clock
    input  wire rst,            // active-high synchronous reset
    input  wire ambulance_ns,   // '1' when camera/sensor detects ambulance on NS road
    input  wire ambulance_ew,   // '1' when camera/sensor detects ambulance on EW road
    output reg  [1:0] ns_light, // 00=Red 01=Yellow 10=Green
    output reg  [1:0] ew_light
);

    // ---------------- light encoding ----------------
    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;

    // ---------------- FSM states ----------------
    localparam S_NS_GREEN  = 3'd0;
    localparam S_NS_YELLOW = 3'd1;
    localparam S_EW_GREEN  = 3'd2;
    localparam S_EW_YELLOW = 3'd3;
    localparam S_AMB_NS    = 3'd4;   // emergency override: force NS green
    localparam S_AMB_EW    = 3'd5;   // emergency override: force EW green

    reg [2:0]  state, next_state;
    reg [31:0] timer;             // counts clock cycles in current state

    // ---------------- timing (in clock cycles; scale to your clk) -------
    localparam T_GREEN  = 32'd10;
    localparam T_YELLOW = 32'd3;

    // ================= sequential: state + timer =================
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_GREEN;
            timer <= 0;
        end else if (state != next_state) begin
            state <= next_state;
            timer <= 0;
        end else begin
            timer <= timer + 1;
        end
    end

    // ================= next-state logic =================
    always @(*) begin
        next_state = state;
        case (state)
            S_NS_GREEN: begin
                if (ambulance_ew)              next_state = S_NS_YELLOW; // clear NS then flip to EW
                else if (timer >= T_GREEN)     next_state = S_NS_YELLOW;
            end
            S_NS_YELLOW: begin
                if (timer >= T_YELLOW)
                    next_state = ambulance_ew ? S_AMB_EW : S_EW_GREEN;
            end
            S_EW_GREEN: begin
                if (ambulance_ns)              next_state = S_EW_YELLOW;
                else if (timer >= T_GREEN)     next_state = S_EW_YELLOW;
            end
            S_EW_YELLOW: begin
                if (timer >= T_YELLOW)
                    next_state = ambulance_ns ? S_AMB_NS : S_NS_GREEN;
            end
            S_AMB_NS: begin   // hold NS green until ambulance has passed
                if (!ambulance_ns) next_state = S_NS_YELLOW;
            end
            S_AMB_EW: begin
                if (!ambulance_ew) next_state = S_EW_YELLOW;
            end
            default: next_state = S_NS_GREEN;
        endcase
    end

    // ================= output logic (Moore) =================
    always @(*) begin
        case (state)
            S_NS_GREEN,  S_AMB_NS: begin ns_light = GREEN;  ew_light = RED;    end
            S_NS_YELLOW:           begin ns_light = YELLOW; ew_light = RED;    end
            S_EW_GREEN,  S_AMB_EW: begin ns_light = RED;    ew_light = GREEN;  end
            S_EW_YELLOW:           begin ns_light = RED;    ew_light = YELLOW; end
            default:                begin ns_light = RED;    ew_light = RED;    end
        endcase
    end

endmodule
