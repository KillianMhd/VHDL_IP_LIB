----------------------------------------------------------------------------------
-- This VHDL file implements an SMBus controller. The controller
-- handles SMBus communication, including generating the SMBus
-- clock, managing read and write operations, and handling 
-- acknowledgments from the slave device. The state machine 
-- transitions through various states to perform these operations.
--
-- The main components of the design include:
--  - Clock generation process (p_clk_gen): Generates the SMBus 
--  clock from the input system clock.
--  - Control process (p_ctrl): Manages the state machine for 
--  SMBus communication, handling read/write operations and acknowledgments.
-- 
-- The design supports both read and write operations, indicated 
-- by the rwb signal, and includes signals for enabling the controller, 
-- resetting it, and indicating busy status.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library WORK;
use WORK.SpyOnMySigPkg.all;

-- Entity declaration for the SMBus Controller
entity SMBus_CONTROLLER is
  generic (
    input_clk : integer := 100_000_000; -- Input clock frequency in Hz
    bus_clk   : integer := 100_000 -- SMBus clock frequency in Hz
  );
  port (
    clk      : in std_logic; -- System clock input
    resetn   : in std_logic; -- Active-low reset input
    en       : in std_logic; -- Enable signal
    busy     : out std_logic; -- Busy status output
    rwb      : in std_logic; -- Read/Write control (0 for write, 1 for read)
    tr_s     : in std_logic; -- Transfer start signal
    addr     : in std_logic_vector(6 downto 0); -- Address input
    data_in  : in std_logic_vector(7 downto 0); -- Data input
    data_out : out std_logic_vector(7 downto 0); -- Data output
    ack      : out std_logic; -- Acknowledge output
    smbdat   : inout std_logic; -- SMBus data line
    smbclk   : inout std_logic -- SMBus clock line
  );
end entity SMBus_CONTROLLER;

architecture Behavioral of SMBus_CONTROLLER is
  -- State machine states
  type t_state is (idle, start, address, slv_ack1, read, write, slv_ack2, mst_ack, stop);
  -- Clock divider to generate SMBus clock from input clock
  constant divider     : integer := (input_clk / bus_clk) / 4;
  signal current_state : t_state; -- Current state of the state machine
  signal bit_cnt       : integer range 0 to 7 := 7; -- Bit counter
  signal addr_rw       : std_logic_vector(7 downto 0); -- Address and read/write bit
  signal data_tx       : std_logic_vector(7 downto 0); -- Data to be transmitted
  signal data_rx       : std_logic_vector(7 downto 0); -- Data received
  signal debug         : std_logic_vector(3 downto 0); -- Debug signal
  signal smbclk_ena    : std_logic := '0'; -- SMBus clock enable
  signal smbdat_int    : std_logic := '1'; -- Internal SMBus data signal
  signal smbdat_ena    : std_logic; -- SMBus data enable
  signal ack           : std_logic; -- Acknowledge signal
  signal stretch       : std_logic; -- Clock stretching signal
  signal clk_prev      : std_logic; -- Previous clock state
  signal data_clk      : std_logic; -- Data clock signal
  signal smb_clk       : std_logic; -- SMBus clock signal
begin
  -- Tri-state buffer control for SMBus data and clock lines
  smbdat <= '0' when smbdat_int = '0' else
    'Z';
  smbclk <= '0' when smb_clk = '0' else
    'Z';
  GlobalState <= debug; -- Assign debug signal to global state

  -- Clock generation process
  p_clk_gen : process (clk, resetn) is
    variable cnt : integer range 0 to divider * 4;
  begin
    if (resetn = '0') then
      stretch <= '0';
      cnt := 0;
    elsif (clk'event and clk = '1') then
      clk_prev <= data_clk;
      if (cnt = divider * 4 - 1) then
        cnt := 0;
      elsif (stretch = '0') then
        cnt := cnt + 1;
      end if;
      case cnt is
        when 0 to divider - 1 =>
          smb_clk  <= '0';
          data_clk <= '0';
        when divider to divider * 2 - 1 =>
          smb_clk  <= '0';
          data_clk <= '1';
        when divider * 2 to divider * 3 - 1 =>
          smb_clk <= '1';
          if (smbclk = '0') then
            stretch <= '1';
          else
            stretch <= '0';
          end if;
          data_clk <= '1';
        when others =>
          smb_clk  <= '1';
          data_clk <= '0';
      end case;
    end if;
  end process p_clk_gen;

  -- Control process for the state machine
  p_ctrl : process (clk, resetn) is
  begin
    if (resetn = '0') then
      -- Asynchronous reset: initialize all signals
      busy          <= '1';
      smbclk_ena    <= '0';
      smbdat_int    <= '1';
      bit_cnt       <= 7;
      data_out      <= x"00";
      ack           <= '0';
      addr_rw       <= (others => '0');
      data_tx       <= (others => '0');
      data_rx       <= (others => '0');
      debug         <= x"0";
      current_state <= idle;
    elsif (clk'event and clk = '1') then
      -- On rising edge of the clock
      if (data_clk = '1' and clk_prev = '0') then
        -- State machine transitions
        case current_state is
          when idle =>
            debug <= x"0";
            if (en = '1') then
              -- Start a new transaction
              busy          <= '1';
              addr_rw       <= addr & rwb;
              data_tx       <= data_in;
              debug         <= x"1";
              current_state <= start;
            else
              busy          <= '0';
              current_state <= idle;
            end if;
          when start =>
            -- Start condition
            busy          <= '1';
            smbdat_int    <= addr_rw(bit_cnt);
            debug         <= x"2";
            current_state <= address;
          when address =>
            -- Send address and read/write bit
            if (bit_cnt = 0) then
              busy          <= '1';
              smbdat_int    <= '1';
              bit_cnt       <= 7;
              debug         <= x"3";
              current_state <= slv_ack1;
            else
              bit_cnt       <= bit_cnt - 1;
              smbdat_int    <= addr_rw(bit_cnt - 1);
              current_state <= address;
            end if;
          when slv_ack1 =>
            -- Wait for slave acknowledgment
            if (to_X01(SMBDAT) = '0') then
              if (addr_rw(0) = '0') then
                -- Write operation
                busy          <= '1';
                smbdat_int    <= addr_rw(bit_cnt);
                debug         <= x"4";
                current_state <= write;
              else
                -- Read operation
                busy          <= '1';
                smbdat_int    <= '1';
                debug         <= x"5";
                current_state <= read;
              end if;
            else
              current_state <= stop;
            end if;
          when write =>
            -- Write data to the bus
            busy <= '1';
            if (bit_cnt = 0) then
              smbdat_int    <= '1';
              bit_cnt       <= 7;
              debug         <= x"6";
              current_state <= slv_ack2;
            else
              bit_cnt       <= bit_cnt - 1;
              smbdat_int    <= data_tx(bit_cnt - 1);
              debug         <= x"4";
              current_state <= write;
            end if;
          when read =>
            -- Read data from the bus
            busy <= '1';
            if (bit_cnt = 0) then
              if (en = '1' and addr_rw = addr & rwb) then
                smbdat_int <= '0';
              else
                smbdat_int <= '1';
              end if;
              bit_cnt       <= 7;
              data_out      <= data_rx;
              debug         <= x"7";
              current_state <= mst_ack;
            else
              bit_cnt       <= bit_cnt - 1;
              debug         <= x"5";
              current_state <= read;
            end if;
          when slv_ack2 =>
            -- Wait for slave acknowledgment after write
            if (to_X01(SMBDAT) = '0') then
              if (en = '1') then
                if (tr_s = '1') then
                  busy    <= '0';
                  addr_rw <= addr & rwb;
                  data_tx <= data_in;
                  if (addr_rw = addr & rwb) then
                    smbdat_int    <= data_in(bit_cnt);
                    current_state <= write;
                  else
                    debug         <= x"1";
                    current_state <= start;
                  end if;
                else
                  debug         <= x"8";
                  current_state <= stop;
                end if;
              else
                debug         <= x"8";
                current_state <= stop;
              end if;
            else
              debug         <= x"8";
              current_state <= stop;
            end if;
          when mst_ack =>
            -- Master acknowledgment
            if (en = '1') then
              if (tr_s = '1') then
                busy    <= '0';
                addr_rw <= addr & rwb;
                data_tx <= data_in;
                if (addr_rw = addr & rwb) then
                  smbdat_int    <= '1';
                  debug         <= x"5";
                  current_state <= read;
                else
                  debug         <= x"1";
                  current_state <= start;
                end if;
              else
                debug         <= x"8";
                current_state <= stop;
              end if;
            else
              debug         <= x"8";
              current_state <= stop;
            end if;
          when stop =>
            debug         <= x"0";
            busy          <= '0';
            current_state <= idle;
          when others =>
            -- Default case to handle unexpected states
            debug         <= x"0";
            current_state <= stop;
        end case;
      elsif (data_clk = '0' and clk_prev = '1') then
        case current_state is
          when start =>
            if (smbclk_ena = '0') then
              smbclk_ena <= '1';
              ack        <= '0';
            end if;
          when slv_ack1 =>
            if (smbdat /= '0' or ack = '1') then
              ack <= '1';
            end if;
          when read =>
            data_rx(bit_cnt) <= to_X01(smbdat);
          when slv_ack2 =>
            if (smbdat /= '0' or ack = '1') then
              ack <= '1';
            end if;
          when stop =>
            smbclk_ena <= '0';
          when others =>
            null;
        end case;
      end if;
    end if;
  end process p_ctrl;

  with current_state select smbdat_ena <=
    clk_prev when start,
    not clk_prev when stop,
    smbdat_int when others;
end Behavioral;