module pipeline_reg #(
  paramter DATA_WIDTH = 32
)(
  input logic clk,
  input logic reset_n,

  //Input Interface
  input logic in_valid,
  output logic in_ready,
  input logic [DATA_WIDTH-1:0] in_data,

  //Output Interface
  output logic out_valid,
  input logic out_ready,
  output logic [DATA_WIDTH-1:0] out_data
);

  //Internal Storage
  logic [DATA_WIDTH-1:0] data_q;
  logic valid_q;

  //Ready when buffer is empty or downstream is ready
  assign in_ready = ~valid_q || (out_ready);

  //output signals
  assign out_valid = valid_q;
  assign out_data = data_q;

  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
      valid_q = 1'b0;
    end else begin
      case({in_valid & in_ready, out_valid & out_ready})
        //Load new data and no output consumed
        2'b10: begin
          data_q <= in_data;
          valid_q <= 1'b1;
        end

        //output consumed , no new input
        2'b01: begin
          valid_q <= 1'b0;
        end

        //Simultaneous input and output
        2'b11: begin
          data_q <= in_data;
          valid_q<= 1'b1;
        end

        //Idle state
        default: begin
          valid_q <= valid_q;
        end
      endcase
    end
  end
endmodule
          

    end






    
