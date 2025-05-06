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
		LRST, -- Local RESET button
		DMERR -- Detector Module Error
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
		DMERRLED -- LED for DMERR light on Display Panel
		: out std_logic;
		SDI, -- Serial Data INTO the Baseboard
		SDO, -- Serial Data OUT of the Baseboard
		DMRST -- Detector Module Reset
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
	signal DCK : std_logic; -- Quadrouple Slow Clock
	signal TCK : std_logic; -- Tenth of Slow Clock
	signal RESET : std_logic; -- RESET from button on dispaly panel or signal from baseboard
	signal HIDEH : std_logic; -- Signal telling the board to hide all lights
	
-- Base Board Interface
	signal BBXMIT : boolean := false; -- Base Board Data Transmit 
	signal BBRCV : boolean := false; -- Base Board Data Received
	signal BBIR : boolean := false; -- Base Board Input Read
	signal bb_in, bb_out : std_logic_vector(7 downto 0);
	signal BBXDONE : boolean := false; -- Final bit in BBXMIT
	signal BBXDONES : std_logic; -- BBXDONE sustained
	signal BBRCNT : boolean := false; -- Baseboard Receiver Continue
	signal CH1F, CH2F, CH3F, CH4F, CH5F, CH6F, CH7F, CH8F, CH9F, 
		CH10F, CH11F, CH12F, CH13F, CH14F,CH15F, ACTF, 
		UPF, EMPF, CONF : boolean := false; --when to flash LEDs

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
constant divisor : integer := 80;
variable count : integer range 0 to 8191;
begin
	if rising_edge(CK) then
			if count = divisor - 1 then
				count := 0;
			else
				count := count + 1;
			end if;
		if count <= divisor / 2 then
			SCK <= '0';
		else
			SCK <= '1';
		end if;
	end if;
end process;


Double_Clock_Divider : process (CK) is
constant divisor : integer := 20;
variable count : integer range 0 to 8191;
begin
	if rising_edge(CK) then
			if count = divisor - 1 then
				count := 0;
			else
				count := count + 1;
			end if;
		if count <= divisor / 2 then
			DCK <= '0';
		else
			DCK <= '1';
		end if;
	end if;
end process;

Tenth_Clock_Divider : process (CK) is
constant divisor : integer := 800;
variable count : integer range 0 to 8191;
begin
	if rising_edge(CK) then
		if count = divisor - 1 then
				count := 0;
			else
				count := count + 1;
			end if;
		if count <= divisor / 2 then
			TCK <= '0';
		else
			TCK <= '1';
		end if;
	end if;
end process;

When_to_Hide : process (HIDE, RESET, TCK) is
variable state, next_state : integer range 0 to 40004;
variable SHIDE : std_logic;
begin
	if rising_edge(TCK) then
		SHIDE := HIDE;
	end if;
	if RESET = '1' then
		state := 0;
		HIDEH <= '0';
	elsif rising_edge(TCK) then
		if (state = 0) and (SHIDE = '1') then
			next_state := 1;
			HIDEH <= '1';
		elsif (state >= 1) and (state <10001) then
			next_state := state+1;
		elsif (state = 10001) and (SHIDE = '0') then
			next_state := 10002;
		elsif (state >= 10002) and (state <20002) then
			next_state := state +1;
		elsif (state = 20002) and (SHIDE = '0') then
			next_state := 20002;
			HIDEH <= '1';
		elsif (state = 20002) and (SHIDE = '1') then
			next_state := 20003;
			HIDEH <= '0';
		elsif (state >= 20003) and (state <30003) then
			next_state := state +1;
		elsif (state = 30003) and (SHIDE = '1') then
			next_state:= 30003;
			HIDEH <= '0';
		elsif (state = 30003) and (SHIDE = '0') then
			next_state:= 30004;
		elsif (state >= 30004) and (state <40004) then
			next_state := state +1;
		elsif (state = 40004) and (SHIDE = '0') then
			next_state := 0;
		end if;
		state := next_state;
	end if;
end process;

When_to_Reset : process (LRST, DMRST) is
begin
	if DMRST = '1' then
		RESET <= '1';
	else 
		RESET <= '0';
	end if;
	
	if LRST = '0' then
		DMRST <= '1';
	else
		DMRST <= 'Z';
	end if;

end process;

BBXDONE_Sustain : entity Turn_Off_Delay port map (
	INPUT => to_std_logic(BBXDONE),
	OUTPUT => BBXDONES,
	RESET => RESET,
	SHOW => '0',
	HIDE => '1',
	CK => TCK);

When_to_Transmit : process (SCK,BBXDONE,SHOW, CONFIG, HIDE, RESET) is
variable state, next_state : integer range 0 to 63;
begin	
	if (RESET = '1') then
		state := 0;
		BBXMIT <= false;
	elsif rising_edge (SCK) then
		next_state := state;
		
		if (state = 0) then
			next_state := 1;
		end if;
		if (state = 1) then
			BBXMIT <= true;
			if (BBXDONES = '1') then
				next_state := 2;
			else
				next_state := 1;
			end if;
		end if;
		if (state = 2) then
			BBXMIT <= true;
			if (BBXDONES ='1') then
				next_state := 2;
			else
				next_state := 0;
			end if;
		end if;
		
		if (SHOW = '1') then 
			bb_out(1) <= '1';
		else
			bb_out(1) <= '0';
		end if;
		if (CONFIG = '1') then
			bb_out(0) <= '1'; 
		else
			bb_out(0) <= '0';
		end if;
		if (HIDEH = '1') then
			bb_out(2) <= '1'; 
		else
			bb_out(2) <= '0';
		end if;
		
		bb_out(7) <= '0';
		bb_out(6) <= '1';
		bb_out(5) <= '1';
		bb_out(4) <= '0';
		bb_out(3) <= '0';

		state := next_state;
	end if;
end process;

Lamp_Controller : process (SCK, RESET) is
variable state, next_state : integer range 0 to 3;
variable opcode, operand : integer range 0 to 15;
constant mr_opcode : integer:= 1;
begin
	opcode:= to_integer(unsigned(bb_in(7 downto 4)));
	operand:= to_integer(unsigned(bb_in(3 downto 0)));
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
			if opcode = mr_opcode then
				if operand = 1 then
					CH1F <= true;
				end if;
				if operand = 2 then
					CH2F <= true;
				end if;
				if operand = 3 then
					CH3F <= true;
				end if;
				if operand = 4 then
					CH4F <= true;
				end if;
				if operand = 5 then
					CH5F <= true;
				end if;
				if operand = 6 then
					CH6F <= true;
				end if;
				if operand = 7 then
					CH7F <= true;
				end if;
				if operand = 8 then
					CH8F <= true;
				end if;
				if operand = 9 then
					CH9F <= true;
				end if;
				if operand = 10 then
					CH10F <= true;
				end if;
				if operand = 11 then
					CH11F <= true;
				end if;
				if operand = 12 then
					CH12F <= true;
				end if;
				if operand = 13 then
					CH13F <= true;
				end if;
				if operand = 14 then
					CH14F <= true;
				end if;
				if operand = 15 then
					CH15F <= true;
				end if;
			end if;
			
			if opcode = 2 then
				if bb_in(3) = '1' then
					CONF <= true;
				else
					CONF <= false;
				end if;
				if bb_in(2) = '1' then
					ACTF <= true;
				else
					ACTF <= false;
				end if;
				if bb_in(1) = '1' then
					UPF <= true;
				else
					UPF <= false;
				end if;
				if bb_in(0) = '1' then
					EMPF <= true;
				else
					EMPF <= false;
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
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Two_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH2F),
			OUTPUT => CH2,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);
			
Channel_Three_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH3F),
			OUTPUT => CH3,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);
			
Channel_Four_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH4F),
			OUTPUT => CH4,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);
			
Channel_Five_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH5F),
			OUTPUT => CH5,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Six_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH6F),
			OUTPUT => CH6,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Seven_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH7F),
			OUTPUT => CH7,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Eight_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH8F),
			OUTPUT => CH8,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Nine_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH9F),
			OUTPUT => CH9,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Ten_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH10F),
			OUTPUT => CH10,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Eleven_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH11F),
			OUTPUT => CH11,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Twelve_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH12F),
			OUTPUT => CH12,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Thirteen_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH13F),
			OUTPUT => CH13,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Fourteen_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH14F),
			OUTPUT => CH14,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Channel_Fifteen_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(CH15F),
			OUTPUT => CH15,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);

Active_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(ACTF),
			OUTPUT => ACTIV,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);
			
Upload_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(UPF),
			OUTPUT => UPLOAD,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
			CK => SCK);
			
Empty_LED : entity Turn_Off_Delay port map (
			INPUT => to_std_logic(EMPF),
			OUTPUT => EMPTY,
			RESET => RESET,
			SHOW => SHOW,
			HIDE => HIDEH,
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
		elsif (state >= 48) and (BBRCNT) and (SSDO = '0') then
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
end process;


Baseboard_Transmitter : process (SCK,RESET,BBXMIT) is
variable state, next_state : integer range 0 to 10000;
begin	
	if (RESET = '1') then
		state:=0;
	elsif rising_edge (SCK) then
		next_state := state;
		
		if (state = 0) and BBXMIT then 
			next_state := 1;
		end if;
		if (state > 0) and (state < 10000) then
			next_state := state + 1;
		end if;
		if (state >= 10000) and (BBXMIT) then
			next_state := 0;
		end if;
		BBXDONE <= (state >=10000);
		
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
			when others => SDI <= '0';
		end case;
	
		state := next_state;
	end if;
	

	BBXDONE <= (state=12);
end process;

Detector_Module_Error: process (DMERR, RESET, SHOW, HIDE) is
begin
	if ((DMERR = '1') or (RESET = '1') or (SHOW = '1')) and (HIDEH = '0') then
		DMERRLED <= '1';
	else
		DMERRLED <= '0';
	end if;
end process;

HIDELED <= HIDEH;
CONFIGLED <= CONFIG;
RESETLED <= RESET;
SHOWLED <= SHOW;

TP1 <= SCK;
TP2 <= SDO;
TP3 <= TCK;
TP4 <= SDI;
	
end behavior;