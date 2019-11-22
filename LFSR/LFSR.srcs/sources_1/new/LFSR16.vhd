library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR16 is
    Port ( Sequence : out STD_LOGIC_VECTOR(15 downto 0);
           CLK: in STD_LOGIC);
end LFSR16;

architecture Behavioral of LFSR16 is
signal rs: std_logic_vector(0 to 15):="1000000000000000"; --random sequence
begin
Sequence <= rs;

process (CLK) is
begin 
if rising_edge(CLK) then 
        rs(0 to 15) <= (rs(15) xor rs(13) xor rs(12) xor rs(10)) & rs(0 to 14); --bit shift en msb vanvoor zetten. Laatste bit valt weg. 
end if;
end process;


end Behavioral;
