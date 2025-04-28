`default_nettype none

module tt_um_factory_test (
    input  wire        clk,	
    input  wire        rst_n,
    input  wire        ena,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);

    // Internal signals to connect submodules
    reg [7:0] medications [0:15];  // Medication memory (Database)
    reg [3:0] med_pointer;         // Pointer to track medications
    reg [7:0] internal_clock;      // Scheduler's internal clock
    reg medication_due;            // Signal to indicate when medication is due
    reg [7:0] log_memory [0:15];   // Logger memory
    reg [3:0] log_pointer;         // Pointer for the logger
    reg log_ready;                 // Signal when log is ready
    reg [7:0] lcd_reg;             // LCD register for output

    // Medication Database Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            med_pointer <= 0;
        end else begin
            if (ui_in[7]) begin // UI input to add new medication
                medications[med_pointer] <= ui_in[6:0]; // Store medication data
                med_pointer <= med_pointer + 1;
            end
        end
    end

    wire [7:0] med_data = medications[0]; // Use first medication entry for now

    // Scheduler Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            internal_clock <= 0;
            medication_due <= 0;
        end else begin
            internal_clock <= internal_clock + 1;
            if (internal_clock == med_data) begin
                medication_due <= 1; // Medication is due when clocks match
            end else begin
                medication_due <= 0;
            end
        end
    end

    // Logger Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            log_pointer <= 0;
            log_ready <= 0;
        end else begin
            if (medication_due) begin
                log_memory[log_pointer] <= log_pointer; // Store log entry
                log_pointer <= log_pointer + 1;
                log_ready <= 1;
            end else begin
                log_ready <= 0;
            end
        end
    end

    wire [7:0] log_data = log_memory[0]; // Use first log entry for now

    // LCD Controller Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lcd_reg <= 8'h00;
        end else begin
            lcd_reg <= log_data; // Show log data on LCD
        end
    end

    // Assign output ports
    assign uo_out = lcd_reg;  // LCD output mapped to uo_out
    assign uio_out = 8'h00;   // No output for uio_out (can be customized)
    assign uio_oe  = 8'h00;   // No output enable for uio_oe (can be customized)

endmodule
