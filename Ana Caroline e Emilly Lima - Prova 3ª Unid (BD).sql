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
	
INSERT INTO Prontuario (data_internacao, motivo_internacao, fk_paciente) VALUES 	
	('01-10-2022', 'complicacoes diabetes', '1'), 
	('25-09-2022', 'crise de ansiedade extrema', '2'), 
	('23-09-2022', 'insuficiencia cardiaca', '3'),
	('04-10-2022', 'hipertensão', '3'),
	('10-08-2022', 'complicacoes obesidade', '3'), 
	('20-08-2022', 'complicacoes tireoide', '3'),
	('28-09-2022', 'crise de panico extrema', '3');
	
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
	
	
/* Criar uma view para acesso dos prontuários de um paciente */
CREATE VIEW ProntuarioPaciente AS
SELECT 
	p.nome AS paciente, 
	pr.data_internacao, 
	pr.duracao_internacao, 
	pr.motivo_internacao 
FROM paciente p, prontuario pr 
WHERE pr.fk_paciente=p.id

SELECT *
FROM ProntuarioPaciente

/* 1. Selecione todos os prontuários de um paciente, ordenados por data de internação, utilizando a view acima */

SELECT *
FROM ProntuarioPaciente
WHERE paciente = 'Julia Anacleto'
ORDER BY data_internacao 

/* Criar uma view para acesso das anotações de um prontuário */

CREATE VIEW AnotacoesPaciente AS
SELECT 
	p.nome AS paciente, 
	pr.data_internacao, 
	pr.duracao_internacao, 
	pr.motivo_internacao,
	m.nome AS medico,
	a.data AS data_anotacao, 
	a.informacoes,
	a.id
FROM paciente p, prontuario pr, medico m, anotacoesprontuario a
WHERE pr.fk_paciente=p.id AND a.fk_prontuario=pr.id AND a.fk_medico=m.id

SELECT *
FROM AnotacoesPaciente

/* 1. Selecione todas as informações anotadas em um prontuário, assim como o nome do médico, a data da anotação, a data de internação,
dos prontuários de um paciente, ordenados por prontuário, utilizando a view acima */

/*--Como não sabíamos qual ordenação a questão pedia exatamente, ordenamos tanto pelo ID quanto por data_anotacao, ambas de AnotacoesPaciente--*/

SELECT *
FROM AnotacoesPaciente
WHERE paciente='Julia Anacleto'
ORDER BY id

SELECT *
FROM AnotacoesPaciente
WHERE paciente='Julia Anacleto'
ORDER BY data_anotacao

/*TRIGGER
Explicar no vídeo o que são trigger, e mostrar exemplos de triggers
1. Criar um trigger que faz com que o status de um prontuário ativo seja atualizado para inativo quando um novo prontuário for inserido para aquele paciente */

CREATE OR REPLACE FUNCTION AlteracaoStatus() RETURNS TRIGGER AS $AlteracaoStatus$
    DECLARE prontuario_id INT;
	DECLARE paciente_id INT;
	BEGIN
		SELECT p.id, p.fk_paciente INTO prontuario_id, paciente_id
        FROM prontuario p
		WHERE p.fk_paciente = NEW.fk_paciente AND p.status = 'ativo'; 

		IF NEW.fk_paciente = paciente_id THEN 
		UPDATE prontuario SET status='inativo' WHERE id=prontuario_id;
		END IF;
		RETURN NEW;
    END;
$AlteracaoStatus$ LANGUAGE plpgsql;

CREATE TRIGGER AlteracaoStatus AFTER INSERT ON Prontuario
    FOR EACH ROW EXECUTE FUNCTION AlteracaoStatus();

/* 2. Criar um trigger que preenche o campo duracao_internacao quando uma internação for atualizada para inativa */

CREATE OR REPLACE FUNCTION DuracaoInternacao() RETURNS TRIGGER AS $DuracaoInternacao$
    DECLARE prontuario_id INT;
	DECLARE paciente_id INT;
	DECLARE duracao_internacao INT;
	BEGIN
		SELECT p.id, p.fk_paciente, p.duracao_internacao INTO prontuario_id, paciente_id
        FROM prontuario p
		WHERE p.fk_paciente = NEW.fk_paciente AND p.status = 'inativo'; 

		IF NEW.fk_paciente = paciente_id THEN 
		UPDATE prontuario SET duracao_internacao='10' WHERE id=prontuario_id;
		END IF;
		RETURN NEW;
    END;
$DuracaoInternacao$ LANGUAGE plpgsql;

CREATE TRIGGER DuracaoInternacao AFTER INSERT ON Prontuario
    FOR EACH ROW EXECUTE FUNCTION DuracaoInternacao();
	

INSERT INTO Prontuario (data_internacao, motivo_internacao, fk_paciente) VALUES 		
('19-12-2022', 'sinusite', '1')