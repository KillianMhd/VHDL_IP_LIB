----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2024 13:35:00
-- Design Name: 
-- Module Name: INV_SUB_BYTE - Behavioral
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
use WORK.AES_PKG.all;

entity INV_SUB_BYTE is
    port(
        CLK     : in std_logic;
        RESETN  : in std_logic;
        READY   : out std_logic;
        VALID   : in std_logic;
        DONE    : out std_logic;
        DATA_I  : in std_logic_vector(127 downto 0);
        DATA_O  : out std_logic_vector(127 downto 0));
end INV_SUB_BYTE;

architecture Behavioral of INV_SUB_BYTE is
    type state_type is (IDLE, SUB, DONE_SUB);
    signal CURRENT_STATE, NEXT_STATE : state_type;
    signal temp_data    : std_logic_vector(127 downto 0); 
    signal done_algo : std_logic;
    
    function INV_SUB_128(
        data_in: STD_LOGIC_VECTOR(127 downto 0))return STD_LOGIC_VECTOR is
        variable temp_data : STD_LOGIC_VECTOR(127 downto 0);
    begin
        for i in 0 to 15 loop
            temp_data((i+1)*8-1 downto i*8) := INV_SBox(to_integer(unsigned(data_in((i+1)*8-1 downto i*8))));
        end loop;    
        return temp_data;
    end function INV_SUB_128;
begin
    DONE <= done_algo;
    P_SYNC  : process(CLK, RESETN,CURRENT_STATE)
        begin
        if RESETN = '0' then
            CURRENT_STATE <= IDLE;
        elsif(rising_edge(CLK)) then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process P_SYNC;
    
    P_CONTROL : process(CURRENT_STATE,VALID,DATA_I,temp_data,done_algo)
    begin
        case CURRENT_STATE is
            when IDLE =>
                READY <= '1';
                done_algo <= '0';
                temp_data <= (others => '0');
                if(VALID = '1' and done_algo = '0')then 
                    NEXT_STATE <= SUB;
                end if;    
            when SUB =>
                READY <= '0';
                done_algo <= '0';
                temp_data <= INV_SUB_128(DATA_I);
                NEXT_STATE <= DONE_SUB;
            when DONE_SUB =>
                READY <= '0';
                done_algo <= '1';
                DATA_O <= temp_data;
                NEXT_STATE <= IDLE;
            when others =>
                NEXT_STATE <= IDLE;
        end case;
    end process P_CONTROL; 
end Behavioral;
