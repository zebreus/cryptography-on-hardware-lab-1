library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity CalculatorController is
  port
  (
    clk        : in std_logic;
    uart_reset : out std_logic;
    tx_enable  : out std_logic;
    tx_idle    : in std_logic;
    data_valid : in std_logic;
    data_in    : in std_logic_vector(7 downto 0);
    data_out   : out std_logic_vector(7 downto 0));
end CalculatorController;

architecture FSM of CalculatorController is
  type states is (S_RESET, S_IDLE, S_RECEIVE_OPERATION, S_RECEIVE_DATA, S_PROCESS, S_SEND_DATA);
  type operations is (O_ADD, O_MULTIPLY);
  signal current_state, next_state : states := S_RESET;

  signal operation     : OPERATIONS                    := O_ADD;
  signal byte_count    : integer range 0 to 7          := 0;
  signal received_data : std_logic_vector(63 downto 0) := (others => '0');
begin

  advance_state : process (clk) begin
    if rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  transition : process (current_state, data_valid, tx_idle) begin
    data_out   <= x"00";
    uart_reset <= '0';
    tx_enable  <= '0';
    next_state <= current_state;

    case current_state is
      when S_RESET =>
        UART_RESET <= '1';
        next_state <= S_IDLE;
      when S_IDLE =>
        next_state <= S_RECEIVE_OPERATION;
      when S_RECEIVE_OPERATION =>
        if (data_valid = '1') then
          tx_enable <= '1';
          if (data_in = x"11") then
            data_out   <= x"11";
            operation  <= O_ADD;
            next_state <= S_RECEIVE_DATA;
          elsif (data_in = x"22") then
            data_out   <= x"22";
            operation  <= O_MULTIPLY;
            next_state <= S_RECEIVE_DATA;
          else
            data_out   <= x"ff";
            next_state <= S_IDLE;
          end if;
        end if;
      when S_RECEIVE_DATA =>
        if (data_valid = '1') then
          case byte_count is
            when 0 =>
              received_data(31 downto 24) <= data_in;
              byte_count                  <= 1;
            when 1 =>
              received_data(23 downto 16) <= data_in;
              byte_count                  <= 2;
            when 2 =>
              received_data(15 downto 8) <= data_in;
              byte_count                 <= 3;
            when 3 =>
              received_data(7 downto 0) <= data_in;
              byte_count                <= 4;
            when 4 =>
              received_data(63 downto 56) <= data_in;
              byte_count                  <= 5;
            when 5 =>
              received_data(55 downto 48) <= data_in;
              byte_count                  <= 6;
            when 6 =>
              received_data(47 downto 40) <= data_in;
              byte_count                  <= 7;
            when 7 =>
              received_data(39 downto 32) <= data_in;
              byte_count                  <= 0;
              next_state                  <= S_PROCESS;
          end case;
        end if;
      when S_PROCESS =>
        case operation is
          when O_ADD =>
            received_data <= std_logic_vector(unsigned(x"00000000" & received_data(31 downto 0)) + unsigned(x"00000000" & received_data(63 downto 32)));
          when O_MULTIPLY =>
            received_data <= std_logic_vector(unsigned(received_data(31 downto 0)) * unsigned(received_data(63 downto 32)));
        end case;
        next_state <= S_SEND_DATA;
      when S_SEND_DATA =>
        tx_enable <= '0';
        if (tx_idle = '1') then
          case byte_count is
            when 0 =>
              data_out   <= received_data(63 downto 56);
              tx_enable  <= '1';
              byte_count <= 1;
            when 1 =>
              data_out   <= received_data(55 downto 48);
              tx_enable  <= '1';
              byte_count <= 2;
            when 2 =>
              data_out   <= received_data(47 downto 40);
              tx_enable  <= '1';
              byte_count <= 3;
            when 3 =>
              data_out   <= received_data(39 downto 32);
              tx_enable  <= '1';
              byte_count <= 4;
            when 4 =>
              data_out   <= received_data(31 downto 24);
              tx_enable  <= '1';
              byte_count <= 5;
            when 5 =>
              data_out   <= received_data(23 downto 16);
              tx_enable  <= '1';
              byte_count <= 6;
            when 6 =>
              data_out   <= received_data(15 downto 8);
              tx_enable  <= '1';
              byte_count <= 7;
            when 7 =>
              data_out   <= received_data(7 downto 0);
              tx_enable  <= '1';
              byte_count <= 0;
              next_state <= S_IDLE;
          end case;
        end if;
    end case;
  end process;
end FSM;