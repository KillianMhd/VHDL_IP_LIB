----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2024 15:57:16
-- Design Name: 
-- Module Name: SpyOnMySigPkg - Behavioral
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

package SpyOnMySigPkg is
    signal GlobalBUSY   : std_logic ; 
    signal GlobalState  : std_logic_vector(3 downto 0);
end package SpyOnMySigPkg ;

