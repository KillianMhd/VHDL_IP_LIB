----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2024 14:05:37
-- Design Name: 
-- Module Name: TB_WB_ITF - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PKG_TOOLS.all;
use WORK.pkg_doc.all;
use WORK.stdio_h.all;
use WORK.pkg_tools_tb.all;

entity TB_WB_ITF is
end TB_WB_ITF;

architecture Behavioral of TB_WB_ITF is
    COMPONENT WB_ITF IS
        PORT(
            WB_CLK_I    : in std_logic;
            WB_RST_I    : in std_logic;
            ARST_I      : in std_logic;
            WB_ADR_I    : in std_logic_vector(2 downto 0);
            WB_DAT_I    : in std_logic_vector(7 downto 0);
            WB_DAT_O    : out std_logic_vector(7 downto 0);
            WB_WE_I     : in std_logic;
            WB_STB_I    : in std_logic;
            WB_CYC_I    : in std_logic;
            WB_ACK_O    : out std_logic;
            WB_INTA_O   : out std_logic;
            -- ADDRESSE --
            ADDR        : out std_logic_vector(6 downto 0);
            -- CONTROL --
            EN          : out std_logic;
            RWB         : out std_logic;
            TR_S        : out std_logic;
            -- TRANSMIT --
            TX_DATA     : out std_logic_vector(7 downto 0);
            -- RECEIVE --
            RX_DATA     : in std_logic_vector(7 downto 0);
            -- STATUS --
            Busy        : in std_logic;
            RxACK       : in std_logic
            );
    END COMPONENT WB_ITF;
    
    COMPONENT WB_MST_MODEL IS
        PORT(  
           clk        : in  STD_LOGIC;
           rst        : in  STD_LOGIC;
           stb        : out STD_LOGIC;
           cyc        : out STD_LOGIC;
           we         : out STD_LOGIC;
           rwb        : in  STD_LOGIC;
           addr_in    : in  STD_LOGIC_VECTOR (2 downto 0);
           data_in    : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out   : out STD_LOGIC_VECTOR (7 downto 0);
           addr       : out STD_LOGIC_VECTOR (2 downto 0);  -- 8-bit address
           dat_m      : out STD_LOGIC_VECTOR (7 downto 0);  -- 8-bit data
           dat_s      : in  STD_LOGIC_VECTOR (7 downto 0);  -- 8-bit data read from slave
           ack        : in  STD_LOGIC;
           err        : in  STD_LOGIC;
           rd_wr_done : out STD_LOGIC
           );
    END COMPONENT WB_MST_MODEL;
    
    CONSTANT INPUT_CLK_PERIOD : time    := 10 ns; -- 100 MHz
    CONSTANT C_RST_TIME       : time    := INPUT_CLK_PERIOD * 4;
    CONSTANT CONTROL    : std_logic_vector(2 downto 0) := "000"; --RW
    CONSTANT STATUS     : std_logic_vector(2 downto 0) := "001"; --RO
    CONSTANT ADDRESS    : std_logic_vector(2 downto 0) := "010"; --WO
    CONSTANT TRANSMIT   : std_logic_vector(2 downto 0) := "011"; --WO
    CONSTANT RECEIVE    : std_logic_vector(2 downto 0) := "100"; --RO
    -- Wishbone signals
    signal wb_clk       : std_logic := '0';
    signal wb_resetn    : std_logic := '0';
    signal wb_addr      : std_logic_vector(2 downto 0);
    signal wb_dat_m     : std_logic_vector(7 downto 0);
    signal wb_dat_s     : std_logic_vector(7 downto 0);
    signal wb_stb       : std_logic;
    signal wb_cyc       : std_logic;
    signal wb_we        : std_logic;
    signal wb_ack       : std_logic;
    signal wb_err       : std_logic;
    -- Internal signals
    signal rwb          : std_logic;
    signal rd_wr_done   : std_logic;
    signal addr_in      : std_logic_vector(2 downto 0);
    signal data_in      : std_logic_vector(7 downto 0);
    signal data_out     : std_logic_vector(7 downto 0);
    signal ADDR_SMB     : std_logic_vector(6 downto 0);
    signal EN           : std_logic;
    signal RWB_SMB      : std_logic;    
    signal TR_S         : std_logic; 
    signal TX_DATA      : std_logic_vector(7 downto 0);
    signal RX_DATA      : std_logic_vector(7 downto 0);          
    signal Busy         : std_logic;
    signal RxACK        : std_logic;
begin
    P_CLK_100MHz : process
    begin
        wb_clk  <= '0';
        wait for INPUT_CLK_PERIOD/2;
        wb_clk  <= '1';
        wait for INPUT_CLK_PERIOD/2;
    end process P_CLK_100MHz;

    P_RESET : process
    begin
        wb_resetn  <= '0';
        wait for C_RST_TIME;
        wb_resetn  <= '1';
        wait;
    end process P_RESET;
  	
    P_SIM : process
        variable testError   : integer := 0;
        variable nbTestOk    : integer := 0;
        variable nbTest      : integer := 0;
    begin
        initLog;
        docTitle1 ("TEST OF WISHBONE SLAVE");
        data_in <= (others => '0');addr_in <=(others => '0'); rwb <= '0'; Busy <= '1'; RxACK <= '0'; RX_DATA <= x"10";
        wait until rising_edge(wb_resetn);
        
        logInitTest("TEST SMBUS CONTROLLER WRITE TRANSACTION", nbTest);
        addr_in <= ADDRESS; data_in <= x"38"; rwb <= '0';
        wait until rd_wr_done = '1';
        compare_Output_To_Reference("ADDR_SMB", ADDR_SMB, "0111000", TRUE, testError);
        addr_in <= TRANSMIT; data_in <= x"FF"; rwb <= '0';
        wait until rd_wr_done = '1';
        compare_Output_To_Reference("TX_DATA", TX_DATA, x"FF", TRUE, testError);
        addr_in <= CONTROL; data_in <= x"03"; rwb <= '0';
        wait until rd_wr_done = '1';
        compare_Output_To_Reference("EN", EN, '1', TRUE, testError);
        compare_Output_To_Reference("RWB_SMB", RWB_SMB, '1', TRUE, testError);
        compare_Output_To_Reference("TR_S", TR_S, '0', TRUE, testError);
        logResultTest(testError,nbTest,nbTestOk);
        
        logInitTest("TEST SMBUS CONTROLLER READ TRANSACTION", nbTest);
        addr_in <= CONTROL; rwb <= '1';data_in <= x"00";
        wait until rd_wr_done = '1';
        compare_Output_To_Reference("DATA_OUT", data_out, x"03", TRUE, testError);
        addr_in <= STATUS; rwb <= '1';data_in <= x"00";
        wait until rd_wr_done = '1';
        compare_Output_To_Reference("DATA_OUT", data_out, x"01", TRUE, testError);
        addr_in <= RECEIVE; rwb <= '1';data_in <= x"00";
        wait until rd_wr_done = '1';
        compare_Output_To_Reference("DATA_OUT", data_out, x"10", TRUE, testError);
        logResultTest(testError,nbTest,nbTestOk);
        
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM; 
    
    DUT : WB_ITF 
        PORT MAP(
            WB_CLK_I    => wb_clk,
            WB_RST_I    => '0',
            ARST_I      => wb_resetn,
            WB_ADR_I    => wb_addr,
            WB_DAT_I    => wb_dat_m,
            WB_DAT_O    => wb_dat_s,
            WB_WE_I     => wb_we,
            WB_STB_I    => wb_stb, 
            WB_CYC_I    => wb_cyc,
            WB_ACK_O    => wb_ack,
            WB_INTA_O   => wb_err,
            -- ADDRESSE --
            ADDR        => ADDR_SMB,
            -- CONTROL --
            EN          => EN,
            RWB         => RWB_SMB,
            TR_S        => TR_S,
            -- TRANSMIT --
            TX_DATA     => TX_DATA,
            -- RECEIVE --
            RX_DATA     => RX_DATA,
            -- STATUS --
            Busy        => Busy,
            RxACK       => RxACK
            );            
    I_WB_MODEL   :   WB_MST_MODEL
        PORT MAP(
           clk        => wb_clk,
           rst        => wb_resetn,
           stb        => wb_stb,
           cyc        => wb_cyc,
           we         => wb_we,
           rwb        => rwb,
           addr_in    => addr_in,
           data_in    => data_in,
           data_out   => data_out,
           addr       => wb_addr,
           dat_m      => wb_dat_m,
           dat_s      => wb_dat_s,
           ack        => wb_ack,
           err        => wb_err,
           rd_wr_done => rd_wr_done
           );      
end Behavioral;
