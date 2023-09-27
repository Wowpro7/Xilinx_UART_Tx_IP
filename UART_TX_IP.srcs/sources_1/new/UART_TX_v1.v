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
 #(parameter SYSTEM_CLOCK = 50e6, //default clock is 50Mhz
   parameter [0:0] RESET_AT = 1, // Reset active at:
   parameter UART_BAUDRATE = 9600, // UART Baudrate clock
   parameter DATA_SIZE = 8, // how many bits in the data vector
   parameter [0:0] PARITY_ENABLE = 0, // to create parity or not
   parameter [0:0] PARITY_ODD_EVEN = 0, // 1 - parity odd, 0 - parity even 
   parameter [0:0] STOP_BITS = 1 // how many stop bits, atleast 1.
 )
(
    input iClock,
    input iReset,
    input iValid_Data, //0  = is not data to be sent, 1 = new data to send
    input [DATA_SIZE-1 :0] iData,
    output reg oData = 1,
    output oBusy
    /*,
    input iParity_enable,
    input iParity_odd_even*/
    );
         
        //MAanging UART_TX clock and data receiving
    localparam [31:0] UART_BAUD_RATE = (SYSTEM_CLOCK / UART_BAUDRATE / 2) -1;
    integer rUART_Clock_Counter = 0;
    reg rUART_Clock = 0;
    reg [1:0] rManagment_state = 0;
    reg rReset = 0;
        //Send Data
    reg [DATA_SIZE -1 :0] rData_To_send = 0;
    reg [2:0] rUART_Tx_State = 0;
    integer rCount_Data_bits = 0; 
    reg rBusy = 0; // cant receive data, busy sending
    reg [3:0] rStop_bits_counter = 0;
    
    assign oBusy = rBusy;
    
    /* 
    Explanation:
        1.check for new data to be vaild at the input using 'iValid_Data'
        2.when saw the new data start the UART_TX clock and let it send the data
        3.when the specific 'if' occurs stop the UART_TX and wait for new data
    */
    
    // TODO: why when having 'iValid_Data' = '1' and doing Reset results in data bein transmited wrong until the 'iValid_Data' changing to '0' and back to '1'
    
    
    
    always @(posedge iClock) begin
        if( iReset == RESET_AT) begin
            rUART_Clock_Counter <= 0;
            rUART_Clock <= 0;
            rManagment_state <=0;
            rReset <= 1;
            rData_To_send <= 0;
        end else begin
            case (rManagment_state)
                (0): begin // wait for new data
                    if (iValid_Data == 1) begin // there is valid data in the iData
                        rData_To_send <= iData; 
                        rReset <= 0; //cancel Reset
                        rManagment_state <= 1;
                        rUART_Clock <= 1; // start with a 'kick start'
                    end
                end
                (1): begin // start the uart clock
                     if(rUART_Clock_Counter < UART_BAUD_RATE) begin
                        rUART_Clock_Counter <= rUART_Clock_Counter + 1;
                     end else begin
                        rUART_Clock_Counter <= 0;
                        rUART_Clock <= !rUART_Clock;
                     end 
                     
                     if (rUART_Tx_State == 0 && rUART_Clock == 1 && rBusy == 0) begin // when the clock is 0, TX is done and its not Busy reset the variables and wait for new data
                        rManagment_state <= 0;
                        rReset <= 1; // Reset
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
    always @(posedge rUART_Clock, posedge rReset) begin
        if (iReset == RESET_AT || rReset == RESET_AT) begin
            rUART_Tx_State <= 0;
            rStop_bits_counter <= 0;
            rBusy <= 0;
            rCount_Data_bits <= 0;
            rUART_Tx_State <= 0;
            oData <= 0;
        end else if(rUART_Clock==1)  begin
            case (rUART_Tx_State)
                (0):begin // 'waiting state' to let the 'Managing always' retrive new data
                    oData <= 1; // idle
                    rUART_Tx_State <= 1;
                end
                (1): begin  // start bit 
                    oData <= 0; // Start bit
                    rUART_Tx_State<= 2;
                    rBusy <= 1; // busy sending data, cant receive new data 
                end
                (2): begin // sending data by increasing the counter of the variable with the valid data
                    if (rCount_Data_bits < DATA_SIZE) begin
                        oData <= rData_To_send[rCount_Data_bits];
                        rCount_Data_bits <= rCount_Data_bits + 1;
                    end 
                    
                    if (rCount_Data_bits==DATA_SIZE-1) begin
                        rCount_Data_bits <= 0;
                        if (PARITY_ENABLE==1) //  check if there is need for parity bit to be sent 
                            rUART_Tx_State <= 3; // required
                        else
                            rUART_Tx_State <= 4; // not required 
                    end
                end
                
                (3): begin
                    if(PARITY_ODD_EVEN == 0) begin // if ODD do XOR logic operand over the whole sent data 
                        oData <= ^rData_To_send; // Do XOR logic operand over all 'rData_To_send' bits
                    end else if (PARITY_ODD_EVEN == 1) begin // if EVEN do XNOR logic operand over the whole sent data 
                        oData <= ~^rData_To_send;   // Do XNOR logic operand over all 'rData_To_send' bits
                    end
                    rUART_Tx_State = 4 ;  
                end
                
                (4): begin
                    oData <= 1; // stop bit
                    if (rStop_bits_counter < STOP_BITS - 1) //how manys clock to hold the stop bit
                        rStop_bits_counter <= rStop_bits_counter + 1;
                    else begin // when done counting stop bits recieve data to send.
                        rStop_bits_counter <= 0;
                        rUART_Tx_State = 0 ;  // waiting for new data state
                        rBusy <= 0; //dont sending data
                    end
                     
                end
           endcase            
        end
        
    end
    
endmodule

