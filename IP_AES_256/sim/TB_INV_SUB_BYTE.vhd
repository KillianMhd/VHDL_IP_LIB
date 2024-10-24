----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.10.2024 09:10:17
-- Design Name: 
-- Module Name: TB_INV_SUB_BYTE - Behavioral
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

entity TB_INV_SUB_BYTE is
end TB_INV_SUB_BYTE;

architecture Behavioral of TB_INV_SUB_BYTE is
    COMPONENT INV_SUB_BYTE IS 
        port(
            CLK     : in std_logic;
            RESETN  : in std_logic;
            READY   : out std_logic;
            VALID   : in std_logic;
            DONE    : out std_logic;
            DATA_I  : in std_logic_vector(127 downto 0);
            DATA_O  : out std_logic_vector(127 downto 0));
    END COMPONENT INV_SUB_BYTE;
       
    CONSTANT CST_CLK_100MHz_PERIODE  : TIME      := 10 ns;  
    CONSTANT C_RST_TIME              : TIME      := CST_CLK_100MHz_PERIODE * 4; 
    
    SIGNAL clk_sys      : std_logic;
    SIGNAL reset_n      : std_logic;
    SIGNAL start          : std_logic;
    SIGNAL done         : std_logic;
    SIGNAL DATA_I       : std_logic_vector(127 downto 0);
    SIGNAL valid        : std_logic;
    SIGNAL ready        : std_logic;
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
        docTitle1 ("TEST OF INV SUB_BYTE FOR AES-256");
    
        DATA_I <= (others => '0');
        valid <= '0';    
        logInitTest("TEST INV CIPHER", nbTest);
        wait until rising_edge(reset_n);
        DATA_I <= x"aa218b56ee5ebeacdd6ecebf26e63c06";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"627bceb9999d5aaac945ecf423f56da5", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"d133f22a1aed2a7bfa0f44697c4f3ffd";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"516604954353950314fb86e401922521", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"cfde0208f4b418ac5309db5c338538ed";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"5f9c6abfbac634aa50409fa766677653", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"783bc54274e280e0511eacc7e200d5ce";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"c14907f6ca3b3aa070e9aa313b52b5ec", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"d61352d1a6f3f3a04327d9fee50d9bdd";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"4a824851c57e7e47643de50c2af3e8c9", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"bec26a12cfb55dff6bf80ac4450d56a6";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"5aa858395fd28d7d05e1a38868f3b9c5", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"f6ed49f950e06576be74624c565058ff";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"d653a4696ca0bc0f5acaab5db96c5e7d", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"d2c5831a1f2f36b278fe0c4cec9d0329";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"7f074143cb4e243ec10c815d8375d54c", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"2e5bacf8af6ea9e73ac67a34c286ee2d";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"c357aae11b45b7b0a2c7bd28a8dc99fa", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"9c6b89a349f0e18499fda678f2515920";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"1c05f271a417e04ff921c5c104701554", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"884a33781fdb75c2d380349e19f876fb";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"975c66c1cb9f3fa8a93a28df8ee10f63", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"adcb0f257e9c63e0bc557e951c15ef01";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"1859fbc28a1c00a078ed8aadc42f6109", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"84fb386f1ae1ac97df5cfd237c49946b";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"4f63760643e0aa85efa7213201a4e705", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"63cab7040953d051cd60e0e7ba70e18c";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"00102030405060708090a0b0c0d0e0f0", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        logResultTest(testError,nbTest,nbTestOk);     
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    I_INV_SUB_BYTE  : INV_SUB_BYTE 
    PORT MAP(
        CLK => clk_sys,
        RESETN => reset_n,
        READY => READY,
        VALID => VALID,
        DATA_I => DATA_I,
        DONE => done,
        DATA_O => DATA_O
    );
end Behavioral;
