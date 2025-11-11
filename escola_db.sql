/*
 * ARQUIVO: escola_db.sql
 * DESCRIÇÃO: Script completo para criação e manipulação do banco de
 * dados de um Sistema de Gestão Escolar.
 */

-- Inicia uma transação para garantir a integridade
BEGIN;

/*
 * PARTE 1: MODELAGEM (CREATE TABLES)
 * Definição das entidades, relacionamentos e restrições.
 */

-- Tabela de Alunos
-- Armazena os dados pessoais dos estudantes.
CREATE TABLE Alunos (
    aluno_id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Tabela de Disciplinas
-- Armazena as disciplinas oferecidas.
CREATE TABLE Disciplinas (
    disciplina_id SERIAL PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    professor_responsavel VARCHAR(100)
);

-- Tabela de Matrículas (Tabela Associativa)
-- Liga um Aluno a uma Disciplina, representando a matrícula.
-- Esta é a tabela central para notas e frequência.
CREATE TABLE Matriculas (
    matricula_id SERIAL PRIMARY KEY,
    aluno_id INT NOT NULL,
    disciplina_id INT NOT NULL,
    ano_letivo INT NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    
    -- Restrições de Chave Estrangeira
    FOREIGN KEY (aluno_id) REFERENCES Alunos(aluno_id) ON DELETE CASCADE,
    FOREIGN KEY (disciplina_id) REFERENCES Disciplinas(disciplina_id) ON DELETE CASCADE,
    
    -- Restrição para evitar duplicidade (aluno não pode se matricular 2x na mesma disciplina no mesmo ano)
    UNIQUE(aluno_id, disciplina_id, ano_letivo)
);

-- Tabela de Notas
-- Armazena as notas de um aluno em uma matrícula específica.
CREATE TABLE Notas (
    nota_id SERIAL PRIMARY KEY,
    matricula_id INT NOT NULL,
    tipo_avaliacao VARCHAR(50) NOT NULL, -- Ex: 'P1', 'Trabalho', 'Seminário'
    nota_valor DECIMAL(4, 2) NOT NULL CHECK (nota_valor >= 0 AND nota_valor <= 10),
    
    FOREIGN KEY (matricula_id) REFERENCES Matriculas(matricula_id) ON DELETE CASCADE
);

-- Tabela de Frequência
-- Armazena os registros de presença (ou falta) de um aluno em uma matrícula.
CREATE TABLE Frequencia (
    frequencia_id SERIAL PRIMARY KEY,
    matricula_id INT NOT NULL,
    data_aula DATE NOT NULL,
    presente BOOLEAN NOT NULL, -- true para presente, false para falta
    
    FOREIGN KEY (matricula_id) REFERENCES Matriculas(matricula_id) ON DELETE CASCADE,
    
    -- Um aluno só pode ter um registro de frequência por dia de aula em uma matrícula
    UNIQUE(matricula_id, data_aula)
);


/*
 * PARTE 2: MANIPULAÇÃO (INSERT)
 * Inserção de dados de exemplo para popular o banco.
 */

-- Inserir Alunos
INSERT INTO Alunos (nome_completo, data_nascimento, email) VALUES
('Ana Clara Souza', '2005-04-12', 'ana.souza@email.com'),
('Bruno Martins Silva', '2006-01-30', 'bruno.silva@email.com'),
('Carla Dias Antunes', '2005-11-22', 'carla.antunes@email.com');

-- Inserir Disciplinas
INSERT INTO Disciplinas (nome_disciplina, professor_responsavel) VALUES
('Matemática', 'Prof. Ricardo Neves'),
('Língua Portuguesa', 'Profa. Mônica Valente'),
('Educação Física', 'Prof. Leonardo Vilarinho');

-- Inserir Matrículas (associando alunos às disciplinas)
-- (Vamos assumir que os IDs são 1, 2, 3 para alunos e disciplinas)
INSERT INTO Matriculas (aluno_id, disciplina_id, ano_letivo) VALUES
(1, 1, 2025), -- Ana em Matemática (Matrícula ID 1)
(1, 2, 2025), -- Ana em Língua Portuguesa (Matrícula ID 2)
(2, 1, 2025), -- Bruno em Matemática (Matrícula ID 3)
(3, 3, 2025); -- Carla em Educação Física (Matrícula ID 4)

-- Inserir Notas
INSERT INTO Notas (matricula_id, tipo_avaliacao, nota_valor) VALUES
(1, 'P1', 8.5),
(1, 'Trabalho', 9.0),
(2, 'P1', 7.0),
(3, 'P1', 6.5),
(4, 'Seminário', 10.0);

-- Inserir Frequência
INSERT INTO Frequencia (matricula_id, data_aula, presente) VALUES
(1, '2025-03-05', true),
(1, '2025-03-06', true),
(1, '2025-03-07', false), -- Ana faltou em BD
(3, '2025-03-05', true),
(3, '2025-03-06', false); -- Bruno faltou em BD


/*
 * PARTE 3: MANIPULAÇÃO (UPDATE, DELETE, SELECT)
 * Exemplos de comandos de atualização, remoção e consulta.
 */

-- 1. UPDATE (Atualização)
-- Corrigir a nota da P1 do Bruno (Matrícula 3) que foi digitada errada.
UPDATE Notas
SET nota_valor = 7.0
WHERE matricula_id = 3 AND tipo_avaliacao = 'P1';


-- 2. DELETE (Remoção)
-- Remover um registro de frequência lançado por engano.
DELETE FROM Frequencia
WHERE frequencia_id = 5; -- Remove a falta do Bruno do dia 06/03


-- 3. SELECT (Consultas)

-- Consulta 3a: Simples - Listar todos os alunos
SELECT * FROM Alunos;


-- Consulta 3b: Média - Calcular a média de notas da Ana na P1
-- (Apenas como exemplo, idealmente seria feito na aplicação)
SELECT AVG(N.nota_valor) AS media_p1_ana
FROM Notas N
JOIN Matriculas M ON N.matricula_id = M.matricula_id
JOIN Alunos A ON M.aluno_id = A.aluno_id
WHERE A.nome_completo = 'Ana Clara Souza' AND N.tipo_avaliacao = 'P1';


-- Consulta 3c: Complexa (JOIN) - "Boletim"
-- Listar todos os alunos, suas disciplinas, notas e avaliações.
SELECT
    A.nome_completo AS Aluno,
    D.nome_disciplina AS Disciplina,
    N.tipo_avaliacao AS Avaliacao,
    N.nota_valor AS Nota
FROM Alunos A
JOIN Matriculas M ON A.aluno_id = M.aluno_id
JOIN Disciplinas D ON M.disciplina_id = D.disciplina_id
JOIN Notas N ON M.matricula_id = N.matricula_id
ORDER BY Aluno, Disciplina;


-- Consulta 3d: Complexa (Agregação) - Contagem de Faltas
-- Contar quantas faltas cada aluno teve em cada disciplina.
SELECT
    A.nome_completo AS Aluno,
    D.nome_disciplina AS Disciplina,
    COUNT(*) AS Total_de_Faltas
FROM Frequencia F
JOIN Matriculas M ON F.matricula_id = M.matricula_id
JOIN Alunos A ON M.aluno_id = A.aluno_id
JOIN Disciplinas D ON M.disciplina_id = D.disciplina_id
WHERE F.presente = false -- Apenas onde o aluno faltou
GROUP BY A.nome_completo, D.nome_disciplina;


-- Finaliza a transação
COMMIT;