----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2025 09:15:18
-- Design Name: 
-- Module Name: fifo_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is

  constant TCLK : time := 10 ns;

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  signal din   : std_logic_vector(7 downto 0) := (others => '0');
  signal wr_en : std_logic := '0';
  signal rd_en : std_logic := '0';
  signal dout  : std_logic_vector(7 downto 0);

  signal full, empty, prog_full : std_logic;
  signal wr_rst_busy, rd_rst_busy : std_logic;

  signal prog_full_thresh : std_logic_vector(9 downto 0) := (others => '0');

  component fifo_generator_1 is
    port (
      clk : in std_logic;
      rst : in std_logic;
      din : in std_logic_vector(7 downto 0);
      wr_en : in std_logic;
      rd_en : in std_logic;
      prog_full_thresh : in std_logic_vector(9 downto 0);
      dout : out std_logic_vector(7 downto 0);
      full : out std_logic;
      empty : out std_logic;
      prog_full : out std_logic;
      wr_rst_busy : out std_logic;
      rd_rst_busy : out std_logic
    );
  end component;

begin

  clk <= not clk after TCLK/2;

  -- petit seuil de prog_full (juste pour voir le flag bouger en TB)
  -- (tu peux mettre 10, 16, 32... comme tu veux)
  prog_full_thresh <= std_logic_vector(to_unsigned(16, 10));

  uut: fifo_generator_1
    port map(
      clk => clk,
      rst => rst,
      din => din,
      wr_en => wr_en,
      rd_en => rd_en,
      prog_full_thresh => prog_full_thresh,
      dout => dout,
      full => full,
      empty => empty,
      prog_full => prog_full,
      wr_rst_busy => wr_rst_busy,
      rd_rst_busy => rd_rst_busy
    );

  stim: process
  begin
    -- =========================
    -- 1) RESET
    -- =========================
    rst <= '1';
    wr_en <= '0';
    rd_en <= '0';
    din <= x"00";
    wait for 300 ns;

    rst <= '0';

    -- attendre que l'IP soit prête
    wait until rising_edge(clk);
    while (wr_rst_busy = '1' or rd_rst_busy = '1') loop
      wait until rising_edge(clk);
    end loop;

    -- =========================
    -- 2) ECRITURE SEULE (0 -> 19)
    -- =========================
    for i in 0 to 19 loop
      wait until rising_edge(clk);

      rd_en <= '0';
      wr_en <= '0';

      din <= std_logic_vector(to_unsigned(i, 8));
      if full = '0' then
        wr_en <= '1';
      end if;
    end loop;

    -- stop écriture
    wait until rising_edge(clk);
    wr_en <= '0';
    din <= x"00";

    -- =========================
    -- 3) LECTURE SEULE (lire 8 valeurs)
    -- =========================
    for k in 0 to 7 loop
      wait until rising_edge(clk);

      wr_en <= '0';
      rd_en <= '0';

      if empty = '0' then
        rd_en <= '1';
      end if;
    end loop;

    -- stop lecture
    wait until rising_edge(clk);
    rd_en <= '0';

    -- =========================
    -- 4) LECTURE + ECRITURE EN MEME TEMPS
    --    écrire 20 -> 35 tout en lisant
    -- =========================
    for i in 20 to 35 loop
      wait until rising_edge(clk);

      -- par défaut
      wr_en <= '0';
      rd_en <= '0';

      -- écrire si possible
      din <= std_logic_vector(to_unsigned(i, 8));
      if full = '0' then
        wr_en <= '1';
      end if;

      -- lire si possible
      if empty = '0' then
        rd_en <= '1';
      end if;
    end loop;

    -- stop écriture
    wait until rising_edge(clk);
    wr_en <= '0';
    din <= x"00";

    -- =========================
    -- 5) VIDER LA FIFO (lecture jusqu'à empty)
    -- =========================
    while empty = '0' loop
      wait until rising_edge(clk);

      wr_en <= '0';
      rd_en <= '0';

      if empty = '0' then
        rd_en <= '1';
      end if;
    end loop;

    -- quand empty=1, on coupe rd_en
    wait until rising_edge(clk);
    rd_en <= '0';

    -- =========================
    -- 6) REDEMARRAGE : réécrire quelques valeurs puis relire
    -- =========================
    for i in 50 to 55 loop
      wait until rising_edge(clk);

      rd_en <= '0';
      wr_en <= '0';

      din <= std_logic_vector(to_unsigned(i, 8));
      if full = '0' then
        wr_en <= '1';
      end if;
    end loop;

    -- relire 6 valeurs
    for k in 0 to 5 loop
      wait until rising_edge(clk);

      wr_en <= '0';
      rd_en <= '0';

      if empty = '0' then
        rd_en <= '1';
      end if;
    end loop;

    -- fin
    wait until rising_edge(clk);
    wr_en <= '0';
    rd_en <= '0';
    din <= x"00";

    wait for 100 ns;
    wait;
  end process;

end Behavioral;
