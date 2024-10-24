----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.10.2024 17:00:05
-- Design Name: 
-- Module Name: TB_CIPHER - Behavioral
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
entity TB_CIPHER is
end TB_CIPHER;

architecture Behavioral of TB_CIPHER is
    COMPONENT CIPHER IS
        port (
        CLK         : in std_logic;
        RESETN      : in std_logic; 
        START       : in std_logic;
        PLAIN_TEXT  : in std_logic_vector(127 downto 0);
        CIPHER_KEY  : in std_logic_vector(255 downto 0);
        DONE        : out std_logic;
        CIPHER_TEXT : out std_logic_vector(127 downto 0));
    END COMPONENT CIPHER;      

    CONSTANT CST_CLK_100MHz_PERIODE  : TIME      := 10 ns;  
    CONSTANT C_RST_TIME              : TIME      := CST_CLK_100MHz_PERIODE * 4; 
    
    SIGNAL clk_sys      : std_logic;
    SIGNAL reset_n      : std_logic;
    SIGNAL start          : std_logic;
    SIGNAL done         : std_logic;
    SIGNAL DATA_I       : std_logic_vector(127 downto 0);
    SIGNAL DATA_KEY     : std_logic_vector(255 downto 0);
    SIGNAL DATA_O       : std_logic_vector(127 downto 0);
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
        docTitle1 ("TEST OF CIPHER FOR AES-256");
    
        DATA_I <= (others => '0');
        start <= '0';
        logInitTest("TEST CIPHER", nbTest);
        
        wait until rising_edge(reset_n);
        DATA_I <= x"00112233445566778899aabbccddeeff";
        DATA_KEY <= x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";
        start <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        start <= '0';
        wait until done = '1';
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"00112233445566778899aabbccddeeff";
        DATA_KEY <= x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";
        start <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        start <= '0';
        wait until done = '1';
        wait for 2*CST_CLK_100MHz_PERIODE;
        logResultTest(testError,nbTest,nbTestOk);   
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    I_CIPHER    : CIPHER
        PORT MAP(
            CLK => clk_sys,
            RESETN => reset_n,
            START => start,
            PLAIN_TEXT => DATA_I,
            CIPHER_KEY => DATA_KEY,
            DONE => done,
            CIPHER_TEXT=>DATA_O);
end Behavioral;
