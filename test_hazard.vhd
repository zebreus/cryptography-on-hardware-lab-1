----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2024 01:25:56 PM
-- Design Name: 
-- Module Name: test_hazard - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_hazard is
end test_hazard;

architecture Behavioral of test_hazard is
    COMPONENT taillights
      Port ( 
           clock: in std_logic;
           left : in std_logic;
           right : in std_logic;
           hazard : in std_logic;
           lights : out std_logic_vector(5 downto 0)
           );
    END COMPONENT;


    --Inputs
    signal clock : std_logic := '0';    
    signal left : std_logic := '0';
    signal right : std_logic := '0';
    signal hazard : std_logic := '0';

 	--Outputs
    signal lights : std_logic_vector(5 downto 0);
begin


   dut: taillights PORT MAP (clock, left,right,hazard,lights);
   
   -- Stimulus process
   stim_proc: process
   begin 
        hazard <= '0';
        clock <= '1';
        wait for 50 ns;
        assert lights = "000000" severity failure;
        clock <= '0';
        wait for 50 ns;
        assert lights = "000000" severity failure;
        clock <= '1';
        wait for 50 ns;
        assert lights = "000000" severity failure;
        clock <= '0';
        wait for 50 ns;
        assert lights = "000000" severity failure;
        hazard <= '1';
        clock <= '1';
        wait for 50 ns;
        assert lights = "111111" severity failure;
        clock <= '0';
        wait for 50 ns;
        assert lights = "111111" severity failure;
        clock <= '1';
        wait for 50 ns;
        assert lights = "000000" severity failure;
        clock <= '0';
        wait for 50 ns;
        assert lights = "000000" severity failure;
        clock <= '1';
        wait for 50 ns;
        assert lights = "111111" severity failure;
        clock <= '0';
        wait for 50 ns;
        assert lights = "111111" severity failure;
        clock <= '1';
        wait for 50 ns;
        wait for 1000 ns;
        
--        assert left_lights = "000" severity failure;
--        assert right_lights = "000" severity failure;
        
--		hazard <= '1';
--		assert left_lights = "111" severity failure;
--		wait for 100 ns;
--		hazard <= '0';
		
--	    wait for 100 ns;
--		hazard <= '1';
--		 wait for 100 ns;
--		hazard <= '0';


   end process;

end Behavioral;
