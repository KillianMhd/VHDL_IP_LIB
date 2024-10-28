----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2024 14:27:10
-- Design Name: 
-- Module Name: TB_INV_CIPHER - Behavioral
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

library WORK;
use WORK.AES_PKG.all;
use WORK.PKG_TOOLS.all;
use WORK.pkg_doc.all;
use WORK.stdio_h.all;
use WORK.pkg_tools_tb.all;

entity TB_INV_CIPHER is
end TB_INV_CIPHER;

architecture Behavioral of TB_INV_CIPHER is
    COMPONENT INV_CIPHER is
        PORT(
        CLK                 : in std_logic;
        RESETN              : in std_logic; 
        START               : in std_logic;
        PLAIN_TEXT          : out std_logic_vector(127 downto 0);
        DECIPHER_KEY        : in std_logic_vector(255 downto 0);
        DONE                : out std_logic;
        RD_EN_CIPHER        : out std_logic;
        RD_EN_DEC_KEY       : out std_logic;
        WR_EN_PLAIN         : out std_logic;
        DECIPHER_KEY_EMPTY  : in std_logic;
        CIPHER_TEXT_EMPTY   : in std_logic;
        CIPHER_TEXT         : in std_logic_vector(127 downto 0));
    END COMPONENT INV_CIPHER;
        
    CONSTANT CST_CLK_100MHz_PERIODE  : TIME      := 10 ns;  
    CONSTANT C_RST_TIME              : TIME      := CST_CLK_100MHz_PERIODE * 4; 
    
    SIGNAL clk_sys      : std_logic;
    SIGNAL reset_n      : std_logic;
    SIGNAL start          : std_logic;
    SIGNAL done         : std_logic;
    SIGNAL DATA_I       : std_logic_vector(127 downto 0);
    SIGNAL DATA_KEY     : std_logic_vector(255 downto 0);
    SIGNAL DATA_O       : std_logic_vector(127 downto 0);
    SIGNAL RD_EN_CIPHER        : std_logic;
    SIGNAL RD_EN_DEC_KEY       : std_logic;
    SIGNAL WR_EN_PLAIN         : std_logic;
    SIGNAL DECIPHER_KEY_EMPTY  : std_logic;
    SIGNAL CIPHER_TEXT_EMPTY   : std_logic;
begin
    P_CLK_100MHz : process
    begin
        clk_sys  <= '0';
        wait for CST_CLK_100MHz_PERIODE/2;
        clk_sys  <= '1';
        wait for CST_CLK_100MHz_PERIODE/2;
    end process P_CLK_100MHz;

    P_RESET : process
    begin
        reset_n  <= '0';
        wait for C_RST_TIME;
        reset_n  <= '1';
        wait;
    end process P_RESET;
 
    P_SIM : process
        variable testError   : integer := 0;
        variable nbTestOk    : integer := 0;
        variable nbTest      : integer := 0;
    begin
        initLog;
        docTitle1 ("TEST OF INV CIPHER FOR AES-256");
    
        DATA_I <= (others => '0');
        start <= '0';
        DECIPHER_KEY_EMPTY <= '0';
        CIPHER_TEXT_EMPTY <= '0';
        logInitTest("TEST INV CIPHER", nbTest);
        wait until rising_edge(reset_n);
        DATA_I <= x"8ea2b7ca516745bfeafc49904b496089";
        DATA_KEY <= x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";
        start <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        start <= '0';
        wait until done = '1';
        wait for 2*CST_CLK_100MHz_PERIODE;
        start <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        start <= '0';
        wait until done = '1';
        wait for 2*CST_CLK_100MHz_PERIODE;
        logResultTest(testError,nbTest,nbTestOk);   
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    I_INV_CIPHER : INV_CIPHER
        PORT MAP(
            CLK => clk_sys,
            RESETN => reset_n,
            START => start,
            PLAIN_TEXT => DATA_O,
            DECIPHER_KEY => DATA_KEY,
            DONE => done,
            RD_EN_CIPHER => RD_EN_CIPHER,
            RD_EN_DEC_KEY => RD_EN_DEC_KEY,
            WR_EN_PLAIN => WR_EN_PLAIN,
            DECIPHER_KEY_EMPTY => DECIPHER_KEY_EMPTY,
            CIPHER_TEXT_EMPTY => CIPHER_TEXT_EMPTY,
            CIPHER_TEXT => DATA_I);
end Behavioral;
