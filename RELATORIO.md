Relatório do Projeto: Modelagem de Banco de Dados e Controle de Versão

Aluno: Daniel Felipe Führ
Curso: Tecnologia da Informação
Disciplina: Projeto Integrador II
Módulo: 3

1. Introdução

Este relatório detalha o desenvolvimento de um projeto para o Módulo 3, que integra os conceitos de modelagem e manipulação de banco de dados com o uso de sistemas de controle de versão (Git e GitHub).

O tema escolhido para o projeto foi um Sistema de Gerenciamento Escolar, com foco no armazenamento e consulta de informações vitais como matrículas, notas e frequência dos alunos.

2. Modelagem e Manipulação de Banco de Dados

A seção a seguir descreve o modelo de dados, a implementação do esquema SQL e as operações de manipulação de dados.

2.1. Modelo de Dados (Entidades e Relacionamentos)

O banco de dados foi projetado para ser relacional e normalizado, separando as responsabilidades em cinco entidades principais:

Alunos: Armazena os dados cadastrais dos estudantes (ID, nome, data de nascimento, etc.).

Disciplinas: Armazena as disciplinas oferecidas pela instituição (ID, nome, professor).

Matriculas: Tabela associativa (N-para-N) que vincula um Aluno a uma Disciplina em um determinado ano_letivo. Esta é a entidade central que permite que um aluno curse várias disciplinas e que uma disciplina tenha vários alunos.

Notas: Vincula-se a uma Matricula (1-para-N). Permite que cada matrícula tenha múltiplos registros de avaliação (P1, P2, Trabalho, etc.) com suas respectivas notas.

Frequencia: Vincula-se a uma Matricula (1-para-N). Permite o registro diário de presença (true) ou falta (false) para um aluno em uma disciplina específica.

Este modelo garante a integridade dos dados (evitando duplicidade) e oferece grande flexibilidade para consultas complexas, como a geração de boletins ou relatórios de assiduidade.

2.2. Implementação do Esquema (SQL - CREATE)

O esquema foi implementado utilizando comandos DDL (Data Definition Language) do SQL. As chaves primárias (PRIMARY KEY), chaves estrangeiras (FOREIGN KEY) e restrições (NOT NULL, UNIQUE, CHECK) foram utilizadas para garantir a integridade referencial e a validade dos dados.

/* --- Criação das Tabelas --- */

CREATE TABLE Alunos (
    aluno_id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Disciplinas (
    disciplina_id SERIAL PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    professor_responsavel VARCHAR(100)
);

CREATE TABLE Matriculas (
    matricula_id SERIAL PRIMARY KEY,
    aluno_id INT NOT NULL,
    disciplina_id INT NOT NULL,
    ano_letivo INT NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    
    FOREIGN KEY (aluno_id) REFERENCES Alunos(aluno_id) ON DELETE CASCADE,
    FOREIGN KEY (disciplina_id) REFERENCES Disciplinas(disciplina_id) ON DELETE CASCADE,
    UNIQUE(aluno_id, disciplina_id, ano_letivo)
);

CREATE TABLE Notas (
    nota_id SERIAL PRIMARY KEY,
    matricula_id INT NOT NULL,
    tipo_avaliacao VARCHAR(50) NOT NULL, 
    nota_valor DECIMAL(4, 2) NOT NULL CHECK (nota_valor >= 0 AND nota_valor <= 10),
    FOREIGN KEY (matricula_id) REFERENCES Matriculas(matricula_id) ON DELETE CASCADE
);

CREATE TABLE Frequencia (
    frequencia_id SERIAL PRIMARY KEY,
    matricula_id INT NOT NULL,
    data_aula DATE NOT NULL,
    presente BOOLEAN NOT NULL,
    FOREIGN KEY (matricula_id) REFERENCES Matriculas(matricula_id) ON DELETE CASCADE,
    UNIQUE(matricula_id, data_aula)
);


2.3. Operações de Manipulação de Dados (SQL DML)

Para validar o modelo, foram executadas operações de DML (Data Manipulation Language), incluindo INSERT, UPDATE, DELETE e SELECT.

Inserção (INSERT)

Dados de exemplo foram inseridos para 3 alunos, 3 disciplinas e suas respectivas matrículas, notas e registros de frequência.

INSERT INTO Alunos (nome_completo, data_nascimento, email) VALUES
('Ana Clara Souza', '2005-04-12', 'ana.souza@email.com'),
('Bruno Martins Silva', '2006-01-30', 'bruno.silva@email.com');

INSERT INTO Disciplinas (nome_disciplina, professor_responsavel) VALUES
('Banco de Dados', 'Prof. Ricardo Neves'),
('Engenharia de Software', 'Profa. Mônica Valente');


(As inserções completas estão no arquivo escola_db.sql)

Atualização (UPDATE)

Exemplo de correção de uma nota lançada incorretamente:

UPDATE Notas
SET nota_valor = 7.0
WHERE matricula_id = 3 AND tipo_avaliacao = 'P1';


Remoção (DELETE)

Exemplo de remoção de um registro de frequência duplicado ou errôneo:

DELETE FROM Frequencia
WHERE frequencia_id = 5;


Consultas (SELECT)

Foram elaboradas consultas para extrair informações do banco. O exemplo mais relevante é a consulta de "Boletim", que utiliza JOIN para unir 4 tabelas e exibir as notas dos alunos em suas respectivas disciplinas.

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


3. Controle de Versão (Git e GitHub)

Todo o desenvolvimento deste projeto foi gerenciado utilizando o sistema de controle de versão Git. O código-fonte, incluindo o script escola_db.sql e este relatório (RELATORIO.md), foi versionado em um repositório no GitHub.

Foram utilizados commits frequentes com mensagens descritivas (seguindo o padrão Conventional Commits quando possível) para registrar a evolução do projeto, desde a criação inicial do esquema até a adição das consultas de manipulação.

3.1. Link do Repositório no GitHub

O projeto completo, incluindo todo o código-fonte SQL e o histórico de commits, está disponível publicamente no seguinte repositório:

(https://github.com/fuhrdaniel/Gestao-de-Dados-Escolares)


4. Bibliografia

A seguir, a bibliografia utilizada como base teórica para o desenvolvimento do projeto.

4.1. Leitura Obrigatória

DUCKETT, Jon. PHP & MYSQL: desenvolvimento web no lado do servidor. Rio de Janeiro: Alta Books, 2024. ISBN 9786555205930. Disponível na Biblioteca Digital da UFMS. Trecho lido: Seção C - Sites orientados a banco de dados.

VALENTE, Marco Tulio. Engenharia de software moderna: princípios e práticas para desenvolvimento de software com produtividade. v. 1, n. 24, 2020. Disponível em: https://link.ufms.br/G5d6h. Acesso em 13 jan. 2025. Trecho lido: Apêndice A - Git.

VILARINHO, Leonardo. Front-end com Vue.js: da teoria à prática sem complicações. São Paulo, SP: Casa do Código, 2021. E-book. Disponível na Biblioteca Digital da UFMS. Acesso em: 13 jan. 2025. Trecho lido: Capítulo 4 - Criando e exibindo dados.

VILARINHO, Leonardo. Front-end com Vue.js: da teoria à prática sem complicações. São Paulo, SP: Casa do Código, 2021. E-book. Disponível na Biblioteca Digital da UFMS. Acesso em: 13 jan. 2025. Trecho lido: Capítulo 5 - Manipulando dados.

4.2. Leitura Complementar

VALENTE, Marco Tulio. Engenharia de software moderna: princípios e práticas para desenvolvimento de software com produtividade. v. 1, n. 24, 2020. Disponível em: https://link.ufms.br/ye4Sd. Acesso em 13 jan. 2025. Trecho lido: Capítulo 10 - DevOps.

VILARINHO, Leonardo. Front-end com Vue.js: da teoria à prática sem complicações. São Paulo, SP: Casa do Código, 2021. E-book. Disponível na Biblioteca Digital da UFMS. Acesso em: 13 jan. 2025. Trecho lido: Capítulo 6 - Componentes juntos são mais fortes.