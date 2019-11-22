--by Willem Van der Elst
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--^dinges die er altijd bij moeten

entity BcdToSegm is
    Port ( bcd : in UNSIGNED (3 downto 0);      --poorten maken
           segm : out STD_LOGIC_VECTOR (6 downto 0));
end BcdToSegm;

architecture Behavioral of BcdToSegm is

type tSegm is array(0 to 10) of std_logic_vector(6 downto 0); --array type aanmaken met juiste dimensies enzo
--array maken en vullen
constant cSegm: tSegm:=     ("0000001", --0          -- ':=' moet direct achter elkaar staan. ': =' werkt niet
                             "1001111",
                             "0010010",
                             "0000110",
                             "1001100",
                             "0100100",
                             "0100000",
                             "0001111",
                             "0000000",
                             "0000100", --9
                             "0110000"  --E
                             );
begin

p_main: process (bcd)
begin
    segm <= cSegm(TO_INTEGER(bcd));
end process p_main;

end Behavioral; --geen idee wat dit doet
