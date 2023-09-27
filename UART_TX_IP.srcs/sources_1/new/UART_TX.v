`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 10:38:20 PM
// Design Name: 
// Module Name: UART_TX
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


module UART_TX
 #(parameter        SYSTEM_CLOCK     = 50e6, //default clock is 50Mhz
   parameter        UART_BAUDRATE    = 9600, // UART Baudrate clock
   parameter        DATA_SIZE        = 8, // how many bits in the data vector
   parameter [0:0]  PARITY_ENABLE    = 1'b0, // 0 - don't add parity, 1- add parity
   parameter [0:0]  PARITY_ODD_EVEN  = 1'b0, // 0 - parity even,      1 - parity odd 
   parameter        STOP_BITS        = 1 // how many stop bits, atleast 1.
 )
(
    input                   iSystem_Clock,
    input                   iReset,
    input                   iValid_Data, //0  = idle state, 1 = new data on iData
    input [0: DATA_SIZE-1]  iData,
    output                  oData,
    output                  oBusy
    /*,
    input iParity_enable,
    input iParity_odd_even*/
    );
         
        //MAanging UART_TX clock
    localparam [31:0]   UART_BAUD_RATE      = (SYSTEM_CLOCK / UART_BAUDRATE / 2) -1;
        
        //Data receiving
    localparam CATCH_DATA               = 2'd0;
    localparam UART_SEND_DATA           = 2'd1;
    localparam UART_DONE                = 2'd2;
        
        //UART States
    localparam IDLE                     = 3'd0;
    localparam START                    = 3'd1;
    localparam DATA                     = 3'd2;
    localparam PARITY                   = 3'd3;
    localparam STOP                     = 3'd4;
    
    
        //Clock variables
    integer     rUART_Clock_Counter = UART_BAUD_RATE;
    reg         rUART_Clock         = 1'b0;
    reg         rReset              = 1'b0;
    
    //Data Receving variales 
    reg [1:0]           rCatch_State  = CATCH_DATA;
    reg [0:DATA_SIZE-1] rCatch_data   = 0;
    
        //Send Data Variables
    reg                     rValid_Data         = 1'b0;
    reg                     rData               = 1'b1;
    reg [0:DATA_SIZE-1]     rData_To_send       = 0;
    reg [2:0]               rUART_Tx_State      = START;
    integer                 rCount_Data_bits    = DATA_SIZE-1; 
    reg                     rBusy               = 1'b1; // cant receive data, busy sending
    reg [3:0]               rStop_bits_counter  = STOP_BITS - 1;
    
    
    assign oBusy = rBusy;
    assign oData = rData;
    
    //Generates UART Clock    
    always @(posedge iSystem_Clock, posedge iReset) begin
        if(iReset) begin
            rReset              <= 1'b1; //cancel Reset
            rUART_Clock         <= 1'b0;
            rUART_Clock_Counter <= UART_BAUD_RATE;
        end else begin
            rReset              <= 1'b0;
            if(rUART_Clock_Counter > 0) begin
               rUART_Clock_Counter <= rUART_Clock_Counter - 1;
            end else begin
               rUART_Clock_Counter <= UART_BAUD_RATE;
               rUART_Clock         <= ~rUART_Clock;
            end 
        end
    end
    
    
    //Controlling oBusy
    always @(posedge iSystem_Clock, posedge iReset) begin
        if(iReset) begin
            rBusy           <= 1'b1; // busy sending data, cant receive new data 
            rCatch_State    <= CATCH_DATA;
            rValid_Data     <= 1'b0;
        end else begin
            case (rCatch_State)
                (CATCH_DATA): begin
                    rValid_Data <= iValid_Data;
                    rCatch_data <= iData; 
                    if(iValid_Data && !rBusy) begin
                        rCatch_State <= UART_SEND_DATA;
                        rBusy  <= 1'b1;
                    end else begin
                        rBusy  <= 1'b0;
                    end
                end
                
                (UART_SEND_DATA): begin
                   if (rUART_Tx_State != START) begin
                        rValid_Data <= 1'b0;
                        rCatch_State <= UART_DONE;
                    end
                end 
                (UART_DONE): begin
                    if (rUART_Tx_State == START) begin
                        rCatch_State <= CATCH_DATA;
                        rBusy  <= 1'b0;
                   end
                end 
            endcase
        end
    end
    
    
    /*
    Explanation:
        1.works on the UART_clock that is generate by the 1st always with its own conditions.
        2.when the clock starts send 'start bit' and then data, as long as the parameter DATA_SIZE decides.
        3.send parity if it was enabled by 'PARITY_ENABLE' parameter/.
        4.send the requested amount of stop bits defined by 'STOP_BITS'
    */
    always @(posedge rUART_Clock, posedge iReset, posedge rReset) begin
        if (iReset || rReset) begin
            rUART_Tx_State      <= START;
            rStop_bits_counter  <= STOP_BITS - 1;
            rCount_Data_bits    <= DATA_SIZE - 1;
            rData               <= 1'b1;
        end else if(rUART_Clock)  begin
            case (rUART_Tx_State)                
                (START): begin  // start bit 
                    if(rValid_Data) begin
                        rData_To_send   <= rCatch_data; 
                        rData           <= 1'b0; // Start bit
                        rUART_Tx_State  <= DATA;
                    end else begin
                        rData           <= 1'b1; // idle bit
                        rUART_Tx_State  <= START;
                    end
                end
                
                (DATA): begin // sending data by increasing the counter of the variable with the valid data
                    rData   <= rData_To_send[rCount_Data_bits];
                    
                    if (rCount_Data_bits == 1'b0) begin
                        rCount_Data_bits    <= DATA_SIZE-1;
                        if (PARITY_ENABLE) //  check if there is need for parity bit to be sent 
                            rUART_Tx_State  <= PARITY; // send parity 
                        else
                            rUART_Tx_State  <= STOP; // don't send parity 
                    end else
                        rCount_Data_bits    <= rCount_Data_bits - 1;
                    
                end
                
                (PARITY): begin
                    if(PARITY_ODD_EVEN == 1'b0) begin // if ODD do XOR logic operand over the whole sent data 
                        rData <= ^rData_To_send; // Do XOR logic operand over all 'rData_To_send' bits
                    end else if (PARITY_ODD_EVEN == 1'b1) begin // if EVEN do XNOR logic operand over the whole sent data 
                        rData <= ~^rData_To_send;   // Do XNOR logic operand over all 'rData_To_send' bits
                    end
                    rUART_Tx_State <= STOP;  
                end
                
                (STOP): begin
                    rData <= 1'b1; // stop bit
                    if (rStop_bits_counter > 0) //how manys clock to hold the stop bit
                        rStop_bits_counter <= rStop_bits_counter - 1;
                    else begin // when done counting stop bits recieve data to send.
                        rStop_bits_counter  <= STOP_BITS - 1;
                        rUART_Tx_State      <= START;  // waiting for new data state
                    end
                end
           endcase            
        end
    end
    
endmodule

