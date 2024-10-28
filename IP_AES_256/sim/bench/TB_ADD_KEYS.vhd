----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2024 14:05:58
-- Design Name: 
-- Module Name: TB_ADD_KEYS - Behavioral
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
use WORK.PKG_TOOLS.all;
use WORK.pkg_doc.all;
use WORK.stdio_h.all;
use WORK.pkg_tools_tb.all;


entity TB_ADD_KEYS is
end TB_ADD_KEYS;

architecture Behavioral of TB_ADD_KEYS is
COMPONENT ROUND_KEY  IS 
        port(
            CLK             : in std_logic;
            RESETN          : in std_logic;
            DATA_I          : in std_logic_vector(127 downto 0);
            ROUND_KEY       : in std_logic_vector(127 downto 0);
            READY           : out std_logic;
            VALID           : in std_logic;
            RD_EN           : out std_logic;
            DONE            : out std_logic;
            DATA_ROUND_KEY  : out std_logic_vector(127 downto 0));
    END COMPONENT ROUND_KEY ;
       
    CONSTANT CST_CLK_100MHz_PERIODE  : TIME      := 10 ns;  
    CONSTANT C_RST_TIME              : TIME      := CST_CLK_100MHz_PERIODE * 4; 
    
    SIGNAL clk_sys      : std_logic;
    SIGNAL reset_n      : std_logic;
    SIGNAL start          : std_logic;
    SIGNAL done         : std_logic;
    SIGNAL DATA_I       : std_logic_vector(127 downto 0);
    SIGNAL DATA_KEY     : std_logic_vector(127 downto 0);
    SIGNAL valid        : std_logic;
    SIGNAL ready        : std_logic;
    SIGNAL rd_en        : std_logic;
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
        docTitle1 ("TEST OF ADD_ROUND_KEYS FOR AES-256");
    
        DATA_I <= (others => '0');
        valid <= '0';    
        logInitTest("TEST ADD_ROUND_KEYS", nbTest);
        wait until rising_edge(reset_n);
        DATA_I <= x"00112233445566778899aabbccddeeff";
        DATA_KEY <= x"000102030405060708090a0b0c0d0e0f";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"00102030405060708090a0b0c0d0e0f0", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"5f72641557f5bc92f7be3b291db9f91a";
        DATA_KEY <= x"101112131415161718191a1b1c1d1e1f";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"4f63760643e0aa85efa7213201a4e705", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"bd2a395d2b6ac438d192443e615da195";
        DATA_KEY <= x"a573c29fa176c498a97fce93a572c09c";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"1859fbc28a1c00a078ed8aadc42f6109", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"810dce0cc9db8172b3678c1e88a1b5bd";
        DATA_KEY <= x"1651a8cd0244beda1a5da4c10640bade";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"975c66c1cb9f3fa8a93a28df8ee10f63", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"b2822d81abe6fb275faf103a078c0033";
        DATA_KEY <= x"ae87dff00ff11b68a68ed5fb03fc1567";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"1c05f271a417e04ff921c5c104701554", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"aeb65ba974e0f822d73f567bdb64c877";
        DATA_KEY <= x"6de1f1486fa54f9275f8eb5373b8518d";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"c357aae11b45b7b0a2c7bd28a8dc99fa", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"b951c33c02e9bd29ae25cdb1efa08cc7";
        DATA_KEY <= x"c656827fc9a799176f294cec6cd5598b";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"7f074143cb4e243ec10c815d8375d54c", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"ebb19e1c3ee7c9e87d7535e9ed6b9144";
        DATA_KEY <= x"3de23a75524775e727bf9eb45407cf39";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"d653a4696ca0bc0f5acaab5db96c5e7d", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"5174c8669da98435a8b3e62ca974a5ea";
        DATA_KEY <= x"0bdc905fc27b0948ad5245a4c1871c2f";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"5aa858395fd28d7d05e1a38868f3b9c5", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"0f77ee31d2ccadc05430a83f4ef96ac3";
        DATA_KEY <= x"45f5a66017b2d387300d4d33640a820a";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"4a824851c57e7e47643de50c2af3e8c9", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"bd86f0ea748fc4f4630f11c1e9331233";
        DATA_KEY <= x"7ccff71cbeb4fe5413e6bbf0d261a7df";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"c14907f6ca3b3aa070e9aa313b52b5ec", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"af8690415d6e1dd387e5fbedd5c89013";
        DATA_KEY <= x"f01afafee7a82979d7a5644ab3afe640";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"5f9c6abfbac634aa50409fa766677653", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"7427fae4d8a695269ce83d315be0392b";
        DATA_KEY <= x"2541fe719bf500258813bbd55a721c0a";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"516604954353950314fb86e401922521", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"2c21a820306f154ab712c75eee0da04f";
        DATA_KEY <= x"4e5a6699a9f24fe07e572baacdf8cdea";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"627bceb9999d5aaac945ecf423f56da5", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        DATA_I <= x"aa5ece06ee6e3c56dde68bac2621bebf";
        DATA_KEY <= x"24fc79ccbf0979e9371ac23c6d68de36";
        valid <= '1';
        wait for CST_CLK_100MHz_PERIODE;
        valid <= '0';
        wait until done = '1';
        compare_Output_To_Reference("DATA_O", DATA_O, x"8ea2b7ca516745bfeafc49904b496089", TRUE, testError);
        wait for 2*CST_CLK_100MHz_PERIODE;
        logResultTest(testError,nbTest,nbTestOk);     
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    I_ROUND_KEY   : ROUND_KEY 
    PORT MAP(
        CLK => clk_sys,
        RESETN => reset_n,
        READY => READY,
        VALID => VALID,
        DATA_I => DATA_I,
        ROUND_KEY => DATA_KEY,
        DONE => done,
        RD_EN => rd_en,
        DATA_ROUND_KEY => DATA_O
    );
end Behavioral;
