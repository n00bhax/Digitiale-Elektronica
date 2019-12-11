--CDC ook tegen vivado zeggen dat ik dit heb gedaan (in xdc komt het dan ergens te staan)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.willem.all;

entity Triangles is
    Port ( 
        CLK100MHz: in STD_LOGIC;
        
        wea0 : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
        addra0 : out STD_LOGIC_VECTOR(18 DOWNTO 0);--:= (others => '1'); --dit adres heeft geen betekenenis en het maakt dus niet uit of we hier iets in steken. 
        dina0 : out STD_LOGIC_VECTOR(2 DOWNTO 0);   
                                                
        wea1 : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
        addra1 : out STD_LOGIC_VECTOR(18 DOWNTO 0); 
        dina1 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        FirstFrameReady: out STD_LOGIC;
        
        klaar: in STD_LOGIC
--        klaar0: in STD_LOGIC; --deze zijn 1 klokflank '1' als het scherm volledig is afgebeeld
--        klaar1: in STD_LOGIC
        
        );
        
end Triangles;
architecture Behavioral of Triangles is
--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------
Constant aantalDriehoeken: integer:= (5-1);

signal Sequence: STD_LOGIC_VECTOR (56 downto 0) :=(others => '1');

signal srst: STD_LOGIC:='0';
signal din: STD_LOGIC_VECTOR (58 downto 0); 
signal wr_en: STD_LOGIC:='0';                                                                    
signal dout: STD_LOGIC_VECTOR (58 downto 0);
signal rd_en: STD_LOGIC:='0';                
signal full: STD_LOGIC;       
signal almost_full: STD_LOGIC;              
signal empty: STD_LOGIC; 

signal x0,x1,CurrentX: STD_LOGIC_VECTOR (9 downto 0);
signal y0,y1,CurrentY: STD_LOGIC_VECTOR (8 downto 0);

signal Start, Plotting: STD_LOGIC;


type t_State_FifoIn IS (Vullen, Vol);   
signal State_FifoIn: t_State_FifoIn:=Vullen;  

type t_State_VideoMemory IS (VideoMemory0, VideoMemory1);   
signal State_VideoMemory: t_State_VideoMemory:=VideoMemory0;  
      
type t_State_Triangles IS (firstCase, ChangeDoutFifo, MakeBlack, ReadingAB, BresenhamAB, BresenhamBC, BresenhamCA, TriangleDone, GoToReadingAB, GoToMakeBlack);
signal State_Triangles: t_State_Triangles:=firstCase;


signal color: STD_LOGIC:= '1';
signal last: STD_LOGIC:= '0'; --een 0 betekent dat het volgende item in de fifo nog een driehoek beschrijft die ook op dit frame getekend moet worden.
signal AantalTeller: integer:= 1; 

signal s_FirstFrameReady: STD_LOGIC:='0'; 

signal started: STD_LOGIC:= '0';  

signal wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal addra : STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0');
signal dina : STD_LOGIC_VECTOR(2 DOWNTO 0);

signal CDCtemp: STD_LOGIC;
signal klaarCDC: STD_LOGIC;

begin
  FirstFrameReady <= s_FirstFrameReady;  


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
    almost_full => almost_full,
    empty => empty
  --  almostempty => almostempty
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

Case State_FifoIn is 
    when Vullen =>
        if full='1' or almost_full='1' then 
            State_FifoIn <= Vol;
            wr_en <= '0';
        end if;
        
        if
        (to_integer(unsigned(Sequence(9 downto 0)))<=640 and to_integer(unsigned(Sequence(28 downto 19)))<=640 and to_integer(unsigned(Sequence(47 downto 38)))<=640 and --testen of de punten wel binnen het scherm vallen. 
        to_integer(unsigned(Sequence(18 downto 10)))<=480 and to_integer(unsigned(Sequence(37 downto 29)))<=480 and to_integer(unsigned(Sequence(56 downto 48)))<=480 ) 
        then        
            din <= last & color & Sequence; --dinges in de fifo steken. 
            wr_en <= '1';
            AantalTeller <= AantalTeller + 1; 
            
            if AantalTeller >= aantalDriehoeken then 
                last <= '1'; --geen driehoek meer voor dit frame. 
                AantalTeller <= 0;
            else 
                last <= '0';
            end if;                  
        else 
            wr_en <= '0'; --slechte sequence. 
            
        end if;
                 
    when Vol =>      
        if full='0' then --dus hij zit niet meer vol. 
            State_FifoIn <= Vullen;
        end if;
        
end case;

Case State_VideoMemory is 

    when VideoMemory0 =>
        wea0 <= wea;
        addra0 <= addra;
        dina0 <= dina;
        
    when VideoMemory1 => 
        wea1 <= wea;
        addra1 <= addra;
        dina1 <= dina;
        
end case;

Case State_Triangles is

    when firstCase => 
        State_Triangles <= ChangeDoutFifo;
        
    when ChangeDoutFifo =>
    
        rd_en <='1'; --na de eerste klokflank zit er al iets in de fifo, nu worden even de nullen aan de uitgang weggewerkt. 
        State_Triangles <= MakeBlack;
        wea <= "1"; --nodig voor MakeBlack0 
        
    when MakeBlack =>
       
        rd_en <='0';
        dina <= "000";
        
        if (to_integer(unsigned(addra)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
            State_Triangles  <= ReadingAB;
            wea <= "0"; 
            addra <= (others => '0'); --naar adress 0 gaan
        else 
            addra <= std_logic_vector(to_unsigned((to_integer(unsigned(addra))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.                                         
        end if;

    when ReadingAB => 

        if empty/='1' then --als de fifo leeg is, moet em wachten. 

            x0 <= dout(9 downto 0);     --a  
            y0 <= dout(18 downto 10);   --a
            x1 <= dout(28 downto 19);   --b
            y1 <= dout(37 downto 29);   --b

            
            rd_en <= '0'; 
            State_Triangles <= BresenhamAB;
            Start <= '1';

            
        end if;
    
    when BresenhamAB => 

        --berekenen en in vidmem plaatsen. 
        addra <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)='1' then --bepaalt kleur
            dina <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
            wea <= "1"; --vertellen aan videoMemory dat we gaan beginnen schrijven.
        end if;
        
        if Plotting='0' and started='1' then 
            State_Triangles <= BresenhamBC;
            x0 <= dout(28 downto 19);   --b --eigenlijk read ik elke keer uit een andere lfsr sequence. BELANGRIJK ANDERS LIJNTJES IPV DRIEHOEKN 
            y0 <= dout(37 downto 29);   --b
            x1 <= dout(47 downto 38);   --c
            y1 <= dout(56 downto 48);   --c
            
            Start <='1'; --vertellen aan DrawLine.vhd dat we gaan beginnen rekenen.  
            started <='0';
        end if;

    when BresenhamBC => 
              
        --berekenen en in vidmem plaatsen. 
        addra <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)='1' then --bepaalt kleur
            dina <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;

        if Plotting='0' and started='1' then 
            State_Triangles <= BresenhamCA;
            x0 <= dout(47 downto 38);   --c
            y0 <= dout(56 downto 48);   --c
            x1 <= dout(9 downto 0);     --a
            y1 <= dout(18 downto 10);   --a
                            
            Start <= '1';
            started <='0';
        end if;

    when BresenhamCA => 
    
        Start <= '0';
        --berekenen en in vidmem plaatsen. 
        addra <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)='1' then --bepaalt kleur
            dina <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;
        
        if Plotting='0' and started='1'  then 
            wea <= "0"; 
            Start <='0';
           
            started <= '0';
            State_Triangles <= TriangleDone;
        end if;
        
    when TriangleDone =>
    
        dina <= "000";
        rd_en <= '1'; --vertellen aan Fifo dat we net hebben gelezen. Hij zal dan zijn dout veranderen voor de volgende driehoek   
        if dout(58)='0' then  
            addra <= (others => '0'); 
            State_Triangles <= GoToReadingAB;
        else 
            State_Triangles <= GoToMakeBlack;    
            wea <= "0";            
            s_FirstFrameReady <='1';    
        end if;
       
        
    when GoToReadingAB=> 
    
        rd_en <= '0';    
        State_Triangles <= ReadingAB;
        
    when GoToMakeBlack => 
    
        addra <= (others => '0'); --naar adress 0 gaan   
        rd_en <= '0'; 
        
        if State_VideoMemory = VideoMemory0 and klaarCDC='1' then 
        
            State_VideoMemory <= VideoMemory1;
            wea <= "1";   
            State_Triangles <= MakeBlack;      
                
        elsif State_VideoMemory = VideoMemory1 and klaarCDC='0' then 
        
            State_VideoMemory <= VideoMemory0;
            wea <= "1";   
            State_Triangles <= MakeBlack;   
                
        end if;
        
    end case;
    
    CDCtemp <= klaar;
    klaarCDC <= CDCtemp;
    
end if;
end process p_Triangles;
    
    end Behavioral;
    
