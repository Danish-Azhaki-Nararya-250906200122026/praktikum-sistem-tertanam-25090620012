
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_lite_gpio_v1_0 is
    Generic (
        C_S_AXI_ADDR_WIDTH : integer := 4;
        C_S_AXI_DATA_WIDTH : integer := 32
    );
    Port (
        -- AXI Clock and Reset
        S_AXI_ACLK    : in  STD_LOGIC;
        S_AXI_ARESETN : in  STD_LOGIC;

        -- AXI Write Address Channel
        S_AXI_AWADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID : in  STD_LOGIC;
        S_AXI_AWREADY : out STD_LOGIC;

        -- AXI Write Data Channel
        S_AXI_WDATA   : in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB   : in  STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID  : in  STD_LOGIC;
        S_AXI_WREADY  : out STD_LOGIC;

        -- AXI Write Response Channel
        S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
        S_AXI_BVALID  : out STD_LOGIC;
        S_AXI_BREADY  : in  STD_LOGIC;

        -- AXI Read Address Channel
        S_AXI_ARADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID : in  STD_LOGIC;
        S_AXI_ARREADY : out STD_LOGIC;

        -- AXI Read Data Channel
        S_AXI_RDATA   : out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
        S_AXI_RVALID  : out STD_LOGIC;
        S_AXI_RREADY  : in  STD_LOGIC;

        -- GPIO Input and Output
        gpio_in  : in  STD_LOGIC_VECTOR(15 downto 0);
        gpio_out : out STD_LOGIC_VECTOR(15 downto 0)
    );
end axi_lite_gpio_v1_0;


architecture rtl of axi_lite_gpio_v1_0 is

    constant ADDR_LSB : integer := 2;

    type reg_array_t is array (0 to 3) of
        STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);

    signal slv_reg : reg_array_t :=
        (others => (others => '0'));

    -- Write Channel Internal Signals
    signal axi_awaddr : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0)
        := (others => '0');

    signal axi_wdata : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0)
        := (others => '0');

    signal axi_wstrb : STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0)
        := (others => '0');

    signal aw_captured : STD_LOGIC := '0';
    signal w_captured  : STD_LOGIC := '0';
    signal axi_bvalid  : STD_LOGIC := '0';

    -- Read Channel Internal Signals
    signal axi_rdata : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0)
        := (others => '0');

    signal axi_rvalid : STD_LOGIC := '0';

begin

    --------------------------------------------------
    -- AXI OUTPUT ASSIGNMENTS
    --------------------------------------------------

    S_AXI_AWREADY <= '1' when
        aw_captured = '0' and axi_bvalid = '0'
        else '0';

    S_AXI_WREADY <= '1' when
        w_captured = '0' and axi_bvalid = '0'
        else '0';

    S_AXI_BVALID <= axi_bvalid;
    S_AXI_BRESP  <= "00";

    S_AXI_ARREADY <= not axi_rvalid;

    S_AXI_RVALID <= axi_rvalid;
    S_AXI_RDATA  <= axi_rdata;
    S_AXI_RRESP  <= "00";

    -- LED Output from Register 0
    gpio_out <= slv_reg(0)(15 downto 0);


    --------------------------------------------------
    -- AXI WRITE PROCESS
    --------------------------------------------------

    write_proc : process(S_AXI_ACLK)

        variable reg_index : integer range 0 to 3;

    begin

        if rising_edge(S_AXI_ACLK) then

            if S_AXI_ARESETN = '0' then

                axi_awaddr  <= (others => '0');
                axi_wdata   <= (others => '0');
                axi_wstrb   <= (others => '0');

                aw_captured <= '0';
                w_captured  <= '0';
                axi_bvalid  <= '0';

                slv_reg <= (others => (others => '0'));

            else

                -- Capture Write Address
                if S_AXI_AWVALID = '1' and
                   aw_captured = '0' and
                   axi_bvalid = '0' then

                    axi_awaddr  <= S_AXI_AWADDR;
                    aw_captured <= '1';

                end if;

                -- Capture Write Data
                if S_AXI_WVALID = '1' and
                   w_captured = '0' and
                   axi_bvalid = '0' then

                    axi_wdata  <= S_AXI_WDATA;
                    axi_wstrb  <= S_AXI_WSTRB;
                    w_captured <= '1';

                end if;

                -- Execute Write Transaction
                if aw_captured = '1' and
                   w_captured = '1' and
                   axi_bvalid = '0' then

                    reg_index := to_integer(
                        unsigned(
                            axi_awaddr(ADDR_LSB+1 downto ADDR_LSB)
                        )
                    );

                    -- Register 1 is Reserved for Switch Input
                    if reg_index /= 1 then

                        for i in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop

                            if axi_wstrb(i) = '1' then

                                slv_reg(reg_index)(i*8+7 downto i*8)
                                    <= axi_wdata(i*8+7 downto i*8);

                            end if;

                        end loop;

                    end if;

                    aw_captured <= '0';
                    w_captured  <= '0';
                    axi_bvalid  <= '1';

                elsif axi_bvalid = '1' and S_AXI_BREADY = '1' then

                    axi_bvalid <= '0';

                end if;

            end if;

        end if;

    end process;


    --------------------------------------------------
    -- AXI READ PROCESS
    --------------------------------------------------

    read_proc : process(S_AXI_ACLK)

        variable reg_index : integer range 0 to 3;

        variable read_value :
            STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);

    begin

        if rising_edge(S_AXI_ACLK) then

            if S_AXI_ARESETN = '0' then

                axi_rdata  <= (others => '0');
                axi_rvalid <= '0';

            else

                -- Complete Read Response
                if axi_rvalid = '1' and S_AXI_RREADY = '1' then

                    axi_rvalid <= '0';

                end if;

                -- Accept Read Address
                if S_AXI_ARVALID = '1' and axi_rvalid = '0' then

                    reg_index := to_integer(
                        unsigned(
                            S_AXI_ARADDR(ADDR_LSB+1 downto ADDR_LSB)
                        )
                    );

                    read_value := (others => '0');

                    case reg_index is

                        -- Register 0: LED Output
                        when 0 =>
                            read_value := slv_reg(0);

                        -- Register 1: Switch Input
                        when 1 =>
                            read_value(15 downto 0) := gpio_in;

                        -- Register 2
                        when 2 =>
                            read_value := slv_reg(2);

                        -- Register 3
                        when 3 =>
                            read_value := slv_reg(3);

                        when others =>
                            read_value := (others => '0');

                    end case;

                    axi_rdata  <= read_value;
                    axi_rvalid <= '1';

                end if;

            end if;

        end if;

    end process;

end rtl;
