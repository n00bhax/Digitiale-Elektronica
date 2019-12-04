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
        
        FirstFrameReady: out STD_LOGIC;
        
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

signal Sequence: STD_LOGIC_VECTOR (56 downto 0) :=(others => '1');

signal srst: STD_LOGIC:='0';
signal din: STD_LOGIC_VECTOR (58 downto 0); 
signal wr_en: STD_LOGIC:='0';                                                                    
signal dout: STD_LOGIC_VECTOR (58 downto 0);
signal rd_en: STD_LOGIC:='0';                
signal full: STD_LOGIC;                     
signal empty: STD_LOGIC; 

signal x0,x1,CurrentX: STD_LOGIC_VECTOR (9 downto 0);
signal y0,y1,CurrentY: STD_LOGIC_VECTOR (8 downto 0);

signal Start, Plotting: STD_LOGIC;


type t_State_FifoIn IS (Vullen, Vol);   
signal State_FifoIn: t_State_FifoIn:=Vullen;  
      
type t_State_Triangles IS (firstCase, ChangeDoutFifo, MakeBlack0, ReadingAB0, BresenhamAB0, BresenhamBC0, BresenhamCA0, TriangleDone0, GoToReadingAB0, GoToMakeBlack1, 
 MakeBlack1, ReadingAB1, BresenhamAB1, BresenhamBC1, BresenhamCA1, TriangleDone1, GoToReadingAB1, GoToMakeBlack0);
signal State_Triangles: t_State_Triangles:=firstCase;


signal color: STD_LOGIC:= '1';
signal last: STD_LOGIC:= '0'; --een 0 betekent dat het volgende item in de fifo nog een driehoek beschrijft die ook op dit frame getekend moet worden.
signal AantalTeller: integer:= 1; 

signal s_FirstFrameReady: STD_LOGIC:='0'; 

signal started: STD_LOGIC:= '0';  

signal s_addra0: STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0'); --nodig omdat een out niet gelezen kan worden. 
signal s_addra1: STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0');


begin
  addra0 <= s_addra0;
  addra1 <= s_addra1;
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

Case State_FifoIn is 
    when Vullen =>
  
        if (to_integer(unsigned(Sequence(9 downto 0)))<=640 and to_integer(unsigned(Sequence(28 downto 19)))<=640 and to_integer(unsigned(Sequence(47 downto 38)))<=640 and --testen of de punten wel binnen het scherm vallen. 
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
                
        if full='1' then 
            State_FifoIn <= Vol;
            wr_en <= '0';
        end if;
        
       
        
    when Vol =>      
        if full='0' then --dus hij zit niet meer vol. 
            State_FifoIn <= Vullen;
        end if;
        
end case;



Case State_Triangles is

    when firstCase => 
        State_Triangles <= ChangeDoutFifo;
        
    when ChangeDoutFifo =>
    
        rd_en <='1'; --na de eerste klokflank zit er al iets in de fifo, nu worden even de nullen weggewerkt. 
        State_Triangles <= MakeBlack0;
        wea0 <= "1"; --nodig voor MakeBlack0 
        
    when MakeBlack0 =>
       
        rd_en <='0';
        dina0 <= "000";
        
        if (to_integer(unsigned(s_addra0)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
            State_Triangles  <= ReadingAB0;
            wea0 <= "0"; 
            s_addra0 <= (others => '0'); --naar adress 0 gaan
   --         VidmemIsBlack0 <= '1';
        else 
            s_addra0 <= std_logic_vector(to_unsigned((to_integer(unsigned(s_addra0))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.                                         
        end if;

    when ReadingAB0 => 

        if empty/='1' then --als de fifo leeg is, moet em wachten. 

            x0 <= dout(9 downto 0);     --a  
            y0 <= dout(18 downto 10);   --a
            x1 <= dout(28 downto 19);   --b
            y1 <= dout(37 downto 29);   --b

            
            rd_en <= '0'; 
            State_Triangles <= BresenhamAB0;
            Start <= '1';

            
        end if;
    
    when BresenhamAB0 => 
    
        wea0 <= "1"; --vertellen aan videoMemory dat we gaan beginnen schrijven. 
        --berekenen en in vidmem plaatsen. 
        s_addra0 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)='1' then --bepaalt kleur
            dina0 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina0 <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;
        
        if Plotting='0' and started='1' then 
            State_Triangles <= BresenhamBC0;
            x0 <= dout(28 downto 19);   --b --eigenlijk read ik elke keer uit een andere lfsr sequence. BELANGRIJK ANDERS LIJNTJES IPV DRIEHOEKN 
            y0 <= dout(37 downto 29);   --b
            x1 <= dout(47 downto 38);   --c
            y1 <= dout(56 downto 48);   --c
            
            Start <='1'; --vertellen aan DrawLine.vhd dat we gaan beginnen rekenen.  
            started <='0';
        end if;

    when BresenhamBC0 => 
        
        
        --berekenen en in vidmem plaatsen. 
        s_addra0 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)='1' then --bepaalt kleur
            dina0 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina0 <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;

        if Plotting='0' and started='1' then 
            State_Triangles <= BresenhamCA0;
            x0 <= dout(47 downto 38);   --c
            y0 <= dout(56 downto 48);   --c
            x1 <= dout(9 downto 0);     --a
            y1 <= dout(18 downto 10);   --a
                            
            Start <= '1';
            started <='0';
        end if;

    when BresenhamCA0 => 
    
        Start <= '0';
        --berekenen en in vidmem plaatsen. 
        s_addra0 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)='1' then --bepaalt kleur
            dina0 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina0 <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;
        
        if Plotting='0' and started='1'  then 
            wea0 <= "0"; 
            Start <='0';
           
            started <= '0';
            State_Triangles <= TriangleDone0;
        end if;
        
    when TriangleDone0 =>
    
        
        rd_en <= '1'; --vertellen aan Fifo dat we net hebben gelezen. Hij zal dan zijn dout veranderen voor de volgende driehoek   
        if dout(58)='0' then  
            State_Triangles <= GoToReadingAB0;
        else 
            State_Triangles <= GoToMakeBlack1;    
            s_FirstFrameReady <='1';    
        end if;
        
        
    when GoToReadingAB0 => 
    
        rd_en <= '0';    
        State_Triangles <= ReadingAB0;
    
    when GoToMakeBlack1 => 
    
        s_addra0 <= (others => '0'); --naar adress 0 gaan
        rd_en <= '0'; 
        if klaar1='1' then
            State_Triangles <= MakeBlack1;   
            wea1 <= "1";      
        end if;
        
    when MakeBlack1 =>
       
        rd_en <='0';
        dina1 <= "000";
        
        if (to_integer(unsigned(s_addra1)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
            State_Triangles  <= ReadingAB1;
            s_addra1 <= (others => '0'); --naar adress 0 gaan
              
        else 
            s_addra1 <= std_logic_vector(to_unsigned((to_integer(unsigned(s_addra1))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.                                         
        end if;

    when ReadingAB1 => 
        wea1 <= "0"; 
        
        if empty/='1' then --als de fifo leeg is, moet em wachten. 
    
            x0 <= dout(9 downto 0);     --a  
            y0 <= dout(18 downto 10);   --a
            x1 <= dout(28 downto 19);   --b
            y1 <= dout(37 downto 29);   --b
    
            wea1 <= "1"; --vertellen aan videoMemory dat we gaan beginnen schrijven. 
            rd_en <= '0'; 
            State_Triangles <= BresenhamAB1;
            Start <='1';
        end if;
    
    when BresenhamAB1 => 

        --berekenen en in vidmem plaatsen. 
        s_addra1 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)/='1' then --bepaalt kleur
            dina1 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina1 <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;

        if Plotting='0' and started='1' then 
            State_Triangles <= BresenhamBC1;
            x0 <= dout(28 downto 19);   --b --eigenlijk read ik elke keer uit een andere lfsr sequence. BELANGRIJK ANDERS LIJNTJES IPV DRIEHOEKN 
            y0 <= dout(37 downto 29);   --b
            x1 <= dout(47 downto 38);   --c
            y1 <= dout(56 downto 48);   --c
            
            Start <='1'; --vertellen aan DrawLine.vhd dat we gaan beginnen rekenen.  
            started <='0';
        end if;

    when BresenhamBC1 => 
    

        --berekenen en in vidmem plaatsen. 
        s_addra1 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)/='1' then --bepaalt kleur
            dina1 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina1 <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;
        
        if Plotting='0' and started='1' then 
            State_Triangles <= BresenhamCA1;
            x0 <= dout(47 downto 38);   --c
            y0 <= dout(56 downto 48);   --c
            x1 <= dout(9 downto 0);     --a
            y1 <= dout(18 downto 10);   --a
                            
            Start <= '1';
            started <='0';
        end if;

    when BresenhamCA1 => 
    
        Start <= '0';
        --berekenen en in vidmem plaatsen. 
        s_addra1 <= std_logic_vector(to_unsigned((to_integer(unsigned(CurrentX)))+((to_integer(unsigned(CurrentY)))*640),19)); --CurrentX+CurrentY*640

        if dout(57)/='1' then --bepaalt kleur
            dina1 <= "010"; --in videomemory de pixel op het juiste adres kleuren. 
        else 
            dina1 <= "100";
        end if;
        
        if Plotting='1' then --nodig want anders wordt de if hieronder direct uitevoerd. Er zijn nog 2 klokflanken ofzo dat plotting 0 is in het begin van deze case
            started <= '1';
        end if;

        if Plotting='0' and started='1' then 
            wea1 <= "0"; 
            Start <='0';
           
            started <= '0';
            State_Triangles <= TriangleDone1;

        end if;
        
    when TriangleDone1 =>
    
        rd_en <= '1'; --vertellen aan Fifo dat we net hebben gelezen. Hij zal dan zijn dout veranderen voor de volgende driehoek             
        if dout(58)='0' then  
            State_Triangles <= GoToReadingAB1;
        else 
            State_Triangles <= GoToMakeBlack0;        
        end if;

    when GoToReadingAB1 => 
    
        rd_en <= '0';    
        State_Triangles <= ReadingAB1;
    
    when GoToMakeBlack0 => 
    
        s_addra1 <= (others => '0'); --naar adress 0 gaan   
        rd_en <= '0'; 
        if klaar0='1' then
            wea0 <= "1";   
            State_Triangles <= MakeBlack0;        
        end if;
        
end case;

end if;
end process p_Triangles;
 
end Behavioral;

