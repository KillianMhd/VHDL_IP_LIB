----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2024 13:50:11
-- Design Name: 
-- Module Name: INV_KEY_BUFFER - Behavioral
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

entity INV_KEY_BUFFER is
    GENERIC(
        FIFO_DEPTH : integer := 15);
    PORT(
        CLK         : in std_logic;
        RESETN      : in std_logic;
        KEY_INPUT   : in round_keys;
        WR_EN       : in std_logic;
        RD_EN       : in std_logic;
        KEY_OUTPUT  : out std_logic_vector(127 downto 0)); 
end INV_KEY_BUFFER;

architecture Behavioral of INV_KEY_BUFFER is

    type mem_FIFO is array (0 to FIFO_DEPTH-1) of std_logic_vector(127 downto 0);

    signal FIFO: mem_FIFO := (others => (others=> '0'));
    signal r_WR_INDEX   : integer range 0 to FIFO_DEPTH-1 := 0;
    signal r_RD_INDEX   : integer range 0 to FIFO_DEPTH-1 := 0;
 
    -- # Words in FIFO, has extra range to allow for assert conditions
    signal r_FIFO_COUNT : integer range -1 to FIFO_DEPTH+1 := 0;
 
    signal w_FULL  : std_logic;
    signal w_EMPTY : std_logic;

begin
     p_CONTROL : process (CLK,RESETN) is
      begin
        if RESETN = '0' then
            r_FIFO_COUNT <= 0;
            r_WR_INDEX   <= 0;
            r_RD_INDEX   <= 14;
            KEY_OUTPUT <= (others => '0');
        elsif rising_edge(CLK) then 
            -- Keeps track of the total number of words in the FIFO
            if (WR_EN = '0' and RD_EN = '1') then
              r_FIFO_COUNT <= r_FIFO_COUNT - 1;
            end if;
            -- Keeps track of the write index (and controls roll-over)
              if r_WR_INDEX = FIFO_DEPTH-1 then
                r_WR_INDEX <= 0;
              end if;  
            -- Keeps track of the read index (and controls roll-over)        
            if (RD_EN = '1' and w_EMPTY = '0') then
              if r_RD_INDEX = 0 then
                r_RD_INDEX <= 14;
              else
                r_RD_INDEX <= r_RD_INDEX -1;
              end if;
            end if;
            -- Registers the input data when there is a write
            if WR_EN = '1' then
                for i in 0 to 14 loop
                    FIFO(i) <= KEY_INPUT(i);
                    r_WR_INDEX <= i;
                    r_FIFO_COUNT <= i+1;
                end loop;
            end if;
            
            if(RD_EN = '1')then 
                KEY_OUTPUT <= FIFO(r_RD_INDEX);
            end if; 
                  
        end if;
    end process p_CONTROL;
    
    w_FULL  <= '1' when r_FIFO_COUNT = FIFO_DEPTH else '0';
    w_EMPTY <= '1' when r_FIFO_COUNT = 0       else '0';   
end Behavioral;
