-- Trabalho de Disciplina de Circuitos Digitais (2023.2)
-- Discentes: Andreina Novaes Silva Melo, Christian Schettine Paiva e Thiago Fernandes Pereira de Sousa
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- define a interface externa da maquina, com suas entradas e saidas
entity MaquinaSalgados is
port(
	-- entradas 
	clock: in std_logic; -- clock essencial para a maquina
	reset: in std_logic; -- resetar a maquina
	inicia: in std_logic; -- para iniciar a maquina
	cancelar: in std_logic; -- cancelar compra
	salgado_escolhido: in std_logic_vector(2 downto 0); -- escolher um dos 5 salgados: 001, 010, 011, 100, 101
	confirma_salgado: in std_logic; -- confirmacao de salgado selecionado
	confirma_moeda: in std_logic; -- confirmacao de moeda 
	moeda: in std_logic_vector(1 downto 0); -- as moedas podem ser de tres tipos: 01 p/ R$0,25, 10 p/ R$0,50 e 11 p/ R$1,00
	liberar: in std_logic; -- liberar salgado
	prosseguir: in std_logic; -- prosseguir depois da devolucao
	-- saidas 
	sem_estoque: out std_logic; -- aviso de estoque vazio
	moeda_nao_permitida: out std_logic; -- aviso de moeda nao permitida
	salgado_invalido: out std_logic; -- aviso de salgadi invalido
	devolvido: out std_logic; -- aviso de dinheiro devolvido
	salgado_liberado: out std_logic; -- aviso de salgado liberado
	display_salgado: out std_logic_vector(6 downto 0); -- display para informar qual salgado foi escolhido
	display_moeda_centena: out std_logic_vector(6 downto 0); -- display para informar valor
	display_moeda_dezena: out std_logic_vector(6 downto 0); -- display para informar valor
	display_moeda_unidade: out std_logic_vector(6 downto 0); -- display para informar valor
	estado: out std_logic_vector(2 downto 0); -- estado atual
	estado_inicial: out std_logic; -- saida para o led
	estado_selecao_salgado: out std_logic; -- saida para o led
	estado_estoque: out std_logic; -- saida para o led
	estado_esperando_moeda: out std_logic; -- saida para o led
	estado_libera_salgado: out std_logic; -- saida para o led
	estado_devolve: out std_logic; -- saida para o led
	
	-- controle da parte financeira
	valor_inserido: buffer integer range 0 to 999 := 000; -- para somar as moedas inseridas
	preco_salgado: buffer integer range 0 to 999 := 000; -- buffer pode ser lido e escrito, contera o valor do salgado escolhido	
	troco: buffer integer range 0 to 999 := 000; -- troco do cliente
	devolucao: buffer integer range 0 to 999 := 000 -- dinheiro devolvido
);
end MaquinaSalgados;

-- descreve o comportamento e a funcionalidade do circuito digital
architecture hardware of MaquinaSalgados is
	-- estados e sinais relacionados
	type estados is (Inicial, SelecaoSalgado, Estoque, EsperandoMoeda, LiberaSalgado, Devolve);
	signal estado_atual: estados;
	signal proximo_estado: estados;
	-- controle de estoque de salgados
	signal estoque_salgado1: integer range 0 to 10 := 0010; --Estoque do Salgado 1
   signal estoque_salgado2: integer range 0 to 10 := 0010; --Estoque do Salgado 2
   signal estoque_salgado3: integer range 0 to 10 := 0010; --Estoque do Salgado 3
   signal estoque_salgado4: integer range 0 to 10 := 0010; --Estoque do Salgado 4
	signal estoque_salgado5: integer range 0 to 10 := 0010;  --Estoque do Salgado 5
	
	-- funcao geral de display de 7 segmentos (altera valores inteiros para serem representados no display)
	function display7 (inteiro: integer) return std_logic_vector is
		variable saida: std_logic_vector(6 downto 0);
		begin
			case(inteiro)is
				when 0 => saida := "1000000";
				when 1 => saida := "1111001";
				when 2 => saida := "0100100";
				when 3 => saida := "0110000";
				when 4 => saida := "0011001";
				when 5 => saida := "0010010";
				when 6 => saida := "0000010";
				when 7 => saida := "1111000";
				when 8 => saida := "0000000";
				when 9 => saida := "0010000";
				when others =>
			end case;
		return saida;
	end display7;
	
begin
	-- processo do clock | padrao
	process(clock, proximo_estado)
	begin
		if (clock'event and clock = '1') then
			estado_atual <= proximo_estado;
		end if;
	end process;
	
	-- processo para adicionar moeda
	somador: process (clock, moeda, confirma_moeda)
	begin
		if(clock = '1' and estado_atual = Inicial)then
			moeda_nao_permitida <= '0';
			valor_inserido <= 000;
		elsif((confirma_moeda'event and confirma_moeda = '0') and estado_atual = EsperandoMoeda) then
			case(moeda) is
				when "01" =>
					moeda_nao_permitida <= '0';
					valor_inserido <= valor_inserido + 025;
				when "10" =>
					moeda_nao_permitida <= '0';
					valor_inserido <= valor_inserido + 050;
				when "11" =>
					moeda_nao_permitida <= '0';
					valor_inserido <= valor_inserido + 100;
				when others =>
					moeda_nao_permitida <= '1';
			end case;
		end if;
	end process;
	
	-- toda a logica dos estados
	maquina_estados: process(clock, reset, inicia,
	estado_atual, confirma_salgado, salgado_escolhido,
	estoque_salgado1, estoque_salgado2, estoque_salgado3,
	estoque_salgado4, estoque_salgado5, cancelar,
	valor_inserido, confirma_moeda, moeda, preco_salgado, troco, prosseguir)
	
	begin 
		if (reset = '1') then -- reiniciar a maquina
			estado <= "000";
			preco_salgado <= 000;
			troco <= 000;
			devolucao <= 000;
			salgado_invalido <= '0';
			sem_estoque <= '0';
			salgado_liberado <= '0';
			devolvido <= '0';
			estoque_salgado1 <= 0010;
			estoque_salgado2 <= 0010;
			estoque_salgado3 <= 0010;
			estoque_salgado4 <= 0010;
			estoque_salgado5 <= 0000;
			proximo_estado <= Inicial;
		else
			case (estado_atual) is
				when Inicial => --comecar a maquina
					estado <= "001";
					-- definindo led do estado
					estado_inicial <= '1';
					estado_selecao_salgado <= '0';
					estado_estoque <= '0';
					estado_esperando_moeda <= '0';
					estado_libera_salgado <= '0';
					estado_devolve <= '0';
					-- definindo valores de saida e sinais para o inicial
					preco_salgado <= 000;
					troco <= 000;
					devolucao <= 000;
					salgado_liberado <= '0';
					devolvido <= '0';
					
					if(inicia = '1') then
						salgado_invalido <= '0';
						sem_estoque <= '0';	
						proximo_estado <= SelecaoSalgado;
					else
						proximo_estado <= Inicial;
					end if;
					
				when SelecaoSalgado => -- logica de escolha entre as 5 opcoes de salgado e definicao do preco
					estado <= "010";
					-- definindo led do estado
					estado_inicial <= '0';
					estado_selecao_salgado <= '1';
					estado_estoque <= '0';
					estado_esperando_moeda <= '0';
					estado_libera_salgado <= '0';
					estado_devolve <= '0';
					
					preco_salgado <= 000;
					if (confirma_salgado = '0') then
						case (salgado_escolhido) is
							when "001" =>
								preco_salgado <= 250;
								proximo_estado <= Estoque;
								
							when "010" =>
								preco_salgado <= 150;
								proximo_estado <= Estoque;
								
							when "011" =>
								preco_salgado <= 075;
								proximo_estado <= Estoque;
								
							when "100" =>
								preco_salgado <= 350;
								proximo_estado <= Estoque;
								
							when "101" =>
								preco_salgado <= 200;
								proximo_estado <= Estoque;
								
							when others =>
								salgado_invalido <= '1'; -- led vermelho de salgado_invalido
								proximo_estado <= SelecaoSalgado;
						end case;
					else
						salgado_invalido <= '0';
						sem_estoque <= '0';
						proximo_estado <= SelecaoSalgado;
					end if;
				
				when Estoque => -- analisa estoque
					estado <= "011";
					-- definindo led do estado
					estado_inicial <= '0';
					estado_selecao_salgado <= '0';
					estado_estoque <= '1';
					estado_esperando_moeda <= '0';
					estado_libera_salgado <= '0';
					estado_devolve <= '0';
					
					case (salgado_escolhido) is
						when "001" =>
							if(estoque_salgado1 > 0) then -- se tiver estoque do salgado 1
								sem_estoque <= '0';
								proximo_estado <= EsperandoMoeda;
							else -- se nao tiver
								sem_estoque <= '1'; -- avisa que nao tem
								proximo_estado <= Inicial; -- volta para comeco
							end if;
						when "010" =>
							if(estoque_salgado2 > 0) then -- se tiver estoque do salgado 2
								sem_estoque <= '0';
								proximo_estado <= EsperandoMoeda;
							else -- se nao tiver
								sem_estoque <= '1'; -- avisa que nao tem
								proximo_estado <= Inicial; -- volta para comeco
							end if;
						when "011" =>
							if(estoque_salgado3 > 0) then -- se tiver estoque do salgado 3
								sem_estoque <= '0';
								proximo_estado <= EsperandoMoeda;
							else -- se nao tiver
								sem_estoque <= '1'; -- avisa que nao tem
								proximo_estado <= Inicial; -- volta para comeco
							end if;
						when "100" =>
							if(estoque_salgado4 > 0) then -- se tiver estoque do salgado 4
								sem_estoque <= '0';
								proximo_estado <= EsperandoMoeda;
							else -- se nao tiver
								sem_estoque <= '1'; -- avisa que nao tem
								proximo_estado <= Inicial; -- volta para comeco
							end if;
						when "101" =>
							if(estoque_salgado5 > 0) then -- se tiver estoque do salgado 5
								sem_estoque <= '0';
								proximo_estado <= EsperandoMoeda;
							else -- se nao tiver
								sem_estoque <= '1'; -- avisa que nao tem
								proximo_estado <= Inicial; -- volta para comeco
							end if;
						when others =>
					end case;
				
				when EsperandoMoeda => -- espera moedas ate que o valor atinja o preco do salgado ou cancela pedido 
					estado <= "100";
					-- definindo led do estado
					estado_inicial <= '0';
					estado_selecao_salgado <= '0';
					estado_estoque <= '0';
					estado_esperando_moeda <= '1';
					estado_libera_salgado <= '0';
					estado_devolve <= '0';
					
					if (cancelar ='0') then
						devolucao <= valor_inserido; -- utilizado no estado devolve
						if (valor_inserido > 0) then
							proximo_estado <= Devolve;
						else
							proximo_estado <= Inicial;
						end if;
					else
						if (valor_inserido >= preco_salgado) then -- se atingiu o valor, libera salgado
							proximo_estado <= LiberaSalgado;		
						else -- espera se nao atingiu
							proximo_estado <= EsperandoMoeda;
						end if;
					end if;
					
				when LiberaSalgado => -- libera salgado escolhido caso pagamento tenha sido efetuado
					estado <= "101";
					-- definindo led do estado
					estado_inicial <= '0';
					estado_selecao_salgado <= '0';
					estado_estoque <= '0';
					estado_esperando_moeda <= '0';
					estado_libera_salgado <= '1';
					estado_devolve <= '0';
					
					salgado_liberado <= '1'; --led verde de salgado liberado
					troco <= valor_inserido - preco_salgado; -- define troco
					devolucao <= troco; -- utilizado no estado devolve
					if (liberar = '1')then
						case (salgado_escolhido) is
							when "001" =>
								estoque_salgado1 <= estoque_salgado1 - 0001; -- decrementa o estoque
							when "010" =>
								estoque_salgado2 <= estoque_salgado2 - 0001; -- decrementa o estoque
							when "011" =>
								estoque_salgado3 <= estoque_salgado3 - 0001; -- decrementa o estoque
							when "100" =>
								estoque_salgado4 <= estoque_salgado4 - 0001; -- decrementa o estoque
							when "101" =>
								estoque_salgado5 <= estoque_salgado5 - 0001; -- decrementa o estoque
							when others =>
						end case;
						--logica para devolucao de troco
						if (troco > 0) then
							proximo_estado <= Devolve;
						else
							proximo_estado <= Inicial;
						end if;
					else 
						proximo_estado <= LiberaSalgado;
					end if;
				
				when Devolve =>
					estado <= "110";
					-- definindo led do estado
					estado_inicial <= '0';
					estado_selecao_salgado <= '0';
					estado_estoque <= '0';
					estado_esperando_moeda <= '0';
					estado_libera_salgado <= '0';
					estado_devolve <= '1';
					
					devolvido <= '1';-- led verde de dinheiro devolvido
					if(prosseguir = '1') then
						proximo_estado <= Inicial;
					else
						proximo_estado <= Devolve;
					end if;
					
				when others =>
			end case;
		end if;
	end process maquina_estados;
	
	--  responsavel por atualizar as informacoes exibidas na maquina de salgados de acordo o estado atual
	display: process(clock)
		variable centena, dezena, unidade, numero_salgado: integer range 0 to 999;
		begin
			if (clock'event and clock = '1') then
				case(estado_atual) is
					when Inicial => -- mostrar desligado
						display_salgado <= "1111111";
						display_moeda_centena <= "1111111";
						display_moeda_dezena <= "1111111";
						display_moeda_unidade <= "1111111";
				
					when SelecaoSalgado =>
						case (salgado_escolhido) is
							when "001" =>
								numero_salgado := 001;
							when "010" =>
								numero_salgado := 002;
							when "011" =>
								numero_salgado := 003;
							when "100" =>
								numero_salgado := 004;
							when "101" =>
								numero_salgado := 005;
							when others =>
								numero_salgado := 000;
						end case;
						
						display_salgado <= display7(numero_salgado);
							case(numero_salgado) is
								when 001 =>
									display_moeda_centena <= display7(2);
									display_moeda_dezena <= display7(5);
									display_moeda_unidade <= display7(0);
								
								when 002 =>
									display_moeda_centena <= display7(1);
									display_moeda_dezena <= display7(5);
									display_moeda_unidade <= display7(0);
								
								when 003 =>		
									display_moeda_centena <= display7(0);
									display_moeda_dezena <= display7(7);
									display_moeda_unidade <= display7(5);
								
								when 004 =>
									display_moeda_centena <= display7(3);
									display_moeda_dezena <= display7(5);
									display_moeda_unidade <= display7(0);									
								
								when 005 =>
									display_moeda_centena <= display7(2);
									display_moeda_dezena <= display7(0);
									display_moeda_unidade <= display7(0);
								when others =>
									display_moeda_centena <= display7(0);
									display_moeda_dezena <= display7(0);
									display_moeda_unidade <= display7(0);
							end case;
			
					when Estoque =>
						display_salgado <= display7(numero_salgado);
						unidade := (valor_inserido mod 10);
						dezena := (valor_inserido - unidade)/10;
						dezena := (dezena mod 10);
						centena := (valor_inserido - unidade)/10;
						centena := (centena - dezena)/10;
						
						display_moeda_centena <= display7(centena);
						display_moeda_dezena <= display7(dezena);
						display_moeda_unidade <= display7(unidade);
						
					when EsperandoMoeda =>
						display_salgado <= display7(numero_salgado);
						unidade := (valor_inserido mod 10);
						dezena := (valor_inserido - unidade)/10;
						dezena := (dezena mod 10);
						centena := (valor_inserido - unidade)/10;
						centena := (centena - dezena)/10;
						
						display_moeda_centena <= display7(centena);
						display_moeda_dezena <= display7(dezena);
						display_moeda_unidade <= display7(unidade);
						
					when LiberaSalgado =>
						display_salgado <= display7(numero_salgado);
						unidade := (troco mod 10);
						dezena := (troco - unidade)/10;
						dezena := (dezena mod 10);
						centena := (troco - unidade)/10;
						centena := (centena - dezena)/10;
						
						display_moeda_centena <= display7(centena);
						display_moeda_dezena <= display7(dezena);
						display_moeda_unidade <= display7(unidade);
					
					when Devolve =>
						display_salgado <= display7(numero_salgado);
						unidade := (devolucao mod 10);
						dezena := (devolucao - unidade)/10;
						dezena := (dezena mod 10);
						centena := (devolucao - unidade)/10;
						centena := (centena - dezena)/10;
						
						display_moeda_centena <= display7(centena);
						display_moeda_dezena <= display7(dezena);
						display_moeda_unidade <= display7(unidade);
					
					when others =>
				end case;
			end if;
		end process;	
end hardware;