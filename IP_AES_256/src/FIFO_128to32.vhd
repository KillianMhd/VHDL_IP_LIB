----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2024 15:14:37
-- Design Name: 
-- Module Name: FIFO_128to32 - Behavioral
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

entity FIFO_128to32 is
    GENERIC(
        FIFO_DEPTH  : integer := 4
        );
    PORT(
        -- System --
        CLK     : in std_logic;
        RESETN  : in std_logic;
        -- Control -- 
        FLUSH   : in std_logic;
        RD_EN   : in std_logic;
        WR_EN   : in std_logic;
        -- Status --
        FULL    : out std_logic;
        EMPTY   : out std_logic;
        -- Data --
        DATA_I  : in std_logic_vector(127 downto 0);
        DATA_O  : out std_logic_vector(31 downto 0));
end FIFO_128to32;

architecture Behavioral of FIFO_128to32 is
    type mem_FIFO is array (0 to FIFO_DEPTH-1) of std_logic_vector(31 downto 0);
    signal FIFO: mem_FIFO := (others => (others=> '0'));
    signal r_WR_INDEX   : integer range 0 to FIFO_DEPTH-1 := 0;
    signal r_RD_INDEX   : integer range 0 to FIFO_DEPTH-1 := 0;
 
    signal r_FIFO_COUNT : integer range -1 to FIFO_DEPTH+1 := 0;
 
    signal w_FULL  : std_logic;
    signal w_EMPTY : std_logic;

begin
    FULL <= w_FULL;
    EMPTY <= w_EMPTY;
     p_CONTROL : process (CLK,RESETN,FLUSH) is
      begin
        if RESETN = '0'  or FLUSH = '1' then
            r_FIFO_COUNT <= 0;
            r_WR_INDEX   <= 0;
            r_RD_INDEX   <= 0;
            DATA_O <= (others => '0');
        elsif(rising_edge(CLK))then 
            -- Keeps track of the total number of words in the FIFO
            if (WR_EN = '1' and RD_EN = '0') then
                r_FIFO_COUNT <= r_FIFO_COUNT + 1;
            elsif (WR_EN = '0' and RD_EN = '1') then
                r_FIFO_COUNT <= r_FIFO_COUNT - 1;
            end if;
            -- Keeps track of the write index (and controls roll-over)
            if(WR_EN = '1' and w_FULL = '0')then
                if r_WR_INDEX = FIFO_DEPTH-1 then
                    r_WR_INDEX <= 0;                  
                end if; 
            end if;       
            -- Keeps track of the read index (and controls roll-over)        
            if (RD_EN = '1' and w_EMPTY = '0') then
              if r_RD_INDEX = FIFO_DEPTH-1 then
                r_RD_INDEX <= 0;
              else
                r_RD_INDEX <= r_RD_INDEX + 1;
              end if;
            end if;
            
            if(RD_EN = '1')then
                DATA_O <= FIFO(r_RD_INDEX);  
            end if;
            
            if(WR_EN ='1')then
                for i in 0 to FIFO_DEPTH-1 loop
                    FIFO(i) <= DATA_I(127-(32*i) downto 96-(32*i));
                    r_WR_INDEX <= i;
                    r_FIFO_COUNT <= i+1;
                end loop;
            end if;         
        end if;
    end process p_CONTROL;
    
    w_FULL  <= '1' when r_FIFO_COUNT = FIFO_DEPTH else '0';
    w_EMPTY <= '1' when r_FIFO_COUNT = 0       else '0';


end Behavioral;
