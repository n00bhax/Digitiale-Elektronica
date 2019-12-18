library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR57 is
    Port ( Sequence : out STD_LOGIC_VECTOR(56 downto 0);
           CLK: in STD_LOGIC);
end LFSR57;

architecture Behavioral of LFSR57 is
signal rs: std_logic_vector(0 to 56):= (5=>'1',10=>'1',16=>'1',20=>'1',22=>'1',30=>'1',34=>'1',40=>'1',46=>'1',49=>'1', others => '0');--een paar bits op 1 zetten, de rest 0 --random sequence
begin
Sequence <= rs;

process (CLK) is
begin 
if rising_edge(CLK) then 
        rs(0 to 56) <= (rs(56) xor rs(55) xor rs(54) xor rs(52)) & rs(0 to 55); --bit shift en msb vanvoor zetten. Laatste bit valt weg. 
end if;
end process;


end Behavioral;
