-- <pre> Telemetry Control Box (TCB) Display Panel (A3042DP) Firmware, Toplevel Unit

-- V1.1 [24-AUG-22] Starting point for development. Defines inputs and outputs.

-- V2.1 [25-AUG-22] All lamps and swithes connected and tested.

-- V2.2 [25-AUG-22] Adding combinatorial logic to permit lighting patterns controlled
-- by switches. Add to_std_logic function.

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

-- to_sdt_logic is a function that takes a boolean variable and returns
-- a variable of type std_ulogic, which is compatible with std_logic as
-- well. Examples of its use in code below.
	function to_std_logic (v: boolean) return std_ulogic is
	begin if v then return('1'); else return('0'); end if; end function;

begin

-- Standard logic inputs can take values 0 and 1 for logic LO and HI -- respectively. But they can also assume values Z for high-impedance
-- L for weak pull-down, H for weak pull-up, and a few other values.
-- So it's not clear what the logical AND operator will do when given
-- two std_logic inputs. Here's the simplest way to perform combinatorial
-- logic on std_logic signals. We compare the signal to one of its
-- possible values, and in so doing generate a boolean result TRUE or
-- FALSE. We apply boolean operators to the boolean values thus 
-- generated, obtain a boolean result, and convert it into a std_logic
-- value '0' if false, '1' if true.
CH1_Generator : process (SHOW) is
begin
	if SHOW = '1' then
		CH1 <= '1';
	else
		CH1 <= '0';
	end if;
end process;

CH2_Generator : process (HIDE) is
begin
	if HIDE = '1' then
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


-- Another way to deal with std_logic is to create a "process". Within
-- a process we are allowed to use "if then else end if". In the 
-- declaration of the process we must name at least one signal that
-- acts as an input to the calculation. You might think we should list
-- all signals that act as inputs, but the compiler won't give you an
-- error if you fail to list them all. In this example, there is only
-- one input: CONFIG. You might ask why we can't use "if" statements
-- outside of a process. It's a question. I don't know the answer.

CH5 <= to_std_logic((HIDE = '1') and (SHOW = '1'));

CH6 <= to_std_logic((CONFIG = '1') and (RESET = '0'));

CH7 <= to_std_logic((SHOW = '1') and (CONFIG = '1'));

CH8 <= to_std_logic((HIDE = '1') and (RESET = '0'));

CH9 <= to_std_logic((HIDE = '1') and (SHOW = '1') and (CONFIG = '1') and (RESET = '0'));

CH10_Generator : process (SHOW) is
begin
	if SHOW = '1' then
		CH10 <= '0';
	else
		CH10 <= '1';
	end if;
end process;

CH11_Generator : process (HIDE) is
begin
	if HIDE = '1' then
		CH11 <= '0';
	else
		CH11 <= '1';
	end if;
end process;

CH12_Generator : process (CONFIG) is
begin
	if CONFIG = '1' then
		CH12 <= '0';
	else
		CH12 <= '1';
	end if;
end process;

CH13_Generator : process (RESET) is
begin
	if RESET = '1' then
		CH13 <= '0';
	else
		CH13 <= '1';
	end if;
end process;

CH14 <= to_std_logic((HIDE = '1') and (CONFIG = '1'));

CH15 <= to_std_logic((RESET = '0') and (SHOW = '1'));

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