CREATE TABLE Person (
  idPerson SERIAL NOT NULL,
  namePerson VARCHAR(255),
  emailPerson VARCHAR(255),
  dateOfBirthPerson DATE,
  PRIMARY KEY (idPerson)
);

CREATE TABLE Publisher (
  idPublisher SERIAL NOT NULL,
  namePublisher VARCHAR(255),
  contactEmailPublisher VARCHAR(255),
  PRIMARY KEY (idPublisher)
);

CREATE TABLE Genre (
  idGenre SERIAL NOT NULL,
  nameGenre VARCHAR(255),
  descriptionGenre TEXT,
  PRIMARY KEY (idGenre)
);

CREATE TABLE Adress (
  idAdress SERIAL NOT NULL,
  streetAdress VARCHAR(255),
  cityAdress VARCHAR(255),
  postalCodeAdress VARCHAR(20),
  PRIMARY KEY (idAdress)
);

CREATE TABLE Author (
  idAuthor SERIAL NOT NULL,
  nameAuthor VARCHAR(255),
  nationalityAuthor VARCHAR(100),
  biographyAuthor TEXT,
  PRIMARY KEY (idAuthor)
);

CREATE TABLE Book (
  idBook SERIAL NOT NULL,
  titleBook VARCHAR(255),
  isbnBook VARCHAR(20) UNIQUE,
  publicationYearBook SMALLINT,
  totalAmountBook INT,
  disponibleAmountBook INT,
  descriptionBook TEXT,
  PRIMARY KEY (idBook)
);

CREATE TABLE User (
  idUser SERIAL NOT NULL,
  idPerson INT NOT NULL,
  registrationDateUser DATE,
  PRIMARY KEY (idUser),
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

CREATE TABLE Staff (
  idStaff SERIAL NOT NULL,
  idPerson INT NOT NULL,
  roleTitleStaff VARCHAR(50),
  employmentDateStaff DATE,
  PRIMARY KEY (idStaff),
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

CREATE TABLE Phone (
  idPhone SERIAL NOT NULL,
  idPerson INT NOT NULL,
  dddPhone VARCHAR(2),
  numberPhone VARCHAR(9),
  typePhone ENUM('mobile', 'home', 'work') DEFAULT 'mobile',
  PRIMARY KEY (idPhone),
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

CREATE TABLE Reservation (
  idReservation SERIAL NOT NULL,
  idUser INT NOT NULL,
  idBook INT NOT NULL,
  dateReservation DATE,
  statusReservation ENUM('active', 'completed', 'canceled') DEFAULT 'active',
  PRIMARY KEY (idReservation),
  FOREIGN KEY (idUser) REFERENCES User(idUser) ON DELETE CASCADE,
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE
);

CREATE TABLE Publisher_has_Adress (
  idPublisher INT NOT NULL,
  idAdress INT NOT NULL,
  PRIMARY KEY (idPublisher, idAdress),
  FOREIGN KEY (idPublisher) REFERENCES Publisher(idPublisher) ON DELETE CASCADE,
  FOREIGN KEY (idAdress) REFERENCES Adress(idAdress) ON DELETE CASCADE
);

CREATE TABLE Book_has_Genre (
  idBook INT NOT NULL,
  idGenre INT NOT NULL,
  PRIMARY KEY (idBook, idGenre),
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE,
  FOREIGN KEY (idGenre) REFERENCES Genre(idGenre) ON DELETE CASCADE
);

CREATE TABLE Book_has_Author (
  idBook INT NOT NULL,
  idAuthor INT NOT NULL,
  PRIMARY KEY (idBook, idAuthor),
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE,
  FOREIGN KEY (idAuthor) REFERENCES Author(idAuthor) ON DELETE CASCADE
);

CREATE TABLE Book_has_Publisher (
  idPublisher INT NOT NULL,
  idBook INT NOT NULL,
  PRIMARY KEY (idPublisher, idBook),
  FOREIGN KEY (idPublisher) REFERENCES Publisher(idPublisher) ON DELETE CASCADE,
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE
);

CREATE TABLE Person_has_Adress (
  idAdress INT NOT NULL,
  idPerson INT NOT NULL,
  PRIMARY KEY (idAdress, idPerson),
  FOREIGN KEY (idAdress) REFERENCES Adress(idAdress) ON DELETE CASCADE,
  FOREIGN KEY (idPerson) REFERENCES Person(idPerson) ON DELETE CASCADE
);

CREATE TABLE Loan (
  idLoan SERIAL NOT NULL,
  idBook INT NOT NULL,
  idUser INT NOT NULL,
  dateLoan DATE,
  dueReturnDateLoan DATE,
  actualReturnDateLoan DATE,
  statusLoan ENUM('borrowed', 'returned', 'overdue') DEFAULT 'borrowed',
  PRIMARY KEY (idLoan),
  FOREIGN KEY (idBook) REFERENCES Book(idBook) ON DELETE CASCADE,
  FOREIGN KEY (idUser) REFERENCES User(idUser) ON DELETE CASCADE
);

CREATE TABLE Fine (
  idFine SERIAL NOT NULL,
  idLoan INT NOT NULL,
  amountFine DECIMAL(10, 2),
  paymentStatusFine ENUM('unpaid', 'paid') DEFAULT 'unpaid',
  PRIMARY KEY (idFine),
  FOREIGN KEY (idLoan) REFERENCES Loan(idLoan) ON DELETE CASCADE
);
