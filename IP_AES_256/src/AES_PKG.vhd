----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2024 10:37:45
-- Design Name: 
-- Module Name: AES_PKG - Behavioral
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
use ieee.numeric_std.all;

package AES_PKG is
    type matrix_type is array (0 to 3, 0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    type sbox_array is array (0 to 255) of std_logic_vector(7 downto 0);
    type mix_array is array (0 to 3, 0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    type round_keys is array (0 to 14) of STD_LOGIC_VECTOR(127 downto 0);
    TYPE rcon_array is array (1 to 7) of std_logic_vector(31 downto 0);
    type array_word is array (integer range <>) of std_logic_vector(31 downto 0);
    type word_array is array (0 to 59) of STD_LOGIC_VECTOR(31 downto 0);
    
    constant Rcon : rcon_array :=(x"01000000",x"02000000",x"04000000",x"08000000",x"10000000",x"20000000",x"40000000");
    
    constant INV_SBox : sbox_array :=(
    x"52", x"09", x"6A", x"D5", x"30", x"36", x"A5", x"38",x"BF", x"40", x"A3", x"9E", x"81", x"F3", x"D7", x"FB",
    x"7C", x"E3", x"39", x"82", x"9B", x"2F", x"FF", x"87",x"34", x"8E", x"43", x"44", x"C4", x"DE", x"E9", x"CB",
    x"54", x"7B", x"94", x"32", x"A6", x"C2", x"23", x"3D",x"EE", x"4C", x"95", x"0B", x"42", x"FA", x"C3", x"4E",
    x"08", x"2E", x"A1", x"66", x"28", x"D9", x"24", x"B2",x"76", x"5B", x"A2", x"49", x"6D", x"8B", x"D1", x"25",
    x"72", x"F8", x"F6", x"64", x"86", x"68", x"98",x"16", x"D4", x"A4", x"5C", x"CC", x"5D", x"65", x"B6", x"92", 
    x"6C", x"70", x"48", x"50", x"FD", x"ED", x"B9",x"DA", x"5E", x"15", x"46", x"57", x"A7", x"8D", x"9D", x"84",
    x"90", x"D8", x"AB", x"00", x"8C", x"BC", x"D3",x"0A", x"F7", x"E4", x"58", x"05", x"B8", x"B3", x"45", x"06",
    x"D0", x"2C", x"1E", x"8F", x"CA", x"3F", x"0F",x"02", x"C1", x"AF", x"BD", x"03", x"01", x"13", x"8A", x"6B", 
    x"3A", x"91", x"11", x"41", x"4F", x"67", x"DC",x"EA", x"97", x"F2", x"CF", x"CE", x"F0", x"B4", x"E6", x"73", 
    x"96", x"AC", x"74", x"22", x"E7", x"AD", x"35",x"85", x"E2", x"F9", x"37", x"E8", x"1C", x"75", x"DF", x"6E", 
    x"47", x"F1", x"1A", x"71", x"1D", x"29", x"C5",x"89", x"6F", x"B7", x"62", x"0E", x"AA", x"18", x"BE", x"1B", 
    x"FC", x"56", x"3E", x"4B", x"C6", x"D2", x"79",x"20", x"9A", x"DB", x"C0", x"FE", x"78", x"CD", x"5A", x"F4", 
    x"1F", x"DD", x"A8", x"33", x"88", x"07", x"C7", x"31", x"B1", x"12", x"10", x"59", x"27", x"80",x"EC", x"5F", 
    x"60", x"51", x"7F", x"A9", x"19", x"B5", x"4A",x"0D", x"2D", x"E5", x"7A", x"9F", x"93", x"C9", x"9C", x"EF", 
    x"A0", x"E0", x"3B", x"4D", x"AE", x"2A", x"F5",x"B0", x"C8", x"EB", x"BB", x"3C", x"83", x"53", x"99", x"61", 
    x"17", x"2B", x"04", x"7E", x"BA", x"77", x"D6",x"26", x"E1", x"69", x"14", x"63", x"55", x"21", x"0C", x"7D"
    );
    
    constant SBox : sbox_array :=(
    x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5", x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76",
    x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0", x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0",
    x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC", x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15",
    x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A", x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75",
    x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0", x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84",
    x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B", x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF",
    x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85", x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8",
    x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5", x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2",
    x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17", x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73",
    x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88", x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB",
    x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C", x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79",
    x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9", x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08",
    x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6", x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A",
    x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E", x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E",
    x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94", x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF",
    x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16"
    );
    
    function VECT_TO_MATRIX(
    data_in: STD_LOGIC_VECTOR(127 downto 0)) return matrix_type;
    
    function GMul(
    a : std_logic_vector(7 downto 0); b : std_logic_vector(7 downto 0)) return std_logic_vector;
    
    function RotWord(
    data_in : std_logic_vector(31 downto 0)) return std_logic_vector;
    
    function initialize_w(
    key : STD_LOGIC_VECTOR(255 downto 0)) return word_array;
    
    function expand_key(
    w : word_array; SBox : sbox_array; rcon : rcon_array) return word_array;
    
    function generate_rd_key(
    w : word_array) return round_keys;
end package AES_PKG;

package body AES_PKG is
    function VECT_TO_MATRIX(
        data_in: STD_LOGIC_VECTOR(127 downto 0)) return matrix_type is
        variable matrix: matrix_type := (others => (others => (others => '0')));
    begin
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                matrix(j, i) := data_in((15 - (i*4 + j))*8 + 7 downto (15 - (i*4 + j))*8);
            end loop;
        end loop;
        return matrix;
    end function VECT_TO_MATRIX;
    
    function GMul(a : std_logic_vector(7 downto 0); b : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable p_var : std_logic_vector(7 downto 0) := (others => '0');
        variable a_var : std_logic_vector(7 downto 0);
        variable b_var : std_logic_vector(7 downto 0);
        variable hi_bit_set : std_logic;
    begin
        a_var := a;
        b_var := b;
        for counter in 0 to 7 loop
            if b_var(0) = '1' then
                p_var := p_var xor a_var;
            end if;
            hi_bit_set := a_var(7);
            a_var := std_logic_vector(shift_left(unsigned(a_var), 1));
            if hi_bit_set = '1' then
                a_var := a_var xor "00011011"; -- x^8 + x^4 + x^3 + x + 1
            end if;
            b_var := std_logic_vector(shift_right(unsigned(b_var), 1));
        end loop;
        return p_var;
    end function GMul;
    
    function RotWord(data_in : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable ret : std_logic_vector(31 downto 0);
    begin
        ret(7 downto 0)     := data_in (31 downto 24);
        ret(15 downto 8)    := data_in (7 downto 0);
        ret(23 downto 16)   := data_in (15 downto 8);
        ret(31 downto 24)   := data_in (23 downto 16);
        return ret;    
    end function RotWord;
    
        function initialize_w(key : STD_LOGIC_VECTOR(255 downto 0)) return word_array is
        variable w : word_array;
    begin
        for i in 0 to 7 loop
            w(i) := key(255-(i*32) downto 256-((i+1)*32));
        end loop;      
        return w;
    end function initialize_w;
    
    function expand_key(w : word_array; SBox : sbox_array; rcon : rcon_array) return word_array is
        variable w_temp : word_array;
        variable temp : STD_LOGIC_VECTOR(31 downto 0);
    begin  
        w_temp:=w;   
        for i in 8 to 59 loop
        temp := w_temp(i-1);
        if i mod 8 = 0 then
            temp := RotWord(temp);
            for j in 0 to 3 loop
                temp((j+1)*8-1 downto j*8) := SBox(to_integer(unsigned(temp((j+1)*8-1 downto j*8))));
            end loop;
            temp := temp xor rcon(i/8);
        elsif i mod 8 = 4 then
            for j in 0 to 3 loop
                temp((j+1)*8-1 downto j*8) := SBox(to_integer(unsigned(temp((j+1)*8-1 downto j*8))));
            end loop;
        end if;
        w_temp(i) := w_temp(i-8) xor temp;
        end loop; 
    return w_temp;     
    end function expand_key;
    
    function generate_rd_key(w : word_array) return round_keys is
        variable RD_KEY : round_keys;
    begin
        for i in 0 to 14 loop
            RD_KEY(i) := w(4*i) & w(4*i+1) & w(4*i+2) & w(4*i+3);
        end loop;
        return RD_KEY;
    end function generate_rd_key;
end AES_PKG;