-- Criando a tabela Person
CREATE TABLE Person (
  idPerson SERIAL NOT NULL,
  namePerson VARCHAR(50),
  emailPerson VARCHAR(50),
  dateOfBirthPerson DATE,
  PRIMARY KEY (idPerson)
);

-- Criando a tabela Genre
CREATE TABLE Genre (
  idGenre SERIAL NOT NULL,
  nameGenre VARCHAR(40),
  descriptionGenre TEXT,
  PRIMARY KEY (idGenre)
);

-- Criando a tabela Adress
CREATE TABLE Adress (
  idAdress SERIAL NOT NULL,
  streetAdress VARCHAR(100),
  cityAdress VARCHAR(50),
  postalCodeAdress VARCHAR(20),
  PRIMARY KEY (idAdress)
);

-- Criando a tabela Author
CREATE TABLE Author (
  idAuthor SERIAL NOT NULL,
  nameAuthor VARCHAR(50),
  nationalityAuthor VARCHAR(30),
  biographyAuthor TEXT,
  PRIMARY KEY (idAuthor)
);

-- Criando a tabela Book
CREATE TABLE Book (
  idBook SERIAL NOT NULL,
  titleBook VARCHAR(100),
  isbnBook VARCHAR(20) UNIQUE,
  publicationYearBook SMALLINT,
  totalAmountBook INT,
  disponibleAmountBook INT,
  descriptionBook TEXT,
  PRIMARY KEY (idBook)
);

-- Criando a tabela SUser
CREATE TABLE SUser (
  idUser SERIAL NOT NULL,
  idPerson INT NOT NULL,
  registrationDateUser DATE,
  PRIMARY KEY (idUser),
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

-- Criando a tabela Staff
CREATE TABLE Staff (
  idStaff SERIAL NOT NULL,
  idPerson INT NOT NULL,
  roleTitleStaff VARCHAR(50),
  employmentDateStaff DATE,
  PRIMARY KEY (idStaff),
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

-- Criando a tabela Phone
-- Possíveis tipos de telefone : Móvel('MOBILE'), Fixo('FIXED'), Comercial('COMMERCIAL')
CREATE TABLE Phone (
  idPhone SERIAL NOT NULL,
  idPerson INT NOT NULL,
  dddPhone VARCHAR(2),
  numberPhone VARCHAR(9),
  typePhone VARCHAR(10) NOT NULL CHECK(typePhone IN ('MOBILE', 'FIXED', 'COMMERCIAL')),
  PRIMARY KEY (idPhone),
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

-- Criando a tabela Publisher
CREATE TABLE Publisher (
  idPublisher SERIAL NOT NULL,
  namePublisher VARCHAR(50),
  contactEmailPublisher VARCHAR(50),
  idAdress INT NOT NULL,
  PRIMARY KEY (idPublisher),
  FOREIGN KEY (idAdress) REFERENCES Adress(idAdress) ON DELETE CASCADE
);

-- Criando a tabela Book-Genre
CREATE TABLE Book_has_Genre (
  idBook INT NOT NULL,
  idGenre INT NOT NULL,
  PRIMARY KEY (idBook, idGenre),
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE,
  FOREIGN KEY (idGenre) REFERENCES Genre(idGenre) ON DELETE CASCADE
);

-- Criando a tabela Book-Author
CREATE TABLE Book_has_Author (
  idBook INT NOT NULL,
  idAuthor INT NOT NULL,
  PRIMARY KEY (idBook, idAuthor),
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE,
  FOREIGN KEY (idAuthor) REFERENCES Author(idAuthor) ON DELETE CASCADE
);

-- Criando a tabela Book-Publisher
CREATE TABLE Book_has_Publisher (
  idPublisher INT NOT NULL,
  idBook INT NOT NULL,
  PRIMARY KEY (idPublisher, idBook),
  FOREIGN KEY (idPublisher) REFERENCES Publisher(idPublisher) ON DELETE CASCADE,
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE
);

-- Criando a tabela Person-Adress
CREATE TABLE Person_has_Adress (
  idAdress INT NOT NULL,
  idPerson INT NOT NULL,
  PRIMARY KEY (idAdress, idPerson),
  FOREIGN KEY (idAdress) REFERENCES Adress(idAdress) ON DELETE CASCADE,
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

-- Criando a tabela Loan
-- Possíveis status do empréstimo: Emprestado('BORROWED'), Devolvido('RETURNED'), Atrasado('OVERDUE')
CREATE TABLE Loan (
  idLoan SERIAL NOT NULL,
  idBook INT NOT NULL,
  idUser INT NOT NULL,
  dateLoan DATE,
  dueReturnDateLoan DATE,
  actualReturnDateLoan DATE,
  statusLoan VARCHAR(10) NOT NULL CHECK(statusLoan IN ('BORROWED', 'RETURNED', 'OVERDUE')),
  PRIMARY KEY (idLoan),
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE,
  FOREIGN KEY (idUser) REFERENCES SUser(idUser) ON DELETE CASCADE
);

-- Criando a tabela Fine
-- Possíveis status do multa: Pendente('PENDING'), Paga('PAID')
CREATE TABLE Fine (
  idFine SERIAL NOT NULL,
  idLoan INT NOT NULL,
  amountFine DECIMAL(10, 2),
  paymentStatusFine VARCHAR(10) NOT NULL CHECK(paymentStatusFine IN ('PENDING', 'PAID')),
  PRIMARY KEY (idFine),
  FOREIGN KEY (idLoan) REFERENCES Loan(idLoan) ON DELETE CASCADE
);
