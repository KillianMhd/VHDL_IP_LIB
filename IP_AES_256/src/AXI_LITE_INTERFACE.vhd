----------------------------------------------------------------------------------
-- Company: ELSYS-DESIGN
-- Engineer: Killian MICHAUD
-- 
-- Create Date: 10.04.2024 16:24:49
-- Module Name: AXI_LITE_INTERFACE - ARCH_AXI_LITE_INTERFACE
-- Project Name: IP_CAN
-- Target Devices: Zy-bo Z7-20
-- Tool Versions: Vivado 2022.2.2
-- Description: 
-- We will use the write channel of the previous axi-lite bridge from the last year project
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AXI_LITE_INTERFACE is
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
end AXI_LITE_INTERFACE;

architecture ARCH_AXI_LITE_INTERFACE of AXI_LITE_INTERFACE is
-- AXI4LITE signals
signal axi_awaddr   : std_logic_vector(31 downto 0);
signal axi_awready  : std_logic;
signal axi_wready   : std_logic;
signal axi_bresp	: std_logic_vector(1 downto 0);
signal axi_bvalid	: std_logic;
signal axi_araddr	: std_logic_vector(31 downto 0);
signal axi_arready	: std_logic;
signal axi_rdata	: std_logic_vector(31 downto 0);
signal axi_rresp	: std_logic_vector(1 downto 0);
signal axi_rvalid	: std_logic;
signal is_cipher_empty : std_logic;
signal is_decipher_empty : std_logic;
---------------------------------------------
---- Constant here
---------------------------------------------
CONSTANT STATUS             : std_logic_vector(7 downto 0) := x"00"; --RO
CONSTANT CONTROL            : std_logic_vector(7 downto 0) := x"04"; --RW
CONSTANT VERSION            : std_logic_vector(7 downto 0) := x"08"; --RO
CONSTANT SCRPAD             : std_logic_vector(7 downto 0) := x"0C"; --RW
CONSTANT KEY_CIPHER         : std_logic_vector(7 downto 0) := x"10"; --WO
CONSTANT KEY_DECIPHER       : std_logic_vector(7 downto 0) := x"14"; --WO
CONSTANT PLAIN_WORD         : std_logic_vector(7 downto 0) := x"18"; --WO
CONSTANT TO_DECIPHER_WORD   : std_logic_vector(7 downto 0) := x"1C"; --WO
CONSTANT CIPHER_WORD        : std_logic_vector(7 downto 0) := x"20"; --RO
CONSTANT DECIPHER_WORD      : std_logic_vector(7 downto 0) := x"24"; --RO

CONSTANT OKAY               : std_logic_vector(1 downto 0) := "00";
CONSTANT SLVERR             : std_logic_vector(1 downto 0) := "10";
CONSTANT DECERR             : std_logic_vector(1 downto 0) := "11"; 
---------------------------------------------
---- Signals here
---------------------------------------------
SIGNAL reg_status           : std_logic_vector(31 downto 0);
SIGNAL reg_ctrl             : std_logic_vector(31 downto 0); 
SIGNAL reg_version          : std_logic_vector(31 downto 0) := x"DEADBEEF"; 
SIGNAL reg_scrpad           : std_logic_vector(31 downto 0); 
SIGNAL reg_key_cipher       : std_logic_vector(31 downto 0); 
SIGNAL reg_key_decipher     : std_logic_vector(31 downto 0); 
SIGNAL reg_text             : std_logic_vector(31 downto 0);
SIGNAL reg_todecipher       : std_logic_vector(31 downto 0);
SIGNAL reg_ciphertext       : std_logic_vector(31 downto 0);  
SIGNAL reg_deciphertext     : std_logic_vector(31 downto 0);
SIGNAL reg_wren	            : std_logic;
SIGNAL reg_rden	            : std_logic;
SIGNAL aw_en                : std_logic;

function mask_data (
        old_data : std_logic_vector;
        new_data : std_logic_vector;
        wstrb : std_logic_vector
    ) return std_logic_vector is
        variable return_data : std_logic_vector(old_data'length-1 downto 0) := old_data;
    begin
        for i in 0 to wstrb'length-1 loop
            if (wstrb(i) = '1') then
                return_data ((i * 8) + 7 downto i * 8) := new_data((i * 8) + 7 downto i * 8);
            end if;
        end loop;
        return return_data;
    end mask_data;
    
begin
------------------------------
-- I/O Connections assignments
------------------------------
--AXI4-Lite
S_AXI_AWREADY   <= axi_awready;
S_AXI_WREADY    <= axi_wready;
S_AXI_BRESP	    <= axi_bresp;
S_AXI_BVALID	<= axi_bvalid;
S_AXI_ARREADY	<= axi_arready;
S_AXI_RDATA	    <= axi_rdata;
S_AXI_RVALID	<= axi_rvalid;
S_AXI_RRESP     <= axi_rresp;
-- Status register
reg_status(0)   <= DONE_CIPHER;
reg_status(1)   <= DONE_DECIPHER;
reg_status(2)   <= CIPHER_TEXT_EMPTY;
reg_status(3)   <= CIPHER_TEXT_FULL;
reg_status(4)   <= PLAIN_TEXT_EMPTY;
reg_status(5)   <= PLAIN_TEXT_FULL;
reg_status(6)   <= CIPHER_KEY_EMPTY;
reg_status(7)   <= CIPHER_KEY_FULL;
reg_status(8)   <= DECIPHER_KEY_EMPTY;
reg_status(9)   <= DECIPHER_KEY_FULL;
reg_status(10)  <= DECIPHER_TEXT_EMPTY;
reg_status(11)  <= DECIPHER_TEXT_FULL;
reg_status(12)  <= ENC_TEXT_EMPTY;
reg_status(13)  <= ENC_TEXT_FULL;
-- Control register
START_CIPHER        <= reg_ctrl(0);
START_DECIPHER      <= reg_ctrl(1);
FLUSH_CIPHER        <= reg_ctrl(2);
FLUSH_PLAIN         <= reg_ctrl(3);
FLUSH_CIPHER_KEY    <= reg_ctrl(4);
FLUSH_DECIPHER_KEY  <= reg_ctrl(5);
FLUSH_ENC           <= reg_ctrl(6);
FLUSH_DEC           <= reg_ctrl(7);
-- Write data register
reg_wren        <= axi_wready;
CIPHER_KEY      <= reg_key_cipher;
DECIPHER_KEY    <= reg_key_decipher;
PLAIN_TEXT      <= reg_text;
TO_DECIPHER     <= reg_todecipher;
-- Read data register
reg_ciphertext  <= CIPHER_TEXT when is_cipher_empty = '0' else (others => '0');
reg_deciphertext<= DECIPHER_TEXT when is_decipher_empty = '0' else (others => '0');
reg_rden <= axi_arready and S_AXI_ARVALID;
P_AWREADY_AWADDR : process (S_AXI_ACLK, S_AXI_ARESETN) 
begin
    if S_AXI_ARESETN = '0' then
            axi_awready <= '0';
            aw_en <= '1';
            axi_awaddr <= (others => '0');
    elsif rising_edge(S_AXI_ACLK) then
            if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
                axi_awready <= '1';
                axi_awaddr <= S_AXI_AWADDR;
                aw_en <= '0';
            elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                aw_en <= '1';
                axi_awready <= '0';
            else
                axi_awready <= '0';
            end if;
    end if;
end process P_AWREADY_AWADDR;

P_WREADY : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
    if S_AXI_ARESETN = '0' then
            axi_wready <= '0';
    elsif rising_edge(S_AXI_ACLK) then
            if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
                axi_wready <= '1';
            else
                axi_wready <= '0';
            end if;
    end if;
end process P_WREADY;

P_WDATA : process (S_AXI_ACLK, S_AXI_ARESETN)
    variable loc_addr : std_logic_vector(7 downto 0);
begin
    if (S_AXI_ARESETN = '0') then
        -- Reset des registres write-only
        reg_ctrl        <= (others => '0');
        reg_scrpad      <= (others => '0');
        reg_key_cipher  <= (others => '0');
        reg_key_decipher<= (others => '0');
        reg_text        <= (others => '0');
        reg_todecipher  <= (others => '0');
        WR_EN_KEY_ENC   <= '0';
        WR_EN_KEY_DEC   <= '0';
        WR_EN_PLAIN     <= '0';
        WR_EN_CIPHER    <= '0';
    elsif rising_edge(S_AXI_ACLK) then
        loc_addr := axi_awaddr(7 downto 0);
        if (reg_wren = '1') then
            case loc_addr is
                when CONTROL =>
                    reg_ctrl        <= mask_data(reg_ctrl  , S_AXI_WDATA, S_AXI_WSTRB);
                when SCRPAD =>
                    reg_scrpad      <= mask_data(reg_scrpad  , S_AXI_WDATA, S_AXI_WSTRB);
                when KEY_CIPHER => 
                    reg_key_cipher  <= mask_data(reg_key_cipher,S_AXI_WDATA,S_AXI_WSTRB);
                    WR_EN_KEY_ENC   <= '1';
                when KEY_DECIPHER =>
                    reg_key_decipher <= mask_data(reg_key_decipher,S_AXI_WDATA,S_AXI_WSTRB);
                    WR_EN_KEY_DEC   <= '1'; 
                when PLAIN_WORD => 
                    reg_text        <= mask_data(reg_text,S_AXI_WDATA,S_AXI_WSTRB);
                    WR_EN_PLAIN     <= '1';
                when TO_DECIPHER_WORD =>
                    reg_todecipher  <= mask_data(reg_todecipher,S_AXI_WDATA,S_AXI_WSTRB);
                    WR_EN_CIPHER    <= '1';       
                when others => 
                    null;
            end case;
        else
        WR_EN_KEY_ENC <= '0';
        WR_EN_KEY_DEC <= '0';
        WR_EN_PLAIN <= '0';
        WR_EN_CIPHER <= '0';
        end if;
    end if;
end process P_WDATA;

P_BVALID_BRESP : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
    if S_AXI_ARESETN = '0' then
            axi_bvalid  <= '0';
            axi_bresp   <= OKAY;
    elsif rising_edge(S_AXI_ACLK) then
            if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
                if(axi_awaddr(7 downto 0) = CONTROL or axi_awaddr(7 downto 0) = SCRPAD or axi_awaddr(7 downto 0) = KEY_CIPHER or axi_awaddr(7 downto 0) = KEY_DECIPHER or axi_awaddr(7 downto 0) = PLAIN_WORD or axi_awaddr(7 downto 0) = TO_DECIPHER_WORD)then
                    axi_bvalid <= '1';
                    axi_bresp   <= OKAY;
                elsif(axi_awaddr(7 downto 0) = STATUS or axi_awaddr(7 downto 0) = VERSION or axi_awaddr(7 downto 0) = CIPHER_WORD or axi_awaddr(7 downto 0) = DECIPHER_WORD)then  
                    axi_bvalid <= '1';
                    axi_bresp   <= SLVERR;   
                else    
                    axi_bvalid <= '1';
                    axi_bresp   <= DECERR;      
                end if;       
            elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
            end if;
    end if;
end process P_BVALID_BRESP;

P_ARREADY_ARADDR : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
    if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_araddr  <= (others => '0');
        RD_EN_DECIPHER <= '0';
        is_cipher_empty <= '0';
        is_decipher_empty <= '0';
        RD_EN_CIPHER <= '0';
    elsif rising_edge(S_AXI_ACLK) then
        if (axi_arready = '0' and S_AXI_ARVALID = '1') then
            -- indicates that the slave has acceped the valid read address
            axi_arready <= '1';
            -- Read Address latching
            axi_araddr  <= S_AXI_ARADDR;
            if (axi_araddr(7 downto 0) = CIPHER_WORD) then
                if (ENC_TEXT_EMPTY = '1') then
                    RD_EN_CIPHER <= '0';
                    is_cipher_empty <= '1';
                else
                    RD_EN_CIPHER <= '1';
                    is_cipher_empty <= '0';
                end if;
            elsif(axi_araddr(7 downto 0) = DECIPHER_WORD)then
                if (DECIPHER_TEXT_EMPTY = '1') then
                    RD_EN_DECIPHER <= '0';
                    is_decipher_empty <= '1';
                else
                    RD_EN_DECIPHER <= '1';
                    is_decipher_empty <= '0';
                end if;       
            end if;
        else
            axi_arready <= '0';
            RD_EN_DECIPHER <= '0';
            is_cipher_empty <= '0';
            is_decipher_empty <= '0';
            RD_EN_CIPHER <= '0';
        end if;
    end if;
end process P_ARREADY_ARADDR;

P_RVALID_RRESP : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
    if S_AXI_ARESETN = '0' then
        axi_rvalid <= '0';
        axi_rresp  <= "00";
    elsif rising_edge(S_AXI_ACLK) then
        if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then  
            if (axi_araddr(7 downto 0) = CONTROL or axi_araddr(7 downto 0) = SCRPAD or axi_araddr(7 downto 0) = VERSION or axi_araddr(7 downto 0) = STATUS or axi_araddr(7 downto 0) = CIPHER_WORD or axi_araddr(7 downto 0) = DECIPHER_WORD) then
                axi_rvalid <= '1';
                axi_rresp  <= OKAY; -- 'OKAY' response
--            elsif(axi_araddr(7 downto 0) = CIPHER_WORD)then
--                if(VALID_ENC = '1')then
--                    axi_rvalid <= '1';
--                    axi_rresp  <= OKAY; -- 'OKAY' response
--                end if; 
--            elsif(axi_araddr(7 downto 0) = DECIPHER_WORD)then
--                if(VALID_DEC = '1')then
--                    axi_rvalid <= '1';
--                    axi_rresp  <= OKAY; -- 'OKAY' response
--                end if; 
            elsif (axi_araddr(7 downto 0) = KEY_CIPHER or axi_araddr(7 downto 0) = KEY_DECIPHER or axi_araddr(7 downto 0) = PLAIN_WORD or axi_araddr(7 downto 0) = TO_DECIPHER_WORD)then -- write only register
                axi_rvalid <= '1';
                axi_rresp  <= SLVERR; -- 'SLVERR' response
            else
                axi_rvalid <= '1';
                axi_rresp  <= DECERR; -- 'DECERR' response        
            end if;
        elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
                -- Read data is accepted by the master
                axi_rvalid <= '0';
        end if;
    end if;
end process P_RVALID_RRESP;

P_RDATA : process (S_AXI_ACLK, S_AXI_ARESETN)
    variable loc_addr : std_logic_vector(7 downto 0);
begin
    if (S_AXI_ARESETN = '0') then
        axi_rdata <= (others => '0');
        
    elsif rising_edge(S_AXI_ACLK) then
        loc_addr := axi_araddr(7 downto 0);
            case loc_addr is
                when STATUS =>
                    reg_status(31 downto 14) <= (others => '0');
                    axi_rdata <= reg_status;  
                when CONTROL =>
                    axi_rdata <= reg_ctrl;
                when VERSION  => 
                    axi_rdata <= reg_version;
                when SCRPAD  => 
                    axi_rdata <= reg_scrpad;
                when CIPHER_WORD => 
                    axi_rdata <= reg_ciphertext;
                when DECIPHER_WORD  =>
                    axi_rdata <= reg_deciphertext;  
                when others => 
                    axi_rdata <= (others => '0');
            end case;          
    end if;
end process P_RDATA;
end ARCH_AXI_LITE_INTERFACE;
