----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2024 14:04:35
-- Design Name: 
-- Module Name: CONTROL_UNIT_INV - Behavioral
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

entity CONTROL_UNIT_INV is
    PORT(
        -- SYSTEM --
        CLK             : in std_logic;
        RESETN          : in std_logic;
        -- CONTROL --
        START_ALGO      : in std_logic;
        START_KEYS      : out std_logic;
        -- STATUS --
        DONE_KEYS       : in std_logic;
        DONE_SUB        : in std_logic;
        DONE_SHF        : in std_logic;
        DONE_MIX        : in std_logic;
        DONE_ADD        : in std_logic;
        DONE_ALGO       : out std_logic;
        -- FIFO --
        RD_EN_CIPHER    : out std_logic;
        RD_EN_DEC_KEY   : out std_logic;
        WR_EN_PLAIN     : out std_logic;
        DECIPHER_KEY_EMPTY  : in std_logic;
        CIPHER_TEXT_EMPTY   : in std_logic;
        -- DATA --
        CIPHER_TEXT     : in std_logic_vector(127 downto 0);
        DATA_ROUND_KEY  : in std_logic_vector(127 downto 0);
        DATA_SUB        : in std_logic_vector(127 downto 0);
        DATA_SHIFT      : in std_logic_vector(127 downto 0);
        DATA_MIX        : in std_logic_vector(127 downto 0);
        DATA_FOR_RD     : out std_logic_vector(127 downto 0);
        DATA_FOR_SUB    : out std_logic_vector(127 downto 0);
        DATA_FOR_SHF    : out std_logic_vector(127 downto 0);
        DATA_FOR_MIX    : out std_logic_vector(127 downto 0);
        PLAIN_TEXT      : out std_logic_vector(127 downto 0);
        --
        READY_ROUND_KEY : in std_logic;
        READY_SUB       : in std_logic;
        READY_SHIFT     : in std_logic;
        READY_MIX       : in std_logic;
        --
        VALID_ROUND_KEY : out std_logic;
        VALID_SUB       : out std_logic;
        VALID_SHIFT     : out std_logic;
        VALID_MIX       : out std_logic);
end CONTROL_UNIT_INV;

architecture Behavioral of CONTROL_UNIT_INV is
    TYPE state_type is (IDLE, INIT,INIT_INV_SHIFT, INV_SHIFT, INV_SBOX, INV_MIX, ADD_KEY_INIT, ADD_KEY, ADD_KEY_LAST, COMPLETE);
    
    CONSTANT MAX_ROUND : integer := 14;
    
    SIGNAL CURRENT_STATE,NEXT_STATE : state_type;
    SIGNAL NB_ROUND : integer;  
begin
    P_COUNTER : process(CURRENT_STATE,RESETN)
    begin
        if(RESETN = '0' or CURRENT_STATE = IDLE)then
            NB_ROUND <= 0; 
        elsif(CURRENT_STATE = INIT_INV_SHIFT)then
            NB_ROUND <= NB_ROUND + 1;            
        elsif(CURRENT_STATE = INV_SHIFT)then
            NB_ROUND <= NB_ROUND + 1;                    
        end if;  
    end process P_COUNTER;
    
    P_SYNC  : process(CLK, RESETN)
    begin
        if RESETN = '0' then
            CURRENT_STATE <= IDLE;
        elsif(rising_edge(CLK)) then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process P_SYNC;
    
    P_COMB  : process(CURRENT_STATE,NB_ROUND,START_ALGO,DONE_KEYS,READY_ROUND_KEY,DONE_SHF,READY_MIX,DONE_MIX,DONE_ADD,READY_SUB,DONE_SUB,READY_SHIFT,DATA_ROUND_KEY,DATA_SUB,DATA_SHIFT,CIPHER_TEXT,DATA_MIX,CIPHER_TEXT_EMPTY,DECIPHER_KEY_EMPTY)
    begin
        case CURRENT_STATE is
            when IDLE =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= (others => '0');
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(START_ALGO = '1')then
                    NEXT_STATE <= INIT;
                else
                    NEXT_STATE <= IDLE;
                end if;            
            when INIT =>
                START_KEYS <= '1';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                if(CIPHER_TEXT_EMPTY = '0')then 
                    RD_EN_CIPHER <= '1';
                else
                    RD_EN_CIPHER <= '0';  
                end if;
                if(DECIPHER_KEY_EMPTY = '0')then 
                    RD_EN_DEC_KEY <= '1';
                else
                    RD_EN_DEC_KEY <= '0';  
                end if;          
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= (others => '0');
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_KEYS = '1')then
                    if(NB_ROUND = 0 and READY_ROUND_KEY = '1')then
                        NEXT_STATE <= ADD_KEY_INIT;
                    end if;
                else    
                    NEXT_STATE <= INIT;       
                end if;  
            when INIT_INV_SHIFT =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '1';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= (others => '0');
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= DATA_ROUND_KEY;
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_SHF = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_SUB = '1')then
                        NEXT_STATE <= INV_SBOX;
                    end if;    
                end if;        
            when INV_SHIFT =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '1';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= (others => '0');
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= DATA_MIX;
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_SHF = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_SUB = '1')then
                        NEXT_STATE <= INV_SBOX;
                    elsif(NB_ROUND = MAX_ROUND and READY_SUB = '1')then
                        NEXT_STATE <= INV_SBOX;
                    end if;
                end if;                 
            when INV_SBOX =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '1';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <=  (others => '0');
                DATA_FOR_SUB <= DATA_SHIFT ;
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_SUB = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_ROUND_KEY = '1')then
                        NEXT_STATE <= ADD_KEY;
                    elsif(NB_ROUND = MAX_ROUND and READY_ROUND_KEY = '1')then
                        NEXT_STATE <= ADD_KEY_LAST;
                    end if;
                end if;           
            when INV_MIX =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '1';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= (others => '0');
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= DATA_ROUND_KEY;
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_MIX = '1'and READY_SHIFT = '1')then
                    NEXT_STATE <= INV_SHIFT;
                end if;
            when ADD_KEY_INIT =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '1';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= CIPHER_TEXT; 
                DATA_FOR_SUB <= (others => '0'); 
                DATA_FOR_SHF <= (others => '0'); 
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_ADD = '1' and READY_SHIFT = '1')then
                    NEXT_STATE <= INIT_INV_SHIFT;
                end if;         
            when ADD_KEY =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '1';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= DATA_SUB;
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_ADD = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_MIX = '1')then
                        NEXT_STATE <= INV_MIX;   
                    end if;
                end if; 
            when ADD_KEY_LAST =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '1';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '0';
                DATA_FOR_RD <= DATA_SUB;
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= (others => '0');
                DONE_ALGO <= '0'; 
                 if(DONE_ADD = '1')then
                    if(NB_ROUND = MAX_ROUND)then 
                        NEXT_STATE <= COMPLETE;
                    end if;
                 end if;                    
            when COMPLETE =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_CIPHER <= '0';
                RD_EN_DEC_KEY <= '0';
                WR_EN_PLAIN <= '1';
                DATA_FOR_RD <= (others => '0');
                DATA_FOR_SUB <= (others => '0');
                DATA_FOR_SHF <= (others => '0');
                DATA_FOR_MIX <= (others => '0');
                PLAIN_TEXT <= DATA_ROUND_KEY;
                DONE_ALGO <= '1';
                NEXT_STATE <= IDLE;                  
            when others =>
                null;
        end case;
    end process P_COMB;
end Behavioral;
