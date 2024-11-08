library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity WB_MST_MODEL is
    Port ( clk        : in  STD_LOGIC;
           rst        : in  STD_LOGIC;
           stb        : out STD_LOGIC;
           cyc        : out STD_LOGIC;
           we         : out STD_LOGIC;
           rwb        : in  STD_LOGIC;
           addr_in    : in  STD_LOGIC_VECTOR (2 downto 0);
           data_in    : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out   : out  STD_LOGIC_VECTOR (7 downto 0);
           addr       : out STD_LOGIC_VECTOR (2 downto 0);  -- 8-bit address
           dat_m      : out STD_LOGIC_VECTOR (7 downto 0);  -- 8-bit data
           dat_s      : in  STD_LOGIC_VECTOR (7 downto 0);  -- 8-bit data read from slave
           ack        : in  STD_LOGIC;
           err        : in  STD_LOGIC;
           rd_wr_done : out STD_LOGIC);  -- Flag to indicate transaction completion
end WB_MST_MODEL;

architecture Behavioral of WB_MST_MODEL is

    type state_type is (IDLE, WRITE, READ, STOP);
    signal state, next_state : state_type;
    signal transaction_addr : STD_LOGIC_VECTOR (2 downto 0);  -- 8-bit address for transaction
    signal transaction_data : STD_LOGIC_VECTOR (7 downto 0);  -- 8-bit data for transaction

begin
    transaction_addr <= addr_in;
    transaction_data <= data_in; 
    -- FSM process
    P_SYNC:process (clk, rst)
    begin
        if rst = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process P_SYNC;

    -- Next state logic and control signal generation
    process (state, ack, err,rwb,transaction_addr,transaction_data,dat_s)
    begin
        stb <= '0';
        cyc <= '0';
        we <= '0';
        addr <= (others => '0');
        dat_m <= (others => '0');
        rd_wr_done <= '0';
        case state is
            when IDLE =>
                -- Idle state, ready to start a transaction
                if(rwb = '0')then
                    next_state <= WRITE; 
                else
                    next_state <= READ;        
                end if;    
            when WRITE =>
                -- Write state: Initiate write
                stb <= '1';
                cyc <= '1';
                we <= '1';   -- Write operation
                addr <= transaction_addr;
                dat_m <= transaction_data;
                if ack = '1' then
                    next_state <= STOP;
                elsif err = '1' then
                    next_state <= IDLE; -- Error handling, retry or abort   
                else
                    next_state <= WRITE;         
                end if;
            when READ =>
                -- Read state: Initiate read
                stb <= '1';
                cyc <= '1';
                we <= '0';   -- Read operation
                addr <= transaction_addr;
                dat_m <= (others => 'Z');  -- Tri-state for read
                if ack = '1' then
                    next_state <= STOP;
                    data_out <= dat_s;
                    --rd_wr_done <= '1';  -- Read data is available
                elsif err = '1' then
                    next_state <= IDLE; -- Error handling, retry or abort 
                else
                    next_state <= READ;             
                end if; 
            when STOP =>
                -- Wait for ack or error
                if ack = '1' then
                    next_state <= IDLE;  -- Transaction completed
                    rd_wr_done <= '1';   -- Transaction done
                elsif err = '1' then
                    next_state <= IDLE;  -- Error handling
                    rd_wr_done <= '0';   -- Transaction failed
                else 
                    next_state <= IDLE;     
                end if;
            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;
