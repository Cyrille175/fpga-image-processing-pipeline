----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2025 10:29:44
-- Design Name: 
-- Module Name: filtre_flou - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
-- Module Name: filtre_flou - Behavioral
-- Description: Filtre flou calculant la moyenne des 8 pixels voisins
--              Utilise une machine à états pour effectuer les additions
----------------------------------------------------------------------------------

entity filtre_flou is
  port(
    clk, rst        : in  std_logic;
    fenetre_valide  : in  std_logic;
    p00, p01, p02   : in  std_logic_vector(7 downto 0);
    p10, p11, p12   : in  std_logic_vector(7 downto 0);
    p20, p21, p22   : in  std_logic_vector(7 downto 0);
    
    pixel_sortie    : out std_logic_vector(7 downto 0)
  );
end filtre_flou;

architecture Behavioral of filtre_flou is

  signal t11, t12, t13, t14 : unsigned(8 downto 0);
  signal t21, t22 : unsigned(9 downto 0);
  signal t31 : unsigned(10 downto 0);

  signal fen_prev : std_logic := '0';
  signal flush_cnt : integer := 0;

begin

  process(clk, rst)
  begin
    if rst = '1' then
      t11 <= (others => '0');
      t12 <= (others => '0');
      t13 <= (others => '0');
      t14 <= (others => '0');
      t21 <= (others => '0');
      t22 <= (others => '0');
      t31 <= (others => '0');
      pixel_sortie <= (others => '0');

      fen_prev <= '0';
      flush_cnt <= 0;

    elsif rising_edge(clk) then

      if (fen_prev = '1' and fenetre_valide = '0') then
        flush_cnt <= 3;
      elsif flush_cnt > 0 and fenetre_valide = '0' then
        flush_cnt <= flush_cnt - 1;
      end if;

      fen_prev <= fenetre_valide;

      t11 <= resize(unsigned(p00), 9) + resize(unsigned(p01), 9);
      t12 <= resize(unsigned(p02), 9) + resize(unsigned(p10), 9);
      t13 <= resize(unsigned(p12), 9) + resize(unsigned(p20), 9);
      t14 <= resize(unsigned(p21), 9) + resize(unsigned(p22), 9);

      t21 <= resize(t11, 10) + resize(t12, 10);
      t22 <= resize(t13, 10) + resize(t14, 10);
      
      if fenetre_valide = '1' or flush_cnt > 0 then
        t31 <= resize(t21, 11) + resize(t22, 11);
        pixel_sortie <= std_logic_vector(t31(10 downto 3));
      end if;

    end if;
  end process;


end Behavioral;