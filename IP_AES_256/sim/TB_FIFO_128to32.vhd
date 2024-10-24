----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2024 13:14:34
-- Design Name: 
-- Module Name: TB_FIFO_128to32 - Behavioral
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
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.AES_PKG.all;
use WORK.PKG_TOOLS.all;
use WORK.pkg_doc.all;
use WORK.stdio_h.all;
use WORK.pkg_tools_tb.all;

entity TB_FIFO_128to32 is
end TB_FIFO_128to32;

architecture Behavioral of TB_FIFO_128to32 is

    COMPONENT FIFO_128to32 is
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
            DATA_O  : out std_logic_vector(31 downto 0)
        );
    END COMPONENT FIFO_128to32;
    
    CONSTANT CST_CLK_100MHz_PERIODE  : TIME      := 10 ns;  
    CONSTANT C_RST_TIME              : TIME      := CST_CLK_100MHz_PERIODE * 4; 
    
    SIGNAL clk_sys      : std_logic;
    SIGNAL reset_n      : std_logic;
    SIGNAL rd_en        : std_logic;
    SIGNAL wr_en        : std_logic;
    SIGNAL flush        : std_logic;
    SIGNAL empty        : std_logic;
    SIGNAL full         : std_logic;
    SIGNAL DATA_I       : std_logic_vector(127 downto 0);
    SIGNAL DATA_O       : std_logic_vector(31 downto 0);
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
        docTitle1 ("TEST OF FIFO 128 TO 32");
    
        DATA_I <= (others => '0');
        rd_en <= '0';
        wr_en <= '0';
        flush <= '0';
        logInitTest("TEST FIFO 128 TO 32", nbTest);
        
        wait until rising_edge(reset_n);
        DATA_I <= x"00112233445566778899aabbccddeeff";
        wr_en <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        wr_en <= '0';
        wait for 2*CST_CLK_100MHz_PERIODE;
        while empty = '0' loop
            rd_en <= '1';
            wait for CST_CLK_100MHz_PERIODE;
            rd_en <= '0';
        end loop;    
        wait for 2*CST_CLK_100MHz_PERIODE;
        logResultTest(testError,nbTest,nbTestOk);   
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    I_FIFO_128to32   : FIFO_128to32
    PORT MAP(
        CLK => clk_sys,
        RESETN => reset_n,
        FLUSH => flush,
        RD_EN => rd_en,
        WR_EN => wr_en,
        FULL => full,
        EMPTY => empty,
        DATA_I  => DATA_I,
        DATA_O  => DATA_O);
end Behavioral;
