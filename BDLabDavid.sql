---------------------------- QUESTÃO 1 ----------------------------
create or replace procedure questao1 ( pCodigoCliente in Cliente.codigo%TYPE) is

-- Variaveis consulta parte 1
vTratamentoCliente Cliente.tratamento%TYPE;
vNomeCliente VARCHAR(256);

-- Variaveis consulta parte 2
vPedidoCodigo Pedido.Codigo%TYPE;
vPedidoDtPedido Pedido.DtPedido%TYPE;
vPedidoDtEnvio Pedido.DtEnvio%TYPE;
vPedidoDtReceb Pedido.DtRecebimento%TYPE;
vPedidoEnderecoComp VARCHAR(256);
vTransportadoraNome Transportadora.Nome%TYPE;
vPedidosValor DetalhesPedido.PrecoUnitario%Type;

-- Variaveis exception
vCodigoEx EXCEPTION;

-- Consulta parte 2
CURSOR cursorQ1 IS SELECT p.Codigo, p.dtPedido, p.dtEnvio, p.dtRecebimento,
e.logradouro || ' ' || nvl(e.complemento,' ') || ' ' || e.cidade || ' ' || e.estado || ' ' || e.pais || ' ' || e.codigopostal as endereco_comp,
t.nome, tb.valor
FROM Pedido p, Endereco e, Transportadora t, Cliente c, 
    (select sum(dp.quantidade*dp.precounitario) as valor, p.codigo as codigo
    from cliente c, pedido p, detalhespedido dp 
    where p.codigocliente = c.codigo and dp.codigopedido = p.codigo and c.codigo = pCodigoCliente 
    group by p.codigo) tb 
WHERE p.codigocliente = c.codigo and e.id = p.enderecoentrega and p.codigotransportadora = t.codigo and tb.codigo = p.codigo and c.codigo = pCodigoCliente
ORDER BY p.dtPedido;

BEGIN

IF (pCodigoCliente is NULL) THEN
RAISE vCodigoEx;
END IF;

-- Consulta parte 1
SELECT nvl(c.tratamento,' '), c.primeironome || ' ' || nvl(c.nomedomeio,' ') || ' ' || c.sobrenome
INTO vTratamentoCliente, vNomeCliente
FROM Cliente c
WHERE c.codigo = pCodigoCliente;

dbms_output.put_line('Cliente: ' || vTratamentoCliente || ' ' ||vNomeCliente);

OPEN cursorQ1;
LOOP
FETCH cursorQ1 INTO vPedidoCodigo, vPedidoDtPedido, vPedidoDtEnvio, vPedidoDtReceb, vPedidoEnderecoComp,vTransportadoraNome, vPedidosValor;
EXIT WHEN cursorQ1%NOTFOUND;
dbms_output.put_line(vPedidoCodigo || ', ' || vPedidoDtPedido || ', ' || vPedidoDtEnvio || ', ' || vPedidoDtReceb || ', ' || vPedidoEnderecoComp || ', ' || vTransportadoraNome || ', ' || vPedidosValor);
END LOOP;

EXCEPTION
WHEN vCodigoEx THEN dbms_output.put_line('Forneceça o código do Cliente');

CLOSE cursorQ1;
END questao1;


---------------------------- QUESTÃO 2 ----------------------------
-- Modificações na Tabela
ALTER TABLE Pedido 
ADD (
    qtdComprados INTEGER,
    valorTotalProdutos DECIMAL,
    valorTotalFrete DECIMAL,
    valorTotalPedido DECIMAL
);

-- Programa PL/SQL
DECLARE
vCodigoPedido Pedido.Codigo%TYPE;
vQtdComprados INTEGER;
vQtdCompradosDif INTEGER;
vValorTotalProdutos DECIMAL;
vValorTotalFrete DECIMAL;
vValorTotalPedido DECIMAL;
vTaxaBase Transportadora.TaxaBase%TYPE;
vTaxaEnvio Transportadora.TaxaEnvio%TYPE;
vImposto Pedido.Imposto%TYPE;

-- Cursor
CURSOR cursorQ2 IS SELECT p.codigo, sum(dp.quantidade) as qtdTotal, sum(dp.quantidade*dp.precounitario) as precoTotal_Produtos, t.taxabase, t.taxaenvio, p.imposto, count(dp.codigoproduto) as qtdProdutoDif
FROM pedido p, transportadora t, detalhespedido dp
WHERE p.codigotransportadora = t.codigo and p.codigo = dp.codigopedido
GROUP BY p.codigo, t.taxabase, t.taxaenvio, p.imposto
ORDER BY p.codigo;

BEGIN

OPEN cursorQ2;
LOOP
FETCH cursorQ2 INTO vCodigoPedido, vQtdComprados, vValorTotalProdutos, vTaxaBase, vTaxaEnvio, vImposto, vQtdCompradosDif;
EXIT WHEN cursorQ2%NOTFOUND;

vValorTotalFrete := vTaxaBase + (vQtdComprados*vTaxaEnvio);
vValorTotalPedido := vValorTotalProdutos + vValorTotalFrete + vImposto;

UPDATE Pedido SET 
    qtdComprados = vQtdComprados,
    valorTotalProdutos = vValorTotalProdutos, 
    valorTotalFrete = vValorTotalFrete,
    valorTotalPedido = vValorTotalPedido
WHERE Pedido.codigo = vCodigoPedido;

END LOOP;

CLOSE cursorQ2;
END;
-------------------------------------------------------------------