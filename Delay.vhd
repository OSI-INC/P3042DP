-- Turn_Off_Delay Entity, turns on LEDs for a certain period of time
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Turn_Off_Delay is
	port (
			OUTPUT : out std_logic;
			CK, RESET, INPUT, SHOW, HIDE : in std_logic
		);
	constant max_count : integer := 1023;
end;

architecture behavior of Turn_Off_Delay is
begin
Sustain: process (RESET, CK, SHOW) is
	variable count, next_count : integer range 0 to max_count;
	begin
		if HIDE = '1' then
			count := max_count;
		end if;
		if ((RESET = '1') or (INPUT = '1') or (SHOW = '1')) and (HIDE = '0') then
			OUTPUT <= '1';
			count := 0;
		elsif rising_edge(CK) then
			next_count := count;
			if count< max_count then
				next_count := next_count+1;
			else
				next_count:= max_count;
			end if;	
			if count < max_count then
				OUTPUT <= '1';
			else
				OUTPUT <= '0';
			end if;
			count := next_count;
		end if;
	end process;
end behavior;