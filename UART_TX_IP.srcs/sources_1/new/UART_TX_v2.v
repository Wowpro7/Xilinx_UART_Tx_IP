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
    input [DATA_SIZE-1 :0]  iData,
    output                  oData,
    output                  oBusy
    /*,
    input iParity_enable,
    input iParity_odd_even*/
    );
         
        //MAanging UART_TX clock and data receiving
    localparam [31:0]   UART_BAUD_RATE      = (SYSTEM_CLOCK / UART_BAUDRATE / 2) -1;
    localparam          WAIT_FOR_VALID      = 2'd0;
    localparam          CREATING_CLOCK      = 2'd1;
    
        //UART States
    localparam IDLE                     = 3'd0;
    localparam START                    = 3'd1;
    localparam DATA                     = 3'd2;
    localparam PARITY                   = 3'd3;
    localparam STOP                     = 3'd4;
    
    
        //Clock variables
    integer     rUART_Clock_Counter = UART_BAUD_RATE;
    reg         rUART_Clock         = 1'b0;
    reg [1:0]   rManagment_state    = 2'd0;
    reg         rReset              = 1'b0;
        //Data Variables
    reg                     rData               = 1'b1;
    reg [0:DATA_SIZE-1]     rData_To_send       = 0;
    reg [2:0]               rUART_Tx_State      = START;
    integer                 rCount_Data_bits    = DATA_SIZE-1; 
    reg                     rBusy               = 1'b0; // cant receive data, busy sending
    reg [3:0]               rStop_bits_counter  = STOP_BITS - 1;
    
    
    assign oBusy = rBusy;
    assign oData = rData;
    /* 
    Explanation:
        1.check for new data to be vaild at the input using 'iValid_Data'
        2.when saw the new data start the UART_TX clock and let it send the data
        3.when the specific 'if' occurs stop the UART_TX and wait for new data
    */
    
    // TODO: why when having 'iValid_Data' = '1' and doing Reset results in data bein transmited wrong until the 'iValid_Data' changing to '0' and back to '1'
    
    
    always @(posedge iSystem_Clock, posedge iReset) begin
        if(iReset) begin
            rUART_Clock_Counter <= UART_BAUD_RATE;
            rUART_Clock         <= 1'b0;
            rBusy               <= 1'b0;
            rManagment_state    <= WAIT_FOR_VALID;
            rReset              <= 1'b1;
        end else begin
            case (rManagment_state)
                (WAIT_FOR_VALID): begin // wait for new data
                    if (iValid_Data) begin // there is valid data in the iData
                        rData_To_send       <= iData; 
                        rReset              <= 1'b0; //cancel Reset
                        rBusy               <= 1'b1; // busy sending data, cant receive new data 
                        rManagment_state    <= CREATING_CLOCK;
                        rUART_Clock         <= 1'b1; // start with a 'kick start' to exit 'IDLE' State
                    end
                end
                
                (CREATING_CLOCK): begin // start the uart clock
                     if(rUART_Clock_Counter > 0) begin
                        rUART_Clock_Counter <= rUART_Clock_Counter - 1;
                     end else begin
                        rUART_Clock_Counter <= UART_BAUD_RATE;
                        rUART_Clock         <= ~rUART_Clock;
                     end 
                     
                     if (rUART_Tx_State == IDLE && rUART_Clock == 1'b1) begin // when the clock is 0, TX is done and its not Busy reset the variables and wait for new data
                        rManagment_state    <= WAIT_FOR_VALID;
                        rReset              <= 1; // Reset
                        rBusy               <= 1'b0; //dont sending data
                        rUART_Clock         <= 1'b0;
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
            rUART_Tx_State      <= IDLE;
            rStop_bits_counter  <= STOP_BITS - 1;
            rCount_Data_bits    <= DATA_SIZE - 1;
            rData               <= 1'b1;
            
        end else if(rUART_Clock)  begin
            case (rUART_Tx_State)
                (IDLE):begin // 'waiting state' to let the 'Managing always' retrive new data
                    rData           <= 1'b1; // idle
                    rUART_Tx_State  <= START;
                end
                
                (START): begin  // start bit 
                    rData           <= 1'b0; // Start bit
                    rUART_Tx_State  <= DATA;
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
                        rUART_Tx_State      <= IDLE;  // waiting for new data state
                    end
                end
           endcase            
        end
    end
    
endmodule

