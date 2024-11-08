----------------------------------------------------------------------------------
-- This file is the TOP module :
-- In this file, we're doing the port map and the connection between
-- Wishbone interface (WB_ITF.vhd) and SMBus Controller (SMBus_CONTROLLER.vhd) 
-- A TOP testbench (TB_IP_SMBus.vhd) is available in the sim folder 
-- with a Wishbone Master model
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library WORK;
use WORK.SpyOnMySigPkg.all;

entity IP_SMBus is
  generic (
    INPUT_CLK : integer := 100_000_000;
    BUS_CLK   : integer := 100_000);
  port (
    -- Wishbone Interface signals
    WB_CLK_I  : in std_logic;
    WB_RST_I  : in std_logic;
    ARST_I    : in std_logic;
    WB_ADR_I  : in std_logic_vector(2 downto 0);
    WB_DAT_I  : in std_logic_vector(7 downto 0);
    WB_DAT_O  : out std_logic_vector(7 downto 0);
    WB_WE_I   : in std_logic;
    WB_STB_I  : in std_logic;
    WB_CYC_I  : in std_logic;
    WB_ACK_O  : out std_logic;
    WB_INTA_O : out std_logic;
    -- SMBus Signals
    SMBCLK : inout std_logic;
    SMBDAT : inout std_logic
  );
end IP_SMBus;

architecture Behavioral of IP_SMBus is
  component WB_ITF is
    port (
      WB_CLK_I  : in std_logic;
      WB_RST_I  : in std_logic;
      ARST_I    : in std_logic;
      WB_ADR_I  : in std_logic_vector(2 downto 0);
      WB_DAT_I  : in std_logic_vector(7 downto 0);
      WB_DAT_O  : out std_logic_vector(7 downto 0);
      WB_WE_I   : in std_logic;
      WB_STB_I  : in std_logic;
      WB_CYC_I  : in std_logic;
      WB_ACK_O  : out std_logic;
      WB_INTA_O : out std_logic;
      -- ADDRESSE --
      ADDR : out std_logic_vector(6 downto 0);
      -- CONTROL --
      EN   : out std_logic;
      RWB  : out std_logic;
      TR_S : out std_logic;
      -- TRANSMIT --
      TX_DATA : out std_logic_vector(7 downto 0);
      -- RECEIVE --
      RX_DATA : in std_logic_vector(7 downto 0);
      -- STATUS --
      Busy  : in std_logic;
      RxACK : in std_logic
    );
  end component WB_ITF;

  component SMBus_CONTROLLER is
    generic (
      INPUT_CLK : integer := 100_000_000; -- FPGA Clock input
      BUS_CLK   : integer := 400_000);
    port (
      CLK      : in std_logic;
      RESETN   : in std_logic;
      EN       : in std_logic;
      BUSY     : out std_logic;
      RWB      : in std_logic;
      tr_s     : in std_logic;
      ADDR     : in std_logic_vector(6 downto 0);
      DATA_IN  : in std_logic_vector(7 downto 0);
      DATA_OUT : out std_logic_vector(7 downto 0);
      ACK      : out std_logic;
      SMBDAT   : inout std_logic;
      SMBCLK   : inout std_logic
    );
  end component SMBus_CONTROLLER;

  signal EN      : std_logic;
  signal RWB     : std_logic;
  signal TR_S    : std_logic;
  signal BUSY    : std_logic;
  signal RxACK   : std_logic;
  signal ADDR    : std_logic_vector(6 downto 0);
  signal TX_DATA : std_logic_vector(7 downto 0);
  signal RX_DATA : std_logic_vector(7 downto 0);
begin
  GlobalBUSY <= BUSY;

  I_WB_ITF : WB_ITF
  port map
  (
    WB_CLK_I  => WB_CLK_I,
    WB_RST_I  => WB_RST_I,
    ARST_I    => ARST_I,
    WB_ADR_I  => WB_ADR_I,
    WB_DAT_I  => WB_DAT_I,
    WB_DAT_O  => WB_DAT_O,
    WB_WE_I   => WB_WE_I,
    WB_STB_I  => WB_STB_I,
    WB_CYC_I  => WB_CYC_I,
    WB_ACK_O  => WB_ACK_O,
    WB_INTA_O => WB_INTA_O,
    -- PRESCALE --
    ADDR => ADDR,
    -- CONTROL --
    EN   => EN,
    RWB  => RWB,
    TR_S => tr_s,
    -- TRANSMIT --
    TX_DATA => TX_DATA,
    -- RECEIVE --
    RX_DATA => RX_DATA,
    -- STATUS --
    Busy  => BUSY,
    RxACK => RxACK
  );

  I_SMBus_CONTROLLER : SMBus_CONTROLLER
  generic map(
    INPUT_CLK => INPUT_CLK,
    BUS_CLK   => BUS_CLK)
  port map
  (
    CLK      => WB_CLK_I,
    RESETN   => ARST_I,
    EN       => EN,
    BUSY     => BUSY,
    RWB      => RWB,
    tr_s     => TR_S,
    ADDR     => ADDR,
    DATA_IN  => TX_DATA,
    DATA_OUT => RX_DATA,
    ACK      => RxACK,
    SMBDAT   => SMBDAT,
    SMBCLK   => SMBCLK
  );
end Behavioral;
