----------------------------------------------------------------------------------
-- This package is use for debug in testbench 
-- To synthesis the TOP module remove this package and signals from the RTL code
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package SpyOnMySigPkg is
    signal GlobalBUSY   : std_logic ; 
    signal GlobalState  : std_logic_vector(3 downto 0);
end package SpyOnMySigPkg ;

