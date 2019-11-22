library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

entity Vermenigvuldigen is
    Port ( A : in integer range 0 to 8;
           B : in integer range 0 to 8;
           C : out integer range 0 to 16
         );
end Vermenigvuldigen;

architecture Behavioral of Vermenigvuldigen is

attribute use_dsp: string;
attribute use_dsp of C : signal is "yes";

begin

    p_Vermenigvuldiging: process (A,B)
    begin
    
    C <= (A / B);
    
    end process  p_Vermenigvuldiging;

end Behavioral;

