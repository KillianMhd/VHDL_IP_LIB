----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2024 13:35:00
-- Design Name: 
-- Module Name: INV_MIX_COLS - Behavioral
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

entity INV_MIX_COLS is
    PORT(
        CLK     : in std_logic;
        RESETN  : in std_logic;
        DATA_I  : in std_logic_vector(127 downto 0);
        READY   : out std_logic;
        VALID   : in std_logic;
        DONE    : out std_logic;
        DATA_O  : out std_logic_vector(127 downto 0));
end INV_MIX_COLS;

architecture Behavioral of INV_MIX_COLS is
    type state_type is (IDLE, MIX, DONE_MIX);
    signal CURRENT_STATE, NEXT_STATE : state_type;
    signal temp_data   : std_logic_vector(127 downto 0);
    signal done_algo : std_logic;
    function INV_MIX_128(
        data_in: STD_LOGIC_VECTOR(127 downto 0))return STD_LOGIC_VECTOR is
        variable matrix_shift: matrix_type;
        variable matrix_mix: matrix_type;
        variable temp_data : std_logic_vector(127 downto 0);
    begin
        matrix_shift := VECT_TO_MATRIX(data_in);
        for c in 0 to 3 loop
            matrix_mix(0,c) := GMul(x"0e", matrix_shift(0,c)) xor GMul(x"0b", matrix_shift(1,c)) xor GMul(x"0d",matrix_shift(2,c)) xor GMul(x"09",matrix_shift(3,c));
            matrix_mix(1,c) := GMul(x"09", matrix_shift(0,c)) xor GMul(x"0e", matrix_shift(1,c)) xor GMul(x"0b",matrix_shift(2,c)) xor GMul(x"0d",matrix_shift(3,c));
            matrix_mix(2,c) := GMul(x"0d", matrix_shift(0,c)) xor GMul(x"09", matrix_shift(1,c)) xor GMul(x"0e",matrix_shift(2,c)) xor GMul(x"0b",matrix_shift(3,c));
            matrix_mix(3,c) := GMul(x"0b", matrix_shift(0,c)) xor GMul(x"0d", matrix_shift(1,c)) xor GMul(x"09",matrix_shift(2,c)) xor GMul(x"0e",matrix_shift(3,c));
        end loop;
        
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                temp_data((15 - (i*4 + j))*8 + 7 downto (15 - (i*4 + j))*8) := matrix_mix(j, i);
            end loop;
        end loop;  
        return temp_data;
    end function INV_MIX_128;
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
                    NEXT_STATE <= MIX;
                else
                    NEXT_STATE <= IDLE;    
                end if;    
            when MIX =>
                READY <= '0';
                done_algo <= '0';
                temp_data <= INV_MIX_128(DATA_I);
                NEXT_STATE <= DONE_MIX;
            when DONE_MIX =>
                READY <= '0';
                done_algo <= '1';
                DATA_O <= temp_data;
                NEXT_STATE <= IDLE;
            when others =>
                NEXT_STATE <= IDLE;
        end case;
    end process P_CONTROL;
end Behavioral;
