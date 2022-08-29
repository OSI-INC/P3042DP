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
		RESET -- RESET button
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
		: out std_logic
	);
end;

architecture behavior of main is

-- Convert boolean to standar logic. We return '1' for 'true' and '0'
-- for 'false'.
	function to_std_logic (v: boolean) return std_ulogic is
	begin if v then return('1'); else return('0'); end if; end function;

-- Signals.
	signal SCK : std_logic; -- Slow Clock

begin

CH1_Generator : process (SHOW) is
begin
	if SHOW = '1' then
		CH1 <= '1';
	else
		CH1 <= '0';
	end if;
end process;

CH2_Generator : process (CONFIG) is
begin
	if CONFIG = '1' then
		CH2 <= '1';
	else
		CH2 <= '0';
	end if;
end process;

CH3_Generator : process (CONFIG) is
begin
	if CONFIG = '1' then
		CH3 <= '1';
	else
		CH3 <= '0';
	end if;
end process;

CH4_Generator : process (RESET) is
begin
	if RESET = '1' then
		CH4 <= '1';
	else
		CH4 <= '0';
	end if;
end process;

CH5 <= to_std_logic((HIDE = '1') and (SHOW = '1'));

CH6 <= to_std_logic((CONFIG = '1') and (RESET = '0'));

CH7 <= to_std_logic((SHOW = '1') and (CONFIG = '1'));

CH8 <= to_std_logic((HIDE = '1') and (RESET = '0'));

CH9 <= to_std_logic((HIDE = '1') and (SHOW = '1') and (CONFIG = '1') and (RESET = '0'));

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
	constant divisor : integer := 8000;
	
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

-- We are going to make lamps CH10 to CH15 flash with a pattern. We define
-- a local variable that is a register of bits as opposed to an integer.
Lamp_Controller : process (SCK) is
	variable count : std_logic_vector(13 downto 0);
begin

	-- Here we convert the register of bits to an integer, add one, and
	-- convert back into a register of bits. These type conversions are
	-- a feature of VHDL that make the code verbose, but also help us
	-- find errors.
	if rising_edge(SCK) then
		count := std_logic_vector(unsigned(count)+1);	end if;
	
	-- Because count is a register of std_logic bits, we can assign the
	-- available lamp outputs to individual bits. We can put this logic
	-- inside the "if rising edge" statement or outside. The difference
	-- in the compiled code can be significant, but in this case there 
	-- will be no difference.
	CH15 <= count(13);
	CH14 <= count(12);
	CH13 <= count(11);
	CH12 <= count(10);
	CH11 <= count(9);
	CH10 <= count(8);
end process;

UPLOAD <= to_std_logic((HIDE = '1') and (SHOW = '1') and (CONFIG = '1') and (RESET = '1'));

EMPTY <= to_std_logic((HIDE = '0') and (SHOW = '0') and (CONFIG = '0') and (RESET = '0'));

ACTIV <= to_std_logic((HIDE = '1') or (SHOW = '1'));

DMERR <= to_std_logic((CONFIG = '1') or (RESET = '0'));

SHOWLED <= SHOW;

HIDELED <= HIDE;

CONFIGLED <= CONFIG;

RESETLED <= RESET;

-- Test Point One appears on P1-6.
	TP1 <= CK;
	
-- Test Point Two appears on P1-3.
	TP2 <= '1';
	
-- Test Point Three appears on P1-2.
	TP3 <= '0';

-- Test Point Four appears on P1-8.
	TP4 <= 'Z';
	
end behavior;