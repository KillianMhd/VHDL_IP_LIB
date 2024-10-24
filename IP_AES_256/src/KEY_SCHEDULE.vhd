----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2024 15:10:16
-- Design Name: 
-- Module Name: KEY_SCHEDULE - Behavioral
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

entity KEY_SCHEDULE is
    PORT(
        CLK     : in std_logic;
        RESETN  : in std_logic;
        KEY     : in std_logic_vector(255 downto 0);
        START   : in std_logic;
        WR_EN   : out std_logic;
        DONE    : out std_logic;
        RD_KEY  : out round_keys
        );
end KEY_SCHEDULE;

architecture Behavioral of KEY_SCHEDULE is
    type state_type is (IDLE, INIT_W, EXPAND_KEY, GEN_RD_KEY, DONE_ALGO);
    signal state, next_state : state_type;
    signal keys : round_keys;
    signal w : word_array;
begin
    RD_KEY <= keys;
    P_SYNC  : process(CLK, RESETN)
    begin
        if RESETN = '0' then
            state <= IDLE;
        elsif(rising_edge(CLK)) then
            state <= next_state;
        end if;
    end process P_SYNC;

    P_COMB  : process(state,KEY,w,START)
    begin
            case state is
        when IDLE =>
            DONE <= '0';
            WR_EN <= '0';
            if(START = '1')then
                next_state <= INIT_W;
            else
                next_state <= IDLE;   
            end if;
        when INIT_W =>
            w <= initialize_w(key);
            next_state <= EXPAND_KEY;
            when EXPAND_KEY =>
            w <= expand_key(w, SBox, rcon);
            next_state <= GEN_RD_KEY;
        when GEN_RD_KEY =>
            keys <= generate_rd_key(w);
            next_state <= DONE_ALGO;
        when DONE_ALGO =>
            DONE <= '1';
            WR_EN <= '1';
            next_state <= IDLE;
        when others =>
            next_state <= IDLE;
    end case;
    end process P_COMB;
end Behavioral;
