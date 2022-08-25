-- <pre> Telemetry Control Box (TCB) Display Panel (A3042DP) Firmware, Toplevel Unit

-- V1.1 [24-AUG-22] Starting point for development. Defines inputs and outputs.

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

begin

CH1 <= '1';

CH2 <= '1';

CH3 <= '1';

CH4 <= '1';

CH5 <= '1';

CH6 <= '1';

CH7 <= '1';

CH8 <= '1';

CH9 <= '1';

CH10 <= '1';

CH11 <= '1';

CH12 <= '1';

CH13 <= '1';

CH14 <= '1';

CH15 <= '1';

UPLOAD <= '1';

EMPTY <= '1';

ACTIV <= '1';

DMERR <= '1';

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