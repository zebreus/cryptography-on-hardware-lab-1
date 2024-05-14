
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Calculator is
  port
  (
    clk     : in std_logic;
    uart_rx : in std_logic;
    uart_tx : out std_logic);
end Calculator;

architecture Structural of Calculator is

  component uart is
    port
    (
      clk        : in std_logic;
      reset      : in std_logic;
      data_in    : in std_logic_vector(7 downto 0);
      tx_enable  : in std_logic;
      tx_idle    : out std_logic;
      tx_out     : out std_logic;
      data_out   : out std_logic_vector(7 downto 0);
      data_valid : out std_logic;
      rx_in      : in std_logic);
  end component;

  component CalculatorController is
    port
    (
      clk        : in std_logic;
      uart_reset : out std_logic;
      tx_enable  : out std_logic;
      tx_idle    : in std_logic;
      data_valid : in std_logic;
      data_in    : in std_logic_vector(7 downto 0);
      data_out   : out std_logic_vector(7 downto 0));
  end component;

  signal uart_data_tx : std_logic_vector(7 downto 0);
  signal uart_data_rx : std_logic_vector(7 downto 0);
  signal tx_enable    : std_logic;
  signal tx_idle      : std_logic;
  signal data_valid   : std_logic;
  signal uart_reset   : std_logic;

begin
  uart_instance : uart port map
  (
    clk        => clk,
    reset      => uart_reset,
    data_in    => uart_data_tx,
    tx_enable  => tx_enable,
    tx_idle    => tx_idle,
    tx_out     => uart_tx,
    data_out   => uart_data_rx,
    data_valid => data_valid,
    rx_in      => uart_rx
  );

  controller : CalculatorController port map (
    clk        => clk,
    uart_reset => uart_reset,
    tx_enable  => tx_enable,
    tx_idle    => tx_idle,
    data_valid => data_valid,
    data_in    => uart_data_rx,
    data_out   => uart_data_tx
  );
end Structural;