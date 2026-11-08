
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_axi_lite_gpio_2 is
end tb_axi_lite_gpio_2;


architecture sim of tb_axi_lite_gpio_2 is

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
    -- DUT
    --------------------------------------------------

    DUT : entity work.axi_lite_gpio_v1_0_2

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

        wait until falling_edge(clk);

        assert gpio_out = x"0000"
            report "FAIL: GPIO output tidak reset ke nol"
            severity failure;

        report "PASS: Reset berhasil";


        --------------------------------------------------
        -- TEST 2: WRITE REGISTER 0
        --------------------------------------------------

        report "TEST 2: WRITE REGISTER 0 (LED)";

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

        assert bvalid = '1'
            report "FAIL: BVALID tidak aktif"
            severity failure;

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

        assert bvalid = '0'
            report "FAIL: Write response tidak selesai"
            severity failure;

        report "PASS: Write response handshake berhasil";


        --------------------------------------------------
        -- TEST 4: READ REGISTER 0
        --------------------------------------------------

        report "TEST 4: READ REGISTER 0 (LED)";

        wait until falling_edge(clk);

        araddr  <= x"0";
        arvalid <= '1';

        wait until rising_edge(clk);

        assert arready = '1'
            report "FAIL: Read address tidak ready"
            severity failure;

        wait until falling_edge(clk);
        arvalid <= '0';

        assert rvalid = '1'
            report "FAIL: RVALID tidak aktif"
            severity failure;

        assert rdata = x"12345678"
            report "FAIL: Data register 0 salah"
            severity failure;

        report "PASS: Register 0 berhasil dibaca";


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

        assert rvalid = '0'
            report "FAIL: Read response tidak selesai"
            severity failure;

        report "PASS: Read response handshake berhasil";


        --------------------------------------------------
        -- TEST 6: READ REGISTER 1 (SWITCH)
        --------------------------------------------------

        report "TEST 6: READ REGISTER 1 (SWITCH)";

        gpio_in <= x"A55A";

        wait until falling_edge(clk);

        araddr  <= x"4";
        arvalid <= '1';

        wait until rising_edge(clk);

        assert arready = '1'
            report "FAIL: Read address switch tidak ready"
            severity failure;

        wait until falling_edge(clk);
        arvalid <= '0';

        assert rvalid = '1'
            report "FAIL: RVALID switch tidak aktif"
            severity failure;

        assert rdata = x"0000A55A"
            report "FAIL: Data switch tidak sesuai"
            severity failure;

        report "PASS: Register 1 berhasil membaca switch";


        --------------------------------------------------
        -- TEST 7: SWITCH INPUT BERUBAH
        --------------------------------------------------

        report "TEST 7: SWITCH INPUT BERUBAH";

        wait until falling_edge(clk);
        rready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        rready <= '0';

        gpio_in <= x"1234";

        wait until falling_edge(clk);

        araddr  <= x"4";
        arvalid <= '1';

        wait until rising_edge(clk);

        assert arready = '1'
            report "FAIL: Read address tidak ready"
            severity failure;

        wait until falling_edge(clk);
        arvalid <= '0';

        assert rvalid = '1'
            report "FAIL: RVALID tidak aktif"
            severity failure;

        assert rdata = x"00001234"
            report "FAIL: Perubahan switch tidak terbaca"
            severity failure;

        report "PASS: Perubahan status switch berhasil dibaca";


        --------------------------------------------------
        -- TEST 8: REGISTER 1 READ ONLY
        --------------------------------------------------

        report "TEST 8: REGISTER 1 READ ONLY";

        -- Selesaikan read response sebelumnya
        wait until falling_edge(clk);
        rready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        rready <= '0';

        -- Coba tulis ke register 1
        awaddr  <= x"4";
        awvalid <= '1';

        wait until rising_edge(clk);

        assert awready = '1'
            report "FAIL: Write address tidak ready"
            severity failure;

        wait until falling_edge(clk);
        awvalid <= '0';

        wdata  <= x"0000FFFF";
        wstrb  <= "1111";
        wvalid <= '1';

        wait until rising_edge(clk);

        assert wready = '1'
            report "FAIL: Write data tidak ready"
            severity failure;

        wait until falling_edge(clk);
        wvalid <= '0';

        assert bvalid = '1'
            report "FAIL: Write response tidak aktif"
            severity failure;

        -- Selesaikan write response
        bready <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        bready <= '0';

        assert gpio_out = x"5678"
            report "FAIL: Register 1 mengubah GPIO output"
            severity failure;

        report "PASS: Register 1 bersifat read-only";


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
