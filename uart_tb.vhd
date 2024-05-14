library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity demo_tb is
end demo_tb;

architecture Behavioral of demo_tb is
  constant frequency : integer := 12000000;
  constant period    : time    := 1 sec / frequency; -- Full period

  -- Procedure for clock generation
  procedure generate_clock_for_cycles(signal clk : out std_logic; constant CYCLES : integer) is
  begin

    -- Generate a clock cycle
    for i in 0 to CYCLES loop
      clk <= '1';
      wait for period / 2;
      clk <= '0';
      wait for period / 2;
    end loop;
  end procedure;

  -- Procedure for clock generation
  procedure generate_clock_for_time(signal clk : out std_logic; constant NANOS : time) is
    constant CYCLES : integer := NANOS / period;
  begin

    -- Generate a clock cycle
    for i in 0 to CYCLES loop
      clk <= '1';
      wait for period / 2;
      clk <= '0';
      wait for period / 2;
    end loop;
  end procedure;

  -- Procedure for clock generation
  procedure wait_cycles(constant CYCLES : integer) is
  begin
    wait for period * CYCLES;
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
    generate_clock_for_time(clock, 2000000 ns);
    wait;
  end process;

  stim_proc : process
  begin
    data_to_dut <= "10101111";
    uart_reset  <= '1', '0' after period;
    tx_enable   <= '1' after period, '0' after period * 2;

    wait until data_valid = '1' for 2000000 ns;
    assert (data_from_dut = "10101111") report "data_from_dut: Not the expected value" severity FAILURE;

    wait;

  end process;
end Behavioral;