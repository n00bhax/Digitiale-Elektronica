library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity TB_7seg is
end TB_7seg;

architecture Behavioral of TB_7seg is

  signal bcd_in : UNSIGNED(3 downto 0);
  signal segm_out : std_logic_vector(6 downto 0);
  signal i: integer;

  -- this component declaration is often moved to a custom package file, containing all components in the design
  component BcdToSegm
  port (
    bcd : in UNSIGNED(3 downto 0);
    segm : out std_logic_vector(6 downto 0));
  end component;--i staat hier niet bij want het moet niks doen buiten even tellen. Op het einde hebben we het niet meer nodig.

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

  TB_BcdToSegm: BcdToSegm port map(
    bcd => bcd_in,
    segm => segm_out);
    
  p_Stimuli: process
  begin
    bcd_in  <= TO_UNSIGNED(0,4); --zet 0 om naar unsigned in binair met grote 4 bits
    i <= 0;
    wait for 50 ns;
    
    assert segm_out=cSegm(i) report "BCD fout omgezet"
    severity warning; --ergheid van de error/warning/info/...
    
    
    LoopLabel: while(bcd_in<9) loop 

      bcd_in <= bcd_in + 1;
      i<= i+1;
      wait for 50 ns; -- What would happen if you remove this line? --dingen gebeuren tezamen en dan gebeuren er rare dingen.
      
      assert segm_out=cSegm(i) report "BCD fout omgezet"
      severity warning;
      
    end loop;
    
    assert false report "Dit is geen fout, maar het einde van de simulatie"
    severity failure; --stopt de simulatie anders doet hij het opnieuw omdat er geen sensitivity list is.
    
  end process p_Stimuli;

end Behavioral;
