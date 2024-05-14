library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

----------------------------------------------------------------------------------
entity MainControler is
  port
  (
    CLK : in std_logic;
    -- UART CONTROL -----------------------------------
    UART_RESET : out std_logic;
    TX_ENABLE  : out std_logic;
    TX_IDLE    : in std_logic;
    DATA_VALID : in std_logic;
    DATA_IN    : in std_logic_vector(7 downto 0);
    -- REGISTER CONTROL -------------------------------
    DATA_OUT : out std_logic_vector(7 downto 0));
end MainControler;
-- ARCHITECTURE: FSM
----------------------------------------------------------------------------------
architecture FSM of MainControler is

  -- STATES --------------------------------------------------------------------
  type STATES is (S_RESET, S_IDLE, S_RECEIVE_OPERATION, S_RECEIVE_DATA, S_PROCESS, S_SEND_DATA);
  type OPERATIONS is (O_ADD, O_MULTIPLY);
  signal CURRENT_STATE, NEXT_STATE : STATES := S_RESET;

  signal operation       : OPERATIONS                    := O_ADD;
  signal byte_count      : integer range 0 to 7          := 0;
  signal received_data   : std_logic_vector(63 downto 0) := (others => '0');
begin

  -- STATE REGISTER PROCESS ----------------------------------------------------
  StateRegister : process (CLK)
  begin
    if RISING_EDGE(CLK) then
      CURRENT_STATE <= NEXT_STATE;
    end if;
  end process;
  ------------------------------------------------------------------------------

  -- OUTPUT SIGNALS AND STATE TRANSITION PROCESS -------------------------------
  OutputAndTransition : process (CURRENT_STATE, DATA_VALID, TX_IDLE)
  begin
    -- DEFAULT ASSIGNMENTS  --------------------------------------------------
    DATA_OUT <= x"00";

    UART_RESET <= '0';
    TX_ENABLE  <= '0';

    NEXT_STATE <= CURRENT_STATE;
    --------------------------------------------------------------------------

    -- CASE EVALUATION -------------------------------------------------------
    case CURRENT_STATE is
        ----------------------------------------------------------------------
      when S_RESET => UART_RESET <= '1';
        NEXT_STATE                 <= S_IDLE;
        ----------------------------------------------------------------------
      when S_IDLE => NEXT_STATE <= S_RECEIVE_OPERATION;
        ----------------------------------------------------------------------
      when S_RECEIVE_OPERATION => if (DATA_VALID = '1') then
        TX_ENABLE <= '1';
        if (DATA_IN = x"11") then
          DATA_OUT   <= x"11";
          operation  <= O_ADD;
          NEXT_STATE <= S_RECEIVE_DATA;
        elsif (DATA_IN = x"22") then
          DATA_OUT   <= x"22";
          operation  <= O_MULTIPLY;
          NEXT_STATE <= S_RECEIVE_DATA;
        else
          DATA_OUT   <= x"ff";
          NEXT_STATE <= S_IDLE;
        end if;
    end if;
    ----------------------------------------------------------------------
    when S_RECEIVE_DATA =>
    if (DATA_VALID = '1') then
      case byte_count is
        when 0 =>
          received_data(31 downto 24) <= DATA_IN;
          byte_count                  <= 1;
        when 1 =>
          received_data(23 downto 16) <= DATA_IN;
          byte_count                  <= 2;
        when 2 =>
          received_data(15 downto 8) <= DATA_IN;
          byte_count                 <= 3;
        when 3 =>
          received_data(7 downto 0) <= DATA_IN;
          byte_count                <= 4;
        when 4 =>
          received_data(63 downto 56) <= DATA_IN;
          byte_count                  <= 5;
        when 5 =>
          received_data(55 downto 48) <= DATA_IN;
          byte_count                  <= 6;
        when 6 =>
          received_data(47 downto 40) <= DATA_IN;
          byte_count                  <= 7;
        when 7 =>
          received_data(39 downto 32) <= DATA_IN;
          byte_count                  <= 0;
          NEXT_STATE                  <= S_PROCESS;
      end case;
    end if;
    ----------------------------------------------------------------------
    when S_PROCESS =>
    case operation is
      when O_ADD =>
        received_data <= std_logic_vector(unsigned(x"00000000" & received_data(31 downto 0)) + unsigned(x"00000000" & received_data(63 downto 32)));
      when O_MULTIPLY =>
        received_data <= std_logic_vector(unsigned(received_data(31 downto 0)) * unsigned(received_data(63 downto 32)));
    end case;
    NEXT_STATE <= S_SEND_DATA;

    ----------------------------------------------------------------------
    when S_SEND_DATA =>
    TX_ENABLE <= '0';
    if (TX_IDLE = '1') then
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
          NEXT_STATE <= S_IDLE;
      end case;
    end if;
    --------------------------------------------------------------------------
  end case;

end process;
------------------------------------------------------------------------------
end FSM;