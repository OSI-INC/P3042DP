-- <pre> Telemetry Control Box (TCB) Display Panel (A3042DP) Firmware, Toplevel Unit

-- V1.1 [24-AUG-22] Starting point for development. Defines inputs and outputs.

-- V2.1 [25-AUG-22] All lamps and swithes connected and tested.

-- V2.2 [25-AUG-22] Adding combinatorial logic to permit lighting patterns controlled
-- by switches. Add to_std_logic function.

-- V2.3 [28-AUG-22] Fix git merge failures. Remove old explanatory comment. Add state 
-- machines.

library ieee;  
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is 
	port (
		CK, -- Clock
		SHOW, -- SHOW button
		HIDE, -- HIDE button
		CONFIG, -- CONFIG button
		LRST -- Local RESET button
		: in std_logic; 
		TP1, -- Test Point One (TMS)
		TP2, -- Test Point Two (TDI)
		TP3, -- Test Point Three (TDO)
		TP4,  -- Test Point Four (TCK)
		CH1, -- Channel 1
		CH2, -- Channel 2
		CH3, -- Channel 3
		CH4, -- Channel 4
		CH5, -- Channel 5
		CH6, -- Channel 6
		CH7, -- Channel 7
		CH8, -- Channel 8
		CH9, -- Channel 9
		CH10, -- Channel 10
		CH11, -- Channel 11
		CH12, -- Channel 12
		CH13, -- Channel 13
		CH14, -- Channel 14
		CH15, -- Channel 15
		SHOWLED, -- LED for SHOW button
		HIDELED, -- LED for HIDE button
		CONFIGLED, -- LED for CONFIG button
		RESETLED, -- LED for RESET button
		UPLOAD, -- Upload
		EMPTY, -- Empty
		ACTIV, -- Active
		DMERR -- Detector Module Error
		: out std_logic;
		SDI, -- Serial Data INTO the Baseboard
		SDO -- Serial Data OUT of the Baseboard
		:inout std_logic
	);
end;



architecture behavior of main is

-- Convert boolean to standar logic. We return '1' for 'true' and '0'
-- for 'false'.
	function to_std_logic (v: boolean) return std_ulogic is
	begin if v then return('1'); else return('0'); end if; end function;

-- Signals.
	signal SCK : std_logic; -- Slow Clock
	signal DCK : std_logic; -- Double Clock
	signal RESET : std_logic; -- RESET from button on dispaly panel or signal from baseboard
	
-- Base Board Interface
	signal BBXMIT : boolean := false; -- Base Board Data Transmit 
	signal BBRCV : boolean := false; -- Base Board Data Received
	signal BBIR : boolean := false; -- Base Board Input Read
	signal bb_in, bb_out : std_logic_vector(7 downto 0);
	signal BBXDONE : boolean := false; -- Final bit in BBXMIT
	signal BBRCNT : boolean := false; -- Baseboard Receiver Continue
	signal CH1F, CH2F, CH3F, CH4F, CH5F, CH6F, CH7F, CH8F, CH9F, CH10F, CH11F, CH12F, CH13F, CH14F,CH15F : boolean := false; --when to flash LEDs

begin


-- Clock_Divider takes CK and divides by 8,000. On the assumption that CK
-- is 80 MHz, this leaves us with 10 kHz, which we apply to the signal SCK.
-- We list all the inputs to the process that must be monitored in order to
-- determine the set of moments in time when the output might change. In our case
-- the output changes only in response to CK. The value the output takes on
-- may be a function of many other inputs to the process, but those inputs can
-- never, on their own, provoke a change in CK. We're saying to the VHDL compiler
-- that a change in CK is nesseccary for a change in the process outputs. We are
-- not saying that a change in CK is sufficient.
Clock_Divider : process (CK) is

-- The divisor is a constant. Its value is used by the compiler, but is not stored
-- anywhere in the logic.
	constant divisor : integer := 80;
	
-- The count will be implemented as a register with a number of bits sufficient to
-- represent count's value range. The range 0..8191 is thirteen bits, because 2^13
-- = 8191 + 1, and our counter counts up from zero.
	variable count : integer range 0 to 8191;

begin

-- There are two ways to get a process to update itself on the rising edge of
-- a clock. One is with the rising_edge command, which we use here. Another is
-- with the "wait" command, which we can do another time.
	if rising_edge(CK) then
	
		-- We count up to divisor minus one, then go back to zero. The "count"
		-- is not a "variable", not a "signal". The compiler decyphers our 
		-- logic sequentially. Later statements override earlier statements when
		-- they conflict. With signals, the value the compiler uses for the 
		-- signal remains the same throughout our logic equations as the compiler
		-- tries to figure out what the next value of the signal should be. For
		-- variables, the compiler allows us to change the value of the variable
		-- as it proceeds through the equations. We use "<=" to update signal
		-- values, to remind us that the value of the signal will not be updated
		-- during our written equations, and ":=" to remind us that it will be
		-- updated. Suppose x is zero at the beginning of our "if" statement. 
		-- If x is a signal, we can say "x <= x + 8; x <= x + 1;" and x will be set
		-- to 1. If x is a variable, we can say "x := x + 8; x := x + 1" and x
		-- will be sset to 9.
			if count = divisor - 1 then
				count := 0;
			else
				count := count + 1;
			end if;
		-- If our counter is less than half the divisor, let our slow
		-- clock, SCK, be zero, otherwise it's one.
		if count <= divisor / 2 then
			SCK <= '0';
		else
			SCK <= '1';
		end if;
	end if;
end process;


Double_Clock_Divider : process (CK) is

-- The divisor is a constant. Its value is used by the compiler, but is not stored
-- anywhere in the logic.
	constant divisor : integer := 20;
	
-- The count will be implemented as a register with a number of bits sufficient to
-- represent count's value range. The range 0..8191 is thirteen bits, because 2^13
-- = 8191 + 1, and our counter counts up from zero.
	variable count : integer range 0 to 8191;

begin

-- There are two ways to get a process to update itself on the rising edge of
-- a clock. One is with the rising_edge command, which we use here. Another is
-- with the "wait" command, which we can do another time.
	if rising_edge(CK) then
	
		-- We count up to divisor minus one, then go back to zero. The "count"
		-- is not a "variable", not a "signal". The compiler decyphers our 
		-- logic sequentially. Later statements override earlier statements when
		-- they conflict. With signals, the value the compiler uses for the 
		-- signal remains the same throughout our logic equations as the compiler
		-- tries to figure out what the next value of the signal should be. For
		-- variables, the compiler allows us to change the value of the variable
		-- as it proceeds through the equations. We use "<=" to update signal
		-- values, to remind us that the value of the signal will not be updated
		-- during our written equations, and ":=" to remind us that it will be
		-- updated. Suppose x is zero at the beginning of our "if" statement. 
		-- If x is a signal, we can say "x <= x + 8; x <= x + 1;" and x will be set
		-- to 1. If x is a variable, we can say "x := x + 8; x := x + 1" and x
		-- will be sset to 9.
			if count = divisor - 1 then
				count := 0;
			else
				count := count + 1;
			end if;
		-- If our counter is less than half the divisor, let our slow
		-- clock, SCK, be zero, otherwise it's one.
		if count <= divisor / 2 then
			DCK <= '0';
		else
			DCK <= '1';
		end if;
	end if;
end process;




When_to_Reset : process (LRST) is
begin
	if LRST = '0' then
		RESET <= '1';
	else 
		RESET <= 'Z';
	end if;
end process;

When_to_Transmit : process (SCK,BBXDONE,SHOW) is
variable state, next_state : integer range 0 to 63;
begin	
	if (RESET = '1') then
		state := 0;
		BBXMIT <= false;
	elsif rising_edge (SCK) then
		next_state := state;
		
		if (state = 0) then
			if (SHOW = '1') or (CONFIG = '1') or (HIDE = '1') then
				next_state := 1;
				BBXMIT <= true;
			else
				next_state := 0;
				BBXMIT <= false;
			end if;
		end if;
		if (state = 1) then
			BBXMIT <= true;
			if BBXDONE then
				next_state := 2;
			else
				next_state := 1;
			end if;
		end if;
		if (state = 2) then
			BBXMIT <= false;
			if BBXDONE then
				next_state := 2;
			else
				next_state := 0;
			end if;
		end if;
		
		

		
		if (SHOW = '1') then 
			bb_out <= "01100010"; 
		elsif (CONFIG = '1') then
			bb_out <= "01100001"; 
		elsif (HIDE = '1') then
			bb_out <= "01100100"; 
		else
			bb_out <= "01100000";
		end if;

		state := next_state;
	end if;
	
	
	
		
end process;

When_to_Recieve : process (SCK, RESET) is
variable state, next_state : integer range 0 to 3;
begin
	if RESET = '1' then
		state := 0;
	elsif rising_edge (SCK) then
		next_state := 0;
		if state = 0 then
			BBRCNT <= false;
			if BBRCV then 
				next_state := 1;
			end if;
		elsif state = 1 then
			next_state := 2;
		elsif state = 2 then
			BBRCNT <= true;
			if BBRCV then
				next_state := 2;
			end if;
		end if;
		
		CH1F <= false;
		CH2F <= false;
		CH3F <= false;
		CH4F <= false;
		CH5F <= false;
		CH6F <= false;
		CH7F <= false;
		CH8F <= false;
		CH9F <= false;
		CH10F <= false;
		CH11F <= false;
		CH12F <= false;
		CH13F <= false;
		CH14F <= false;
		CH15F <= false;
		
		if state = 1 then
			if (bb_in(7) = '0') and (bb_in(6) = '0') and (bb_in(5) = '0') and (bb_in(4) = '1') then
				if (bb_in(3) = '0') and (bb_in(2) = '0') and (bb_in(1) = '0') and (bb_in(0) = '1') then
					CH1F <= true;
				end if;
				if (bb_in(3) = '0') and (bb_in(2) = '0') and (bb_in(1) = '1') and (bb_in(0) = '0') then
					CH2F <= true;
				end if;
				if (bb_in(3) = '0') and (bb_in(2) = '0') and (bb_in(1) = '1') and (bb_in(0) = '1') then
					CH3F <= true;
				end if;
				if (bb_in(3) = '0') and (bb_in(2) = '1') and (bb_in(1) = '0') and (bb_in(0) = '0') then
					CH4F <= true;
				end if;
				if (bb_in(3) = '0') and (bb_in(2) = '1') and (bb_in(1) = '0') and (bb_in(0) = '1') then
					CH5F <= true;
				end if;
				if (bb_in(3) = '0') and (bb_in(2) = '1') and (bb_in(1) = '1') and (bb_in(0) = '0') then
					CH6F <= true;
				end if;
				if (bb_in(3) = '0') and (bb_in(2) = '1') and (bb_in(1) = '1') and (bb_in(0) = '1') then
					CH7F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '0') and (bb_in(1) = '0') and (bb_in(0) = '0') then
					CH8F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '0') and (bb_in(1) = '0') and (bb_in(0) = '1') then
					CH9F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '0') and (bb_in(1) = '1') and (bb_in(0) = '0') then
					CH10F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '0') and (bb_in(1) = '1') and (bb_in(0) = '1') then
					CH11F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '1') and (bb_in(1) = '0') and (bb_in(0) = '0') then
					CH12F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '1') and (bb_in(1) = '0') and (bb_in(0) = '1') then
					CH13F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '1') and (bb_in(1) = '1') and (bb_in(0) = '0') then
					CH14F <= true;
				end if;
				if (bb_in(3) = '1') and (bb_in(2) = '1') and (bb_in(1) = '1') and (bb_in(0) = '1') then
					CH1F <= true;
				end if;
			end if;
		end if;
		
		state := next_state;
	end if;
end process;

Channel_One_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH1F),
			OUTPUT => CH1,
			RESET => RESET,
			CK => SCK);

Channel_Two_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH2F),
			OUTPUT => CH2,
			RESET => RESET,
			CK => SCK);
			
Channel_Three_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH3F),
			OUTPUT => CH3,
			RESET => RESET,
			CK => SCK);
			
Channel_Four_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH4F),
			OUTPUT => CH4,
			RESET => RESET,
			CK => SCK);
			
Channel_Five_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH5F),
			OUTPUT => CH5,
			RESET => RESET,
			CK => SCK);

Channel_Six_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH6F),
			OUTPUT => CH6,
			RESET => RESET,
			CK => SCK);

Channel_Seven_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH7F),
			OUTPUT => CH7,
			RESET => RESET,
			CK => SCK);

Channel_Eight_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH8F),
			OUTPUT => CH8,
			RESET => RESET,
			CK => SCK);

Channel_Nine_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH9F),
			OUTPUT => CH9,
			RESET => RESET,
			CK => SCK);

Channel_Ten_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH10F),
			OUTPUT => CH10,
			RESET => RESET,
			CK => SCK);

Channel_Eleven_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH11F),
			OUTPUT => CH11,
			RESET => RESET,
			CK => SCK);

Channel_Twelve_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH12F),
			OUTPUT => CH12,
			RESET => RESET,
			CK => SCK);

Channel_Thirteen_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH13F),
			OUTPUT => CH13,
			RESET => RESET,
			CK => SCK);

Channel_Fourteen_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH14F),
			OUTPUT => CH14,
			RESET => RESET,
			CK => SCK);

Channel_Fifteen_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH15F),
			OUTPUT => CH15,
			RESET => RESET,
			CK => SCK);

Baseboard_Reciever : process (DCK, RESET) is
variable state, next_state : integer range 0 to 48;
variable SSDO : std_logic;
begin
	if falling_edge (DCK) then
		SSDO := SDO;
	end if;
	if (RESET = '1') then
		state:=0;
		BBRCV <= false;
		bb_in <= "00000000";
	elsif rising_edge (DCK) then
		next_state := 0;
		BBRCV <= false;
		if (state = 0) and (SSDO = '1') then
			next_state := 1;
		end if;
		if (state > 0) and (state <48) then
			next_state := state + 1;
		end if;
		if (state >= 48) and (not BBRCNT) then
			next_state := 48;
			BBRCV <= true;
		elsif (state >= 48) and (BBRCNT) then
			next_state:=0;
		end if;
	
		case state is
			when 5 => bb_in(7) <= SSDO;
			when 9 => bb_in(6) <= SSDO;
			when 13 => bb_in(5) <= SSDO;
			when 17 => bb_in(4) <= SSDO;
			when 21 => bb_in(3) <= SSDO;
			when 25 => bb_in(2) <= SSDO;
			when 29 => bb_in(1) <= SSDO;
			when 33 => bb_in(0) <= SSDO;
			when others => bb_in <= bb_in;
		end case;
		state := next_state;
	end if;
	
	TP1 <= SSDO;
		
end process;


Baseboard_Transmitter : process (SCK,RESET,BBXMIT) is
variable state, next_state : integer range 0 to 12;
begin	
	if (RESET = '1') then
		state:=0;
	elsif rising_edge (SCK) then
		next_state := state;
		
		if (state = 0) and BBXMIT then 
			next_state := 1;
		end if;
		if (state > 0) and (state < 12) then
			next_state := state + 1;
		end if;
		if (state >= 12) and (not BBXMIT) then
			next_state := 0;
		end if;
		BBXDONE <= (state >=12);
		
		case state is
			when 0 => SDI <= '0';
			when 1 => SDI <= '0';
			when 2 => SDI <= '0';
			when 3 => SDI <= '1';
			when 4 => SDI <= bb_out(7);
			when 5 => SDI <= bb_out(6);
			when 6 => SDI <= bb_out(5);
			when 7 => SDI <= bb_out(4);
			when 8 => SDI <= bb_out(3);
			when 9 => SDI <= bb_out(2);
			when 10 => SDI <= bb_out(1);
			when 11 => SDI <= bb_out(0);
			when 12 => SDI <= '0';
		end case;
	
		state := next_state;
	end if;
	

	BBXDONE <= (state=12);
end process;





SHOWLED <= SHOW;

HIDELED <= HIDE;

CONFIGLED <= CONFIG;

RESETLED <= RESET;

	
-- Test Point Two appears on P1-3.
	TP2 <= SCK;
	
-- Test Point Three appears on P1-2.
	TP3 <= DCK;

-- Test Point Four appears on P1-8.
	TP4 <= SDO;
	
end behavior;