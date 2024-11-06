library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library WORK;
use WORK.SpyOnMySigPkg.all;
entity smbus_controller is
  generic (
    input_clk : integer := 100_000_000;
    bus_clk   : integer := 400_000
  );
  port (
    clk      : in    std_logic;
    resetn   : in    std_logic;
    en       : in    std_logic;
    busy     : out   std_logic;
    rwb      : in    std_logic; -- 0 for write, 1 for read
    tr_s     : in    std_logic;   
    addr     : in    std_logic_vector(6 downto 0);
    data_in  : in    std_logic_vector(7 downto 0);
    data_out : out   std_logic_vector(7 downto 0);
    ack_err  : out   std_logic;
    smbdat   : inout std_logic;
    smbclk   : inout std_logic   
  );
end entity smbus_controller;

architecture behavioral of smbus_controller is
    type t_state is (idle, start, addresse, slv_ack1, read, write, slv_ack2, mst_ack, stop);
    constant divider        : integer := (input_clk / bus_clk) / 4;
    signal current_state    : t_state;
    signal bit_cnt          : integer range 0 to 7 := 7;
    signal addr_rw          : std_logic_vector(7 downto 0);
    signal data_tx          : std_logic_vector(7 downto 0);
    signal data_rx          : std_logic_vector(7 downto 0);
    signal debug            : std_logic_vector(3 downto 0);
    signal smbclk_ena       : std_logic            := '0';
    signal smbdat_int       : std_logic            := '1';
    signal smbdat_ena       : std_logic;
    signal ack              : std_logic;
    signal stretch          : std_logic;
    signal clk_prev         : std_logic;
    signal data_clk         : std_logic;
    signal smb_clk          : std_logic;
begin
    smbdat  <= '0' when smbdat_int = '0' else 'Z';
    smbclk  <= '0' when smb_clk = '0' else 'Z';
    ack_err <= ack;
    GlobalState <= debug;
    p_clk_gen : process (clk, resetn) is
        variable cnt : integer range 0 to divider * 4;
    begin
        if (resetn = '0') then
            stretch <= '0';
            cnt     := 0;
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
    
    p_ctrl : process (clk, resetn) is
    begin
  
      if (resetn = '0') then
        busy          <= '1';
        smbclk_ena    <= '0';
        smbdat_int    <= '1';
        bit_cnt       <= 7;
        data_out      <= x"00";
        ack           <= '0';
        addr_rw       <= (others => '0');
        data_tx       <= (others => '0');
        data_rx       <= (others => '0');
        debug <= x"0";
        current_state <= idle;
      elsif (clk'event and clk = '1') then
        if (data_clk = '1' and clk_prev = '0') then
          case current_state is
            when idle =>
              debug <= x"0";
              if (en = '1') then
                busy          <= '1';
                addr_rw       <= addr & rwb;
                data_tx       <= data_in;
                debug <= x"1";
                current_state <= start;
              else
                busy          <= '0';
                current_state <= idle;
              end if;
            when start =>
              busy          <= '1';
              smbdat_int    <= addr_rw(bit_cnt);
              debug <= x"2";
              current_state <= addresse;
            when addresse => 
              if (bit_cnt = 0) then
                busy          <= '1';
                smbdat_int    <= '1';
                bit_cnt       <= 7;
                debug <= x"3";
                current_state <= slv_ack1;
              else
                bit_cnt       <= bit_cnt - 1;
                smbdat_int    <= addr_rw(bit_cnt - 1);
                current_state <= addresse;
              end if;
            when slv_ack1 =>  
              if (to_X01(SMBDAT) = '0') then
                  if(addr_rw(0) = '0')then
                    busy          <= '1';
                    smbdat_int    <= addr_rw(bit_cnt);
                    debug <= x"4"; 
                    current_state <= write;
                  else
                    busy          <= '1';
                    smbdat_int    <= '1';
                    debug <= x"5"; 
                    current_state <= read;
                  end if;
              else
                  current_state <= stop;           
              end if;
            when write =>          
              busy <= '1';
              if (bit_cnt = 0) then
                smbdat_int    <= '1';
                bit_cnt       <= 7;
                debug <= x"6";
                current_state <= slv_ack2;
              else
                bit_cnt       <= bit_cnt - 1;
                smbdat_int    <= data_tx(bit_cnt - 1);
                debug <= x"4";
                current_state <= write;
              end if;
            when read =>              
              busy <= '1';
              if (bit_cnt = 0) then
                if (en = '1' and addr_rw = addr & rwb) then
                  smbdat_int <= '0';
                else
                  smbdat_int <= '1';
                end if;
                bit_cnt       <= 7;
                data_out      <= data_rx;
                debug <= x"7";
                current_state <= mst_ack;
              else
                bit_cnt       <= bit_cnt - 1;
                debug <= x"5";
                current_state <= read;
              end if;
            when slv_ack2 =>
            if (to_X01(SMBDAT) = '0') then
                if (en = '1') then
                    if(tr_s ='1')then
                        busy    <= '0';
                        addr_rw <= addr & rwb;
                        data_tx <= data_in;
                        if (addr_rw = addr & rwb) then
                            smbdat_int    <= data_in(bit_cnt);
                            current_state <= write;
                        else
                            debug <= x"1";
                            current_state <= start;
                        end if;
                    else
                        debug <= x"8";
                        current_state <= stop;  
                    end if;                  
                else
                    debug <= x"8";
                    current_state <= stop;
                end if;
            else
                debug <= x"8";
                current_state <= stop;
            end if;            
            when mst_ack =>
              if (en = '1') then
                if(tr_s ='1')then
                    busy    <= '0';
                    addr_rw <= addr & rwb;
                    data_tx <= data_in;
                    if (addr_rw = addr & rwb) then
                      smbdat_int    <= '1';
                      debug <= x"5"; 
                      current_state <= read;
                    else
                      debug <= x"1";   
                      current_state <= start;
                    end if;
                else
                    debug <= x"8"; 
                    current_state <= stop; 
                end if;                      
              else
                debug <= x"8"; 
                current_state <= stop;
              end if;
            when stop =>
              debug <= x"0";  
              busy          <= '0';
              current_state <= idle;
            when others =>
              debug <= x"0";   
              current_state <= idle;
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
                ack           <= '1';
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
      NOT clk_prev when stop,
      smbdat_int when others;
end behavioral;   