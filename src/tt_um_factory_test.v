`default_nettype none

module tt_um_medication_reminder (
    input  wire        clk,	
    input  wire        rst_n,
    input  wire        ena,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);

    // Internal signals
    reg [7:0] medications [0:15];  // Medication database
    reg [3:0] med_pointer;         // Number of stored medications

    reg [7:0] internal_clock;      // Scheduler's internal clock
    reg medication_due;            // Signal: medication is due
    reg [3:0] due_med_idx;          // Which medication is due

    reg [15:0] log_memory [0:15];   // Logger memory: [15:8]=time, [7:0]=medication idx
    reg [3:0] log_pointer;          // Points to last written log
    reg [3:0] lcd_pointer;          // Points to current displayed log

    reg [7:0] lcd_reg;              // LCD output register

    reg ack_prev;                   // Previous ack button state (for edge detection)

    // Add new medication logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            med_pointer <= 0;
        end else if (ui_in[7]) begin
            medications[med_pointer] <= ui_in[6:0];
            med_pointer <= med_pointer + 1;
        end
    end

    // Scheduler Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            internal_clock <= 0;
            medication_due <= 0;
            due_med_idx <= 0;
        end else begin
            internal_clock <= internal_clock + 1;
            medication_due <= 0;
            for (integer i = 0; i < 16; i = i + 1) begin
                if (i < med_pointer) begin
                    if (internal_clock == medications[i]) begin
                        medication_due <= 1;
                        due_med_idx <= i[3:0];
                    end
                end
            end
        end
    end

    // Logger Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            log_pointer <= 0;
        end else if (medication_due) begin
            log_memory[log_pointer] <= {internal_clock, due_med_idx}; // Log time and medication index
            log_pointer <= log_pointer + 1;
        end
    end

    // LCD Controller Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lcd_pointer <= 0;
            lcd_reg <= 8'h00;
            ack_prev <= 0;
        end else begin
            ack_prev <= uio_in[0]; // Capture previous state for edge detection

            if (uio_in[0] && !ack_prev) begin
                // Rising edge detected: user pressed ACK button
                lcd_pointer <= lcd_pointer + 1; // Cycle to next log entry
            end

            lcd_reg <= log_memory[lcd_pointer][15:8]; // Display time part of the log
        end
    end

    // Assign outputs
    assign uo_out  = lcd_reg;    // LCD shows the time when medication was due
    assign uio_out = 8'h00;      // Not driving any special signals
    assign uio_oe  = 8'h00;      // All UIO pins set to input mode except uio_in[0]

endmodule
