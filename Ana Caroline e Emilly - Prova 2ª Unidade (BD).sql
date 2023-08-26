CREATE TABLE IF NOT EXISTS Paciente (
	id SERIAL, 
	nome TEXT, 
	data_nascimento DATE, 
	endereco TEXT, 
	cpf VARCHAR(11), 
	PRIMARY kEY(id)
);

CREATE TABLE IF NOT EXISTS Prontuario (
	id SERIAL, 
	data_internacao DATE, 
	duracao_internacao INT DEFAULT 0, 
	motivo_internacao TEXT, 
	fk_paciente INT, 
	status TEXT DEFAULT 'ativo', 
	FOREIGN KEY (fk_paciente) REFERENCES Paciente (id),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Medico ( 
	id SERIAL, 
	nome TEXT,
	especialidade TEXT, 
	crm INT, 
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS AnotacoesProntuario (
	id SERIAL, 
	data DATE, 
	informacoes TEXT, 
	fk_medico INT, 
	fk_prontuario INT,
	FOREIGN KEY (fk_medico) REFERENCES Medico (id),
	FOREIGN KEY (fk_prontuario) REFERENCES Prontuario (id),
	PRIMARY KEY (id)
);

INSERT INTO Paciente (nome, data_nascimento, endereco, cpf) VALUES 
	('Carla Fernandes', '28-04-1992', 'rua dos passaros', '97256715845'),
	('Camila Castro', '01-05-1989', 'rua das palmeiras', '46389756601'),
	('Julia Anacleto', '16-07-1990', 'rua do abacaxi', '04673864092'),
	('Ana Cecilia Nascimento', '23-05-2000', 'rua da colina', '51472967340'),
	('Juliana Pedrosa', '10-12-2002', 'rua da praia', '05763986753');
	
INSERT INTO Medico (nome, especialidade, crm) VALUES 
	('Danilo','cardiologista', '937548'),
	('Joao', 'endocrinologista', '846793'),
	('Andreia', 'dermatologista', '951874'),
	('Claudia', 'psiquiatra', '749983'),
	('Pedro', 'neurologista', '156385');	
	
INSERT INTO Prontuario (data_internacao, duracao_internacao, motivo_internacao, fk_paciente) VALUES 	
	('01-10-2022', '10', 'complicacoes diabetes', '1'), 
	('25-09-2022', '20', 'crise de ansiedade extrema', '2'), 
	('23-09-2022', '15', 'insuficiencia cardiaca', '3'),
	('04-10-2022', '10', 'hipertensão', '3'),
	('10-08-2022', '30', 'complicacoes obesidade', '3'), 
	('20-08-2022', '20','complicacoes tireoide', '3'),
	('28-09-2022', '25', 'crise de panico extrema', '3');
	
INSERT INTO AnotacoesProntuario (data, informacoes, fk_medico, fk_prontuario) VALUES 	
	('05-10-2022', 'hemodialise realizada', '2', '1'),
	('05-10-2022', 'medicacao administrada', '4', '2'),
	('05-10-2022', 'eletrocardiograma realizado', '2', '3'),
	('05-10-2022', 'medicacao administrada', '4', '3'),
	('04-10-2022', 'necessario exame glicemia', '2', '5'),
	('05-09-2022', 'exame tireoide', '2', '5'),
	('02-09-2022', 'solicitacao eletrocardiograma', '1', '5'),
	('01-09-2022', 'solicitacao hemograma', '4', '5'),	
	('01-09-2022', 'medicacao necessaria', '4', '5');	
	
	
/* 1. Altere o status de dois prontuários para inativo */
UPDATE prontuario 
SET status='inativo' 
WHERE id=5 OR id=6	

/* 2. Altere o CPF do paciente Carla para 01323344599 */
UPDATE paciente 
SET cpf='01323344599' 
WHERE nome='Carla Fernandes'

/* 3. Delete o médico com nome Pedro */
DELETE FROM medico
WHERE nome='Pedro'

/* 4. Buscar todos os pacientes que tenham c no seu nome (maiúsculo ou minúsculo) */
SELECT nome
FROM paciente
WHERE UPPER (nome) LIKE UPPER ('%c%')

/* 5.Selecione o nome de todos os pacientes que estão internados, ou seja, que tem um
prontuário ativo */
SELECT DISTINCT p.nome, pr.status
FROM paciente AS p
JOIN prontuario AS pr
ON pr.status='ativo' AND pr.fk_paciente=p.id

/* 6. Selecione o valor médio de duração das internações */
SELECT ROUND (AVG (duracao_internacao))
FROM prontuario

/* 7. Selecione o valor médio de duração das internações finalizadas, ou seja, inativas */
SELECT ROUND (AVG (duracao_internacao))
FROM prontuario
WHERE status='inativo'

/* 8. Selecione as internações com maior e menor duração */
SELECT 
MAX (duracao_internacao) AS maior_duracao,
MIN (duracao_internacao) AS menor_duracao
FROM prontuario 

/* 9. Selecione a quantidade de internações por paciente */
SELECT p.nome AS paciente, COUNT(*) AS qtd_internacoes
FROM (paciente p JOIN prontuario pr ON pr.fk_paciente =p.id)
GROUP BY p.id

/* 10. Selecione a quantidade de Anotações em Prontuário por médico */
SELECT m.nome as medico, COUNT(*) AS qtd_anotacoes
FROM (medico m JOIN anotacoesProntuario a ON a.fk_medico=m.id)
GROUP BY m.id

/* 11. Selecione a quantidade de Anotações em Prontuário por médico, por prontuário*/
SELECT DISTINCT m.nome AS medico, pr.id AS id_prontuario, COUNT(*) AS quantidade
FROM (prontuario pr JOIN anotacoesProntuario a ON a.fk_prontuario=pr.id) JOIN medico m ON a.fk_medico=m.id
GROUP BY m.id, pr.id

/* 12. Selecione os médicos que não fizeram anotação em nenhum prontuário */
SELECT nome AS medico
FROM Medico
WHERE id IN (
	SELECT id AS Id_medico FROM Medico 
	EXCEPT
	SELECT fk_medico FROM AnotacoesProntuario
)

/* 13. Selecione os médicos que visitaram a paciente Carla e a paciente Júlia */
SELECT DISTINCT m.nome
FROM anotacoesProntuario a, medico m, prontuario pr, paciente p
WHERE a.fk_medico = m.id AND
		a.fk_prontuario = pr.id AND
		pr.fk_paciente = p.id AND
		p.nome='Carla Fernandes'
INTERSECT
SELECT DISTINCT m.nome
FROM anotacoesProntuario a, medico m, prontuario pr, paciente p
WHERE a.fk_medico = m.id AND
		a.fk_prontuario = pr.id AND
		pr.fk_paciente = p.id AND
		p.nome='Julia Anacleto'

/* 14. Selecione os médicos que visitaram a paciente Carla e não visitaram a paciente Júlia */
SELECT DISTINCT m.nome
FROM anotacoesProntuario a, medico m, prontuario pr, paciente p
WHERE a.fk_medico = m.id AND
		a.fk_prontuario = pr.id AND
		pr.fk_paciente = p.id AND
		p.nome='Julia Anacleto'
EXCEPT
SELECT DISTINCT m.nome
FROM anotacoesProntuario a, medico m, prontuario pr, paciente p
WHERE a.fk_medico = m.id AND
		a.fk_prontuario = pr.id AND
		pr.fk_paciente = p.id AND
		p.nome='Carla Fernandes'

/* 15. Selecione os pacientes ordenados por ordem alfabética. */
SELECT nome
FROM paciente
ORDER BY nome ASC

/* 16. Selecione os médicos que visitaram dois ou mais pacientes no dia 05/10/2022 */
SELECT m.nome AS medico, COUNT(*) AS quantidadeVisita, a.data AS data
FROM (medico m JOIN anotacoesProntuario a ON m.id=a.fk_medico)
WHERE a.data = '2022-10-05'
GROUP BY m.nome, a.data
HAVING COUNT (*) >=2

/* 17. Selecione os pacientes (nome) que foram visitados por pelo menos 2 médicos durante sua estadia, 
já tendo sido liberados, ou seja, o status do prontuário já está inativo*/
SELECT p.nome AS paciente, COUNT (DISTINCT fk_medico) AS qtd_medicos, pr.status AS status
FROM (prontuario pr JOIN anotacoesProntuario a ON pr.id=a.fk_prontuario) JOIN paciente p ON p.id = pr.fk_paciente AND pr.status = 'inativo'
GROUP BY p.nome, pr.status
HAVING COUNT (*) >=2