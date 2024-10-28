----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2024 14:05:58
-- Design Name: 
-- Module Name: TB_INV_SHIFT - Behavioral
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

entity TB_INV_SHIFT is
end TB_INV_SHIFT;

architecture Behavioral of TB_INV_SHIFT is
    COMPONENT INV_SHIFT_ROWS IS 
        port(
            CLK     : in std_logic;
            RESETN  : in std_logic;
            READY   : out std_logic;
            VALID   : in std_logic;
            DONE    : out std_logic;
            DATA_I  : in std_logic_vector(127 downto 0);
            DATA_O  : out std_logic_vector(127 downto 0));
    END COMPONENT INV_SHIFT_ROWS;
       
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
        docTitle1 ("TEST OF INV SHIFT_ROWS FOR AES-256");
    
        DATA_I <= (others => '0');
        valid <= '0';    
        logInitTest("TEST INV SHIFT_ROWS", nbTest);
        wait until rising_edge(reset_n);
        DATA_I <= x"aa5ece06ee6e3c56dde68bac2621bebf";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"aa218b56ee5ebeacdd6ecebf26e63c06", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"d1ed44fd1a0f3f2afa4ff27b7c332a69";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"d133f22a1aed2a7bfa0f44697c4f3ffd", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"cfb4dbedf4093808538502ac33de185c";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"cfde0208f4b418ac5309db5c338538ed", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"78e2acce741ed5425100c5e0e23b80c7";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"783bc54274e280e0511eacc7e200d5ce", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"d6f3d9dda6279bd1430d52a0e513f3fe";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"d61352d1a6f3f3a04327d9fee50d9bdd", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"beb50aa6cff856126b0d6aff45c25dc4";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"bec26a12cfb55dff6bf80ac4450d56a6", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"f6e062ff507458f9be50497656ed654c";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"f6ed49f950e06576be74624c565058ff", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"d22f0c291ffe031a789d83b2ecc5364c";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"d2c5831a1f2f36b278fe0c4cec9d0329", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"2e6e7a2dafc6eef83a86ace7c25ba934";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"2e5bacf8af6ea9e73ac67a34c286ee2d", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"9cf0a62049fd59a399518984f26be178";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"9c6b89a349f0e18499fda678f2515920", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"88db34fb1f807678d3f833c2194a759e";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"884a33781fdb75c2d380349e19f876fb", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"ad9c7e017e55ef25bc150fe01ccb6395";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"adcb0f257e9c63e0bc557e951c15ef01", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"84e1fd6b1a5c946fdf4938977cfbac23";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"84fb386f1ae1ac97df5cfd237c49946b", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"6353e08c0960e104cd70b751bacad0e7";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"63cab7040953d051cd60e0e7ba70e18c", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        logResultTest(testError,nbTest,nbTestOk);     
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    I_INV_SHIFT_ROWS  : INV_SHIFT_ROWS 
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
