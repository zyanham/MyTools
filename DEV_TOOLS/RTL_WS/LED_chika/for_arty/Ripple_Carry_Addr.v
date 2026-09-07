module Ripple_Carry_Addr(
    input        CLK,
    input        RST,
    input  [3:0] SLIDE_SW_SIG,
    input        PUSH_SW_SIG,
    output [3:0] ANSWER_OUT
);

    reg [3:0] LATCH_VALUE;
    wire carry01;
    wire carry12;
    wire carry23;
    wire s0, s1, s2, s3;

    ADDR ADDR0(
        .A   (SLIDE_SW_SIG[0]),
        .B   (LATCH_VALUE[0]),
        .Cin (1'd0),
        .S   (s0),
        .Cout(carry01),
    );

    ADDR ADDR1(
        .A   (SLIDE_SW_SIG[1]),
        .B   (LATCH_VALUE[1]),
        .Cin (carry01),
        .S   (s1),
        .Cout(carry12),
    );

    ADDR ADDR2(
        .A   (SLIDE_SW_SIG[2]),
        .B   (LATCH_VALUE[2]),
        .Cin (carry12),
        .S   (s2),
        .Cout(carry23),
    );

    ADDR ADDR3(
        .A   (SLIDE_SW_SIG[3]),
        .B   (LATCH_VALUE[3]),
        .Cin (carry23),
        .S   (s3),
        .Cout(),
    );

    always @(posedge CLK) begin
        if(~RST) begin
            LATCH_VALUE[3:0] <= #1 4'd0;
        end else if(PUSH_SW_SIG) begin
            LATCH_VALUE[3:0] <= {s3, s2, s1, s0};
        end
    end

    assign ANSWER_OUT[3:0] = LATCH_VALUE[3:0];

endmodule
