library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.willem.all;

entity Triangles is
    Port ( 
        CLK100MHz: in STD_LOGIC;
        
        wea0 : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
        addra0 : out STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '1'); --dit adres heeft geen betekenenis en het maakt dus niet uit of we hier iets in steken. 
        dina0 : out STD_LOGIC_VECTOR(2 DOWNTO 0);   
                                                
        wea1 : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
        addra1 : out STD_LOGIC_VECTOR(18 DOWNTO 0); 
        dina1 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        WritingInVidmem0: out STD_LOGIC;
        WritingInVidmem1: out STD_LOGIC;
        
        klaar0: in STD_LOGIC; --deze zijn 1 klokflank '1' als het scherm volledig is afgebeeld
        klaar1: in STD_LOGIC;
        
        LED: out std_logic_vector (6 downto 0);
        SW: in STD_LOGIC
        );
        
end Triangles;
architecture Behavioral of Triangles is
--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------
Constant aantalDriehoeken: integer:= (5-1);

signal Sequence: STD_LOGIC_VECTOR (0 to 56):=(others => '1');

signal srst: STD_LOGIC:='0';
signal din: STD_LOGIC_VECTOR (58 downto 0); 
signal wr_en: STD_LOGIC:='0';                                                                    
signal dout: STD_LOGIC_VECTOR (0 to 58);
signal rd_en: STD_LOGIC:='0';                
signal full: STD_LOGIC;                     
signal empty: STD_LOGIC; 

signal x0,x1,CurrentX: STD_LOGIC_VECTOR (9 downto 0);
signal y0,y1,CurrentY: STD_LOGIC_VECTOR (8 downto 0);

signal Start, Plotting: STD_LOGIC;


type t_State_FifoIn IS (Vullen, Vol);   
signal State_FifoIn: t_State_FifoIn:=Vullen;  
      
type t_State_FifoOut IS (firstCase, Reading, Bresenham_state, Waiting);    
signal State_FifoOut: t_State_FifoOut:=firstCase;

type t_State_Bresenham IS (Bresenham2, Bresenham3, Bresenham_done);
signal State_Bresenham: t_State_Bresenham:=Bresenham2;

type t_State_VideoMemory IS (MakeBlack0, MakeBlack1, Waiting);
signal State_VideoMemory: t_State_VideoMemory:=MakeBlack0;


signal color: STD_LOGIC:= '1';
signal last: STD_LOGIC:= '0'; --een 0 betekent dat het volgende item in de fifo nog een driehoek beschrijft die ook op dit frame getekend moet worden.
signal AantalTeller: integer:=1;
signal naEersteKlokFlank: STD_LOGIC:= '0'; 

signal s_WritingInVidmem0: STD_LOGIC:='1'; 
signal s_WritingInVidmem1: STD_LOGIC:='0'; 

signal started: STD_LOGIC:= '0';  

--signal VideoMemoryReq: STD_LOGIC:='0';
--signal VideoMemoryAck: STD_LOGIC;

signal s_addra0: STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0'); --nodig omdat een out niet gelezen kan worden. 
signal s_addra1: STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0');

--signal tempstop: STD_LOGIC:='0';

signal VidmemIsBlack0: STD_LOGIC:= '0'; --1 als het frame zwart is
signal VidmemIsBlack1: STD_LOGIC:= '0';

signal ifFirstFrame: STD_LOGIC:='1';


begin
  addra0 <= s_addra0;
  addra1 <= s_addra1;
  WritingInVidmem0 <= s_WritingInVidmem0;  
  WritingInVidmem1 <= s_WritingInVidmem1;


--------------------------------------------------------------
--PORT MAPS--
--------------------------------------------------------------
 LFSR: LFSR57
  PORT MAP (
    Sequence => Sequence,
    CLK => CLK100MHz
  );
 
 Fifo: TriangleFifo
   PORT MAP (
    clk => CLK100MHz,
    srst => srst,
    
    din   => din,
    wr_en => wr_en,
    dout  => dout,
    rd_en => rd_en, --beter beschouwen als een 'change output' (na 1 klokflank)
    full  => full,
    empty => empty
  );
  
 Bresenham: DrawLine
  PORT MAP (
    x0 => x0,
    y0 => y0,
    x1 => x1,
    y1 => y1,
    Start => Start,
    CurrentX => CurrentX,
    CurrentY => CurrentY,
    Plotting => Plotting,
            
    CLK => CLK100MHz
  );
  

--------------------------------------------------------------
--PROCESSES--
--------------------------------------------------------------  
p_Triangles: process (CLK100MHz) is 
begin 
if(rising_edge(CLK100MHz)) then 

naEersteKlokFlank <= '1';
    
Case State_FifoIn is 
    when Vullen =>
  
        if (to_integer(unsigned(Sequence(0 to 9)))<=640 or to_integer(unsigned(Sequence(19 to 28)))<=640 or to_integer(unsigned(Sequence(38 to 47)))<=640 or --testen of de punten wel binnen het scherm vallen. 
        to_integer(unsigned(Sequence(10 to 18)))<=480 or to_integer(unsigned(Sequence(29 to 37)))<=480 or to_integer(unsigned(Sequence(48 to 56)))<=480 ) 
        then        
            din <= Sequence & color & last; --dinges in de fifo steken. 
            wr_en <= '1';
            AantalTeller <= AantalTeller + 1;
        else 
            wr_en <= '0'; --slechte sequence. 
        end if;
        
        if full='1' then 
            State_FifoIn <= Vol;
            wr_en <= '0';
        end if;
        
        if AantalTeller >= aantalDriehoeken then 
            last <= '1'; --geen driehoek meer voor dit frame. 
            AantalTeller <= 0;
        else 
            last <= '0';
        end if;
        
    when Vol =>      
        if full='0' then --dus hij zit niet meer vol. 
            State_FifoIn <= Vullen;
        end if;
        
end case;

Case State_FifoOut is

    when firstCase => 
        if naEersteKlokFlank='1' then 
            rd_en <='1'; --na de eerste klokflank zit er al iets in de fifo, nu worden even de nullen weggewerkt. 
            State_FifoOut <= Waiting;
        end if;

    when Reading =>   
        rd_en <='0';
        LED(1) <= '1';
        LED(0) <= '0';
        
        if empty='1' then 
            State_FifoOut <= Waiting; --als de fifo leeg is, moet em wachten. 
        else  
            x0 <= dout(0 to 9);     --a  
            y0 <= dout(10 to 18);   --a
            x1 <= dout(19 to 28);   --b
            y1 <= dout(29 to 37);   --b
            
            if s_WritingInVidmem0='1' then 
                wea0 <= "1"; --vertellen aan videoMemory dat we gaan beginnen schrijven.              
            elsif s_WritingInVidmem1='1' then
                wea1 <= "1";
            end if;
 
            State_FifoOut  <= Bresenham_state;   
  
       end if;      
    when Bresenham_state =>         
        LED(2) <= '1';   
        LED(1) <= '0';
        
--        if State_Bresenham/=Bresenham3 then 
--            rd_en <= '0'; --deze state duurt wel ff en er wordt dan niet constant iets op deze ingang gezet, maar rd_en = nog 0 van de vorige keer? 
--        end if;
        
        if s_WritingInVidmem0='1' then    
            if State_Bresenham=Bresenham_done and Plotting='0' and started='1' then 
--                s_addra0 <= (others => '0'); 
            else
                s_addra0 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640
            end if;
            
            if dout(57)='1' then --bepaalt kleur
                dina0 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
            else 
                dina0 <= "100";
            end if;
            
        elsif s_WritingInVidmem1='1' then
            if State_Bresenham=Bresenham_done and Plotting='0' and started='1' then 
 --               s_addra1 <= (others => '0');
            else 
                s_addra1 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640
            end if;
            
            if dout(57)='1' then 
                dina1 <= "100"; --in videomemory de pixel op het juiste adres kleuren.        
            else 
                dina1 <= "010";
            end if;
        end if;
        
      
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;

        if Plotting='0' and started='1' then --einde van een lijntje berekenen.   

            started<='0';
            Case State_Bresenham is    
                when Bresenham2 =>
                    x0 <= dout(19 to 28);   --b --eigenlijk read ik elke keer uit een andere lfsr sequence. BELANGRIJK ANDERS LIJNTJES IPV DRIEHOEKN 
                    y0 <= dout(29 to 37);   --b
                    x1 <= dout(38 to 47);   --c
                    y1 <= dout(48 to 56);   --c
                    
                    Start <='1'; --vertellen aan DrawLine.vhd dat we gaan beginnen rekenen.                 
                    State_Bresenham <= Bresenham3;
              
                when Bresenham3 =>
                    x0 <= dout(38 to 47);   --c
                    y0 <= dout(48 to 56);   --c
                    x1 <= dout(0 to 9);     --a
                    y1 <= dout(10 to 18);   --a
                                    
                    Start <= '1';
                   
                    State_Bresenham  <= Bresenham_done;
                  
                when Bresenham_done =>
                    wea0 <= "0";  --vertellen aan videoMemory dat we stoppen met schrijven. 
                    wea1 <= "0"; 
                    
                    if dout(58)='1' then                                                                                                 
                        if s_WritingInVidmem0='1' and klaar1='1' then --rekening houdend met het feit dat vidmem volgende klokflank verandert. Vidmem0 is nu helemaal klaar om gelezen te worden. 
                            --frame van vidmem1 is volledig afgebeeld. Indien dit niet het geval is zal deze case blijven worden doorlopen tot het wel het geval is. 
                                
                                s_WritingInVidmem0 <= '0';
                                ifFirstFrame <='0';              
                                --ONDERSTAANDE VERPLAATSTEN NAAR WAITING?
                                State_VideoMemory <= MakeBlack1;  --we wisselen van videomemory. Het andere moet dus terug gereset worden.  
                                VidmemIsBlack0 <= '0'; 
                                
                                rd_en <= '1';--vertellen aan Fifo dat we net hebben gelezen. Hij zal dan zijn dout veranderen voor de volgende driehoek
                                State_Bresenham <= Bresenham2;
                                State_FifoOut <= Waiting;

                        elsif s_WritingInVidmem1='1' and klaar0='1' then      --vidmem1 is klaar om gelezen te worden. en af te drukken op het scherm
                 
                                s_WritingInVidmem1 <= '0';
                                
                                State_VideoMemory <= MakeBlack0; 
                                VidmemIsBlack1 <= '0';   
                                
                                rd_en <= '1';--vertellen aan Fifo dat we net hebben gelezen. Hij zal dan zijn dout veranderen voor de volgende driehoek
                                State_Bresenham <= Bresenham2;
                                State_FifoOut <= Waiting;                 
                        end if;           
                    else --een driehoek is net in het geheugen geplaatst, maar er moeten nog driehoeken berekend worden. 
                        rd_en <= '1';--vertellen aan Fifo dat we net hebben gelezen. Hij zal dan zijn dout veranderen voor de volgende driehoek
                        State_Bresenham <= Bresenham2;
                        State_FifoOut <= Waiting;             
                    end if;
                                             
             end case;
        else 
            Start <= '0';
        end if;           
        
     when Waiting =>
        LED(0) <= '1';
        LED(1) <= '0';
        LED(2) <= '0';
        wea0 <= "0";
        wea1 <= "0";
        rd_en <= '0';
        
        if  empty='0' then  --empty=0=> fifo is niet leeg.
        
            if VidmemIsBlack0='1' and klaar0='1' then  -- klaar0='1' => mem0 is net afgebeeld en mag dus overschreven worden  
                
                 s_WritingInVidmem0 <= '1';
                 Start <= '1';--vertellen aan DrawLine.vhd dat we gaan beginnen rekenen.                           --ge moogt alleen beginnen aan een nieuw frame als hij zwart is gemaakt en hij klaar is met alles af te beelden
                 State_FifoOut  <= Reading;
                 
            elsif VidmemIsBlack1='1' and klaar1='1' then --IS NOOIT WAAR OP DIT MOMENT?
                
                 s_WritingInVidmem1 <= '1';
                 Start <= '1';--vertellen aan DrawLine.vhd dat we gaan beginnen rekenen.                           --ge moogt alleen beginnen aan een nieuw frame als hij zwart is gemaakt en hij klaar is met alles af te beelden
                 State_FifoOut  <= Reading;
                 
            end if;
            
           
        end if;
     
end Case; 


Case State_VideoMemory is --kan mooier/kleiner door een extra state te maken zodat het gemeenschappelijke stuk niet herhaald moet worden. 

    when MakeBlack0 =>
    
        LED(3) <= '1';
        wea0 <= "1"; --paar pixels links boven die nog niet verwijderd worden 
        dina0 <= "000";
        
        if (to_integer(unsigned(s_addra0)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
            State_VideoMemory <= Waiting;
            s_addra0 <= (others => '0'); --naar adress 0 gaan
            VidmemIsBlack0 <= '1';
        else 
            if naEersteKlokFlank='1' then 
                s_addra0 <= std_logic_vector(to_unsigned((to_integer(unsigned(s_addra0))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.           
                State_FifoOut  <= Waiting;
            end if;
        end if;
        
    when MakeBlack1 =>
    
        LED(4) <= '1';
        wea1 <= "1"; --paar pixels links boven die nog niet verwijderd worden 
        dina1 <= "000";
        
        if (to_integer(unsigned(s_addra1)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
            State_VideoMemory <= Waiting;
            s_addra1 <= (others => '0'); --naar adress 0 gaan
            VidmemIsBlack1 <= '1';
        else 
            if naEersteKlokFlank='1' then 
                s_addra1 <= std_logic_vector(to_unsigned((to_integer(unsigned(s_addra1))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.           
                State_FifoOut  <= Waiting;
            end if;
        end if;

    when Waiting =>
        
        LED(5) <= '1';
        LED(4) <= '0';
        LED(3) <= '0';
        --Uit deze state geraken gebeurt in een andere State (Bresenham_done)
end Case;   

     
end if;
end process p_Triangles;
 
end Behavioral;
