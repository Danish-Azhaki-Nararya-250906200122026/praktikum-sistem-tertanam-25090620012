
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_axi_lite_gpio is
end tb_axi_lite_gpio;

architecture sim of tb_axi_lite_gpio is

    constant CLK_PERIOD : time := 10 ns;

    signal clk    : STD_LOGIC := '0';
    signal resetn : STD_LOGIC := '0';

    signal awaddr  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal awvalid : STD_LOGIC := '0';
    signal awready : STD_LOGIC;

    signal wdata   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal wstrb   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal wvalid  : STD_LOGIC := '0';
    signal wready  : STD_LOGIC;

    signal bresp   : STD_LOGIC_VECTOR(1 downto 0);
    signal bvalid  : STD_LOGIC;
    signal bready  : STD_LOGIC := '0';

    signal araddr  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal arvalid : STD_LOGIC := '0';
    signal arready : STD_LOGIC;

    signal rdata   : STD_LOGIC_VECTOR(31 downto 0);
    signal rresp   : STD_LOGIC_VECTOR(1 downto 0);
    signal rvalid  : STD_LOGIC;
    signal rready  : STD_LOGIC := '0';

    signal gpio_in  : STD_LOGIC_VECTOR(15 downto 0)
        := (others => '0');

    signal gpio_out : STD_LOGIC_VECTOR(15 downto 0);

begin

    --------------------------------------------------
    -- CLOCK GENERATOR
    --------------------------------------------------

    clk <= not clk after CLK_PERIOD / 2;


    --------------------------------------------------
    -- DUT: AXI-LITE GPIO
    --------------------------------------------------

    DUT : entity work.axi_lite_gpio_v1_0
        generic map (
            C_S_AXI_ADDR_WIDTH => 4,
            C_S_AXI_DATA_WIDTH => 32
        )
        port map (
            S_AXI_ACLK    => clk,
            S_AXI_ARESETN => resetn,

            S_AXI_AWADDR  => awaddr,
            S_AXI_AWVALID => awvalid,
            S_AXI_AWREADY => awready,

            S_AXI_WDATA   => wdata,
            S_AXI_WSTRB   => wstrb,
            S_AXI_WVALID  => wvalid,
            S_AXI_WREADY  => wready,

            S_AXI_BRESP   => bresp,
            S_AXI_BVALID  => bvalid,
            S_AXI_BREADY  => bready,

            S_AXI_ARADDR  => araddr,
            S_AXI_ARVALID => arvalid,
            S_AXI_ARREADY => arready,

            S_AXI_RDATA   => rdata,
            S_AXI_RRESP   => rresp,
            S_AXI_RVALID  => rvalid,
            S_AXI_RREADY  => rready,

            gpio_in  => gpio_in,
            gpio_out => gpio_out
        );


    --------------------------------------------------
    -- TEST PROCESS
    --------------------------------------------------

    stimulus : process

    begin

        --------------------------------------------------
        -- TEST 1: RESET
        --------------------------------------------------

        report "TEST 1: RESET";

        resetn <= '0';

        wait for 3 * CLK_PERIOD;

        wait until falling_edge(clk);
        resetn <= '1';

        wait for CLK_PERIOD;

        assert gpio_out = x"0000"
            report "FAIL: GPIO output tidak reset ke nol"
            severity failure;

        report "PASS: Reset berhasil";


        --------------------------------------------------
        -- TEST 2: WRITE REGISTER 0
        --------------------------------------------------

        report "TEST 2: WRITE REGISTER 0";

        wait until falling_edge(clk);

        awaddr  <= x"0";
        awvalid <= '1';

        wdata   <= x"12345678";
        wstrb   <= "1111";
        wvalid  <= '1';

        wait until rising_edge(clk);

        assert awready = '1' and wready = '1'
            report "FAIL: Write channel tidak ready"
            severity failure;

        wait until falling_edge(clk);

        awvalid <= '0';
        wvalid  <= '0';

        -- Tunggu write response
        if bvalid /= '1' then
            wait until bvalid = '1';
        end if;

        assert bresp = "00"
            report "FAIL: Write response error"
            severity failure;

        assert gpio_out = x"5678"
            report "FAIL: Data LED tidak sesuai"
            severity failure;

        report "PASS: Register 0 berhasil ditulis";


        --------------------------------------------------
        -- TEST 3: BVALID HOLD
        --------------------------------------------------

        report "TEST 3: BVALID HOLD";

        wait for 2 * CLK_PERIOD;

        assert bvalid = '1'
            report "FAIL: BVALID tidak bertahan"
            severity failure;

        wait until falling_edge(clk);
        bready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        bready <= '0';

        wait for 1 ns;

        assert bvalid = '0'
            report "FAIL: Write response tidak selesai"
            severity failure;

        report "PASS: Write response handshake berhasil";


        --------------------------------------------------
        -- TEST 4: READ REGISTER 0
        --------------------------------------------------

        report "TEST 4: READ REGISTER 0";

        wait until falling_edge(clk);

        araddr  <= x"0";
        arvalid <= '1';

        wait until rising_edge(clk);

        assert arready = '1'
            report "FAIL: Read address tidak ready"
            severity failure;

        wait until falling_edge(clk);
        arvalid <= '0';

        -- Hindari menunggu RVALID yang sudah aktif
        if rvalid /= '1' then
            wait until rvalid = '1';
        end if;

        assert rdata = x"12345678"
            report "FAIL: Data register 0 salah"
            severity failure;

        assert rresp = "00"
            report "FAIL: Read response error"
            severity failure;

        report "PASS: Data register 0 berhasil dibaca";


        --------------------------------------------------
        -- TEST 5: RVALID HOLD
        --------------------------------------------------

        report "TEST 5: RVALID HOLD";

        wait for 2 * CLK_PERIOD;

        assert rvalid = '1'
            report "FAIL: RVALID tidak bertahan"
            severity failure;

        assert rdata = x"12345678"
            report "FAIL: Data berubah saat menunggu"
            severity failure;

        wait until falling_edge(clk);
        rready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        rready <= '0';

        wait for 1 ns;

        assert rvalid = '0'
            report "FAIL: Read response tidak selesai"
            severity failure;

        report "PASS: Read response handshake berhasil";


        --------------------------------------------------
        -- TEST 6: BYTE WRITE STROBE
        --------------------------------------------------

        report "TEST 6: BYTE WRITE STROBE";

        wait until falling_edge(clk);

        -- AW channel
        awaddr  <= x"0";
        awvalid <= '1';

        wait until rising_edge(clk);

        assert awready = '1'
            report "FAIL: Write address tidak ready"
            severity failure;

        wait until falling_edge(clk);
        awvalid <= '0';

        -- W channel dikirim terpisah
        wdata  <= x"AAAAAAAA";
        wstrb  <= "0010";
        wvalid <= '1';

        wait until rising_edge(clk);

        assert wready = '1'
            report "FAIL: Write data tidak ready"
            severity failure;

        wait until falling_edge(clk);
        wvalid <= '0';

        if bvalid /= '1' then
            wait until bvalid = '1';
        end if;

        assert gpio_out = x"AA78"
            report "FAIL: WSTRB tidak bekerja sesuai harapan"
            severity failure;

        report "PASS: Byte write strobe berhasil";

        wait until falling_edge(clk);
        bready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        bready <= '0';


        --------------------------------------------------
        -- TEST 7: READ GPIO INPUT
        --------------------------------------------------

        report "TEST 7: READ GPIO INPUT";

        gpio_in <= x"A55A";

        wait until falling_edge(clk);

        araddr  <= x"4";
        arvalid <= '1';

        wait until rising_edge(clk);

        assert arready = '1'
            report "FAIL: Read address GPIO tidak ready"
            severity failure;

        wait until falling_edge(clk);
        arvalid <= '0';

        -- Hindari menunggu RVALID yang sudah aktif
        if rvalid /= '1' then
            wait until rvalid = '1';
        end if;

        assert rdata = x"0000A55A"
            report "FAIL: Data GPIO input salah"
            severity failure;

        assert rresp = "00"
            report "FAIL: GPIO input read response error"
            severity failure;

        report "PASS: GPIO input berhasil dibaca";

        wait until falling_edge(clk);
        rready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        rready <= '0';

        wait for 1 ns;

        assert rvalid = '0'
            report "FAIL: GPIO input response tidak selesai"
            severity failure;


        --------------------------------------------------
        -- TEST FINISHED
        --------------------------------------------------

        report "================================";
        report "ALL TESTS PASSED";
        report "AXI-LITE GPIO TEST COMPLETED";
        report "================================";

        wait;

    end process;

end sim;
