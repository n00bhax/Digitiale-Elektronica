
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scorebord is
    Port (  
           SW1: in std_logic_vector(6 downto 0);
           SWB: in std_logic_vector(1 downto 0);
           SW2: in std_logic_vector(6 downto 0);
           
           AN : out std_logic_vector(7 downto 0); --Anodes (1=af)
           CA,CB,CC,CD,CE,CF,CG : out std_logic -- Kathodes
         );    

end Scorebord;

architecture Behavioral of Scorebord is

component BcdToSegm --hier wordt mijn ander vhdl bestand aangesproken.
port (
        bcd : in UNSIGNED(3 downto 0);
        segm : out std_logic_vector(6 downto 0));
end component;

signal bcd : UNSIGNED(3 downto 0);
signal segm : std_logic_vector(6 downto 0);
signal score: integer;
signal eenheden: integer;
signal tientallen: integer;
signal ee: std_logic;

begin

    BCD2SEGM: BcdToSegm port map ( --wordt dit project nu automatisch gebruikt/uitgevoerd? ja
        bcd => bcd,
        segm => segm); 
 -----------------------------------------------------------------------------------------------------------------   
    p_ScoreToBcd: process (SW1,SW2,SWB,eenheden,tientallen,ee)
    begin
        
         bcd <= "0000"; --om latches te vermijden
         
        --Welk display staat wanneer aan en welke waarde moet deze display tonen?  
        if SWB = "00" then
            if ee = '0' then
                if tientallen<10 and eenheden<10 then
                    -- AN <="01111111";
                     bcd <= to_UNSIGNED(tientallen,4);      
                else 
                     AN <="11111111";
                end if;
            else 
                bcd <= "1010"; --10de element is E
               -- AN <="01111111";
            end if;
            AN <="01111111";
            score <= to_integer(unsigned(SW1(6 downto 0)));

        elsif SWB = "01" then
            
            if ee='0' then
             --   AN <="10111111";
                bcd <= to_UNSIGNED(eenheden,4);               
            else 
              --  AN <="10111111";
                bcd <= "1010"; --10de element is E
            end if;
            AN <="10111111";
            score <= to_integer(unsigned(SW1(6 downto 0)));
        
        elsif SWB = "10" then
          
            if ee='0' then
                if tientallen<10 and eenheden<10 then
                    AN <="11111101";
                    bcd <= to_UNSIGNED(tientallen,4);
                else
              --      AN <="11111111";
                end if;
            else 
                 bcd <= "1010"; --10de element is E
              --   AN <="11111101";
            end if;
            AN <="11111101";
            score <= to_integer(unsigned(SW2(6 downto 0)));
                 
        else --SWB="11"    hier een else van maken omdat een else verplicht is
                 
            if ee='0' then
              --  AN <="11111110";
                bcd <= to_UNSIGNED(eenheden,4);                  
            else
                bcd <= "1010"; --10de element is E
               -- AN <="11111110";
            end if;
            AN <="11111110";
            score <= to_integer(unsigned(SW2(6 downto 0)));
            
        end if;     
     end process p_ScoreToBcd;  
   --------------------------------------------------------------------------------------------------------------------
   p_switchToBCD: process (score)
   begin      
        --Zet de switches om naar eenheden en tientallen van een getal.    
                
        ee<='0'; --anti-latch
        
        if score>89 and score<100 then
            eenheden <= score - 90;
            tientallen <= 9;
              
        elsif score>79 and score<90 then
            eenheden <= score - 80;
            tientallen <= 8;
          
        elsif score>69 and score<80 then
            eenheden <= score - 70;
            tientallen <= 7;
          
        elsif score>59 and score<70 then
            eenheden <= score - 60;
            tientallen <= 6;
             
        elsif score>49 and score<60 then
            eenheden <= score - 50;
            tientallen <= 5;
           
        elsif score>39 and score<50 then
            eenheden <= score - 40;
            tientallen <= 4;
             
        elsif score>29 and score<40 then
            eenheden <= score - 30;
            tientallen <= 3;
         
        elsif score>19 and score<30 then
            eenheden <= score - 20;
            tientallen <= 2;
     
        elsif score>9 and score<20 then
            eenheden <= score - 10;
            tientallen <= 1;
          
        elsif score<10 then
            eenheden <= score;
            tientallen <= 99; -- kan nooit werken, maar een if lost dit op
            
        else        
             tientallen <= 99;
             eenheden <= 99;
             ee <= '1';
        end if;            
                                     
     end process p_switchToBCD;
        
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
