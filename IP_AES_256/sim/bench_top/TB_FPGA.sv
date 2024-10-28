`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2024 15:32:59
// Design Name: 
// Module Name: TB_FPGA
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
import axi_vip_pkg::*;                      //erreur normal peut rien faire. 
import TB_IP_AES_axi_vip_0_0_pkg::*;      // AXI VIP Master  (port master CPU)

module TB_FPGA(
    );
    logic clock;
    logic resetn;
    
    TB_IP_AES_wrapper DUT(
        .clk_in1(clock),
        .reset(resetn)
        ); 
    TB_IP_AES_axi_vip_0_0_mst_t     mst_agent; 
    
    axi_monitor_transaction                 mst_monitor_transaction;
    // monitor transaction queue for master VIP 
    axi_monitor_transaction                 master_moniter_transaction_queue[$];
    // size of master_moniter_transaction_queue
    xil_axi_uint                           master_moniter_transaction_queue_size =0;
    //scoreboard transaction from master monitor transaction queue
    axi_monitor_transaction                 mst_scb_transaction;
    // monitor transaction for slave VIP
    axi_monitor_transaction                 slv_monitor_transaction;
    // monitor transaction queue for slave VIP
    axi_monitor_transaction                 slave_moniter_transaction_queue[$];
    // size of slave_moniter_transaction_queue
    xil_axi_uint                            slave_moniter_transaction_queue_size =0;
    // scoreboard transaction from slave monitor transaction queue
    axi_monitor_transaction                 slv_scb_transaction;
       
    xil_axi_ulong                            mem_wr_addr;
    xil_axi_ulong                            mem_rd_addr;
    bit[32-1:0]                              mem_wr_data;
    bit[(32/8)-1:0]                          mem_wr_strb;
    bit[32-1:0]                              mem_rd_data;
    bit[32-1:0]                              mem_fill_payload;
  /*************************************************************************************************
  * Declare variables which will be used in API and parital randomization for transaction generation
  * and data read back from driver.
  *************************************************************************************************/
  axi_transaction                                          wr_trans;            // Write transaction
  axi_transaction                                          rd_trans;            // Read transaction
  xil_axi_uint                                             mtestWID;            // Write ID  
  xil_axi_uint                                             W_ADDR;          // Write ADDR  (32 bits)
  xil_axi_len_t                                            mtestWBurstLength;   // Write Burst Length   
  xil_axi_size_t                                           mtestWDataSize;      // Write SIZE  
  xil_axi_burst_t                                          mtestWBurstType;     // Write Burst Type  
  xil_axi_uint                                             mtestRID;            // Read ID  
  xil_axi_ulong                                            mtestRADDR;          // Read ADDR  
  xil_axi_len_t                                            mtestRBurstLength;   // Read Burst Length   
  xil_axi_size_t                                           mtestRDataSize;      // Read SIZE  
  xil_axi_burst_t                                          mtestRBurstType;     // Read Burst Type  

  xil_axi_data_beat [255:0]                                mtestWUSER;         // Write user  
  xil_axi_data_beat                                        mtestAWUSER;        // Write Awuser 
  xil_axi_data_beat                                        mtestARUSER;        // Read Aruser
  
  // Error count to check how many comparison failed
  xil_axi_uint                                            error_cnt = 0;

  /************************************************************************************************
  * A burst can not cross 4KB address boundry for AXI4
  * Maximum data bits = 4*1024*8 =32768
  * Write Data Value for WRITE_BURST transaction
  * Read Data Value for READ_BURST transaction
  ************************************************************************************************/
  bit [31:0]                                               W_Data;         // Write Data (32 bits)
  bit[8*4096-1:0]                                          Rdatablock;        // Read data block
  xil_axi_data_beat                                        Rdatabeat[];       // Read data beats
  bit[8*4096-1:0]                                          Wdatablock;        // Write data block
  xil_axi_data_beat                                        Wdatabeat[];       // Write data beats
// ------------------------   CLOCK & RESET   --------------------------------------------- 
    bit[127:0] text = 128'h00112233445566778899aabbccddeeff;
    bit[127:0] enc_text = 128'h8ea2b7ca516745bfeafc49904b496089;
    bit[255:0] key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
    bit[31:0] data_text[3:0];
    bit[31:0] dec_text[3:0];
    bit[31:0] data_key[7:0];
    bit[31:0] dec_key[7:0];
    initial begin
        resetn <= 1'b0;
        #320 resetn <= 1'b1;
    end
    
    initial begin 
        clock <= 0;
        forever begin
            #10 clock <= ~clock;
        end 
    end
   
    initial begin
        mst_agent = new("master vip agent", DUT.TB_IP_AES_i.axi_vip_0.inst.IF);
        mst_agent.start_master();
        read_master_vip(mst_agent,32'h0000_0008);
        #200;
        for(int i = 0; i < 4; i++)begin
            data_text[i] = text[127-i*32 -: 32];
            write_master_vip(mst_agent,32'h0000_0018,data_text[i]);
            #200;
        end
        for(int i = 0; i < 8; i++)begin
            data_key[i] = key[255-i*32 -: 32];
            write_master_vip(mst_agent,32'h0000_0010,data_key[i]);
            #200;
        end
        #400;
        write_master_vip(mst_agent,32'h0000_0004,32'h0000_0001);
        #200;
        write_master_vip(mst_agent,32'h0000_0004,32'h0000_0000);
        #5000;
        for(int i = 0; i < 5; i++)begin
            read_master_vip(mst_agent,32'h0000_0020);
            #200;
        end
        #200;
        for(int i = 0; i < 4; i++)begin
            dec_text[i] = enc_text[127-i*32 -: 32];
            write_master_vip(mst_agent,32'h0000_001C,dec_text[i]);
            #200;
        end
        for(int i = 0; i < 8; i++)begin
            dec_key[i] = key[255-i*32 -: 32];
            write_master_vip(mst_agent,32'h0000_0014,dec_key[i]);
            #200;
        end
        #400;
        write_master_vip(mst_agent,32'h0000_0004,32'h0000_00002);
        #200;
        write_master_vip(mst_agent,32'h0000_0004,32'h0000_0000);
        #5000;
        for(int i = 0; i < 5; i++)begin
            read_master_vip(mst_agent,32'h0000_0024);
            #200;
        end
        $finish();  
    end 
    
        //-------write_master_vip------- Elea task
    task automatic write_master_vip(input TB_IP_AES_axi_vip_0_0_mst_t mst_agent,
                                  input logic [31:0] addr,
                                  input logic [31:0] data);
    axi_transaction   wr_trans;
    xil_axi_ulong     wr_ADDR;          // WRITE ADDR
    xil_axi_burst_t   wr_BurstType;     // WRITE Burst Type
    xil_axi_uint      wr_ID;            // WRITE ID
    xil_axi_len_t     wr_BurstLength;   // WRITE Burst Length
    xil_axi_size_t    wr_DataSize;      // WRITE SIZE
    bit [31:0]        wr_Data;
 
    wr_ID = $urandom_range(0,(1<<(0)-1));
    wr_ADDR = 'd0;
    wr_ADDR[31:0]  = addr;
    wr_BurstLength = 0;
    wr_DataSize    = xil_axi_size_t'(xil_clog2((32)/8));
    wr_BurstType   = XIL_AXI_BURST_TYPE_INCR;
    wr_Data        = data;
 
    wr_trans = mst_agent.wr_driver.create_transaction("write transaction");
    wr_trans.set_write_cmd(wr_ADDR,wr_BurstType,wr_ID,wr_BurstLength,wr_DataSize);
    wr_trans.set_data_block(wr_Data);
    mst_agent.wr_driver.send(wr_trans);
    endtask
  //-------read_master_vip-------
    task automatic read_master_vip(input TB_IP_AES_axi_vip_0_0_mst_t mst_agent,
                                 input logic [31:0] addr);
    axi_transaction   rd_trans;
    xil_axi_ulong     rd_ADDR;          // Read ADDR
    xil_axi_burst_t   rd_BurstType;     // Read Burst Type
    xil_axi_uint      rd_ID;            // Read ID
    xil_axi_len_t     rd_BurstLength;   // Read Burst Length
    xil_axi_size_t    rd_DataSize;      // Read SIZE
 
    rd_ID = $urandom_range(0,(1<<(0)-1));
    rd_ADDR = 'd0;
    rd_ADDR[31:0] = addr;
    rd_BurstLength = 0;
    rd_DataSize = xil_axi_size_t'(xil_clog2((32)/8));
    rd_BurstType = XIL_AXI_BURST_TYPE_INCR;
 
    rd_trans = mst_agent.rd_driver.create_transaction("read transaction");
    rd_trans.set_read_cmd(rd_ADDR,rd_BurstType,rd_ID,
    rd_BurstLength,rd_DataSize);
    mst_agent.rd_driver.send(rd_trans);
    endtask    
endmodule