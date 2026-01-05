----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2025 10:38:20
-- Design Name: 
-- Module Name: tb_image_flou - Behavioral
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

----------------------------------------------------------------------------------
-- Module Name: tb_filtre_flou_lena - Behavioral
-- Description: Testbench complet mémoire cache + filtre flou
--              Lit Lena, applique le flou, écrit l'image floutée
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_filtre_flou_lena is
end tb_filtre_flou_lena;

architecture Behavioral of tb_filtre_flou_lena is

  component memoire_cache is
    generic(
      LARGEUR_IMAGE : integer := 128;
      HAUTEUR_IMAGE : integer := 128
    );
    port(
      clk, rst   : in  std_logic;
      pixel_entree     : in  std_logic_vector(7 downto 0);
      pixel_valide     : in  std_logic;
      p00, p01, p02 : out std_logic_vector(7 downto 0);
      p10, p11, p12 : out std_logic_vector(7 downto 0);
      p20, p21, p22 : out std_logic_vector(7 downto 0);
      fenetre_valide  : out std_logic
    );
  end component;

  component filtre_flou is
    port(
      clk, rst        : in  std_logic;
      fenetre_valide  : in  std_logic;
      p00, p01, p02   : in  std_logic_vector(7 downto 0);
      p10, p11, p12   : in  std_logic_vector(7 downto 0);
      p20, p21, p22   : in  std_logic_vector(7 downto 0);
      pixel_sortie    : out std_logic_vector(7 downto 0)
    );
  end component;

  constant LARGEUR_IMAGE : integer := 128;
  constant HAUTEUR_IMAGE : integer := 128;
  
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal pixel_entree : std_logic_vector(7 downto 0);
  signal pixel_valide_in : std_logic := '0';
  
  signal p00, p01, p02 : std_logic_vector(7 downto 0);
  signal p10, p11, p12 : std_logic_vector(7 downto 0);
  signal p20, p21, p22 : std_logic_vector(7 downto 0);
  
  signal fenetre_valide_memory : std_logic;
  
  signal pixel_sortie : std_logic_vector(7 downto 0);

begin

  u_memoire: memoire_cache
    generic map(
      LARGEUR_IMAGE => LARGEUR_IMAGE,
      HAUTEUR_IMAGE => HAUTEUR_IMAGE
    )
    port map(
      clk => clk,
      rst => rst,
      pixel_entree => pixel_entree,
      pixel_valide => pixel_valide_in,
      p00 => p00, p01 => p01, p02 => p02,
      p10 => p10, p11 => p11, p12 => p12,
      p20 => p20, p21 => p21, p22 => p22,
      fenetre_valide => fenetre_valide_memory
    );


  u_filtre: filtre_flou
    port map(
      clk => clk,
      rst => rst,
      fenetre_valide => fenetre_valide_memory,
      p00 => p00, p01 => p01, p02 => p02,
      p10 => p10, p11 => p11, p12 => p12,
      p20 => p20, p21 => p21, p22 => p22,
      pixel_sortie => pixel_sortie
    );

  clk <= not clk after 5 ns;


  process
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait;
  end process;


  p_read: process
    file vectors : text;
    variable Iline : line;
    variable I1_var : std_logic_vector(7 downto 0);
  begin
    pixel_valide_in <= '0';
    pixel_entree <= (others => '0');
    
    wait until rst = '0';
    wait for 200 ns;
    
    file_open(vectors, "Lena128x128g_8bits.dat", read_mode);
    
    while not endfile(vectors) loop
      wait until rising_edge(clk);
      
      readline(vectors, Iline);
      read(Iline, I1_var);
      pixel_entree <= I1_var;
      pixel_valide_in <= '1';
      
    end loop;
    
    wait until rising_edge(clk);
    pixel_valide_in <= '0';
    
    file_close(vectors);
    wait;
  end process;

p_write: process
    file results : text;
    variable OLine : line;
  begin
    wait until rst = '0';
    
    file_open(results, "Lena128x128g_8bits_floue.dat", write_mode);

    wait until fenetre_valide_memory = '1';
    
    while pixel_valide_in = '1' or fenetre_valide_memory = '1' loop
      wait until rising_edge(clk);
      
      if fenetre_valide_memory = '1' then
        write(OLine, pixel_sortie, right, 2);
        writeline(results, OLine);
      end if;
    end loop;
    
    file_close(results);
    wait;
  end process;


end Behavioral;
