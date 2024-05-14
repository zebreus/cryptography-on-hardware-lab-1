library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity calculator_tb is
end calculator_tb;

architecture Behavioral of calculator_tb is
  constant frequency : integer := 12000000;
  constant period    : time    := 1 sec / frequency; -- Full period

  -- Procedure for clock generation
  procedure generate_clock(signal clk : out std_logic) is
  begin
    loop
      clk <= '1';
      wait for period / 2;
      clk <= '0';
      wait for period / 2;
    end loop;
  end procedure;

  procedure test_operation(
    signal data_to_dut       : out std_logic_vector(7 downto 0);
    signal tx_enable         : out std_logic;
    signal tx_idle           : in std_logic;
    signal data_from_dut     : in std_logic_vector(7 downto 0);
    signal data_valid        : in std_logic;
    constant operation       : std_logic_vector(7 downto 0);
    constant a               : unsigned(31 downto 0);
    constant b               : unsigned(31 downto 0);
    constant expected_result : unsigned(63 downto 0)
  ) is
    constant a_vec               : std_logic_vector(31 downto 0) := std_logic_vector(a);
    constant b_vec               : std_logic_vector(31 downto 0) := std_logic_vector(b);
    constant expected_result_vec : std_logic_vector(63 downto 0) := std_logic_vector(expected_result);
  begin

    data_to_dut <= operation;
    tx_enable   <= '1', '0' after period;

    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = operation) report "DUT did not reflect the command" severity FAILURE;

    -- Send a
    data_to_dut <= a_vec(31 downto 24);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    data_to_dut <= a_vec(23 downto 16);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    data_to_dut <= a_vec(15 downto 8);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    data_to_dut <= a_vec(7 downto 0);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    -- Send b
    data_to_dut <= b_vec(31 downto 24);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    data_to_dut <= b_vec(23 downto 16);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    data_to_dut <= b_vec(15 downto 8);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    data_to_dut <= b_vec(7 downto 0);
    tx_enable   <= '1', '0' after period;
    wait until rising_edge(tx_idle) for 2000000 ns;
    assert (tx_idle = '1') report "tx_idle is not ready" severity FAILURE;

    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(63 downto 56)) report "1st byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(55 downto 48)) report "2nd byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(47 downto 40)) report "3rd byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(39 downto 32)) report "4th byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(31 downto 24)) report "5th byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(23 downto 16)) report "6th byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(15 downto 8)) report "7th byte of the result is wrong" severity FAILURE;
    wait for period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = expected_result_vec(7 downto 0)) report "8th byte of the result is wrong" severity FAILURE;

  end procedure;

  component CMODA7Framework is
    port
    (
      CLK     : in std_logic;
      UART_RX : in std_logic;
      UART_TX : out std_logic);
  end component;

  -- The UART thing wants to be reset at the start, it will do goofy things otherwise
  component uart is
    port
    (
      CLK        : in std_logic;
      RESET      : in std_logic;
      DATA_IN    : in std_logic_vector(7 downto 0);
      TX_ENABLE  : in std_logic;
      TX_IDLE    : out std_logic;
      TX_OUT     : out std_logic;
      DATA_OUT   : out std_logic_vector(7 downto 0);
      DATA_VALID : out std_logic;
      RX_IN      : in std_logic);
  end component;

  -- Connections to dut
  signal clock   : std_logic;
  signal uart_rx : std_logic;
  signal uart_tx : std_logic;

  --UART inputs
  signal uart_reset  : std_logic;
  signal data_to_dut : std_logic_vector(7 downto 0);
  signal tx_enable   : std_logic;

  --UART outputs
  signal tx_idle       : std_logic;
  signal data_from_dut : std_logic_vector(7 downto 0);
  signal data_valid    : std_logic;

begin
  uart_device : uart port map
  (
    clk        => clock,
    reset      => uart_reset,
    data_in    => data_to_dut,
    tx_enable  => tx_enable,
    tx_idle    => tx_idle,
    tx_out     => uart_tx,
    data_out   => data_from_dut,
    data_valid => data_valid,
    rx_in      => uart_rx
  );

  dut : CMODA7Framework port
  map (clock, uart_tx, uart_rx);

  clock_proc : process
  begin
    generate_clock(clock);
    wait;
  end process;

  stim_proc : process
  begin
    uart_reset <= '1', '0' after period;
    wait for period;

    -- Test simple operations
    test_operation(data_to_dut, tx_enable, tx_idle, data_from_dut, data_valid, x"11", to_unsigned(4, 32), to_unsigned(4, 32), to_unsigned(8, 64));
    test_operation(data_to_dut, tx_enable, tx_idle, data_from_dut, data_valid, x"22", to_unsigned(4, 32), to_unsigned(4, 32), to_unsigned(16, 64));

    -- Test invalid operation
    data_to_dut <= x"53";
    tx_enable   <= '1', '0' after period;
    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = x"ff") report "DUT returned wrong code for invalid operation" severity FAILURE;

    -- Test some more complex operations after the invalid one
    test_operation(data_to_dut, tx_enable, tx_idle, data_from_dut, data_valid, x"11", x"FFFFFFA0", to_unsigned(800, 32), x"00000001000002C0");
    test_operation(data_to_dut, tx_enable, tx_idle, data_from_dut, data_valid, x"22", x"FFFFFFA0", to_unsigned(4234232, 32), x"00409BF7E7C58300");
    wait;

  end process;
end Behavioral;