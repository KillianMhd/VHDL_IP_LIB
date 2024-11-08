----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.10.2024 11:42:41
-- Design Name: 
-- Module Name: SHIFT_ROWS - Behavioral
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

entity SHIFT_ROWS is
    PORT(
        CLK     : in std_logic;
        RESETN  : in std_logic;
        DATA_I  : in std_logic_vector(127 downto 0);
        READY   : out std_logic;
        VALID   : in std_logic;
        DONE    : out std_logic;
        DATA_O  : out std_logic_vector(127 downto 0));
end SHIFT_ROWS;

architecture Behavioral of SHIFT_ROWS is
    type state_type is (IDLE, SHIFT, DONE_SHF);
    signal CURRENT_STATE, NEXT_STATE : state_type;
    signal temp_data   : std_logic_vector(127 downto 0);
    signal done_algo : std_logic;
    function SHIFT_128(
        data_in: STD_LOGIC_VECTOR(127 downto 0))return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR(127 downto 0);
        VARIABLE matrix_shift,matrix : matrix_type;
    begin
        matrix := VECT_TO_MATRIX(data_in);
        matrix_shift(0,0) := matrix(0,0);
        matrix_shift(0,1) := matrix(0,1);
        matrix_shift(0,2) := matrix(0,2);
        matrix_shift(0,3)  :=  matrix(0,3);
        matrix_shift(1,0) := matrix(1,1);
        matrix_shift(1,1) := matrix(1,2);
        matrix_shift(1,2) := matrix(1,3);
        matrix_shift(1,3) := matrix(1,0);
        matrix_shift(2,0) := matrix(2,2);
        matrix_shift(2,1) := matrix(2,3);
        matrix_shift(2,2) := matrix(2,0);
        matrix_shift(2,3) := matrix(2,1);
        matrix_shift(3,0) := matrix(3,3);
        matrix_shift(3,1) := matrix(3,0);
        matrix_shift(3,2) := matrix(3,1);
        matrix_shift(3,3) := matrix(3,2);
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                result((15 - (i*4 + j))*8 + 7 downto (15 - (i*4 + j))*8) := matrix_shift(j, i);
            end loop;
        end loop;   
        return result;
    end function SHIFT_128;
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
                    NEXT_STATE <= SHIFT;
                else
                     NEXT_STATE <= IDLE;    
                end if;    
            when SHIFT =>
                READY <= '0';
                done_algo <= '0';
                temp_data <= SHIFT_128(DATA_I);
                DATA_O <= (others => '0');
                NEXT_STATE <= DONE_SHF;
            when DONE_SHF =>
                READY <= '0';
                done_algo <= '1';
                temp_data <= SHIFT_128(DATA_I);
                DATA_O <= temp_data;
                NEXT_STATE <= IDLE;
            when others =>
                NEXT_STATE <= IDLE;
        end case;
    end process P_CONTROL; 
end Behavioral;
