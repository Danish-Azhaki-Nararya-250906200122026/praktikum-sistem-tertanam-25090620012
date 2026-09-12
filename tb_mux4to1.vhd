library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mux4to1 is
end tb_mux4to1;

architecture Behavioral of tb_mux4to1 is

    -- Deklarasi signal
    signal sel : STD_LOGIC_VECTOR(1 downto 0);
    signal in0 : STD_LOGIC_VECTOR(3 downto 0);
    signal in1 : STD_LOGIC_VECTOR(3 downto 0);
    signal in2 : STD_LOGIC_VECTOR(3 downto 0);
    signal in3 : STD_LOGIC_VECTOR(3 downto 0);
    signal y   : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Menghubungkan testbench dengan rangkaian MUX
    DUT: entity work.mux4to1
        port map (
            sel => sel,
            in0 => in0,
            in1 => in1,
            in2 => in2,
            in3 => in3,
            y   => y
        );

    -- Proses pengujian
    process
    begin

        -- Memberikan nilai pada setiap input
        in0 <= "0001";
        in1 <= "0010";
        in2 <= "0011";
        in3 <= "0100";

        -- Pengujian 1
        sel <= "00";
        wait for 50 ns;

        assert (y = in0)
            report "MUX gagal: sel = 00, y seharusnya mengikuti in0"
            severity error;

        -- Pengujian 2
        sel <= "01";
        wait for 50 ns;

        assert (y = in1)
            report "MUX gagal: sel = 01, y seharusnya mengikuti in1"
            severity error;

        -- Pengujian 3
        sel <= "10";
        wait for 50 ns;

        assert (y = in2)
            report "MUX gagal: sel = 10, y seharusnya mengikuti in2"
            severity error;

        -- Pengujian 4
        sel <= "11";
        wait for 50 ns;

        assert (y = in3)
            report "MUX gagal: sel = 11, y seharusnya mengikuti in3"
            severity error;

        -- Menghentikan proses
        wait;

    end process;

end Behavioral;