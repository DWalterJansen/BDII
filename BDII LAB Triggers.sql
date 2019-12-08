DECLARE Delta INTERVAL DAY(5) TO SECOND;
BEGIN
SELECT Trunc(SYSDATE) - Max(DTPedido) INTO Delta FROM Pedido;
UPDATE Pedido
SET DTENVIO=DTENVIO + Delta,
DTPEDIDO=DTPEDIDO + Delta,
DTRECEBIMENTO=DTRECEBIMENTO + Delta;
UPDATE Produto
SET DTINICIOVENDA=DTINICIOVENDA + Delta+410,
DTFIMVENDA=DTFIMVENDA + Delta+500;
DBMS_OUTPUT.Put_Line('Avançou ' || delta || ' dias.');
END;
-----------------------------------------------------------
-----------------------------------------------------------
-- Questão 1
-- Criando tabela
CREATE TABLE ativpedido (
    codigopedido NUMBER,
    codigoproduto NUMBER,
    dtpedido DATE,
    dteventoreg DATE,
    descricao VARCHAR2(500)
);

ALTER TABLE ativpedido
ADD CONSTRAINT ativpedido_pk PRIMARY KEY (codigopedido);


CREATE OR REPLACE TRIGGER questao1Pedido
BEFORE INSERT ON Pedido
FOR EACH ROW
BEGIN
    :new.dtpedido := sysdate;
    :new.dtenvio := NULL;
    :new.dtrecebimento := NULL;
    :new.codigoconfirmacao := NULL;
END;

CREATE OR REPLACE TRIGGER questao1DtPedido
AFTER INSERT ON DetalhesPedido
FOR EACH ROW
BEGIN
    INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    VALUES (:new.codigopedido, :new.codigoproduto, (select dtpedido from Pedido where codigo = :new.codigopedido), sysdate, 'Pedido ' || :new.codigopedido || ' criado com o produto ' || :new.codigoproduto);
END;

-----------------------------------------------------------
-----------------------------------------------------------
-- Questão 2
CREATE OR REPLACE TRIGGER questao2DetalhesPedido
BEFORE INSERT ON DetalhesPedido
FOR EACH ROW
DECLARE
-- Variavel de exception
    vAbortar EXCEPTION;
    vDataFimVenda DATE;
    vDataPedido DATE;
    vDataEnvio DATE;
BEGIN
    SELECT dtfimvenda INTO vDataFimVenda FROM Produto WHERE codigo = :new.codigoproduto;
    SELECT dtpedido INTO vDataPedido FROM Pedido WHERE codigo = :new.codigopedido;
    SELECT dtenvio INTO vDataEnvio FROM Pedido WHERE codigo = :new.codigopedido;
    
    IF(vDataFimVenda <= vDataPedido) THEN
        RAISE vAbortar;
    END IF;
    
    -- Log de Insert
    INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    VALUES (:new.codigopedido, :new.codigoproduto, vDataPedido, sysdate, 'Produto ' || :new.codigoproduto || ' inserido no pedido ' || :new.codigopedido);
    
    EXCEPTION
    	WHEN vAbortar THEN
        	INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    		VALUES (:new.codigopedido, :new.codigoproduto, vDataPedido, sysdate, 'Produto ' || :new.codigoproduto || ' não inserido no pedido ' || :new.codigopedido);
END;

-----------------------------------------------------------
-----------------------------------------------------------
-- Questão 3
CREATE OR REPLACE TRIGGER questao3DetalhesPedido
BEFORE DELETE ON DetalhesPedido
FOR EACH ROW
DECLARE
-- Variavel de exception
    vAbortar EXCEPTION;
    vDataFimVenda DATE;
    vDataPedido DATE;
    vDataEnvio DATE;
BEGIN
    SELECT dtfimvenda INTO vDataFimVenda FROM Produto WHERE codigo = :new.codigoproduto;
    SELECT dtpedido, dtenvio INTO vDataPedido, vDataEnvio FROM Pedido WHERE codigo = :new.codigopedido;
    
    IF(NOT (vDataEnvio IS NULL and vDataFimVenda < sysdate)) THEN
        RAISE vAbortar;
    END IF;
    
    -- Log de Delete
    INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    VALUES (:old.codigopedido, :old.codigoproduto, vDataPedido, sysdate, 'Produto ' || :old.codigoproduto || ' removido do pedido ' || :old.codigopedido);
    
    EXCEPTION
    WHEN vAbortar THEN
    	INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    	VALUES (:old.codigopedido, :old.codigoproduto, vDataPedido, sysdate, 'Produto ' || :old.codigoproduto || 'não pode ser removido do pedido ' || :old.codigopedido);
END;

-----------------------------------------------------------
-----------------------------------------------------------
-- Questão 4
CREATE OR REPLACE TRIGGER questao4Pedido
BEFORE UPDATE ON Pedido
FOR EACH ROW
DECLARE
-- Variavel de exception
    vAbortar EXCEPTION;
    vAbortarCampos EXCEPTION;
    vDataPedido DATE;
    vDataEnvio DATE;
BEGIN
    SELECT dtpedido, dtenvio INTO vDataPedido, vDataEnvio FROM Pedido WHERE codigo = :new.codigo;
    
    IF(NOT (vDataEnvio IS NULL)) THEN
        RAISE vAbortar;
    END IF;
    
    IF(NOT (
      :old.codigo = :new.codigo and
      :old.dtpedido = :new.dtpedido and
      :old.dtenvio = :new.dtenvio and
      :old.dtrecebimento = :new.dtrecebimento and
      :old.codigocliente = :new.codigocliente and
      :old.contacliente = :new.contacliente and
      :old.codigoconfirmacao = :new.codigoconfirmacao and
      :old.imposto = :new.imposto and
      :old.qtdcomprados = :new.qtdcomprados and
      :old.valortotalprodutos = :new.valortotalprodutos and
      :old.valortotalfrete = :new.valortotalfrete and
      :old.valortotalpedido = :new.valortotalpedido   
    )) THEN
    	RAISE vAbortarCampos;
    END IF;
    
    -- Log de Delete
    INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    VALUES (:old.codigo, NULL, vDataPedido, sysdate, 'Pedido ' || :old.codigo || ' atualizado com sucesso!');
    
    EXCEPTION
    WHEN vAbortar THEN
    	INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    VALUES (:old.codigo, NULL, vDataPedido, sysdate, 'Pedido ' || :old.codigo || ' não pode ser atualizado porque já tem data de envio');
    
    WHEN vAbortarCampos THEN
    	INSERT INTO ativpedido (codigopedido, codigoproduto, dtpedido, dteventoreg, descricao)
    VALUES (:old.codigo, NULL, vDataPedido, sysdate, 'Pedido ' || :old.codigo || ' não pode ser atualizado nesses campos');
END;