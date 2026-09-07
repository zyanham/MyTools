module ADDR(
    input A,
    input B,
    input Cin,
    output Cout,
    output S
);

    wire AB,
    wire Cab,
    wire Cabc,

    assign AB  = A ^ B;       // A+B
    assign Cab = A & B;       // Carry in A+B

    assign S    = AB ^ Cin;   // AB+Cin
	assign Cabc = AB & Cin;   // Carry in AB+Cin
    assign Cout = Cab | Cabc; // Carry in A+B+Cin

endmodule
