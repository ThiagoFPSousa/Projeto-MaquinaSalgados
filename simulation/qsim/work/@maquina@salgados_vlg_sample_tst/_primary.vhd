library verilog;
use verilog.vl_types.all;
entity MaquinaSalgados_vlg_sample_tst is
    port(
        cancelar        : in     vl_logic;
        clock           : in     vl_logic;
        confirma_moeda  : in     vl_logic;
        confirma_salgado: in     vl_logic;
        inicia          : in     vl_logic;
        liberar         : in     vl_logic;
        moeda           : in     vl_logic_vector(1 downto 0);
        prosseguir      : in     vl_logic;
        reset           : in     vl_logic;
        salgado_escolhido: in     vl_logic_vector(2 downto 0);
        sampler_tx      : out    vl_logic
    );
end MaquinaSalgados_vlg_sample_tst;
