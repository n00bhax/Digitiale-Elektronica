library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity TB_LFSR16 is
--  Port ( );
end TB_LFSR16;

architecture Behavioral of TB_LFSR16 is

COMPONENT LFSR16
Port(   CLK: in STD_LOGIC;
        Sequence: out STD_LOGIC_VECTOR(15 downto 0)
        );
END COMPONENT;

signal simCLK: STD_LOGIC := '0';
signal Sequence: STD_LOGIC_VECTOR(15 downto 0);

file testFile: text;

function slv_to_string ( a: std_logic_vector) return string is
    variable b : string (a'length downto 1) := (others => NUL); --was eerst a'length-1
begin
        for i in a'length downto 1 loop                         --was eerst a'length-1
        b(i) := std_logic'image(a((i-1)))(2);
        end loop;
    return b;
end function;

begin

dut: LFSR16
port map (
            CLK => simCLK,
            Sequence => Sequence
            );
            
process 
    variable inLine    : line;
    variable number : STD_LOGIC_VECTOR(15 downto 0);
begin 

    file_open(testFile,"testLFSR.txt", read_mode);
 --   wait for 10 ns; --pas na 2 klokflanken wordt de eerste sequence gemaakt. na 10 ns is er dus nog niets gebeurt
    
    while not endfile(testFile) loop
        readline(testFile,inline);
        read(inLine,number);
        if number/=Sequence then
             assert false report "Wrong number! Expected :" & slv_to_string(number) & ", but got: "
             & slv_to_string(Sequence) & " instead." 
             severity warning;
        else 
             report "OK: " & slv_to_string(number);-- severity warning niet nodig, want er is geen probleem. 
        end if;     
        wait for 20ns;
    end loop;      
    assert false severity failure;        
end process;

p_Clock: process
begin 
    simCLK<= not simCLK;
    wait for 10ns; 
end process p_Clock;

end Behavioral;
