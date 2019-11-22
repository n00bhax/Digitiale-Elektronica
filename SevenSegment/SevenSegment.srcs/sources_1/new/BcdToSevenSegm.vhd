library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--^dinges die er altijd bij moeten

entity BcdToSegm is
    Port ( bcd : in UNSIGNED (3 downto 0);      --poorten maken
           segm : out STD_LOGIC_VECTOR (6 downto 0));
end BcdToSegm;

architecture Behavioral of BcdToSegm is

type tSegm is array(0 to 9) of std_logic_vector(6 downto 0); --array type aanmaken met juiste dimensies enzo
--array maken en vullen
constant cSegm: tSegm:=     ("1111110", --0          -- ':=' moet direct achter elkaar staan. ': =' werkt niet
                             "0110000",
                             "1101101",
                             "1111001",
                             "0110011",
                             "1011011",
                             "1011111",
                             "1110000",
                             "1111111",
                             "1111011");--9  
begin

p_main: process (bcd)
begin
    segm <= cSegm(TO_INTEGER(bcd));
end process p_main;

end Behavioral; --geen idee wat dit doet
