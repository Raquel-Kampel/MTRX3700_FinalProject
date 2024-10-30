module led_display(
    input [11:0] distance,    // 12-bit distance input
    output reg [17:0] LEDR    // 18-bit LED output
);

    always_comb begin
        if (distance < 12'd10)       LEDR = 18'b111111111111111111; // 0-10 cm, all LEDs on
        else if (distance < 12'd20)  LEDR = 18'b011111111111111111; // 10-20 cm, 17 LEDs on
        else if (distance < 12'd30)  LEDR = 18'b001111111111111111; // 20-30 cm, 16 LEDs on
        else if (distance < 12'd40)  LEDR = 18'b000111111111111111; // 30-40 cm, 15 LEDs on
        else if (distance < 12'd50)  LEDR = 18'b000011111111111111; // 40-50 cm, 14 LEDs on
        else if (distance < 12'd60)  LEDR = 18'b000001111111111111; // 50-60 cm, 13 LEDs on
        else if (distance < 12'd70)  LEDR = 18'b000000111111111111; // 60-70 cm, 12 LEDs on
        else if (distance < 12'd80)  LEDR = 18'b000000011111111111; // 70-80 cm, 11 LEDs on
        else if (distance < 12'd90)  LEDR = 18'b000000001111111111; // 80-90 cm, 10 LEDs on
        else if (distance < 12'd100) LEDR = 18'b000000000111111111; // 90-100 cm, 9 LEDs on
        else if (distance < 12'd110) LEDR = 18'b000000000011111111; // 100-110 cm, 8 LEDs on
        else if (distance < 12'd120) LEDR = 18'b000000000001111111; // 110-120 cm, 7 LEDs on
        else if (distance < 12'd130) LEDR = 18'b000000000000111111; // 120-130 cm, 6 LEDs on
        else if (distance < 12'd140) LEDR = 18'b000000000000011111; // 130-140 cm, 5 LEDs on
        else if (distance < 12'd150) LEDR = 18'b000000000000001111; // 140-150 cm, 4 LEDs on
        else if (distance < 12'd160) LEDR = 18'b000000000000000111; // 150-160 cm, 3 LEDs on
        else if (distance < 12'd170) LEDR = 18'b000000000000000011; // 160-170 cm, 2 LEDs on
        else if (distance < 12'd180) LEDR = 18'b000000000000000001; // 170-180 cm, 1 LED on
        else                         LEDR = 18'b000000000000000000; // Beyond 180 cm, no LEDs on
    end
endmodule
