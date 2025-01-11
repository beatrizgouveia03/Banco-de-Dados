-- CRIAÇÃO DE EXEMPLAR:
CREATE OR REPLACE FUNCTION f_set_copy_status_available()
RETURNS trigger AS $set_copy_status_available$
BEGIN
    -- Atualizar status do exemplar para disponível
    NEW.statusCopy := 'AVAILABLE';
    RETURN NEW;
END;
$set_copy_status_available$ LANGUAGE plpgsql;

-- Setando o trigger para exemplar
CREATE TRIGGER trigger_set_copy_status_available
BEFORE INSERT ON copy
FOR EACH ROW EXECUTE PROCEDURE set_copy_status_available();

-- CRIAÇÃO DE RESERVA:
CREATE OR REPLACE FUNCTION f_handle_reservation_creation()
RETURNS trigger AS $handle_reservation_creation$
BEGIN
    -- Verificar se o usuário já tem uma reserva ativa
    IF EXISTS (
        SELECT 1
            FROM reservation
                WHERE idUser = NEW.idUser
                    AND statusReservation = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION 'Usuário já possui uma reserva ativa.';
    END IF;

    -- Atualizar status da reserva e do exemplar
    NEW.statusReservation := 'ACTIVE';
    NEW.dateReservation := CURRENT_DATE;

    UPDATE copy
        SET statusCopy = 'RESERVED'
            WHERE idCopy = NEW.idCopy;

    RETURN NEW;
END;
$handle_reservation_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de reserva
CREATE TRIGGER trigger_reservation_creation
BEFORE INSERT ON reservation
FOR EACH ROW EXECUTE PROCEDURE handle_reservation_creation();

-- ATUALIZAÇÃO DE RESERVA:
CREATE OR REPLACE FUNCTION f_handle_reservation_update()
RETURNS trigger AS $handle_reservation_update$
BEGIN
    -- Verificar se reserva está ativa
    IF OLD.dateReservation := 'ACTIVE' THEN
        -- Se estiver, criar um empréstimo e finalizar a reserva
        INSERT INTO loan (idUser, idCopy, dateLoan, dueReturnDateLoan, statusLoan)
        VALUES (NEW.idUser, NEW.idCopy, CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days', 'ACTIVE');
        
        -- Finalizar a reserva
        NEW.statusReservation := 'FINISHED';
    ELSE
        -- Caso contrário
        RAISE EXCEPTION 'Reserva não está ativa.';        
    END IF;

    RETURN NEW;
END;
$handle_reservation_update$ LANGUAGE plpgsql;

-- Setando o trigger para atualização de reserva
CREATE TRIGGER trigger_reservation_update
BEFORE UPDATE ON reservation
FOR EACH ROW EXECUTE PROCEDURE handle_reservation_update();

-- CRIAÇÃO DE EMPRÉSTIMO:
CREATE OR REPLACE FUNCTION f_handle_loan_creation()
RETURNS trigger AS $handle_loan_creation$
BEGIN
    -- Verificar se o usuário possui multa pendente
    IF EXISTS (
        SELECT 1
            FROM fine
                WHERE idLoan = NEW.idLoan
                    AND statusFine = 'PENDING'
    ) THEN
        RAISE EXCEPTION 'Usuário possui multa pendente.';
    END IF;

    -- Verificar se o exemplar está disponível ou reservado
    IF NOT EXISTS (
        SELECT 1
            FROM copy
                WHERE idCopy = NEW.idCopy
                    AND statusCopy IN ('AVAILABLE', 'RESERVED')
    ) THEN
        RAISE EXCEPTION 'Exemplar não disponível ou reservado.';
    END IF;

    -- Atualizar status do empréstimo e do exemplar
    NEW.dateLoan := CURRENT_DATE;
    NEW.dueReturnDateLoan := CURRENT_DATE + INTERVAL '7 days';
    NEW.statusLoan := 'ACTIVE';

    UPDATE copy
    SET statusCopy = 'BORROWED'
    WHERE idCopy = NEW.idCopy;

    RETURN NEW;
END;
$handle_loan_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de empréstimo
CREATE TRIGGER trigger_loan_creation
BEFORE INSERT ON loan
FOR EACH ROW EXECUTE PROCEDURE handle_loan_creation();

-- ATUALIZAÇÃO DE EMPRÉSTIMO:
CREATE OR REPLACE FUNCTION f_handle_loan_update()
RETURNS trigger AS $handle_loan_update$
BEGIN
    -- Atualizar status do exemplar
    UPDATE copy
    SET statusCopy = 'AVAILABLE'
    WHERE idCopy = NEW.idCopy;

    -- Verificar status do empréstimo
    IF OLD.statusLoan := 'BORROWED' THEN
        -- Atualizar status
        NEW.statusLoan := 'RETURNED';
    ELSE IF OLD.statusLoan := 'OVERDUE' THEN
        -- Criar multa
        INSERT INTO Fine (idLoan, amountFine, statusFine)
        VALUES (NEW.idLoan, (CURRENT_DATE - NEW.dueReturnDateLoan) * 0.5, 'PENDING');
    END IF;

    RETURN NEW;
END;
$handle_loan_update$ LANGUAGE plpgsql;

-- Setando o trigger para atualização de empréstimo
CREATE TRIGGER trigger_loan_update
BEFORE UPDATE ON loan
FOR EACH ROW EXECUTE PROCEDURE handle_loan_update();

-- CRIAÇÃO DE MULTA:
CREATE OR REPLACE FUNCTION f_handle_fine_creation()
RETURNS trigger AS $handle_fine_creation$
DECLARE
    days_late INTEGER;
    fine_rate NUMERIC;
    book_level VARCHAR(10);
BEGIN
    -- Verifica quantos dias o empréstimo está atrasado
    days_late := NEW.actualReturnDateLoan - NEW.dueReturnDateLoan;

    -- Caso não haja atraso, não aplica multa
    IF days_late <= 0 THEN
        RAISE EXCEPTION 'Empréstimo não está atrasado, multa não será criada.';
    END IF;

    -- Busca o nível de busca do livro
    SELECT searchLevel
        INTO book_level
            FROM Book
                JOIN Copy ON Book.idBook = Copy.idBook
                    JOIN Loan ON Copy.idCopy = Loan.idCopy
                        WHERE Loan.idLoan = NEW.idLoan;

    -- Define a taxa de multa com base no nível de busca
    CASE book_level
        WHEN 'LOW' THEN fine_rate := 0.5;
        WHEN 'MEDIUM' THEN fine_rate := 1.0;
        WHEN 'HIGH' THEN fine_rate := 1.5;
        ELSE
            RAISE EXCEPTION 'Nível de busca desconhecido: %', book_level;
    END CASE;

    -- Calcula o valor da multa
    NEW.amountFine := days_late * fine_rate;

    -- Atualizar o status da multa
    NEW.paymentStatusFine := 'PENDING';

    RETURN NEW;
END;
$handle_fine_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de multa
CREATE TRIGGER trigger_fine_creation
BEFORE INSERT ON fine
FOR EACH ROW EXECUTE PROCEDURE handle_fine_creation();

-- ATUALIZAÇÃO DE MULTA:
CREATE OR REPLACE FUNCTION f_handle_fine_update()
RETURNS trigger AS $handle_fine_update$
BEGIN
    -- Atualizar o status da multa
    NEW.paymentStatusFine := 'PENDING';

    RETURN NEW;
END;
$handle_fine_update$ LANGUAGE plpgsql;

-- Setando o trigger para atualização de multa
CREATE TRIGGER trigger_fine_update
BEFORE UPDATE ON fine
FOR EACH ROW EXECUTE PROCEDURE handle_fine_update();

-- CRIAÇÃO DE PESSOA:
CREATE OR REPLACE FUNCTION f_handle_person_creation()
RETURNS trigger AS $handle_person_creation$
BEGIN
    -- Verificar se a pessoa já existe no sistema
    IF EXISTS (
        SELECT 1 
            FROM person 
                WHERE person.idPerson = NEW.idPerson
    ) THEN
        RAISE EXCEPTION 'Pessoa já existe no sistema';
    END IF;
END;
$handle_person_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de pessoa
CREATE TRIGGER trigger_person_creation
BEFORE INSERT ON person
FOR EACH ROW EXECUTE PROCEDURE handle_person_creation();

-- CRIAÇÃO DE USUÁRIO:
CREATE OR REPLACE FUNCTION f_handle_user_creation()
RETURNS trigger AS $handle_user_creation$
BEGIN
    -- Verificar se o usuário já existe no sistema
    IF EXISTS (
        SELECT 1
            FROM SUser 
                WHERE SUser.idPerson = NEW.idPerson
    ) THEN
        RAISE EXCEPTION 'Usuário já existe no sistema';
    END IF;
END;
$handle_user_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de usuário
CREATE TRIGGER trigger_user_creation
BEFORE INSERT ON SUser
FOR EACH ROW EXECUTE PROCEDURE handle_user_creation();

-- CRIAÇÃO DE FUNCIONÁRIO:
CREATE OR REPLACE FUNCTION f_handle_staff_creation()
RETURNS trigger AS $handle_staff_creation$
BEGIN
    -- Verificar se o funcionário já existe no sistema
    IF EXISTS (
        SELECT 1
            FROM Staff
                WHERE Staff.idPerson = NEW.idPerson
    ) THEN
        RAISE EXCEPTION 'Funcionário já existe no sistema';
    END IF;
END;
$handle_staff_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de funcionário
CREATE TRIGGER trigger_staff_creation
BEFORE INSERT ON Staff
FOR EACH ROW EXECUTE PROCEDURE handle_staff_creation();

-- CRIAÇÃO DE LIVRO:
CREATE OR REPLACE FUNCTION f_handle_book_creation()
RETURNS trigger AS $handle_book_creation$
BEGIN
    -- Verificar se o livro já existe no sistema
    IF EXISTS (
        SELECT 1
            FROM Book
                WHERE Book.isbnBook = NEW.isbnBook
    ) THEN
        RAISE EXCEPTION 'Livro já existe no sistema';
    END IF;
END;
$handle_book_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de livro
CREATE TRIGGER trigger_book_creation
BEFORE INSERT ON Book
FOR EACH ROW EXECUTE PROCEDURE handle_book_creation();

-- CRIAÇÃO DE GÊNERO:
CREATE OR REPLACE FUNCTION f_handle_genre_creation()
RETURNS trigger AS $handle_genre_creation$
BEGIN
    -- Verificar se o gênero já existe no sistema
    IF EXISTS (
        SELECT 1
            FROM Genre
                WHERE Genre.nameGenre = NEW.nameGenre
    ) THEN
        RAISE EXCEPTION 'Gênero já existe no sistema';
    END IF;
END;
$handle_genre_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de gênero
CREATE TRIGGER trigger_genre_creation
BEFORE INSERT ON Genre
FOR EACH ROW EXECUTE PROCEDURE handle_genre_creation();

-- CRIAÇÃO DE AUTOR:
CREATE OR REPLACE FUNCTION f_handle_author_creation()
RETURNS trigger AS $handle_author_creation$
BEGIN
    -- Verificar se o autor já existe no sistema
    IF EXISTS (
        SELECT 1
            FROM Author
            WHERE Author.nameAuthor = NEW.nameAuthor
                AND Author.birthDateAuthor = NEW.birthDateAuthor
                    AND Author.nationalityAuthor = NEW.nationalityAuthor
    ) THEN
        RAISE EXCEPTION 'Autor já existe no sistema';
    END IF;
END;
$handle_author_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de autor
CREATE TRIGGER trigger_author_creation
BEFORE INSERT ON Author
FOR EACH ROW EXECUTE PROCEDURE handle_author_creation();

-- CRIAÇÃO DE EDITORA
CREATE OR REPLACE FUNCTION f_handle_publisher_creation()
RETURNS trigger AS $handle_publisher_creation$
BEGIN
    -- Verificar se a editora já existe no sistema
    IF EXISTS (
    SELECT 1
        FROM Publisher
            WHERE Publisher.cnpjPublisher = NEW.cnpjPublisher
    ) THEN
        RAISE EXCEPTION 'Editora já existe no sistema';
    END IF;
END;
$handle_publisher_creation$ LANGUAGE plpgsql;

-- Setando o trigger para criação de editora
CREATE TRIGGER trigger_publisher_creation
BEFORE INSERT ON Publisher
FOR EACH ROW EXECUTE PROCEDURE handle_publisher_creation();


