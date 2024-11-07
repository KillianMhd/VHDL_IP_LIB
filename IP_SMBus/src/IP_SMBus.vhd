----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2024 17:59:10
-- Design Name: 
-- Module Name: IP_SMBus - Behavioral
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
use WORK.SpyOnMySigPkg.all;

entity IP_SMBus is
    GENERIC(
        INPUT_CLK   : INTEGER := 100_000_000;
        BUS_CLK     : INTEGER := 100_000);
    PORT(
        -- Wishbone Interface signals
        WB_CLK_I    : in std_logic;
        WB_RST_I    : in std_logic;
        ARST_I      : in std_logic;
        WB_ADR_I    : in std_logic_vector(2 downto 0);
        WB_DAT_I    : in std_logic_vector(7 downto 0);
        WB_DAT_O    : out std_logic_vector(7 downto 0);
        WB_WE_I     : in std_logic;
        WB_STB_I    : in std_logic;
        WB_CYC_I    : in std_logic;
        WB_ACK_O    : out std_logic;
        WB_INTA_O   : out std_logic;
        -- SMBus Signals
        SMBCLK      : INOUT std_logic;
        SMBDAT      : INOUT std_logic
        );
end IP_SMBus;

architecture Behavioral of IP_SMBus is
    COMPONENT WB_ITF IS
        PORT(
            WB_CLK_I    : in std_logic;
            WB_RST_I    : in std_logic;
            ARST_I      : in std_logic;
            WB_ADR_I    : in std_logic_vector(2 downto 0);
            WB_DAT_I    : in std_logic_vector(7 downto 0);
            WB_DAT_O    : out std_logic_vector(7 downto 0);
            WB_WE_I     : in std_logic;
            WB_STB_I    : in std_logic;
            WB_CYC_I    : in std_logic;
            WB_ACK_O    : out std_logic;
            WB_INTA_O   : out std_logic;
            -- ADDRESSE --
            ADDR         : out std_logic_vector(6 downto 0);
            -- CONTROL --
            EN          : out std_logic;
            RWB         : out std_logic;
            TR_S        : out std_logic;
            -- TRANSMIT --
            TX_DATA     : out std_logic_vector(7 downto 0);
            -- RECEIVE --
            RX_DATA     : in std_logic_vector(7 downto 0);
            -- STATUS --
            Busy        : in std_logic;
            RxACK       : in std_logic
            );
    END COMPONENT WB_ITF;
    
    COMPONENT SMBus_CONTROLLER IS
       GENERIC(
            INPUT_CLK   : INTEGER := 100_000_000;
            BUS_CLK     : INTEGER := 400_000);
       PORT (
            CLK         : in STD_LOGIC;
            RESETN      : in STD_LOGIC;
            EN          : in std_logic;
            BUSY        : out std_logic;
            RWB         : in STD_LOGIC;
            tr_s        : in STD_LOGIC;
            ADDR        : in STD_LOGIC_VECTOR(6 downto 0);
            DATA_IN     : in STD_LOGIC_VECTOR(7 downto 0);
            DATA_OUT    : out STD_LOGIC_VECTOR(7 downto 0);
            ACK         : out STD_LOGIC;
            SMBDAT      : inout STD_LOGIC;
            SMBCLK      : inout STD_LOGIC
            );
    END COMPONENT SMBus_CONTROLLER;    
    
    SIGNAL EN       : std_logic;
    SIGNAL RWB      : std_logic;
    SIGNAL TR_S     : std_logic;
    SIGNAL BUSY     : std_logic;
    SIGNAL RxACK    : std_logic;
    SIGNAL ADDR     : std_logic_vector(6 downto 0);
    SIGNAL TX_DATA  : std_logic_vector(7 downto 0);
    SIGNAL RX_DATA  : std_logic_vector(7 downto 0);
begin
    GlobalBUSY <= BUSY;
    
    I_WB_ITF    : WB_ITF
        PORT MAP(
            WB_CLK_I    => WB_CLK_I,
            WB_RST_I    => WB_RST_I,
            ARST_I      => ARST_I,
            WB_ADR_I    => WB_ADR_I,
            WB_DAT_I    => WB_DAT_I,
            WB_DAT_O    => WB_DAT_O,
            WB_WE_I     => WB_WE_I,
            WB_STB_I    => WB_STB_I,
            WB_CYC_I    => WB_CYC_I,
            WB_ACK_O    => WB_ACK_O,
            WB_INTA_O   => WB_INTA_O,
            -- PRESCALE --
            ADDR         => ADDR,
            -- CONTROL --
            EN          => EN,
            RWB         => RWB,
            TR_S        => tr_s,
            -- TRANSMIT --
            TX_DATA     => TX_DATA,
            -- RECEIVE --
            RX_DATA     => RX_DATA,
            -- STATUS --
            Busy        => BUSY,
            RxACK       => RxACK
            );

    I_SMBus_CONTROLLER    : SMBus_CONTROLLER
        GENERIC MAP(
            INPUT_CLK   => INPUT_CLK,
            BUS_CLK     => BUS_CLK)
        PORT MAP(
            CLK         => WB_CLK_I,
            RESETN      => ARST_I, 
            EN          => EN,
            BUSY        => BUSY,
            RWB         => RWB,
            tr_s        => TR_S,
            ADDR        => ADDR,
            DATA_IN     => TX_DATA,
            DATA_OUT    => RX_DATA,
            ACK         => RxACK,
            SMBDAT      => SMBDAT,
            SMBCLK      => SMBCLK
            );
end Behavioral;
