---------------------------- QUESTÃO 1 ----------------------------
create or replace procedure questao1 ( pCodigoCliente in Cliente.codigo%TYPE) is

-- Variaveis consulta parte 1
vTratamentoCliente Cliente.tratamento%TYPE;
vNomeCliente VARCHAR(256);

-- Variaveis consulta parte 2
vPedidoCodigo Pedido.Codigo%TYPE;
vPedidoDtEnvio Pedido.DtEnvio%TYPE;
vPedidoDtReceb Pedido.DtRecebimento%TYPE;
vPedidoEnderecoComp VARCHAR(256);
vTransportadoraNome Transportadora.Nome%TYPE;
vPedidosValor DetalhesPedido.PrecoUnitario%Type;

-- Variaveis exception
vCodigoEx EXCEPTION;

CURSOR pedido_cursor IS SELECT p.Codigo, p.dtEnvio, p.dtRecebimento,
e.logradouro || ' ' || nvl(e.complemento,' ') || ' ' || e.cidade || ' ' || e.estado || ' ' || e.pais || ' ' || e.codigopostal as endereco_comp,
t.nome, tb.valor
FROM Pedido p, Endereco e, Transportadora t, Cliente c, (select sum(dp.quantidade*dp.precounitario) as valor, p.codigo as codigo
from cliente c, pedido p, detalhespedido dp where p.codigocliente = c.codigo and dp.codigopedido = p.codigo group by p.codigo) tb
WHERE p.codigocliente = c.codigo and e.id = p.enderecoentrega and p.codigotransportadora = t.codigo and tb.codigo = p.codigo
ORDER BY p.codigo;

BEGIN

IF (pCodigoCliente is NULL) THEN
RAISE vCodigoEx;
END IF;

SELECT nvl(c.tratamento,'ei psiu'), c.primeironome || ' ' || nvl(c.nomedomeio,' ') || ' ' || c.sobrenome
INTO vTratamentoCliente, vNomeCliente
FROM Cliente c
WHERE c.codigo = pCodigoCliente;

dbms_output.put_line('Cliente: ' || vTratamentoCliente || ' ' ||vNomeCliente);

OPEN pedido_cursor;
LOOP
FETCH pedido_cursor INTO vPedidoCodigo, vPedidoDtEnvio, vPedidoDtReceb, vPedidoEnderecoComp,vTransportadoraNome, vPedidosValor;
dbms_output.put_line(vPedidoCodigo || ' ' || vPedidoDtEnvio || ' ' || vPedidoDtReceb || ' ' || vPedidoEnderecoComp || ' ' || vTransportadoraNome || ' ' || vPedidosValor);
END LOOP;

EXCEPTION
WHEN vCodigoEx THEN dbms_output.put_line('Sem código não dá');

CLOSE pedido_cursor;
END questao1;


---------------------------- QUESTÃO 2 ----------------------------
-------------------------------------------------------------------