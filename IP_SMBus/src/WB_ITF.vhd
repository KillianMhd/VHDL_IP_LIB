----------------------------------------------------------------------------------
-- This the Wishbone Slave Interface to enable interconnection with others IP Cores
-- In this file, we've got 8bits Data in/out length and 3bits Address length
-- Also, there is 5 internal registers : CONTROL,STATUS,ADDRESS,TRANSMIT and RECEIVE
-- All of this registers are describe in the Technical Specification document (TS_SMBus_Core)
-- With the help of the Wishbone specification document (wbspec_b3), we validate this 
-- interface with a testbench (TB_WB_ITF.vhd) with a Wishbone Master model
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration for the Wishbone Interface (WB_ITF)
entity WB_ITF is
    PORT(
        WB_CLK_I    : in std_logic;  -- Wishbone clock input
        WB_RST_I    : in std_logic;  -- Wishbone reset input
        ARST_I      : in std_logic;  -- Asynchronous reset input
        WB_ADR_I    : in std_logic_vector(2 downto 0);  -- Wishbone address input
        WB_DAT_I    : in std_logic_vector(7 downto 0);  -- Wishbone data input
        WB_DAT_O    : out std_logic_vector(7 downto 0); -- Wishbone data output
        WB_WE_I     : in std_logic;  -- Wishbone write enable input
        WB_STB_I    : in std_logic;  -- Wishbone strobe input
        WB_CYC_I    : in std_logic;  -- Wishbone cycle input
        WB_ACK_O    : out std_logic; -- Wishbone acknowledge output
        WB_INTA_O   : out std_logic; -- Wishbone interrupt acknowledge output
        -- Address output
        ADDR        : out std_logic_vector(6 downto 0);
        -- Control signals
        EN          : out std_logic; -- Enable signal
        RWB         : out std_logic; -- Read/Write signal
        TR_S        : out std_logic; -- Transfer start signal
        -- Transmit data output
        TX_DATA     : out std_logic_vector(7 downto 0);
        -- Receive data input
        RX_DATA     : in std_logic_vector(7 downto 0);
        -- Status signals
        Busy        : in std_logic;  -- Busy status signal
        RxACK       : in std_logic   -- Receive acknowledge signal
    );
end WB_ITF;

architecture Behavioral of WB_ITF is
    -- Constant definitions for register addresses
    CONSTANT CONTROL  : std_logic_vector(2 downto 0) := "000"; -- Control register (Read/Write)
    CONSTANT STATUS   : std_logic_vector(2 downto 0) := "001"; -- Status register (Read Only)
    CONSTANT ADDRESS  : std_logic_vector(2 downto 0) := "010"; -- Address register (Write Only)
    CONSTANT TRANSMIT : std_logic_vector(2 downto 0) := "011"; -- Transmit register (Write Only)
    CONSTANT RECEIVE  : std_logic_vector(2 downto 0) := "100"; -- Receive register (Read Only)
    
    -- Signal declarations for internal registers
    SIGNAL reg_data_out : std_logic_vector(7 downto 0);
    SIGNAL reg_control  : std_logic_vector(7 downto 0);
    SIGNAL reg_status   : std_logic_vector(7 downto 0);
    SIGNAL reg_addr     : std_logic_vector(7 downto 0);
    SIGNAL reg_transmit : std_logic_vector(7 downto 0);
    SIGNAL reg_receive  : std_logic_vector(7 downto 0);
begin
    -- Assign internal register values to output ports
    ADDR             <= reg_addr(6 downto 0); -- Address output
    EN              <= reg_control(0);        -- Enable signal
    RWB             <= reg_control(1);        -- Read/Write signal
    TR_s            <= reg_control(2);        -- Transfer start signal
    TX_DATA         <= reg_transmit;          -- Transmit data output
    reg_receive     <= RX_DATA;               -- Receive data input
    reg_status(0)   <= Busy;                  -- Busy status signal
    reg_status(1)   <= RxACK;                 -- Receive acknowledge signal
    reg_status(7 downto 2) <= (others => '0');-- Unused status bits set to 0
    WB_DAT_O        <= reg_data_out;          -- Wishbone data output

    -- Process for handling write operations
    P_WR : process(WB_CLK_I, WB_RST_I, ARST_I)
    begin
        if ARST_I = '0' then    -- Asynchronous reset
            WB_ACK_O <= '0';
            WB_INTA_O <= '0';
            reg_addr <= (others => '0');
            reg_control <= (others => '0');
            reg_transmit <= (others => '0');
        elsif rising_edge(WB_CLK_I) then
            if WB_RST_I = '1' then
                WB_ACK_O <= '0';
            else
                if WB_CYC_I = '1' and WB_STB_I = '1' then
                    if WB_WE_I = '1' then   -- Write operation
                        case WB_ADR_I is
                            when ADDRESS =>
                                WB_INTA_O <= '0';
                                reg_addr <= WB_DAT_I;
                            when CONTROL =>
                                WB_INTA_O <= '0';
                                reg_control(7 downto 3) <= (others => '0');
                                reg_control <= WB_DAT_I;
                            when TRANSMIT =>    
                                WB_INTA_O <= '0';
                                reg_transmit <= WB_DAT_I;
                            when others => 
                                WB_INTA_O <= '1';
                        end case;
                    end if;
                    WB_ACK_O <= '1';
                else
                    WB_ACK_O <= '0';
                end if;
            end if;
        end if;
    end process P_WR;

    -- Process for handling read operations
    P_RD : process(WB_ADR_I, ARST_I, WB_CLK_I)
    begin
        if ARST_I = '0' then
            reg_data_out <= (others => '0');
        elsif rising_edge(WB_CLK_I) then
            if WB_RST_I = '1' then
                reg_data_out <= (others => '0');
            else    
                if WB_WE_I = '0' then  -- Read operation
                    case WB_ADR_I is
                        when CONTROL =>
                            reg_data_out <= reg_control;
                        when STATUS => 
                            reg_data_out <= reg_status;
                        when RECEIVE => 
                            reg_data_out <= reg_receive;
                        when others => 
                            reg_data_out <= (others => '0');
                    end case;
                end if;
            end if;
        end if;                    
    end process P_RD;

end Behavioral;
