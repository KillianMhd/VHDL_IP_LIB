----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2024 17:59:10
-- Design Name: 
-- Module Name: WB_ITF - Behavioral
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

entity WB_ITF is
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
        ADDR         : out std_logic_vector(6 downto 0);
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
end WB_ITF;

architecture Behavioral of WB_ITF is
    CONSTANT CONTROL  : std_logic_vector(2 downto 0) := "000"; --RW
    CONSTANT STATUS   : std_logic_vector(2 downto 0) := "001"; --RO
    CONSTANT ADDRESS  : std_logic_vector(2 downto 0) := "010"; --WO
    CONSTANT TRANSMIT : std_logic_vector(2 downto 0) := "011"; --WO
    CONSTANT RECEIVE  : std_logic_vector(2 downto 0) := "100"; --RO
    
    SIGNAL reg_data_out : std_logic_vector(7 downto 0);
    SIGNAL reg_control  : std_logic_vector(7 downto 0);
    SIGNAL reg_status   : std_logic_vector(7 downto 0);
    SIGNAL reg_addr     : std_logic_vector(7 downto 0);
    SIGNAL reg_transmit : std_logic_vector(7 downto 0);
    SIGNAL reg_receive  : std_logic_vector(7 downto 0);
begin
    -- PRESCALE Register --
    ADDR             <= reg_addr(6 downto 0);
    -- CONTROL Register --
    EN              <= reg_control(0);
    RWB             <= reg_control(1);
    TR_s            <= reg_control(2);
    -- TRANSMIT Register --
    TX_DATA         <= reg_transmit;
    -- RECEIVE Register --
    reg_receive <= RX_DATA;
    -- STATUS Register --
    reg_status(0)   <= Busy;
    reg_status(1)   <= RxACK;
    reg_status(7 downto 2) <= (others => '0');
    -- RX Register --
    WB_DAT_O        <= reg_data_out;
    P_WR : process(WB_CLK_I, WB_RST_I, ARST_I)
    begin
        if ARST_I = '0' then
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
                    if WB_WE_I = '1' then
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

    P_RD : process(WB_ADR_I,ARST_I,WB_CLK_I)
    begin
        if ARST_I = '0' then
            reg_data_out <= (others => '0');
        elsif rising_edge(WB_CLK_I) then
            if WB_RST_I = '1' then
                reg_data_out <= (others => '0');
            else    
                if WB_WE_I = '0' then
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
