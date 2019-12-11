--------------------------------------------------------------------
-------------------------- PRÉ REQUISITOS --------------------------
ALTER TRIGGER codigo_seq DISABLE;
ALTER TRIGGER questao1Pedido DISABLE;
ALTER TRIGGER questao1Pedido_2 DISABLE;
ALTER TRIGGER questao1DtPedido DISABLE;
ALTER TRIGGER questao2DetalhesPedido DISABLE;
ALTER TRIGGER questao3DetalhesPedido DISABLE;
ALTER TRIGGER questao4Pedido DISABLE;
--------------------------------------------------------------------
--------------------------------------------------------------------

-- QUESTÃO 1
CREATE OR REPLACE VIEW q1_ControlaEstoque AS
    SELECT pd.codigo, sum(dp.quantidade) as qtdVendida
    FROM Produto pd, DetalhesPedido dp
    WHERE pd.codigo = dp.codigoproduto
    GROUP BY pd.codigo
    ORDER BY qtdVendida
WITH READ ONLY;

-- TESTE
SELECT * FROM q1_ControlaEstoque;
--------------------------------------------------------------------
--------------------------------------------------------------------

-- QUESTÃO 2
CREATE OR REPLACE VIEW q2_PedidosOnline AS
    SELECT  p.codigo as Codigo_Pedido,
            pd.nome as Nome_Produto,
            pd.codigo as Codigo_Produto,
            c.codigo as Codigo_Cliente,
            c.primeironome || ' ' || nvl(c.nomedomeio,' ') || ' ' || c.sobrenome as nome_completo,
            p.valortotalpedido,
            t.nome as Nome_Transportadora,
            e.logradouro || ' ' || nvl(e.complemento,' ') || ' ' || e.cidade || ' ' || e.estado || ' ' || e.pais || ' ' || e.codigopostal as endereco_comp
    FROM    Pedido p, Produto pd, Cliente c, Transportadora t, Endereco e, DetalhesPedido dp
    WHERE   p.codigoVendedor IS NULL and p.codigo = dp.codigopedido and pd.codigo = dp.codigoproduto and
            c.codigo = p.codigocliente and t.codigo = p.codigotransportadora and e.id = p.enderecoentrega
    ORDER BY p.codigo
WITH READ ONLY;

-- TESTE
SELECT * FROM q2_PedidosOnline;
--------------------------------------------------------------------
--------------------------------------------------------------------

-- QUESTÃO 3 (EXTRA)

CREATE OR REPLACE VIEW q3_PedidosOffline AS
    SELECT  p.codigo as Codigo_Pedido,
            pd.nome as Nome_Produto,
            pd.codigo as Codigo_Produto,
            c.codigo as Codigo_Cliente,
            c.primeironome || ' ' || nvl(c.nomedomeio,' ') || ' ' || c.sobrenome as nome_completo,
            p.valortotalpedido,
            t.nome as Nome_Transportadora,
            e.logradouro || ' ' || nvl(e.complemento,' ') || ' ' || e.cidade || ' ' || e.estado || ' ' || e.pais || ' ' || e.codigopostal as endereco_comp
    FROM    Pedido p, Produto pd, Cliente c, Transportadora t, Endereco e, DetalhesPedido dp
    WHERE   p.codigoVendedor IS NOT NULL and p.codigo = dp.codigopedido and pd.codigo = dp.codigoproduto and
            c.codigo = p.codigocliente and t.codigo = p.codigotransportadora and e.id = p.enderecoentrega
    ORDER BY p.codigo;

-- TESTE
SELECT * FROM q3_PedidosOffline;

CREATE OR REPLACE TRIGGER q3_Gatilho
INSTEAD OF INSERT ON q3_PedidosOffline
FOR EACH ROW
DECLARE
    vPrecoProduto Produto.preco%TYPE;
BEGIN

    SELECT preco INTO vPrecoProduto FROM Produto WHERE codigo = :new.codigo_produto;

    INSERT INTO DETALHESPEDIDO (codigopedido, codigoproduto, quantidade, precounitario, desconto)
    VALUES (:new.codigo_pedido, :new.codigo_produto, 1, vPrecoProduto, 0);
    
END;