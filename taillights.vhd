library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity taillights is
  port
  (
    clock  : in std_logic;
    left   : in std_logic;
    right  : in std_logic;
    hazard : in std_logic;
    lights : out std_logic_vector(5 downto 0) := "000000"
  );
end taillights;

architecture Behavioral of taillights is
  type STATE_TYPE is
  (STATE_OFF, STATE_LEFT_A, STATE_LEFT_B, STATE_LEFT_C, STATE_RIGHT_A, STATE_RIGHT_B, STATE_RIGHT_C, STATE_FULL);
  signal state : STATE_TYPE := STATE_OFF;
begin
  process (clock) begin
    if rising_edge(clock) then
      if hazard = '1' or (left = '1' and right = '1') then
        case state is
          when STATE_FULL =>
            state <= STATE_OFF;
          when others =>
            state <= STATE_FULL;
        end case;
      elsif left = '1' then
        case state is
          when STATE_LEFT_A =>
            state <= STATE_LEFT_B;
          when STATE_LEFT_B =>
            state <= STATE_LEFT_C;
          when STATE_LEFT_C =>
            state <= STATE_OFF;
          when others =>
            state <= STATE_LEFT_A;
        end case;
      elsif right = '1' then
        case state is
          when STATE_RIGHT_A =>
            state <= STATE_RIGHT_B;
          when STATE_RIGHT_B =>
            state <= STATE_RIGHT_C;
          when STATE_RIGHT_C =>
            state <= STATE_OFF;
          when others =>
            state <= STATE_RIGHT_A;
        end case;
      else
        state <= STATE_OFF;
      end if;
    end if;
  end process;
  process (state) begin
    case state is
      when STATE_LEFT_A =>
        lights <= "001000";
      when STATE_LEFT_B =>
        lights <= "011000";
      when STATE_LEFT_C =>
        lights <= "111000";
      when STATE_RIGHT_A =>
        lights <= "000100";
      when STATE_RIGHT_B =>
        lights <= "000110";
      when STATE_RIGHT_C =>
        lights <= "000111";
      when STATE_FULL =>
        lights <= "111111";
      when others =>
        lights <= "000000";
    end case;
  end process;
end Behavioral;