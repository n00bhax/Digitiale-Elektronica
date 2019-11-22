library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Pong is
generic(
    g_yMax : integer; 
    g_xMax : integer;
    g_BallSize: integer :=9
    );
Port (    
    x: in integer;
    y: in integer;
    VideoActive: in std_logic;
    
    pixelClock: in std_logic;
    
    BTNL: in std_logic; --linker pallet
    BTND: in std_logic; --linker pallet  
    BTNR: in std_logic; --rechter pallet
    BTNU: in std_logic; --rechter pallet      
    BTNC: in std_logic;
    
    SW: in std_logic_vector(2 downto 0);
    
    AN : out std_logic_vector(7 downto 0); --Anodes (1=af)    
    CA,CB,CC,CD,CE,CF,CG : out std_logic; -- Kathodes
    
    VGA_R: out std_logic_vector (3 downto 0) := "0000";
    VGA_G: out std_logic_vector (3 downto 0) := "0000";
    VGA_B: out std_logic_vector (3 downto 0) := "0000" 
 );
end Pong;
  architecture Behavioral of Pong is

--constants
type tSegm is array(0 to 9) of std_logic_vector(6 downto 0); --array type aanmaken met juiste dimensies enzo
--constante array maken 
constant cSegm: tSegm:=     ("0000001", --0         
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
--signals
signal Border_white: std_logic :='0';
signal Dotted_white: std_logic :='0';
signal Ball_white: std_logic :='0';
signal Pallet_white: std_logic :='0';

signal Ball_x: integer range 0 to g_xMax :=g_xMax/2;
signal Ball_y: integer range 0 to g_yMax :=g_yMax/2;

signal angle: integer range -3 to 3 :=1;
signal pauze: std_logic :='1';
signal pauzeTeller: integer range 0 to 2000 :=0;

signal BalTeller: integer range 0 to 100000:=0;
signal BalSpeed: integer :=20000; --hoe kleiner, hoe sneller de bal. 
signal BallClock: std_logic :='0';

signal PalletTeller: integer range 0 to 80000:=0;
signal PalletSpeed: integer range 0 to 80000:=60000; --hoe kleiner, hoe sneller 
signal PalletClock: std_logic:='0';

signal PalletL_length: integer range 20 to 80:=30;
signal PalletL_Y: integer range 0 to g_yMax :=g_yMax/2;
signal PalletR_length: integer range 20 to 80:=30;
signal PalletR_Y: integer range 0 to g_yMax :=g_yMax/2;
signal angleTeller: integer range 0 to 5:=0;
signal goingRight: std_logic:='0';
signal goingLeft: std_logic:='1';

--signal tellerDispChange: integer range 0 to 25000000:=0; --voor debuggen
signal tellerDispChange: integer range 0 to 250000:=0;
signal segm: std_logic_vector(6 downto 0) :="0000001";
signal ANtemp: std_logic_vector(3 downto 0) :="0111"; --nodig om AN in if statements te gebruiken, een out kan niet gelezen worden.
signal ScoreR: integer range 0 to 101:=0;
signal ScoreL: integer range 0 to 101:=0;
signal ScoreReenheden: integer range 0 to 9:=0;
signal ScoreRtientallen: integer range 0 to 9:=0;
signal ScoreLeenheden: integer range 0 to 9:=0;
signal ScoreLtientallen: integer range 0 to 9:=0;
signal SevenSegClock: std_logic:='0';

begin 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Display
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
p_Display: process (VideoActive, Border_white, Dotted_white, Ball_white, Pallet_white) is
begin
    if VideoActive='1' then
        if Border_white='1' or Dotted_white='1' or Ball_white='1' or Pallet_white='1' then
            VGA_R<="1111";
            VGA_G<="1111";
            VGA_B<="1111";
        else 
            VGA_R<="0001";
            VGA_G<="0111";
            VGA_B<="0111";
        end if;
    else    --not in sync or other reason display video can't be active
        VGA_R<="0000";
        VGA_G<="0000";
        VGA_B<="0000";
    end if;
    
end process p_Display;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--STATIC THINGS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
p_Borders: process(x,y) is
begin 
    if y<15 or y>g_yMax-15 or ((x<15 or x>g_xMax-15) and (y<60 or y>g_yMax-60))  then
        Border_white <='1';
    else 
        Border_white <='0';
    end if;   
end process p_Borders;

p_DottedLine: process(x,y) is
begin
Dotted_white <='0'; --initialisatie (anti-latch)
    dot_loop: for k in 0 to 10 loop
        if (x>g_xMax/2-6 and x<g_xMax/2+6) and (y>k*60+15 and y<k*60+30+15) then
            Dotted_white <='1';
        end if;
    end loop dot_loop;
end process p_DottedLine;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CLOCKS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

p_Clocks: process(pixelClock)
begin
    if rising_edge(pixelClock) then
        if (balTeller = balSpeed) then
            balTeller <= 0;
            ballClock <= not(ballClock);
        else
            balTeller <= balTeller + 1;
        end if;
        
        if (PalletTeller = PalletSpeed) then
            PalletTeller <= 0;
            PalletClock <= not(PalletClock);
        else
            PalletTeller <= PalletTeller + 1;
        end if;
        
     --   if tellerDispChange = 25000000  then --om te debuggen
        if tellerDispChange = 62500  then --25.1xxMhz/62500 => ongeveer 400hz                                
            tellerDispChange <= 0; 
            SevenSegClock <=  not(SevenSegClock);        
        else
            tellerDispChange <= tellerDispChange + 1;
       end if;
    end if;
end process p_Clocks;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--7segment Display
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
p_7seg: process (ANtemp)
begin
    AN <= (0 => ANtemp(0),  --anodes die niet gebruikt worden op '1' zetten (actief laag)
           1 => ANtemp(1),  --wel gebruikt -> ANtemp erin steken
           6 => ANtemp(2), 
           7 => ANtemp(3), 
           others=> '1');
end process p_7seg;

p_Cathodes: process (segm)  
begin     
           
    CA <= segm(6);
    CB <= segm(5);
    CC <= segm(4);
    CD <= segm(3);
    CE <= segm(2);
    CF <= segm(1);
    CG <= segm(0);
    
end process p_Cathodes;

p_Anodes: process (SevenSegClock)
begin
    if rising_edge(SevenSegClock) then
        if ANtemp="0111" then   --if ene disp is aan, zet andere aan
            ANtemp<="1110";
            segm <= cSegm(ScoreReenheden);
        
        elsif ANtemp="1110" then
            ANtemp<="1101";
            segm <= cSegm(ScoreRtientallen);
        
        elsif ANtemp="1101" then
            ANtemp<="1011";
            segm <= cSegm(ScoreLeenheden);
            
        elsif ANtemp="1011" then
            ANtemp<="0111";
            segm <= cSegm(ScoreLtientallen);                  
        end if;
    end if;
end process p_Anodes;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--MOVING THINGS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BALL

p_DrawBall: process(x,y,Ball_x,Ball_y) is
begin
    if( x>Ball_x-g_ballSize and x<Ball_x+g_ballSize and y>Ball_y-g_ballSize and y<Ball_y+g_ballSize) then --bal tekenen
        Ball_white <='1';
    else
        Ball_white <='0';
    end if;       
end process p_DrawBall;
    

p_Ball: process(ballClock,BTNC,SW)
begin
    --Reset
    if BTNC='1' then
         Ball_x <= g_xMax/2;
         Ball_y <= g_yMax/2;
         ScoreR <=0;
         ScoreL <=0;
         angle <= 1;
         pauze<='1';

    --Pauze
    elsif SW(2)='1' then
        pauze<='1';
  
        
    elsif rising_edge(ballClock) then
              
        --Gescoord    
       if (Ball_x-g_BallSize=0) then  
            Ball_x <= g_xMax/2;
            Ball_y <= g_yMax/2;
                   
            angle <= 1;
            pauze<='1';
             
            ScoreR<=ScoreR +1;
            if ScoreR>=99 then
               ScoreR <=0;       
            end if;
       end if;
            
          
       if (Ball_x+g_BallSize=g_xMax) then  
            Ball_x <= g_xMax/2;
            Ball_y <= g_yMax/2;
            
            angle <= 1;
            pauze<='1';
            
            ScoreL<=ScoreL +1;            
            if ScoreL>=99 then
                 ScoreL <=0;  
        end if;   
        
        --Score opsplitsen
       Splits_loop: for I in 0 to 9 loop
          if ScoreR>=I*10 and ScoreR < (I+1)*10 then    
              ScoreReenheden<=ScoreR-I*10;
              ScoreRtientallen<=I; 
          end if;  
          
          if ScoreL>=I*10 and ScoreL < (I+1)*10 then    
              ScoreLeenheden<=ScoreL-I*10;
              ScoreLtientallen<=I; 
          end if;                        
       end loop Splits_loop;           
                     
        elsif pauze='0' then  --alles onder deze if moet niet uitgevoerd worden tijdens een pauze.                                    
                
           --Botshoek bepalen      
           if ( Ball_y+g_BallSize>=PalletL_Y-PalletL_length and Ball_y-g_BallSize<=PalletL_Y+PalletL_length and Ball_x<=29+g_BallSize and Ball_x>=28+g_BallSize)then --als hij stoot tegen het linkerPalletje 
                     GoingRight <= '1';
                     --PalletHit Links
                
                       --ongeveer 80°
                       if    (Ball_y+g_BallSize<=palletL_Y-palletL_Length+12) then --als hij tegen het randje botst (bovenkant 12 pixels)
                            angle <= -3;
                       elsif (Ball_y-g_BallSize>=palletL_Y+palletL_Length-12) then --als hij tegen het randje botst (onderkant 12 pixels)
                            angle <= 3;
                       
                       --60°
                       elsif (Ball_y+g_BallSize<=palletL_Y-palletL_Length+24) then --als hij bijna tegen het randje botst (bovenkant 24 pixels)
                            angle <= -2;
                       elsif (Ball_y-g_BallSize>=palletL_Y+palletL_Length-24) then --als hij bijna tegen het randje botst (onderkant 24 pixels)
                            angle <= 2;
                      --45°  
                      elsif (Ball_y<=palletL_Y-palletL_Length/7) then --als hij tussen het bijna randje en het midden botst (bovenkant)
                           angle <= -1;
                      elsif (Ball_y>=palletL_Y+palletL_Length/7) then --als hij tussen het bijna randje en het midden botst (onderkant)
                           angle <= 1;
                      
                      --0°
                      else 
                           angle <= 0;            
                      end if;              
           --    end if;
               
            --PalletHit Rechts
              elsif ( Ball_y+g_BallSize>=PalletR_Y-PalletR_length and Ball_y-g_BallSize<=PalletR_Y+PalletR_length and Ball_x<=g_xMax-28-g_BallSize and Ball_x>=g_xMax-29-g_BallSize)then --als hij stoot tegen het rechterPalletje
                    GoingRight <= '0';
                  --botshoek bepalen 
                     --ongeveer 80°
                     if    (Ball_y+g_BallSize<=palletR_Y-palletR_Length+12) then 
                          angle <= -3;
                     elsif (Ball_y-g_BallSize>=palletR_Y+palletR_Length-12) then 
                          angle <= 3;
                     
                     --60°
                     elsif (Ball_y+g_BallSize<=palletR_Y-palletR_Length+24) then 
                          angle <= -2;
                     elsif (Ball_y-g_BallSize>=palletR_Y+palletR_Length-24) then 
                          angle <= 2;
                     --45°  
                     elsif (Ball_y<=palletR_Y-palletR_Length/7) then
                          angle <= -1;
                     elsif (Ball_y>=palletR_Y+palletR_Length/7) then 
                          angle <= 1;
                     
                     --0°
                     else 
                          angle <= 0;            
                     end if;              
             -- end if;                
                             
             --Bots tegen randjes                                                         
             elsif Ball_y>g_yMax-15-g_BallSize or ( (Ball_y+g_BallSize=PalletR_y-PalletR_Length and (g_xMax-30<Ball_x+g_BallSize and g_xMax-20>Ball_x-g_BallSize)) or (Ball_y+g_BallSize=PalletL_y-PalletL_Length and (Ball_x-g_BallSize<30 and Ball_x+g_BallSize>20))) then --als hij stoot tegen de onderkant (pallet of rand)
                              --                  ^check if y coordinaten zijn juist                    ^check if x coordinaten zijn juist                
                 if angle>0 then--altijd negatief maken
                     angle<=-angle;
                 end if;
             elsif Ball_y<15+g_BallSize  or ( (Ball_y-g_BallSize=PalletR_y+PalletR_Length and (g_xMax-30<Ball_x+g_BallSize and g_xMax-20>Ball_x-g_BallSize)) or (Ball_y-g_BallSize=PalletL_y+PalletL_Length and (Ball_x-g_BallSize<30 and Ball_x+g_BallSize>20))) then --als hij stoot tegen de bovenkant (pallet of rand)
                
                 if angle<0 then --positief maken
                     angle <= -angle;
                 end if;
             end if;
                   
             if ( (Ball_x<15+g_BallSize) and ( Ball_y<60+g_BallSize or Ball_y>g_yMax-60-g_BallSize) )then --als hij stoot tegen de linker haakjes langs de zijkant
                 goingRight <= '1';
             
             elsif ( (Ball_x>g_xMax-15-g_BallSize) and ( Ball_y<60+g_BallSize or Ball_y>g_yMax-60-g_BallSize) )then --als hij stoot tegen de rechter haakjes langs de zijkant
                 goingRight <= '0';                        
             end if; 
                 
                 
             
             --Bal verplaatsen
             if (angle=0) then --rechtdoor gaat snel, maar dit is de bedoeling en kan als taktiek gebruikt worden. 
                 if GoingRight='1' then
                      Ball_x <= Ball_x+ 1;--voor linkerpalletje moet x pos worden
                 else --goingLeft
                      Ball_x <= Ball_x- 1;--voor rechterpalletje moet x pos worden
                 end if;
                 
             elsif angle=1 then --ball gaat 45 graden naar boven
                 if angleTeller=2 then
                     Ball_y <= Ball_y +1;
                     angleTeller <= 0;
                     if goingRight='1' then
                         Ball_x <= Ball_x +1;
                     else 
                         Ball_x <= Ball_x -1;
                     end if;                
                 else 
                    angleTeller <= angleTeller +1;
                 end if;
             
             elsif angle=-1 then --ball gaat 45 graden naar onder
                 if angleTeller=2 then
                     Ball_y <= Ball_y -1;
                     angleTeller <= 0;
                     if goingRight='1' then
                         Ball_x <= Ball_x +1;
                     else 
                         Ball_x <= Ball_x -1;
                     end if;         
                 else 
                    angleTeller <= angleTeller +1;
                 end if;  
                 
             elsif angle=2 then --ball gaat 45 graden naar boven
                 if angleTeller=2 or  angleTeller=3 then
                     Ball_y <= Ball_y +1;
                 end if;
                 if angleTeller=3 then          
                     angleTeller <= 0;
                     if goingRight='1' then
                         Ball_x <= Ball_x +1;
                     else 
                         Ball_x <= Ball_x -1;
                     end if;                
                 else 
                    angleTeller <= angleTeller +1;
                 end if;
                   
             elsif angle=-2 then --ball gaat 60 graden naar onder
                 if angleTeller=2 or  angleTeller=3 then
                     Ball_y <= Ball_y -1;
                 end if;
                 if angleTeller=3 then          
                     angleTeller <= 0;
                     if goingRight='1' then
                         Ball_x <= Ball_x +1;
                     else 
                         Ball_x <= Ball_x -1;
                     end if;                
                 else 
                    angleTeller <= angleTeller +1;
                 end if;
             
             elsif angle=3 then  
                 Ball_y <= Ball_y +1;
                 if angleTeller >=3 then
                    angleTeller <= 0;
                    if goingRight='1' then
                        Ball_x <= Ball_x +1;
                    else 
                        Ball_x <= Ball_x -1;
                    end if;
                 else 
                    angleTeller <= angleTeller +1;
                 end if;   
             else --angle=-3       
                 Ball_y <= Ball_y -1;
                 if angleTeller >=3 then
                    angleTeller <= 0;
                    if goingRight='1' then
                       Ball_x <= Ball_x +1;
                    else 
                       Ball_x <= Ball_x -1;
                    end if;   
                 else 
                    angleTeller <= angleTeller +1;
                 end if;
            end if;       
                                
        --Bonussen/nerfs
       if ScoreR>=ScoreL+5 then
            PalletR_length <= 20;      
       else 
            PalletR_length <= 30;
       end if;
       
       if ScoreL>=ScoreR+5 then
            PalletL_length <= 20;      
       else 
            PalletL_length <= 30;
       end if;
       
                            
       else --pauze= '1'
            if pauzeTeller=1000 then
                pauzeTeller<=0;  
                pauze<='0';            
            else 
               pauzeTeller<= pauzeTeller + 1;
            end if; 
       end if;
   end if;
 end process p_Ball;          


--PALLETTEN
p_DrawPallets: process(x,y,PalletL_y,PalletL_length,PalletR_y,PalletR_length) is
begin
    if( (x>20 and x< 30 and y>PalletL_y-PalletL_length and y<PalletL_y+PalletL_length) or (x<g_xMax-20 and x>g_xMax-30 and y>PalletR_y-PalletR_length and y<PalletR_y+PalletR_length)) then --Palletten tekenen (eerste x coördinaten zijn de dikte van het palletje)
        Pallet_white <='1';
    else
        Pallet_white  <='0';
    end if;       
end process p_DrawPallets;

p_MovePalletL: process(PalletClock)
begin
    if rising_edge(PalletClock) then
        if SW(0)='0' then 
            if  ((Ball_x=g_xMax/2) and (Ball_y=g_yMax/2) and pauze='1') or pauze='0' then     
                if(PalletL_y >=15+PalletL_length and BTNL='1') then       
                    PalletL_Y <= PalletL_Y-1;
                end if;
                if(PalletL_y <= g_yMax-PalletL_length-15 and BTND='1') then
                    PalletL_Y <= PalletL_Y+1;
                end if;    
            end if;
        else --SW0 staat aan
            if Ball_Y<PalletL_Y and PalletL_y >=15+PalletL_length then 
                PalletL_Y <= PalletL_Y-1;
            elsif Ball_Y>PalletL_Y and PalletL_y <= g_yMax-PalletL_length-15 then 
                PalletL_Y <= PalletL_Y+1;
            end if;
        end if;
    end if;
end process p_MovePalletL;

p_MovePalletR: process(PalletClock)
begin
    if rising_edge(PalletClock) then
        if SW(1)='0' then 
             if  ((Ball_x=g_xMax/2) and (Ball_y=g_yMax/2) and pauze='1') or pauze='0' then  
                    if(PalletR_y >=15+PalletR_length and BTNU='1') then       
                        PalletR_Y <= PalletR_Y-1;
                    end if;
                    if(PalletR_y <= g_yMax-PalletR_length-15 and BTNR='1') then
                        PalletR_Y <= PalletR_Y+1;
                    end if;    
             end if;           
        else --SW1 staat aan CPU vs Speler
            if Ball_Y<PalletR_Y and PalletR_y >=15+PalletR_length then 
                PalletR_Y <= PalletR_Y-1;
            elsif Ball_Y>PalletR_Y and PalletR_y <= g_yMax-PalletR_length-15 then 
                PalletR_Y <= PalletR_Y+1;
            end if;
        end if;
     end if;
end process p_MovePalletR;


end Behavioral;
