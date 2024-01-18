library verilog;
use verilog.vl_types.all;
entity MaquinaSalgados_vlg_check_tst is
    port(
        devolucao       : in     vl_logic_vector(9 downto 0);
        devolvido       : in     vl_logic;
        display_moeda_centena: in     vl_logic_vector(6 downto 0);
        display_moeda_dezena: in     vl_logic_vector(6 downto 0);
        display_moeda_unidade: in     vl_logic_vector(6 downto 0);
        display_salgado : in     vl_logic_vector(6 downto 0);
        estado          : in     vl_logic_vector(2 downto 0);
        estado_devolve  : in     vl_logic;
        estado_esperando_moeda: in     vl_logic;
        estado_estoque  : in     vl_logic;
        estado_inicial  : in     vl_logic;
        estado_libera_salgado: in     vl_logic;
        estado_selecao_salgado: in     vl_logic;
        moeda_nao_permitida: in     vl_logic;
        preco_salgado   : in     vl_logic_vector(9 downto 0);
        salgado_invalido: in     vl_logic;
        salgado_liberado: in     vl_logic;
        sem_estoque     : in     vl_logic;
        troco           : in     vl_logic_vector(9 downto 0);
        valor_inserido  : in     vl_logic_vector(9 downto 0);
        sampler_rx      : in     vl_logic
    );
end MaquinaSalgados_vlg_check_tst;
