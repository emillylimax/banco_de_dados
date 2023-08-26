CREATE TABLE IF NOT EXISTS carro (
    id serial,
    ano int,
    modelo text,
    marca text,
    chassi varchar(17),
    novo boolean,
    quilometragem float,
    PRIMARY KEY (id)
)

CREATE TABLE IF NOT EXISTS cliente (
    id serial,
    nome text,
    data_nascimento date,
    endereco text,
    cpf varchar (11),
    PRIMARY KEY (id)
)

CREATE TABLE IF NOT EXISTS funcionario (
    id serial,
    nome text,
    data_nascimento date,
    endereco text,
    cpf varchar (11),
    carteira_trabalho varchar (8),
    tipo_contrato text,
    email text,
    login text,
    senha text,
    PRIMARY KEY (id)
)

CREATE TABLE IF NOT EXISTS venda (
    numero_venda serial,
    data date,
    preco money,
    forma_pagamento text,
    qtd_parcelas int,
    fk_carro int,
    fk_vendedor int,
    fk_cliente int,
    PRIMARY KEY (numero_venda),
    FOREIGN KEY (fk_carro) REFERENCES carro (id),
    FOREIGN KEY (fk_vendedor) REFERENCES funcionario (id),
    FOREIGN KEY (fk_cliente) REFERENCES cliente (id)
)

CREATE TABLE IF NOT EXISTS entradacarro (
    fk_carro int,
    fk_venda int,
    valor money,
    PRIMARY KEY (fk_carro, fk_venda),
    FOREIGN KEY (fk_carro) REFERENCES carro (id),
    FOREIGN KEY (fk_venda) REFERENCES venda (numero_venda)
)

CREATE TABLE IF NOT EXISTS parcela (
    id serial,
    data_vencimento date,
    valor_parcela money,
    fk_venda int,
    PRIMARY KEY (id),
    FOREIGN KEY (fk_venda) REFERENCES venda (numero_venda)
)
   
CREATE TABLE IF NOT EXISTS aluguel (
    id serial, 
    data_inicio date,
    data_fim date,
    preco money,
    forma_pagamento text,
    fk_carro int,
    fk_cliente int, 
    fk_vendedor int,
    PRIMARY KEY (id),
    FOREIGN KEY (fk_carro) REFERENCES carro (id),
    FOREIGN KEY (fk_cliente) REFERENCES cliente (id),
    FOREIGN KEY (fk_vendedor) REFERENCES funcionario (id)
)

CREATE TABLE IF NOT EXISTS motorista (
    id serial,
    nome text,
    data_nascimento date,
    endereco text,
    cpf varchar (11),
    carteira_motorista varchar (11),
    PRIMARY KEY (id)
)

CREATE TABLE IF NOT EXISTS motorista_aluguel (
    fk_aluguel int,
    fk_motorista int,
    FOREIGN KEY (fk_aluguel) REFERENCES aluguel (id),
    FOREIGN KEY (fk_motorista) REFERENCES motorista (id)
)

INSERT INTO carro (ano, modelo, marca, chassi, novo, quilometragem) VALUES
    ('2022', 'compass', 'jeep', '12345678910111213', 'true', '0'),
    ('1997', 'vitara', 'suzuki', '10101010101010101','false', '1321623'),
    ('2000', 'gol', 'volkswagen', '20202020202020202', 'false', '345623'),
    ('2022', 'argo', 'fiat', '30303030303030303', 'true', '1000'),
    ('2022', 'samurai', 'suzuki', '40404040404040404', 'true', '2000')
    
INSERT INTO cliente (nome, data_nascimento, endereco, cpf) VALUES
    ('carla', '30-03-1989', 'rua só jesus sabe', '45678912345'),
    ('carol', '14-05-2003', 'rua dos bobos', '46312789643'),
    ('emilly', '17-03-1993', 'rua das orquídeas', '12459873105'),
    ('angela', '25-08-1993', 'rua ponta negra', '78563421631'),
    ('alefe','10-05-2004', 'rua macaiba', '15642398410')
    
INSERT INTO funcionario (nome, data_nascimento, endereco, cpf, carteira_trabalho, tipo_contrato, email, login, senha) VALUES
    ('alessandra', '15-10-1975', 'rua dos saberes', '07894563181', '13846175', 'CLT', 'alessandrinha123@gmail.com', 'alessandra', 'alessandra123'),
    ('tasia', '10-05-1980', 'rua dos numeros', '78512364910', '17563486', 'CLT', 'tasia123@gmail.com', 'tasia', 'tasia123')

INSERT INTO venda (data, preco, forma_pagamento, qtd_parcelas, fk_carro, fk_vendedor, fk_cliente) VALUES
    ('26-09-2022', '25000', 'a vista', '0', '2', '2', '2'),
    ('23-09-2022', '10000', 'a vista', '0', '3', '1', '3'),
    ('28-09-2022', '200000', 'parcelado','3', '1', '1', '1'),
    ('29-09-2022', '150000', 'parcelado', '2', '4', '2', '1')
    
INSERT INTO entradacarro (fk_carro, fk_venda, valor) VALUES
    ('1', '3', '10000'),
    ('4', '4', '15000')

/*UPDATE DATE entradacarro
SET fk_venda = '3'
WHERE fk_carro = '1'*/

INSERT INTO parcela (data_vencimento, valor_parcela, fk_venda) VALUES
    ('20-11-2022', '63333', '3'),
	('20-12-2022', '63333', '3'),
	('20-01-2023', '63333', '3'),
    ('25-11-2022', '67500', '2'),
	('25-12-2022', '67500', '2')

INSERT INTO aluguel (data_inicio, data_fim, preco, forma_pagamento, fk_carro, fk_cliente, fk_vendedor) VALUES
    ('20-11-2022', '20-02-2023', '30000','a vista','5','3','1'),
	('25-12-2022', '25-03-2023', '40000', 'a vista','3','5','2')
	
INSERT INTO motorista (nome, data_nascimento, endereco, cpf, carteira_motorista) VALUES
	('danilo', '04-09-1985', 'rua dos pardais', '93746528734', '03627836547'),
	('claudio', '18-02-1970', 'rua do abacaxi', '83725493823', '57369045217'),
	('rose', '26-03-1980', 'rua dos pinheiros', '87364519783', '75846584673'),
	('janete', '02-01-1994', 'rua america', '73826574567', '84673956478')

INSERT INTO motorista_aluguel (fk_aluguel, fk_motorista) VALUES
	('1', '1'),
	('1', '2'),
	('1', '3'),
	('2', '4'),
	('2', '2')

SELECT v.data, v.preco, car.ano, car.modelo, car.chassi, c.nome
FROM venda v, carro car, cliente c
WHERE c.nome = 'carla' AND v.fk_carro = car.id AND v.fk_cliente = c.id

SELECT car.ano, car.modelo, car.chassi, m.nome, a.data_inicio, a.data_fim 
FROM carro car, motorista m, aluguel a, motorista_aluguel ma
WHERE m.nome = 'danilo' AND a.fk_carro = car.id AND ma.fk_aluguel = a.id AND ma.fk_motorista = m.id

SELECT car.ano, car.modelo, car.chassi, v.data, c.nome
FROM carro car, venda v, cliente c, entradacarro e
WHERE v.fk_carro = car.id AND e.fk_carro = car.id AND e.fk_venda = v.numero_venda AND v.fK_cliente = c.id

SELECT v.numero_venda, p.valor_parcela, p.data_vencimento, car.modelo, car. ano
FROM venda v, parcela p, carro car
WHERE p.fk_venda = v.numero_venda AND v.fk_carro = car.id AND car.modelo = 'compass'

	