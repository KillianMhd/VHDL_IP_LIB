----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2024 16:31:24
-- Design Name: 
-- Module Name: AES_CORE - Behavioral
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


entity AES_CORE is
    port ( 
        CLK             : in std_logic;
        RESETN          : in std_logic; 
        -- CONTROL --
        START_CIPHER    : in std_logic;
        START_DECIPHER  : in std_logic;
        -- STATUS --
        DONE_CIPHER     : out std_logic;
        DONE_DECIPHER   : out std_logic;
        -- FIFO --
        RD_EN_PLAIN     : out std_logic;    
        RD_EN_CIPHER    : out std_logic;
        RD_EN_DEC_KEY   : out std_logic;    
        RD_EN_ENC_KEY   : out std_logic;
        WR_EN_PLAIN     : out std_logic;    
        WR_EN_CIPHER    : out std_logic;
        PLAIN_TEXT_EMPTY    : in std_logic;
        CIPHER_KEY_EMPTY    : in std_logic;
        DECIPHER_KEY_EMPTY  : in std_logic;
        CIPHER_TEXT_EMPTY   : in std_logic;
        -- TEXT/KEY --
        PLAIN_TEXT      : in std_logic_vector(127 downto 0);
        TO_DECIPHER     : in std_logic_vector(127 downto 0);
        DECIPHER_KEY    : in std_logic_vector(255 downto 0);
        CIPHER_KEY      : in std_logic_vector(255 downto 0);
        CIPHER_TEXT     : out std_logic_vector(127 downto 0);
        DECIPHER_TEXT   : out std_logic_vector(127 downto 0));
end AES_CORE;

architecture Behavioral of AES_CORE is

    component CIPHER is
        port(
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
    end component CIPHER;   
    
    component INV_CIPHER is
        port(
            CLK             : in std_logic;
            RESETN          : in std_logic; 
            START           : in std_logic;
            PLAIN_TEXT      : out std_logic_vector(127 downto 0);
            DECIPHER_KEY    : in std_logic_vector(255 downto 0);
            DONE            : out std_logic;
            RD_EN_CIPHER    : out std_logic;
            RD_EN_DEC_KEY   : out std_logic;
            WR_EN_PLAIN     : out std_logic;
            DECIPHER_KEY_EMPTY  : in std_logic;
            CIPHER_TEXT_EMPTY   : in std_logic; 
            CIPHER_TEXT     : in std_logic_vector(127 downto 0)
            );
    end component;            
begin

    I_CIPHER : CIPHER 
        port map(
            CLK => CLK,
            RESETN => RESETN,
            PLAIN_TEXT => PLAIN_TEXT,
            START => START_CIPHER,
            CIPHER_KEY => CIPHER_KEY,
            DONE => DONE_CIPHER,
            RD_EN_ENC_KEY => RD_EN_ENC_KEY,
            RD_EN_PLAIN => RD_EN_PLAIN,
            WR_EN_CIPHER => WR_EN_CIPHER,
            PLAIN_TEXT_EMPTY => PLAIN_TEXT_EMPTY,
            CIPHER_KEY_EMPTY => CIPHER_KEY_EMPTY,
            CIPHER_TEXT => CIPHER_TEXT
        );
    I_DECIPHER : INV_CIPHER
        port map(
            CLK => CLK,
            RESETN => RESETN,
            CIPHER_TEXT => TO_DECIPHER,
            START => START_DECIPHER,
            DECIPHER_KEY => DECIPHER_KEY,
            DONE => DONE_DECIPHER,
            RD_EN_CIPHER => RD_EN_CIPHER,
            RD_EN_DEC_KEY => RD_EN_DEC_KEY,
            WR_EN_PLAIN => WR_EN_PLAIN,
            DECIPHER_KEY_EMPTY => DECIPHER_KEY_EMPTY,
            CIPHER_TEXT_EMPTY => CIPHER_TEXT_EMPTY, 
            PLAIN_TEXT => DECIPHER_TEXT);     
end Behavioral;
