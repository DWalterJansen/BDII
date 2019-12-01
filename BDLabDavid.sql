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
ALTER TABLE Pedido 
ADD (
    qtdComprados INTEGER,
    valorTotalProdutos DECIMAL,
    valorTotalFrete DECIMAL,
    valorTotalPedido DECIMAL
);

DECLARE
qtdComprados INTEGER;
vValorTotalProdutos DECIMAL;
vValorTotalFrete DECIMAL;
vValorTotalPedido DECIMAL;
vTaxaBase Transportadora.TaxaBase%TYPE;
vTaxaEnvio Transportadora.TaxaEnvio%TYPE;

CURSOR cursorQ2 IS SELECT p.codigo, dp.codigoproduto, dp.quantidade
FROM cliente c, pedido p, detalhespedido dp
WHERE p.codigocliente = c.codigo and dp.codigopedido = p.codigo;

BEGIN
CLOSE cursorQ2;
END;
-------------------------------------------------------------------