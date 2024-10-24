----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2024 14:00:56
-- Design Name: 
-- Module Name: ROUND_KEY - Behavioral
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
entity ROUND_KEY is
    PORT(
        CLK             : in std_logic;
        RESETN          : in std_logic;
        DATA_I          : in std_logic_vector(127 downto 0);
        ROUND_KEY       : in std_logic_vector(127 downto 0);
        READY           : out std_logic;
        VALID           : in std_logic;
        RD_EN           : out std_logic;
        DONE            : out std_logic;
        DATA_ROUND_KEY  : out std_logic_vector(127 downto 0)
        );
end ROUND_KEY;

architecture Behavioral of ROUND_KEY is
    type state_type is (IDLE, READ, ADD, DONE_ADD);
    signal CURRENT_STATE, NEXT_STATE : state_type;
    signal temp_data   : std_logic_vector(127 downto 0);
    signal done_algo : std_logic;
    function ADD_128(
        data_in: STD_LOGIC_VECTOR(127 downto 0);key : std_logic_vector(127 downto 0))return STD_LOGIC_VECTOR is
        variable matrix : matrix_type;
        variable matrix_key: matrix_type;
        variable matrix_round: matrix_type;
        variable temp_data : std_logic_vector(127 downto 0);
    begin
        matrix := VECT_TO_MATRIX(data_in);
        matrix_key := VECT_TO_MATRIX(key);
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                matrix_round(j,i) := matrix(j,i) xor matrix_key(j,i);
            end loop;
        end loop;
        
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                temp_data((15 - (i*4 + j))*8 + 7 downto (15 - (i*4 + j))*8) := matrix_round(j, i);
            end loop;
        end loop;
        return temp_data;
    end function ADD_128;
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
    
    P_CONTROL : process(CURRENT_STATE,VALID,DATA_I,temp_data,ROUND_KEY,done_algo)
    begin
        case CURRENT_STATE is
            when IDLE =>
                READY <= '1';
                done_algo <= '0';
                RD_EN <= '0';
                temp_data <= (others => '0');
                if(VALID = '1' and done_algo ='0')then 
                    NEXT_STATE <= READ;
                end if;
            when READ => 
                READY <= '0';
                done_algo <= '0';
                RD_EN <= '1';
                temp_data <= (others => '0');  
                NEXT_STATE <= ADD;     
            when ADD =>
                READY <= '0';
                done_algo <= '0';
                RD_EN <= '0';
                temp_data <= ADD_128(DATA_I,ROUND_KEY);
                NEXT_STATE <= DONE_ADD;
            when DONE_ADD =>
                READY <= '0';
                done_algo <= '1';
                RD_EN <= '0';
                DATA_ROUND_KEY <= temp_data;
                NEXT_STATE <= IDLE;
            when others =>
                NEXT_STATE <= IDLE;
        end case;
    end process P_CONTROL;           
end Behavioral;
