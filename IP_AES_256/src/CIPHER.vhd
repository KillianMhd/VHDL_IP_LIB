----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2024 17:10:51
-- Design Name: 
-- Module Name: CIPHER - Behavioral
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

entity CIPHER is
    port (
        CLK             : in std_logic;
        RESETN          : in std_logic; 
        START           : in std_logic;
        PLAIN_TEXT      : in std_logic_vector(127 downto 0);
        CIPHER_KEY      : in std_logic_vector(255 downto 0);
        DONE            : out std_logic;
        RD_EN_ENC_KEY   : out std_logic;
        RD_EN_PLAIN     : out std_logic;
        WR_EN_CIPHER    : out std_logic;
        PLAIN_TEXT_EMPTY    : in std_logic;
        CIPHER_KEY_EMPTY   : in std_logic;
        CIPHER_TEXT     : out std_logic_vector(127 downto 0));
end CIPHER;

architecture Behavioral of CIPHER is
    COMPONENT SUB_BYTE IS
        PORT(
            CLK     : in std_logic;
            RESETN  : in std_logic;
            READY   : out std_logic;
            VALID   : in std_logic;
            DONE    : out std_logic;
            DATA_I  : in std_logic_vector(127 downto 0);
            DATA_O  : out std_logic_vector(127 downto 0));
    END COMPONENT SUB_BYTE;
    
    COMPONENT SHIFT_ROWS IS
        PORT(
            CLK     : in std_logic;
            RESETN  : in std_logic;
            DATA_I  : in std_logic_vector(127 downto 0);
            READY   : out std_logic;
            VALID   : in std_logic;
            DONE    : out std_logic;
            DATA_O  : out std_logic_vector(127 downto 0));
    END COMPONENT SHIFT_ROWS; 
    
    COMPONENT ROUND_KEY IS
        PORT(
            CLK             : in std_logic;
            RESETN          : in std_logic;
            DATA_I          : in std_logic_vector(127 downto 0);
            ROUND_KEY       : in std_logic_vector(127 downto 0);
            READY           : out std_logic;
            VALID           : in std_logic;
            DONE            : out std_logic;
            RD_EN           : out std_logic;            
            DATA_ROUND_KEY  : out std_logic_vector(127 downto 0)
            );
    END COMPONENT ROUND_KEY;
    
    COMPONENT MIX_COLS IS 
        PORT(
            CLK     : in std_logic;
            RESETN  : in std_logic;
            DATA_I  : in std_logic_vector(127 downto 0);
            READY   : out std_logic;
            VALID   : in std_logic;
            DONE    : out std_logic;
            DATA_O  : out std_logic_vector(127 downto 0));
    END COMPONENT MIX_COLS;
    
    COMPONENT KEY_SCHEDULE IS
        PORT(
            CLK     : in std_logic;
            RESETN  : in std_logic;
            KEY     : in std_logic_vector(255 downto 0);
            START   : in std_logic;
            WR_EN   : out std_logic;
            DONE    : out std_logic;
            RD_KEY  : out round_keys
            ); 
    END COMPONENT KEY_SCHEDULE;
    
    COMPONENT KEY_BUFFER IS
        PORT(
            CLK         : in std_logic;
            RESETN      : in std_logic;
            KEY_INPUT   : in round_keys;
            WR_EN       : in std_logic;
            RD_EN       : in std_logic;
            KEY_OUTPUT  : out std_logic_vector(127 downto 0)); 
    END COMPONENT KEY_BUFFER;
               
    COMPONENT CONTROL_UNIT IS
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
    END COMPONENT CONTROL_UNIT;
    
    SIGNAL RD_KEY           : round_keys;
    SIGNAL RD_BUFFER        : std_logic;
    SIGNAL WR_BUFFER        : std_logic;
    SIGNAL BUFFER_KEY       : std_logic_vector(127 downto 0);
    SIGNAL START_KEYS       : std_logic;
    
    SIGNAL DONE_KEYS        : std_logic;
    SIGNAL DONE_SUB         : std_logic;
    SIGNAL DONE_SHF         : std_logic;
    SIGNAL DONE_MIX         : std_logic;
    SIGNAL DONE_ADD         : std_logic;
    
    SIGNAL DATA_AFTER_RD    : std_logic_vector(127 downto 0);        
    SIGNAL DATA_AFTER_SUB   : std_logic_vector(127 downto 0);
    SIGNAL DATA_AFTER_SHF   : std_logic_vector(127 downto 0);
    SIGNAL DATA_AFTER_MIX   : std_logic_vector(127 downto 0);

    SIGNAL DATA_FOR_RD      : std_logic_vector(127 downto 0);        
    SIGNAL DATA_FOR_SUB     : std_logic_vector(127 downto 0);
    SIGNAL DATA_FOR_SHF     : std_logic_vector(127 downto 0);
    SIGNAL DATA_FOR_MIX     : std_logic_vector(127 downto 0);
    
    SIGNAL READY_RD         : std_logic;        
    SIGNAL READY_SUB        : std_logic;
    SIGNAL READY_SHF        : std_logic;
    SIGNAL READY_MIX        : std_logic;
    
    SIGNAL VALID_RD         : std_logic;        
    SIGNAL VALID_SUB        : std_logic;
    SIGNAL VALID_SHF        : std_logic;
    SIGNAL VALID_MIX        : std_logic;
begin

I_ROUND_KEY : ROUND_KEY
    PORT MAP(
        CLK => CLK,
        RESETN => RESETN,
        DATA_I => DATA_FOR_RD,
        READY => READY_RD,
        VALID => VALID_RD,
        ROUND_KEY => BUFFER_KEY, 
        DONE => DONE_ADD,
        RD_EN => RD_BUFFER,
        DATA_ROUND_KEY => DATA_AFTER_RD);

I_SUB_BYTE  : SUB_BYTE 
    PORT MAP(
        CLK => CLK,
        RESETN => RESETN,
        READY => READY_SUB,
        VALID => VALID_SUB,
        DATA_I => DATA_FOR_SUB,
        DONE => DONE_SUB,
        DATA_O => DATA_AFTER_SUB
    );

I_SHIFT_ROWS    : SHIFT_ROWS
    PORT MAP(
        CLK => CLK,
        RESETN => RESETN,
        DATA_I => DATA_FOR_SHF,
        READY => READY_SHF,
        VALID => VALID_SHF,
        DONE => DONE_SHF,
        DATA_O => DATA_AFTER_SHF
    );

I_MIX_COLS  : MIX_COLS
    PORT MAP(
        CLK => CLK,
        RESETN => RESETN,
        DATA_I => DATA_FOR_MIX,
        READY => READY_MIX,
        VALID => VALID_MIX,
        DONE => DONE_MIX,
        DATA_O => DATA_AFTER_MIX);

I_KEY_SCHEDULE  : KEY_SCHEDULE
    PORT MAP(
        CLK => CLK,
        RESETN => RESETN,
        KEY => CIPHER_KEY,
        START => START_KEYS,
        WR_EN  => WR_BUFFER,
        DONE  => DONE_KEYS,
        RD_KEY => RD_KEY);

I_KEY_BUFFER    : KEY_BUFFER
    PORT MAP(
        CLK => CLK,
        RESETN => RESETN,
        KEY_INPUT => RD_KEY,
        WR_EN   => WR_BUFFER,
        RD_EN => RD_BUFFER,
        KEY_OUTPUT => BUFFER_KEY);
    
I_CONTROL_UNIT  : CONTROL_UNIT
    PORT MAP(
--        -- SYSTEM --
            CLK => CLK,
            RESETN => RESETN,
            -- CONTROL --
            START_ALGO => START,
            START_KEYS => START_KEYS,
            -- STATUS --
            DONE_KEYS => DONE_KEYS,
            DONE_SUB => DONE_SUB,
            DONE_SHF => DONE_SHF,
            DONE_MIX => DONE_MIX,
            DONE_ADD => DONE_ADD,
            DONE_ALGO => DONE,
            -- FIFO --
            RD_EN_ENC_KEY => RD_EN_ENC_KEY,
            RD_EN_PLAIN => RD_EN_PLAIN ,
            WR_EN_CIPHER => WR_EN_CIPHER,
            PLAIN_TEXT_EMPTY => PLAIN_TEXT_EMPTY,
            CIPHER_KEY_EMPTY => CIPHER_KEY_EMPTY,
--             DATA --
            PLAIN_TEXT => PLAIN_TEXT,
            DATA_ROUND_KEY => DATA_AFTER_RD,
            DATA_SUB => DATA_AFTER_SUB,
            DATA_SHIFT => DATA_AFTER_SHF,
            DATA_MIX  => DATA_AFTER_MIX,
            DATA_NEXT_RD => DATA_FOR_SUB,
            DATA_NEXT_SUB => DATA_FOR_SHF,
            DATA_NEXT_SHF  => DATA_FOR_MIX,
            DATA_NEXT_MIX => DATA_FOR_RD,
            CIPHER_TEXT  => CIPHER_TEXT,
            --
            READY_ROUND_KEY => READY_RD,
            READY_SUB => READY_SUB,
            READY_SHIFT => READY_SHF,
            READY_MIX => READY_MIX,
            --
            VALID_ROUND_KEY => VALID_RD,
            VALID_SUB => VALID_SUB,
            VALID_SHIFT => VALID_SHF,
            VALID_MIX  => VALID_MIX);
end Behavioral;
