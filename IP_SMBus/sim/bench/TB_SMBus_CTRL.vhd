library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library WORK;
use WORK.PKG_TOOLS.all;
use WORK.pkg_doc.all;
use WORK.stdio_h.all;
use WORK.pkg_tools_tb.all;
use WORK.SpyOnMySigPkg.all;

entity TB_SMBus_CONTROLLER is
end TB_SMBus_CONTROLLER;

architecture Behavioral of TB_SMBus_CONTROLLER is

    -- Constants
    constant INPUT_CLK_PERIOD : time := 10 ns; -- 100 MHz
    CONSTANT C_RST_TIME              : TIME      := INPUT_CLK_PERIOD * 4; 
    -- Signals for the SMBus Controller
    signal clk        : std_logic := '0';
    signal resetn     : std_logic := '0';
    signal en         : std_logic := '0';
    signal busy       : std_logic;
    signal rwb        : std_logic; -- 0 for write, 1 for read
    signal tr_s       : std_logic;  
    signal addr       : std_logic_vector(6 downto 0);
    signal data_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out_tx    : std_logic_vector(7 downto 0);
    signal data_out_rx    : std_logic_vector(7 downto 0);
    signal ack_err_tx  : std_logic;
    signal ack_err_rx  : std_logic;
    signal smbdat     : std_logic;
    signal smbclk     : std_logic;
	signal result	: std_logic_vector(7 downto 0);
    -- Instantiate the SMBus controller
    component smbus_controller is
        generic (
            INPUT_CLK : INTEGER;
            BUS_CLK   : INTEGER);
        port (
            CLK      : in STD_LOGIC;
            RESETN   : in STD_LOGIC;
            EN       : in std_logic;
            BUSY     : out std_logic;
            RWB      : in STD_LOGIC;
            tr_s     : in    std_logic;
            ADDR     : in STD_LOGIC_VECTOR(6 downto 0);
            DATA_IN  : in STD_LOGIC_VECTOR(7 downto 0);
            DATA_OUT  : out STD_LOGIC_VECTOR(7 downto 0);
            ACK_ERR  : out STD_LOGIC;
            SMBDAT   : inout STD_LOGIC;
            SMBCLK   : inout STD_LOGIC
           );
    end component smbus_controller;
begin

    smbclk <= 'H'; 
    smbdat <= 'H';
    
    P_DEBUG : process(GlobalState)
    begin
        if(GlobalState = x"3" or GlobalState = x"6")then
            smbdat <= '0';
        else
            smbdat <= 'Z';
        end if;            
    end process P_DEBUG;
    
    P_CLK_100MHz : process
    begin
        clk  <= '0';
        wait for INPUT_CLK_PERIOD/2;
        clk  <= '1';
        wait for INPUT_CLK_PERIOD/2;
    end process P_CLK_100MHz;

    P_RESET : process
    begin
        resetn  <= '0';
        wait for C_RST_TIME;
        resetn  <= '1';
        wait;
    end process P_RESET;
  	
    P_SIM : process
        variable testError   : integer := 0;
        variable nbTestOk    : integer := 0;
        variable nbTest      : integer := 0;
    begin
        initLog;
        docTitle1 ("TEST OF SMBUS CONTROLLER");
        data_in <= (others => '0');addr <=(others => '0');en <= '0';rwb <='0'; tr_s <= '0';
        wait until rising_edge(resetn);
        logInitTest("TEST SMBUS CONTROLLER WRITE TRANSACTION", nbTest);
        data_in <= x"38";en <= '1';rwb <='0';addr <="0101001";tr_s <= '0';
        wait until busy = '0';
        en <= '0';
        logResultTest(testError,nbTest,nbTestOk);
        wait for 4 * INPUT_CLK_PERIOD;
        
        logInitTest("TEST SMBUS CONTROLLER READ TRANSACTION", nbTest);
        data_in <= x"00";en <= '1';rwb <='1'; addr <=  "0101011";tr_s <= '0';
        wait until busy = '0';
        en <= '0';
        logResultTest(testError,nbTest,nbTestOk);
        wait for 4 * INPUT_CLK_PERIOD;
     
        logResultTestGlobal(nbTestOk, nbTest);
    end process P_SIM;
    
    DUT: smbus_controller
        generic map (
            INPUT_CLK => 100_000_000,
            BUS_CLK => 100_000)
        port map (
            CLK => clk,
            RESETN => resetn,
            EN => en,
            BUSY => busy,
            RWB => rwb,
            tr_s => tr_s,
            ADDR => addr,
            DATA_IN => data_in,
            DATA_OUT => data_out_tx,
            ACK_ERR => ack_err_tx,
            SMBDAT => smbdat,
            SMBCLK => smbclk
            );      
end Behavioral;
