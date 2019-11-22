--Willem Van der Elst
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Klok is
    generic (g_MaxClock : integer := 59);
    port(
          AN : out std_logic_vector(7 downto 0); --Anodes (1=af)    
          CA,CB,CC,CD,CE,CF,CG : out std_logic; -- Kathodes
          
          CLK100MHZ: in std_logic
          );
end Klok;

architecture Behavioral of Klok is

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_10Mhz          : out   std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;


type tSegm is array(0 to 9) of std_logic_vector(6 downto 0); --array type aanmaken met juiste dimensies enzo
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
                             "0000100" --9
                             );
                           
signal clk_10Mhz : std_logic;
signal reset : std_logic:= '0';             --De reset zal nooit plaats vinden, maar dit is niet zo erg. Hij is actief hoog
signal locked : std_logic;                    
signal clk_in1 : std_logic;                  

signal tellerDispChange: integer :=0;
signal teller60: integer :=0;

signal Klok: integer range 0 to g_MaxClock :=0;
signal segm: std_logic_vector(6 downto 0) :="0000001";
signal ANtemp: std_logic_vector(1 downto 0) :="10"; --nodig om AN in if statements te gebruiken, een out kan niet gelezen worden.

signal eenheden: integer range 0 to 10 :=0;
signal tientallen: integer range 0 to 10:=0;


begin

AN <= (0 => ANtemp(0),  --anodes die niet gebruikt worden op '1' zetten (actief laag)
       1 => ANtemp(1),  
       others=> '1');

clock : clk_wiz_0 
                                port map ( 
                               -- Clock out ports  
                                clk_10Mhz => clk_10Mhz,
                               -- Status and control signals                
                                reset => reset, --de reset is actief hoog
                                locked => open,  --hebben we nu niet nodig
                                -- Clock in ports
                                clk_in1  => CLK100MHZ --clk_in1
                              );                             

p_60sTeller: process (clk_10Mhz) is
begin 
   if rising_edge(clk_10Mhz) then -- stijgende flank van klok    
              
           --   if tellerDispChange = 1 then --voor simulatie
            if tellerDispChange = 100000  then --10Mhz/100000 => 100hz                                
                tellerDispChange <= 0;
                
                if ANtemp="01" or Klok<10 then   --if ene disp is aan, zet andere aan
                    ANtemp<="10";
                    segm <= cSegm(eenheden);
                    
                elsif ANtemp="10" and Klok>9 then
                    ANtemp<="01";
                    segm <= cSegm(tientallen);
   
                end if;
            else
                tellerDispChange <= tellerDispChange + 1;
            end if;
   --------------------------------------------------------------------------------------         
           -- if teller60 = 99 then  --simulatie
            if teller60 = 9999999 then 
              
                 teller60 <= teller60+1;
                 
                 if Klok=59 then 
                    Klok <= 0;
                 else 
                    Klok <= Klok +1;
                 end if;  
                 
          --  elsif teller60 = 100 then --voor simulatie
            elsif teller60 = 10000000 then 
                teller60 <= 0;

                Splits_loop: for I in 0 to 5 loop
                    if Klok>=I*10 and Klok < (I+1)*10 then    
                        eenheden<=Klok-I*10;
                        tientallen<=I; 
                    end if;                        
                end loop Splits_loop;               
                  
            else 
               teller60 <= teller60+1;         
                 
            end if;
    end if;
end process p_60sTeller;

p_Display: process (segm)  
begin     
           
    CA <= segm(6);
    CB <= segm(5);
    CC <= segm(4);
    CD <= segm(3);
    CE <= segm(2);
    CF <= segm(1);
    CG <= segm(0);
    
end process p_Display;

end Behavioral;
