----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2024 17:36:16
-- Design Name: 
-- Module Name: IP_AES - Behavioral
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

entity IP_AES is
    port(
        S_AXI_ACLK      : in  std_logic;
        S_AXI_ARESETN   : in  std_logic;
        S_AXI_AWADDR    : in  std_logic_vector(31 downto 0);
        S_AXI_AWVALID   : in  std_logic;
        S_AXI_AWREADY   : out std_logic;
        S_AXI_WDATA     : in  std_logic_vector(31 downto 0);
        S_AXI_WSTRB     :  in std_logic_vector(3 downto 0);
        S_AXI_WVALID    : in  std_logic; 
        S_AXI_WREADY    : out std_logic;
        S_AXI_BRESP     : out std_logic_vector(1 downto 0);
        S_AXI_BVALID    : out std_logic;
        S_AXI_BREADY    : in  std_logic;
        S_AXI_ARADDR    : in  std_logic_vector(31 downto 0);
        S_AXI_ARVALID   : in  std_logic;
        S_AXI_ARREADY   : out std_logic;
        S_AXI_RDATA     : out std_logic_vector(31 downto 0);
        S_AXI_RRESP     : out std_logic_vector(1 downto 0);
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in  std_logic
        );
end IP_AES;

architecture Behavioral of IP_AES is

    COMPONENT AXI_LITE_INTERFACE IS
        port(
            -- AXI4-LITE SLAVE SIGNALS
            S_AXI_ACLK          : in  std_logic;
            S_AXI_ARESETN       : in  std_logic;
            S_AXI_AWADDR        : in  std_logic_vector(31 downto 0);
            S_AXI_AWVALID       : in  std_logic;
            S_AXI_AWREADY       : out std_logic;
            S_AXI_WDATA         : in  std_logic_vector(31 downto 0);
            S_AXI_WSTRB         :  in std_logic_vector(3 downto 0);
            S_AXI_WVALID        : in  std_logic; 
            S_AXI_WREADY        : out std_logic;
            S_AXI_BRESP         : out std_logic_vector(1 downto 0);
            S_AXI_BVALID        : out std_logic;
            S_AXI_BREADY        : in  std_logic;
            S_AXI_ARADDR        : in  std_logic_vector(31 downto 0);
            S_AXI_ARVALID       : in  std_logic;
            S_AXI_ARREADY       : out std_logic;
            S_AXI_RDATA         : out std_logic_vector(31 downto 0);
            S_AXI_RRESP         : out std_logic_vector(1 downto 0);
            S_AXI_RVALID        : out std_logic;
            S_AXI_RREADY        : in  std_logic;
            -- STATUS --
            DONE_CIPHER         : in std_logic;
            DONE_DECIPHER       : in std_logic;
            CIPHER_TEXT_EMPTY   : in std_logic;
            CIPHER_TEXT_FULL    : in std_logic;
            PLAIN_TEXT_EMPTY    : in std_logic;
            PLAIN_TEXT_FULL     : in std_logic;
            CIPHER_KEY_EMPTY    : in std_logic;
            CIPHER_KEY_FULL     : in std_logic;
            DECIPHER_KEY_EMPTY  : in std_logic;
            DECIPHER_KEY_FULL   : in std_logic;
            DECIPHER_TEXT_EMPTY : in std_logic;
            DECIPHER_TEXT_FULL  : in std_logic;
            ENC_TEXT_EMPTY      : in std_logic;
            ENC_TEXT_FULL       : in std_logic;
            -- CONTROL -- 
            START_CIPHER        : out std_logic;
            START_DECIPHER      : out std_logic; 
            FLUSH_CIPHER        : out std_logic;
            FLUSH_PLAIN         : out std_logic;
            FLUSH_CIPHER_KEY    : out std_logic;
            FLUSH_DECIPHER_KEY  : out std_logic;
            FLUSH_ENC           : out std_logic;
            FLUSH_DEC           : out std_logic; 
            -- FIFOs --
            WR_EN_CIPHER        : out std_logic;    
            WR_EN_PLAIN         : out std_logic; 
            WR_EN_KEY_ENC       : out std_logic; 
            WR_EN_KEY_DEC       : out std_logic; 
            RD_EN_DECIPHER      : out std_logic;    
            RD_EN_CIPHER        : out std_logic;
            -- KEY -- 
            CIPHER_KEY          : out std_logic_vector(31 downto 0);
            DECIPHER_KEY        : out std_logic_vector(31 downto 0);
            -- TEXT --
            PLAIN_TEXT          : out std_logic_vector(31 downto 0);
            DECIPHER_TEXT       : in std_logic_vector(31 downto 0);
            TO_DECIPHER         : out std_logic_vector(31 downto 0);
            CIPHER_TEXT         : in std_logic_vector(31 downto 0)
        );  
    END COMPONENT AXI_LITE_INTERFACE;
        
    COMPONENT AES_CORE IS
        PORT ( 
            CLK             : in std_logic;
            RESETN          : in std_logic; 
            START_CIPHER    : in std_logic;
            START_DECIPHER  : in std_logic;
            PLAIN_TEXT      : in std_logic_vector(127 downto 0);
            TO_DECIPHER     : in std_logic_vector(127 downto 0);
            DECIPHER_KEY    : in std_logic_vector(255 downto 0);
            CIPHER_KEY      : in std_logic_vector(255 downto 0);
            DONE_CIPHER     : out std_logic;
            DONE_DECIPHER   : out std_logic;
            RD_EN_PLAIN     : out std_logic;    
            RD_EN_CIPHER    : out std_logic;
            RD_EN_DEC_KEY   : out std_logic;    
            RD_EN_ENC_KEY   : out std_logic;
            WR_EN_PLAIN     : out std_logic;    
            WR_EN_CIPHER    : out std_logic;
            PLAIN_TEXT_EMPTY    : in std_logic;
            CIPHER_KEY_EMPTY   : in std_logic;
            DECIPHER_KEY_EMPTY  : in std_logic;
            CIPHER_TEXT_EMPTY   : in std_logic;
            CIPHER_TEXT     : out std_logic_vector(127 downto 0);
            DECIPHER_TEXT   : out std_logic_vector(127 downto 0)
            );
    END COMPONENT AES_CORE;
        
    COMPONENT FIFO_32to128 IS
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
            DATA_I  : in std_logic_vector(31 downto 0);
            DATA_O  : out std_logic_vector(127 downto 0)
        );
    END COMPONENT FIFO_32to128;
    
    COMPONENT FIFO_32to256 IS
        GENERIC(
            FIFO_DEPTH  : integer := 8
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
            DATA_I  : in std_logic_vector(31 downto 0);
            DATA_O  : out std_logic_vector(255 downto 0)
        );
    END COMPONENT FIFO_32to256;
    
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
    
    -- DATA/KEY --       
    SIGNAL CIPHER_KEY       : std_logic_vector(255 downto 0);
    SIGNAL DECIPHER_KEY     : std_logic_vector(255 downto 0);
    SIGNAL CIPHER_TEXT      : std_logic_vector(127 downto 0);
    SIGNAL PLAIN_TEXT       : std_logic_vector(127 downto 0);
    SIGNAL DECIPHER_TEXT    : std_logic_vector(127 downto 0);
    SIGNAL TO_DECIPHER_TEXT : std_logic_vector(127 downto 0);
    SIGNAL REG_CIPHER_KEY   : std_logic_vector(31 downto 0);
    SIGNAL REG_DECIPHER_KEY : std_logic_vector(31 downto 0);
    SIGNAL REG_CIPHER_TEXT  : std_logic_vector(31 downto 0);
    SIGNAL REG_TO_DECIPHER  : std_logic_vector(31 downto 0);
    SIGNAL REG_PLAIN_TEXT   : std_logic_vector(31 downto 0);
    SIGNAL REG_DECIPHER     : std_logic_vector(31 downto 0);
    -- CONTROL --
    SIGNAL START_CIPHER        : std_logic;
    SIGNAL START_DECIPHER      : std_logic;
    SIGNAL FLUSH_CIPHER        : std_logic;
    SIGNAL FLUSH_PLAIN         : std_logic;
    SIGNAL FLUSH_CIPHER_KEY    : std_logic;
    SIGNAL FLUSH_DECIPHER_KEY  : std_logic;
    SIGNAL FLUSH_ENC           : std_logic;
    SIGNAL FLUSH_DEC           : std_logic;
    -- STATUS --
    SIGNAL DONE_CIPHER         : std_logic;
    SIGNAL DONE_DECIPHER       : std_logic;
    SIGNAL CIPHER_TEXT_EMPTY   : std_logic;
    SIGNAL CIPHER_TEXT_FULL    : std_logic;
    SIGNAL PLAIN_TEXT_EMPTY    : std_logic;
    SIGNAL PLAIN_TEXT_FULL     : std_logic;
    SIGNAL CIPHER_KEY_EMPTY    : std_logic;
    SIGNAL CIPHER_KEY_FULL     : std_logic;
    SIGNAL DECIPHER_KEY_EMPTY  : std_logic;
    SIGNAL DECIPHER_KEY_FULL   : std_logic;
    SIGNAL DECIPHER_TEXT_EMPTY : std_logic;
    SIGNAL DECIPHER_TEXT_FULL  : std_logic;
    SIGNAL ENC_TEXT_EMPTY      : std_logic;
    SIGNAL ENC_TEXT_FULL       : std_logic;
    -- FIFO --
    SIGNAL WR_EN_CIPHER        : std_logic;    
    SIGNAL WR_EN_PLAIN         : std_logic; 
    SIGNAL WR_EN_KEY_ENC       : std_logic; 
    SIGNAL WR_EN_KEY_DEC       : std_logic; 
    SIGNAL RD_EN_DECIPHER      : std_logic;    
    SIGNAL RD_EN_CIPHER        : std_logic;
    SIGNAL RD_EN_ENC           : std_logic;    
    SIGNAL RD_EN_PLAIN         : std_logic; 
    SIGNAL RD_EN_KEY_ENC       : std_logic; 
    SIGNAL RD_EN_KEY_DEC       : std_logic; 
    SIGNAL WR_EN_DECIPHER      : std_logic;    
    SIGNAL WR_EN_ENC           : std_logic; 
begin

I_FIFO_KEY_CIPHER : FIFO_32to256
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN,
        FLUSH => FLUSH_CIPHER_KEY,
        RD_EN => RD_EN_KEY_ENC,
        WR_EN => WR_EN_KEY_ENC,
        FULL => CIPHER_KEY_FULL,
        EMPTY => CIPHER_KEY_EMPTY,
        DATA_I  => REG_CIPHER_KEY,
        DATA_O  => CIPHER_KEY);

I_FIFO_KEY_DECIPHER : FIFO_32to256
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN,
        FLUSH => FLUSH_DECIPHER_KEY,
        RD_EN => RD_EN_KEY_DEC,
        WR_EN => WR_EN_KEY_DEC,
        FULL => DECIPHER_KEY_FULL,
        EMPTY => DECIPHER_KEY_EMPTY,
        DATA_I  => REG_DECIPHER_KEY,
        DATA_O  => DECIPHER_KEY);
    
I_FIFO_PLAIN_TEXT   : FIFO_32to128
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN,
        FLUSH => FLUSH_PLAIN,
        RD_EN => RD_EN_PLAIN,
        WR_EN => WR_EN_PLAIN,
        FULL => PLAIN_TEXT_FULL,
        EMPTY => PLAIN_TEXT_EMPTY,
        DATA_I  => REG_PLAIN_TEXT,
        DATA_O  => PLAIN_TEXT); 

I_FIFO_TO_DECIPHER   : FIFO_32to128
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN,
        FLUSH => FLUSH_CIPHER,
        RD_EN => RD_EN_ENC,
        WR_EN => WR_EN_CIPHER,
        FULL => CIPHER_TEXT_FULL,
        EMPTY => CIPHER_TEXT_EMPTY,
        DATA_I  => REG_TO_DECIPHER,
        DATA_O  => TO_DECIPHER_TEXT); 
           
I_FIFO_CIPHER_TEXT   : FIFO_128to32
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN,
        FLUSH => FLUSH_ENC,
        RD_EN => RD_EN_CIPHER,
        WR_EN => WR_EN_ENC,
        FULL => ENC_TEXT_FULL,
        EMPTY => ENC_TEXT_EMPTY,
        DATA_I  => CIPHER_TEXT,
        DATA_O  => REG_CIPHER_TEXT);

I_FIFO_DECIPHER_TEXT    : FIFO_128to32
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN,
        FLUSH => FLUSH_DEC,
        RD_EN => RD_EN_DECIPHER,
        WR_EN => WR_EN_DECIPHER,
        FULL => DECIPHER_TEXT_FULL,
        EMPTY => DECIPHER_TEXT_EMPTY,
        DATA_I  => DECIPHER_TEXT,
        DATA_O  => REG_DECIPHER);
                       
I_AXI_LITE_INTERFACE    : AXI_LITE_INTERFACE
    PORT MAP(
        S_AXI_ACLK => S_AXI_ACLK,
        S_AXI_ARESETN => S_AXI_ARESETN,
        S_AXI_AWADDR => S_AXI_AWADDR,
        S_AXI_AWVALID => S_AXI_AWVALID,
        S_AXI_AWREADY => S_AXI_AWREADY,
        S_AXI_WDATA => S_AXI_WDATA,
        S_AXI_WSTRB => S_AXI_WSTRB ,
        S_AXI_WVALID => S_AXI_WVALID,
        S_AXI_WREADY => S_AXI_WREADY,
        S_AXI_BRESP => S_AXI_BRESP,
        S_AXI_BVALID => S_AXI_BVALID,
        S_AXI_BREADY => S_AXI_BREADY,
        S_AXI_ARADDR => S_AXI_ARADDR,
        S_AXI_ARVALID => S_AXI_ARVALID,
        S_AXI_ARREADY => S_AXI_ARREADY,
        S_AXI_RDATA => S_AXI_RDATA,
        S_AXI_RRESP => S_AXI_RRESP,
        S_AXI_RVALID => S_AXI_RVALID,
        S_AXI_RREADY => S_AXI_RREADY,
        -- STATUS --
        DONE_CIPHER => DONE_CIPHER,
        DONE_DECIPHER => DONE_DECIPHER,
        CIPHER_TEXT_EMPTY => CIPHER_TEXT_EMPTY,
        CIPHER_TEXT_FULL => CIPHER_TEXT_FULL,
        PLAIN_TEXT_EMPTY  => PLAIN_TEXT_EMPTY,
        PLAIN_TEXT_FULL => PLAIN_TEXT_FULL,
        CIPHER_KEY_EMPTY => CIPHER_KEY_EMPTY,
        CIPHER_KEY_FULL => CIPHER_KEY_FULL,
        DECIPHER_KEY_EMPTY => DECIPHER_KEY_EMPTY,
        DECIPHER_KEY_FULL => DECIPHER_KEY_FULL,
        DECIPHER_TEXT_EMPTY => DECIPHER_TEXT_EMPTY,
        DECIPHER_TEXT_FULL => DECIPHER_TEXT_FULL,
        ENC_TEXT_EMPTY => ENC_TEXT_EMPTY,
        ENC_TEXT_FULL => ENC_TEXT_FULL,
        -- CONTROL --
        START_CIPHER => START_CIPHER,
        START_DECIPHER => START_DECIPHER,
        FLUSH_CIPHER => FLUSH_CIPHER,
        FLUSH_PLAIN => FLUSH_PLAIN ,
        FLUSH_CIPHER_KEY => FLUSH_CIPHER_KEY,
        FLUSH_DECIPHER_KEY => FLUSH_DECIPHER_KEY,
        FLUSH_ENC => FLUSH_ENC,
        FLUSH_DEC => FLUSH_DEC,
        -- FIFO --
        WR_EN_CIPHER => WR_EN_CIPHER,   
        WR_EN_PLAIN => WR_EN_PLAIN,
        WR_EN_KEY_ENC => WR_EN_KEY_ENC,
        WR_EN_KEY_DEC => WR_EN_KEY_DEC,
        RD_EN_DECIPHER => RD_EN_DECIPHER,   
        RD_EN_CIPHER => RD_EN_CIPHER,
        -- KEY --     
        CIPHER_KEY => REG_CIPHER_KEY,
        DECIPHER_KEY => REG_DECIPHER_KEY,
        -- TEXT --
        DECIPHER_TEXT => REG_DECIPHER,
        TO_DECIPHER => REG_TO_DECIPHER,
        PLAIN_TEXT => REG_PLAIN_TEXT,
        CIPHER_TEXT => REG_CIPHER_TEXT
            );       
I_AES_CORE  : AES_CORE
    PORT MAP(
        CLK => S_AXI_ACLK,
        RESETN => S_AXI_ARESETN ,
        START_CIPHER => START_CIPHER,
        START_DECIPHER =>START_DECIPHER ,
        PLAIN_TEXT => PLAIN_TEXT,
        TO_DECIPHER  => TO_DECIPHER_TEXT,
        DECIPHER_KEY => DECIPHER_KEY,
        CIPHER_KEY => CIPHER_KEY,
        DONE_CIPHER => DONE_CIPHER,
        DONE_DECIPHER => DONE_DECIPHER,
        RD_EN_PLAIN => RD_EN_PLAIN,
        RD_EN_CIPHER => RD_EN_ENC,
        RD_EN_DEC_KEY => RD_EN_KEY_DEC,    
        RD_EN_ENC_KEY => RD_EN_KEY_ENC,
        WR_EN_PLAIN => WR_EN_DECIPHER,    
        WR_EN_CIPHER => WR_EN_ENC,
        PLAIN_TEXT_EMPTY => PLAIN_TEXT_EMPTY,
        CIPHER_KEY_EMPTY => CIPHER_KEY_EMPTY,
        DECIPHER_KEY_EMPTY => DECIPHER_KEY_EMPTY,
        CIPHER_TEXT_EMPTY => CIPHER_TEXT_EMPTY,
        CIPHER_TEXT => CIPHER_TEXT,
        DECIPHER_TEXT => DECIPHER_TEXT 
        );          
end Behavioral;
