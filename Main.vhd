-- <pre> Telemetry Control Box (TCB) Display Panel (A3042DP) Firmware, Toplevel Unit

-- V1.1 [24-AUG-22] Starting point for development. Defines inputs and outputs.

library ieee;  
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is 
	port (
		CK -- Clock
		: in std_logic; 
		TP1, -- Test Point One (TMS)
		TP2, -- Test Point Two (TDI)
		TP3, -- Test Point Three (TDO)
		TP4  -- Test Point Four (TCK)
		: out std_logic
	);
end;

architecture behavior of main is

begin

-- Test Point One appears on P1-6.
	TP1 <= CK;
	
-- Test Point Two appears on P1-3.
	TP2 <= '1';
	
-- Test Point Three appears on P1-2.
	TP3 <= '0';

-- Test Point Four appears on P1-8.
	TP4 <= 'Z';
	
end behavior;