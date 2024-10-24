----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2024 17:38:36
-- Design Name: 
-- Module Name: REGISTERS - Behavioral
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

entity REGISTERS is
    port(
        -- SYSTEM --
        CLK             : in std_logic;
        ARESETN         : in std_logic;
        -- REGISTERS SIGNALS --   
        WRITE_ADDR      : in std_logic_vector(31 downto 0);
        WRITE_DATA      : in std_logic_vector(31 downto 0);
        WRITE_RESP      : out std_logic_vector(1 downto 0);
        READ_ADDR       : in std_logic_vector(31 downto 0);
        READ_DATA       : out std_logic_vector(31 downto 0);
        READ_RESP       : out std_logic_vector(1 downto 0);
        -- STATUS --
        DONE_CIPHER     : in std_logic;
        DONE_DECIPHER   : in std_logic;
        -- CONTROL -- 
        START_CIPHER    : out std_logic;
        START_DECIPHER  : out std_logic;      
        -- KEY -- 
        CIPHER_KEY      : out std_logic_vector(31 downto 0);
        DECIPHER_KEY    : out std_logic_vector(31 downto 0);
        -- TEXT --
        PLAIN_TEXT      : out std_logic_vector(31 downto 0);
        DECIPHER_TEXT   : in std_logic_vector(31 downto 0);
        TO_DECIPHER     : out std_logic_vector(31 downto 0);
        CIPHER_TEXT     : in std_logic_vector(31 downto 0));
end REGISTERS;

architecture Behavioral of REGISTERS is
    CONSTANT STATUS             : std_logic_vector(7 downto 0) := x"00";
    CONSTANT CONTROL            : std_logic_vector(7 downto 0) := x"04";
    CONSTANT VERSION            : std_logic_vector(7 downto 0) := x"08";
    CONSTANT SCRPAD             : std_logic_vector(7 downto 0) := x"0C";
    CONSTANT KEY_CIPHER         : std_logic_vector(7 downto 0) := x"10"; 
    CONSTANT KEY_DECIPHER       : std_logic_vector(7 downto 0) := x"14";
    CONSTANT PLAIN_WORD         : std_logic_vector(7 downto 0) := x"18";
    CONSTANT CIPHER_WORD        : std_logic_vector(7 downto 0) := x"1C";
    CONSTANT TO_DECIPHER_WORD   : std_logic_vector(7 downto 0) := x"20";
    CONSTANT DECIPHER_WORD      : std_logic_vector(7 downto 0) := x"24";
    
    CONSTANT OKAY               : std_logic_vector(1 downto 0) := "00";
    CONSTANT SLVERR             : std_logic_vector(1 downto 0) := "10";
    CONSTANT DECERR             : std_logic_vector(1 downto 0) := "11";    
    
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
begin
----------- I/O ASSIGNMENTS -----------
-- CONTROL REGISTER --
START_CIPHER <= reg_ctrl(0);
START_DECIPHER <= reg_ctrl(1);
-- STATUS REGISTER --
reg_status(0) <= DONE_CIPHER;
reg_status(1) <= DONE_DECIPHER;
-- DATA REGISTERS --
CIPHER_KEY <= reg_key_cipher;
DECIPHER_KEY <= reg_key_decipher;
PLAIN_TEXT <= reg_text;
TO_DECIPHER <= reg_todecipher;
reg_ciphertext <= CIPHER_TEXT;
reg_deciphertext <= DECIPHER_TEXT;
----------- BEGIN CODE HERE -----------
P_WRITE_DATA : process(CLK,ARESETN)
    variable loc_addr : std_logic_vector(7 downto 0);
begin
    if(ARESETN = '0')then
        reg_ctrl        <= (others => '0');
        reg_scrpad      <= (others => '0'); 
        reg_key_cipher  <= (others => '0');
        reg_text        <= (others => '0');
        reg_ciphertext  <=(others => '0');
    elsif(rising_edge(CLK))then         
        loc_addr := WRITE_ADDR(7 downto 0);
        case loc_addr is
            when CONTROL =>
                reg_ctrl <= WRITE_DATA; 
            when SCRPAD =>
                reg_scrpad <= WRITE_DATA;
            when KEY_WORD =>
                reg_key_cipher <= WRITE_DATA;
            when TEXT_WORD =>
                reg_text <= WRITE_DATA;            
            when others =>
                null; 
        end case;
    end if;                                          
end process P_WRITE_DATA;

P_WRITE_RESP : process(CLK,ARESETN)
begin
    if ARESETN = '0' then
        WRITE_RESP   <= OKAY;
    elsif rising_edge(CLK) then
        if(WRITE_ADDR(7 downto 0) = CONTROL or WRITE_ADDR(7 downto 0) = KEY_WORD or WRITE_ADDR(7 downto 0) = SCRPAD or WRITE_ADDR(7 downto 0) = TEXT_WORD)then
            WRITE_RESP   <= OKAY;
        elsif(WRITE_ADDR(7 downto 0) = STATUS or WRITE_ADDR(7 downto 0) = VERSION)then  
            WRITE_RESP   <= SLVERR;   
        else    
            WRITE_RESP   <= DECERR;      
        end if;
    end if;
end process P_WRITE_RESP;

P_READ_DATA : process(CLK,ARESETN)
    variable loc_addr : std_logic_vector(7 downto 0);
begin
    if ARESETN = '0' then
        READ_DATA <= (others => '0');
    elsif(rising_edge(CLK))then         
        loc_addr := READ_ADDR(7 downto 0);
        case loc_addr is
            when CONTROL =>
                READ_DATA <= reg_ctrl; 
            when SCRPAD =>
                READ_DATA <= reg_scrpad; 
            when VERSION =>
                READ_DATA <= reg_version;
            when STATUS =>
                READ_DATA <= reg_status;             
            when others =>
                READ_DATA <= (others => '0');
        end case;
    end if;                                          
end process P_READ_DATA;

P_READ_RESP : process(CLK,ARESETN)
begin
    if ARESETN = '0' then
        READ_RESP  <= OKAY;
    elsif rising_edge(CLK) then 
        if (READ_ADDR(7 downto 0) = CONTROL or READ_ADDR(7 downto 0) = SCRPAD or READ_ADDR(7 downto 0) = VERSION or READ_ADDR(7 downto 0) = STATUS) then
            READ_RESP  <= OKAY; -- 'OKAY' response
        elsif (READ_ADDR(7 downto 0) = TEXT_WORD or READ_ADDR(7 downto 0) = KEY_WORD)then -- write only register
            READ_RESP  <= SLVERR; -- 'SLVERR' response
        else
            READ_RESP  <= DECERR; -- 'DECERR' response        
        end if;
    end if;
end process P_READ_RESP;
end Behavioral;
