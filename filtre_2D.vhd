----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2025 12:58:02
-- Design Name: 
-- Module Name: filtre_2D - Behavioral
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

entity filtre_2D is
  port(
    clk, rst        : in  std_logic;
    fenetre_valide  : in  std_logic;
    p00, p01, p02   : in  std_logic_vector(7 downto 0);
    p10, p11, p12   : in  std_logic_vector(7 downto 0);
    p20, p21, p22   : in  std_logic_vector(7 downto 0);
    
    pixel_sortie    : out std_logic_vector(7 downto 0)
  );
end filtre_2D;

architecture Behavioral of filtre_2D is
  signal t11, t12, t13, t14 : integer;
  signal t21, t22 : integer;
  signal t31 : integer;

  -- gestion du vidage du pipeline
  signal fen_prev  : std_logic := '0';
  signal flush_cnt : integer range 0 to 3 := 0;

begin

  process(clk, rst)
  begin
    if rst = '1' then
      t11 <= 0;
      t12 <= 0;
      t13 <= 0;
      t14 <= 0;
      t21 <= 0;
      t22 <= 0;
      t31 <= 0;
      pixel_sortie <= (others => '0');
      fen_prev <= '0';
      flush_cnt <= 0;

    elsif rising_edge(clk) then

      -- détection de la fin de fenetre_valide
      if (fen_prev = '1' and fenetre_valide = '0') then
        flush_cnt <= 3;                 -- 3 cycles pour vider le pipeline
      elsif flush_cnt > 0 then
        flush_cnt <= flush_cnt - 1;
      end if;

      fen_prev <= fenetre_valide;

      -- calcul pipeline
      t11 <= to_integer(unsigned(p00)) + 2*to_integer(unsigned(p01));
      t12 <= to_integer(unsigned(p02)) + 2*to_integer(unsigned(p10));
      t13 <= to_integer(unsigned(p12)) + 2*to_integer(unsigned(p20));
      t14 <= to_integer(unsigned(p21)) + 2*to_integer(unsigned(p22));     

      t21 <= t11 + t12;
      t22 <= t13 + t14;

      -- sortie autorisée pendant fenetre_valide OU vidage
      if (fenetre_valide = '1' or flush_cnt > 0) then
        t31 <= (t21 + t22)/16;
        pixel_sortie <= std_logic_vector(to_unsigned(t31, 8));
      end if;

    end if;
  end process;

end Behavioral;
