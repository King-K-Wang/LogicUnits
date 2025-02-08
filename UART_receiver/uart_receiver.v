/**
 * @filename: uart_receiver.v
 * @author: K.Wang
 * @date: 2025.01
 * @version: V1.2
 * @brief: UART Receiver with 8-bits data width, 1-stop bit, no parity check, no flow control
 * @details: (1) UART only supports 8 bit data 1 start bit, no parity check, stop bit should more than 1 bit, flow control is not supported.
 *           (2) You can change parameter to adjust different baud rate and clock frequency, default is 100MHz clock and 1Mbps baud rate.
 *           (3) Pay attention not overflow.
 *           (4) Valid output and data output clock(state machine) can be adjusted by parameter to satisfy timing.
 * @reference: without parameter
 *             uart_receiver uart_receiver_inst (
 *              .clock(clock),
 *              .resetn(resetn),
 *              .rx(rx),
 *              .rx_valid(rx_valid),
 *              .rx_data(rx_data)
 *              );
 * @reference: with parameter
 *             uart_receiver #(
 *              .CLOCK_COUNTER_BIT(9),
 *              .CLOCK_COUNTER(899),
 *              .CAPTURE_LSB1(149),
 *              .CAPTURE_LSB2(249),
 *              .CAPTURE_LSB3(349),
 *              .CAPTURE_LSB4(449),
 *              .CAPTURE_LSB5(549),
 *              .CAPTURE_LSB6(649),
 *              .CAPTURE_LSB7(749),
 *              .CAPTURE_LSB8(849),
 *              .VALID_OUT(889),
 *              .DATA_OUT(890)
 *              )
 *             uart_receiver_inst (
 *              .clock(clock),
 *              .resetn(resetn),
 *              .rx(rx),
 *              .rx_valid(rx_valid),
 *              .rx_data(rx_data)
 *              );
 * @note: 
 */

module uart_receiver #(
  parameter CLOCK_COUNTER_BIT = 9,
  parameter CLOCK_COUNTER = 899,
  parameter CAPTURE_LSB1 = 149,
  parameter CAPTURE_LSB2 = 249,
  parameter CAPTURE_LSB3 = 349,
  parameter CAPTURE_LSB4 = 449,
  parameter CAPTURE_LSB5 = 549,
  parameter CAPTURE_LSB6 = 649,
  parameter CAPTURE_LSB7 = 749,
  parameter CAPTURE_LSB8 = 849,
  parameter VALID_OUT = 889,
  parameter DATA_OUT = 890
  ) (
  input wire clock,
  input wire resetn,
  input wire rx,
  output reg rx_valid,
  output reg [7:0] rx_data
);

// start bit detection
reg rx_start;
always @(posedge clock or negedge resetn) begin
  if(!resetn) begin
    rx_start <= 0;
  end else begin
    rx_start <= rx;
  end
end

// receive state machine
reg [CLOCK_COUNTER_BIT:0] rx_cnt;
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    rx_cnt <= 0;
  end else begin
    if (rx_cnt == 0) begin
      if (rx_start == 1 && rx == 0) begin
        rx_cnt <= 1;
      end else begin
        rx_cnt <= 0;
      end
    end else begin
      if (rx_cnt == CLOCK_COUNTER) begin
        rx_cnt <= 0;
      end else begin
        rx_cnt <= rx_cnt + 1;
      end
    end
  end
end

// data capture
reg [7:0] rx_data_reg;
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    rx_data_reg <= 0;
  end else begin
    case (rx_cnt)
      CAPTURE_LSB1: begin
        rx_data_reg <= {rx_data_reg[7:1], rx};
      end
      CAPTURE_LSB2: begin
        rx_data_reg <= {rx_data_reg[7:2], rx, rx_data_reg[0]};
      end
      CAPTURE_LSB3: begin
        rx_data_reg <= {rx_data_reg[7:3], rx, rx_data_reg[1:0]};
      end
      CAPTURE_LSB4: begin
        rx_data_reg <= {rx_data_reg[7:4], rx, rx_data_reg[2:0]};
      end
      CAPTURE_LSB5: begin
        rx_data_reg <= {rx_data_reg[7:5], rx, rx_data_reg[3:0]};
      end
      CAPTURE_LSB6: begin
        rx_data_reg <= {rx_data_reg[7:6], rx, rx_data_reg[4:0]};
      end
      CAPTURE_LSB7: begin
        rx_data_reg <= {rx_data_reg[7], rx, rx_data_reg[5:0]};
      end
      CAPTURE_LSB8: begin
        rx_data_reg <= {rx, rx_data_reg[6:0]};
      end
      default: rx_data_reg <= rx_data_reg;
    endcase
  end
end

// output data and valid
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    rx_data <= 0;
  end else begin
    if (rx_cnt == DATA_OUT) begin
      rx_data <= rx_data_reg;
    end else begin
      rx_data <= rx_data;
    end
  end
end

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    rx_valid <= 0;
  end else begin
    if (rx_cnt == VALID_OUT) begin
      rx_valid <= 1;
    end else begin
      rx_valid <= 0;
    end
  end
end

endmodule
