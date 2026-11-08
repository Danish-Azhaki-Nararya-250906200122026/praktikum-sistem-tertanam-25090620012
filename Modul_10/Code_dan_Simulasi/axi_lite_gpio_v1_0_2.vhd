
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_lite_gpio_v1_0_2 is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 4
    );
    port (
        S_AXI_ACLK    : in  STD_LOGIC;
        S_AXI_ARESETN : in  STD_LOGIC;

        S_AXI_AWADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID : in  STD_LOGIC;
        S_AXI_AWREADY : out STD_LOGIC;

        S_AXI_WDATA   : in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB   : in  STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID  : in  STD_LOGIC;
        S_AXI_WREADY  : out STD_LOGIC;

        S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
        S_AXI_BVALID  : out STD_LOGIC;
        S_AXI_BREADY  : in  STD_LOGIC;

        S_AXI_ARADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID : in  STD_LOGIC;
        S_AXI_ARREADY : out STD_LOGIC;

        S_AXI_RDATA   : out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
        S_AXI_RVALID  : out STD_LOGIC;
        S_AXI_RREADY  : in  STD_LOGIC;

        gpio_in  : in  STD_LOGIC_VECTOR(15 downto 0);
        gpio_out : out STD_LOGIC_VECTOR(15 downto 0)
    );
end axi_lite_gpio_v1_0_2;


architecture arch_imp of axi_lite_gpio_v1_0_2 is

    constant ADDR_LSB : integer := 2;
    constant OPT_MEM_ADDR_BITS : integer := 1;

    type reg_array is array (0 to 3) of
        STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);

    signal slv_reg : reg_array := (others => (others => '0'));

    signal aw_pending : STD_LOGIC := '0';
    signal w_pending  : STD_LOGIC := '0';

    signal awaddr_hold :
        STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0)
        := (others => '0');

    signal wdata_hold :
        STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0)
        := (others => '0');

    signal wstrb_hold :
        STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0)
        := (others => '0');

    signal axi_bvalid : STD_LOGIC := '0';
    signal axi_rvalid : STD_LOGIC := '0';

    signal axi_rdata :
        STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0)
        := (others => '0');

    -- Sinyal internal untuk AXI READY
    signal axi_awready : STD_LOGIC;
    signal axi_wready  : STD_LOGIC;
    signal axi_arready : STD_LOGIC;

begin

    --------------------------------------------------
    -- AXI-LITE OUTPUT
    --------------------------------------------------

    axi_awready <= '1' when
        aw_pending = '0' and axi_bvalid = '0'
        else '0';

    axi_wready <= '1' when
        w_pending = '0' and axi_bvalid = '0'
        else '0';

    axi_arready <= not axi_rvalid;

    S_AXI_AWREADY <= axi_awready;
    S_AXI_WREADY  <= axi_wready;
    S_AXI_ARREADY <= axi_arready;

    S_AXI_BVALID <= axi_bvalid;
    S_AXI_BRESP  <= "00";

    S_AXI_RVALID <= axi_rvalid;
    S_AXI_RDATA  <= axi_rdata;
    S_AXI_RRESP  <= "00";

    -- REG0: GPIO OUTPUT / LED
    gpio_out <= slv_reg(0)(15 downto 0);


    --------------------------------------------------
    -- AXI-LITE WRITE PROCESS
    --------------------------------------------------

    write_process : process(S_AXI_ACLK)

        variable v_aw_pending : STD_LOGIC;
        variable v_w_pending  : STD_LOGIC;

        variable v_awaddr :
            STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);

        variable v_wdata :
            STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);

        variable v_wstrb :
            STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0);

        variable v_index : integer range 0 to 3;

    begin

        if rising_edge(S_AXI_ACLK) then

            if S_AXI_ARESETN = '0' then

                slv_reg <= (others => (others => '0'));

                aw_pending <= '0';
                w_pending  <= '0';

                awaddr_hold <= (others => '0');
                wdata_hold  <= (others => '0');
                wstrb_hold  <= (others => '0');

                axi_bvalid <= '0';

            else

                v_aw_pending := aw_pending;
                v_w_pending  := w_pending;

                v_awaddr := awaddr_hold;
                v_wdata  := wdata_hold;
                v_wstrb  := wstrb_hold;

                -- Write response handshake
                if axi_bvalid = '1' and S_AXI_BREADY = '1' then
                    axi_bvalid <= '0';
                end if;

                -- Capture write address
                if S_AXI_AWVALID = '1' and
                   axi_awready = '1' then

                    v_awaddr := S_AXI_AWADDR;
                    v_aw_pending := '1';

                end if;

                -- Capture write data
                if S_AXI_WVALID = '1' and
                   axi_wready = '1' then

                    v_wdata := S_AXI_WDATA;
                    v_wstrb := S_AXI_WSTRB;
                    v_w_pending := '1';

                end if;

                -- Execute when address and data are available
                if v_aw_pending = '1' and
                   v_w_pending = '1' and
                   axi_bvalid = '0' then

                    v_index := to_integer(
                        unsigned(
                            v_awaddr(ADDR_LSB+OPT_MEM_ADDR_BITS
                                     downto ADDR_LSB)
                        )
                    );

                    -- REG1 is read-only
                    if v_index /= 1 then

                        for i in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop

                            if v_wstrb(i) = '1' then

                                slv_reg(v_index)(i*8+7 downto i*8)
                                    <= v_wdata(i*8+7 downto i*8);

                            end if;

                        end loop;

                    end if;

                    axi_bvalid <= '1';

                    v_aw_pending := '0';
                    v_w_pending  := '0';

                end if;

                aw_pending <= v_aw_pending;
                w_pending  <= v_w_pending;

                awaddr_hold <= v_awaddr;
                wdata_hold  <= v_wdata;
                wstrb_hold  <= v_wstrb;

            end if;
        end if;

    end process;


    --------------------------------------------------
    -- AXI-LITE READ PROCESS
    --------------------------------------------------

    read_process : process(S_AXI_ACLK)

        variable v_index : integer range 0 to 3;

    begin

        if rising_edge(S_AXI_ACLK) then

            if S_AXI_ARESETN = '0' then

                axi_rvalid <= '0';
                axi_rdata  <= (others => '0');

            else

                -- Read response handshake
                if axi_rvalid = '1' and S_AXI_RREADY = '1' then

                    axi_rvalid <= '0';

                -- Read address handshake
                elsif S_AXI_ARVALID = '1' and
                      axi_arready = '1' then

                    v_index := to_integer(
                        unsigned(
                            S_AXI_ARADDR(ADDR_LSB+OPT_MEM_ADDR_BITS
                                         downto ADDR_LSB)
                        )
                    );

                    case v_index is

                        -- REG0: GPIO OUTPUT / LED
                        when 0 =>
                            axi_rdata <= slv_reg(0);

                        -- REG1: GPIO INPUT / SWITCH
                        when 1 =>
                            axi_rdata <= std_logic_vector(
                                resize(unsigned(gpio_in),
                                       C_S_AXI_DATA_WIDTH)
                            );

                        -- REG2
                        when 2 =>
                            axi_rdata <= slv_reg(2);

                        -- REG3
                        when 3 =>
                            axi_rdata <= slv_reg(3);

                        when others =>
                            axi_rdata <= (others => '0');

                    end case;

                    axi_rvalid <= '1';

                end if;

            end if;
        end if;

    end process;

end arch_imp;
