--Willem Van der Elst
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DrawLine is
    Port ( x0 : in STD_LOGIC_VECTOR (9 downto 0);
           y0 : in STD_LOGIC_VECTOR (8 downto 0);
           x1 : in STD_LOGIC_VECTOR (9 downto 0);
           y1 : in STD_LOGIC_VECTOR (8 downto 0);
           Start : in STD_LOGIC;
           CurrentX : out STD_LOGIC_VECTOR (9 downto 0);
           CurrentY : out STD_LOGIC_VECTOR (8 downto 0);
           Plotting : out STD_LOGIC;
           
           CLK: in STD_LOGIC);
end DrawLine;

architecture Behavioral of DrawLine is
--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------
signal dx,dy: integer;
signal err,e2: integer;
signal sx,sy: integer range -1 to 1;
signal currX,currY: integer;
signal busy: std_logic:='0';

type t_State is (Starting,change_e2,initializeErr,Drawing,Done);
signal State: t_State:=Done;

begin
--deze signalen moeten altijd worden doorgegeven aan deze uitgangen
CurrentX <= std_logic_vector(to_unsigned(currX,10)); 
CurrentY <= std_logic_vector(to_unsigned(currY,9));
Plotting <= busy;
--------------------------------------------------------------
--PROCESSES--
--------------------------------------------------------------
p_Bresenham: process (CLK) is 
begin 
if(rising_edge(CLK)) then 
case State is 
    when Starting => 
           currX <= to_integer(unsigned(x0)); 
           currY <= to_integer(unsigned(y0));            
           
           if x0<x1 then 
                sx <= 1; --dit signaal wordt opgeteld bij CurrX
                dx <= to_integer(unsigned(x1))- to_integer(unsigned(x0));
           else 
                sx <= -1;  
                dx <= to_integer(unsigned(x0))- to_integer(unsigned(x1));
           end if;
           
           if y0<y1 then 
                sy <= 1;
                dy <= to_integer(unsigned(y1))- to_integer(unsigned(y0));
           else 
                sy <= -1;  
                dy <= to_integer(unsigned(y0))- to_integer(unsigned(y1));
           end if;    
           State <= initializeErr;     --pas als dx en dy vast staan, kunnen we err berekenen
           
    when initializeErr => --Deze state wordt maar een keer gebruikt en kan eigenlijk weggewerkt worden door hierboven err te berekenen adhv to_integer(unsigned(x1))- to_integer(unsigned(x0)) enzo
           err <= dx - dy; 
           State <= change_e2; 
           
    when change_e2 =>          
           e2<=err*2; --normaal moeten we iets anders /2, maar vhdl en kommagetallen zijn geen vrienden dus we doen hier maal 2 zodat de vergelijking nog klopt                     
           busy <= '1'; --plotting='1'                 
           State <= Drawing;
    when Drawing =>
           if currX=to_integer(unsigned(x1)) and currY=to_integer(unsigned(y1)) then 
               busy <='0'; --de coordinaten zijn berekend
               State <= Done;
           else 
               if e2 > -dy and e2 < dx then 
                     err <= err - dy + dx; --deze lijn zou niet kunnen uitgevoerd worden indien we geen if apart nemen voor wanneer beide statements waar zijn. 
                     currX <= currX + sx; 
                     currY <= currY + sy;
               elsif e2 > -dy then 
                    err <= err - dy;
                    currX <= currX + sx; 
               elsif e2 < dx then 
                    err <= err + dx;
                    currY <= currY + sy;                   
               end if;
               State <= change_e2;
           end if; 
    when Done =>    
        busy <= '0';
        if Start='1' and busy='0' then
            State <= Starting;
        end if;                            
end case;
   
end if;     
end process p_Bresenham;

end Behavioral;
