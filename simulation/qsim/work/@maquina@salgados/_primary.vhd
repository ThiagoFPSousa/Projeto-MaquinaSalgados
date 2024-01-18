library verilog;
use verilog.vl_types.all;
entity MaquinaSalgados is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        inicia          : in     vl_logic;
        cancelar        : in     vl_logic;
        salgado_escolhido: in     vl_logic_vector(2 downto 0);
        confirma_salgado: in     vl_logic;
        confirma_moeda  : in     vl_logic;
        moeda           : in     vl_logic_vector(1 downto 0);
        liberar         : in     vl_logic;
        prosseguir      : in     vl_logic;
        sem_estoque     : out    vl_logic;
        moeda_nao_permitida: out    vl_logic;
        salgado_invalido: out    vl_logic;
        devolvido       : out    vl_logic;
        salgado_liberado: out    vl_logic;
        display_salgado : out    vl_logic_vector(6 downto 0);
        display_moeda_centena: out    vl_logic_vector(6 downto 0);
        display_moeda_dezena: out    vl_logic_vector(6 downto 0);
        display_moeda_unidade: out    vl_logic_vector(6 downto 0);
        estado          : out    vl_logic_vector(2 downto 0);
        estado_inicial  : out    vl_logic;
        estado_selecao_salgado: out    vl_logic;
        estado_estoque  : out    vl_logic;
        estado_esperando_moeda: out    vl_logic;
        estado_libera_salgado: out    vl_logic;
        estado_devolve  : out    vl_logic;
        valor_inserido  : out    vl_logic_vector(9 downto 0);
        preco_salgado   : out    vl_logic_vector(9 downto 0);
        troco           : out    vl_logic_vector(9 downto 0);
        devolucao       : out    vl_logic_vector(9 downto 0)
    );
end MaquinaSalgados;
