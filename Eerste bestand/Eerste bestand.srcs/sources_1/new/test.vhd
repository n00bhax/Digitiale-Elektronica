
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity test is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;               
           G : out STD_LOGIC);
end test;

architecture Behavioral of test is

begin

G <= ((not C) and ((not B) or A)) or ((C and (not B)) nor (not A)) or (A and B);

end Behavioral;
