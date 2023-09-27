`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2023 06:58:51 PM
// Design Name: 
// Module Name: TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TB();
localparam DATA_SIZE = 8;
reg                   rSystem_Clock = 0;                                        
reg                   rReset        = 0;                                               
reg                   rValid_Data   = 0; //0  = idle state, 1 = new data on iData 
reg [DATA_SIZE-1 :0]  rData_in      = 98;                                                
wire                  rData_out     ;                                                
wire                  rBusy         ;                                       

 UART_TX
#(
        .SYSTEM_CLOCK     (125_000_000),
        .UART_BAUDRATE    (9600 ),
        .DATA_SIZE        (8    ),
        .PARITY_ENABLE    (1'b1 ),
        .PARITY_ODD_EVEN  (1'b0 ),
        .STOP_BITS        (1    )
)
UART_TX_i
(
    .iSystem_Clock(rSystem_Clock),
    .iReset       (rReset       ),       
    .iValid_Data  (rValid_Data  ),
    .iData        (rData_in     ),        
    .oData        (rData_out    ),        
    .oBusy        (rBusy        )
); 

initial begin
    rReset = 1;
    #100;
    rReset = 0;
end   

always begin
    rSystem_Clock <= ~rSystem_Clock;
    #4;
end

always @ (posedge rSystem_Clock) begin
    if(!rBusy) begin
        rValid_Data <= 1;
        rData_in    <= rData_in + 1;
    end else 
        rValid_Data <= 0;
end
endmodule
