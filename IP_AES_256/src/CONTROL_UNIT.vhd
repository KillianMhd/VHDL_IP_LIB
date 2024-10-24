----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2024 14:02:59
-- Design Name: 
-- Module Name: CONTROL_UNIT - Behavioral
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
entity CONTROL_UNIT is
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
        RD_EN_ENC_KEY   : out std_logic;
        RD_EN_PLAIN     : out std_logic;
        WR_EN_CIPHER    : out std_logic;
        PLAIN_TEXT_EMPTY    : in std_logic;
        CIPHER_KEY_EMPTY   : in std_logic;
        -- DATA --
        PLAIN_TEXT      : in std_logic_vector(127 downto 0);
        DATA_ROUND_KEY  : in std_logic_vector(127 downto 0);
        DATA_SUB        : in std_logic_vector(127 downto 0);
        DATA_SHIFT      : in std_logic_vector(127 downto 0);
        DATA_MIX        : in std_logic_vector(127 downto 0);
        DATA_NEXT_RD    : out std_logic_vector(127 downto 0);
        DATA_NEXT_SUB   : out std_logic_vector(127 downto 0);
        DATA_NEXT_SHF   : out std_logic_vector(127 downto 0);
        DATA_NEXT_MIX   : out std_logic_vector(127 downto 0);
        CIPHER_TEXT     : out std_logic_vector(127 downto 0);
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
end CONTROL_UNIT;

architecture Behavioral of CONTROL_UNIT is
    TYPE state_type is (IDLE, INIT, SBOX, SHIFT, MIX, ADD_KEY_INIT, ADD_KEY, ADD_KEY_LAST, COMPLETE);
    
    CONSTANT MAX_ROUND : integer := 14;
    
    SIGNAL CURRENT_STATE,NEXT_STATE : state_type;
    SIGNAL NB_ROUND : integer;  
    
begin
    P_COUNTER : process(CURRENT_STATE,RESETN)
    begin
        if(RESETN = '0' or CURRENT_STATE = IDLE)then
            NB_ROUND <= 0;    
        elsif(CURRENT_STATE = SBOX)then
            NB_ROUND <= NB_ROUND + 1;                    
        end if;  
    end process P_COUNTER;
    
    P_SYNC  : process(CLK, RESETN,CURRENT_STATE)
    begin
        if(RESETN = '0' )then
            CURRENT_STATE <= IDLE;
        elsif(rising_edge(CLK)) then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process P_SYNC;
    
    P_COMB  : process(CURRENT_STATE,NB_ROUND,START_ALGO,DONE_KEYS,READY_ROUND_KEY,DONE_SHF,READY_MIX,DONE_MIX,DONE_ADD,READY_SUB,DONE_SUB,READY_SHIFT,DATA_ROUND_KEY,DATA_SUB,DATA_SHIFT,PLAIN_TEXT,DATA_MIX,PLAIN_TEXT,PLAIN_TEXT_EMPTY,CIPHER_KEY_EMPTY)
    begin
        case CURRENT_STATE is
            when IDLE =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= (others => '0');
                CIPHER_TEXT <= (others => '0');
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
                if(CIPHER_KEY_EMPTY = '0')then
                    RD_EN_ENC_KEY <= '1';
                else
                    RD_EN_ENC_KEY <= '0';
                end if; 
                if(PLAIN_TEXT_EMPTY = '0')then
                    RD_EN_PLAIN <= '1';
                else
                    RD_EN_PLAIN <= '0';
                end if;  
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= (others => '0');
                CIPHER_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_KEYS = '1')then
                    if(NB_ROUND = 0 and READY_ROUND_KEY = '1')then
                        NEXT_STATE <= ADD_KEY_INIT;
                    end if;
                else
                    NEXT_STATE <= INIT;    
                end if;              
            when SBOX =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '1';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= DATA_ROUND_KEY;
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= (others => '0');
                CIPHER_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_SUB = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_SHIFT = '1')then
                        NEXT_STATE <= SHIFT;
                    elsif(NB_ROUND = MAX_ROUND and READY_SHIFT = '1')then
                        NEXT_STATE <= SHIFT;
                    end if;
                end if;           
            when SHIFT =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '1';
                VALID_MIX <= '0';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= DATA_SUB;
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= (others => '0');
                CIPHER_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_SHF = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_MIX = '1')then
                        NEXT_STATE <= MIX;
                    elsif(NB_ROUND = MAX_ROUND and READY_ROUND_KEY = '1')then
                        NEXT_STATE <= ADD_KEY_LAST;
                    end if;
                end if;      
            when MIX =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '0';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '1';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= DATA_SHIFT;
                DATA_NEXT_MIX <= (others => '0');
                CIPHER_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_MIX = '1'and READY_ROUND_KEY = '1')then
                    NEXT_STATE <= ADD_KEY;
                end if;
            when ADD_KEY_INIT =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '1';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0'); --for sub
                DATA_NEXT_SUB <= (others => '0'); -- for shift
                DATA_NEXT_SHF <= (others => '0'); -- for mix
                DATA_NEXT_MIX <= PLAIN_TEXT; -- for rd
                CIPHER_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_ADD = '1' and READY_SUB = '1')then
                    NEXT_STATE <= SBOX;
                end if;         
            when ADD_KEY =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '1';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= DATA_MIX;
                CIPHER_TEXT <= (others => '0');
                DONE_ALGO <= '0';
                if(DONE_ADD = '1')then
                    if(NB_ROUND < MAX_ROUND and READY_SUB = '1')then
                        NEXT_STATE <= SBOX;   
                    end if;
                end if; 
            when ADD_KEY_LAST =>
                START_KEYS <= '0';
                VALID_ROUND_KEY <= '1';
                VALID_SUB <= '0';
                VALID_SHIFT <= '0';
                VALID_MIX <= '0';
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '0';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= DATA_SHIFT;
                CIPHER_TEXT <= (others => '0');
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
                RD_EN_ENC_KEY <= '0';
                RD_EN_PLAIN <= '0';
                WR_EN_CIPHER <= '1';
                DATA_NEXT_RD <= (others => '0');
                DATA_NEXT_SUB <= (others => '0');
                DATA_NEXT_SHF <= (others => '0');
                DATA_NEXT_MIX <= (others => '0');
                CIPHER_TEXT <= DATA_ROUND_KEY;
                DONE_ALGO <= '1';
                NEXT_STATE <= IDLE;                  
            when others =>
                NEXT_STATE <= IDLE;
        end case;
    end process P_COMB;
end Behavioral;
