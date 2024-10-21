CREATE TABLE [Atleta] (
	[idAtleta] int IDENTITY(1,1) NOT NULL UNIQUE,
	[nomeAtleta] nvarchar(max) NOT NULL,
	[dataNascimento] date NOT NULL,
	PRIMARY KEY ([idAtleta])
);

CREATE TABLE [Treinador] (
	[idTreinador] int IDENTITY(1,1) NOT NULL UNIQUE,
	[nomeTreinador] nvarchar(max) NOT NULL,
	PRIMARY KEY ([idTreinador])
);

CREATE TABLE [Modalidade] (
	[idModalidade] int IDENTITY(1,1) NOT NULL UNIQUE,
	[nomeModalidade] nvarchar(max) NOT NULL,
	PRIMARY KEY ([idModalidade])
);

CREATE TABLE [Rel_Atl_Mod] (
	[idAtleta] int NOT NULL,
	[idModalidade] int NOT NULL,
	[idRel_Atl_Mod] int IDENTITY(1,1) NOT NULL UNIQUE,
	PRIMARY KEY ([idRel_Atl_Mod])
);

CREATE TABLE [Rel_Trei_Mod] (
	[idRel_Trei_Mod] int IDENTITY(1,1) NOT NULL UNIQUE,
	[idTreinador] int NOT NULL,
	[idModalidade] int NOT NULL,
	PRIMARY KEY ([idRel_Trei_Mod])
);

CREATE TABLE [Rel_Atl_Trei] (
	[idRel_Atl_Trei] int IDENTITY(1,1) NOT NULL UNIQUE,
	[idAtleta] int NOT NULL,
	[idTreinador] int NOT NULL,
	PRIMARY KEY ([idRel_Atl_Trei])
);




ALTER TABLE [Rel_Atl_Mod] ADD CONSTRAINT [Rel_Atl_Mod_fk0] FOREIGN KEY ([idAtleta]) REFERENCES [Atleta]([idAtleta]);

ALTER TABLE [Rel_Atl_Mod] ADD CONSTRAINT [Rel_Atl_Mod_fk1] FOREIGN KEY ([idModalidade]) REFERENCES [Modalidade]([idModalidade]);
ALTER TABLE [Rel_Trei_Mod] ADD CONSTRAINT [Rel_Trei_Mod_fk1] FOREIGN KEY ([idTreinador]) REFERENCES [Treinador]([idTreinador]);

ALTER TABLE [Rel_Trei_Mod] ADD CONSTRAINT [Rel_Trei_Mod_fk2] FOREIGN KEY ([idModalidade]) REFERENCES [Modalidade]([idModalidade]);
ALTER TABLE [Rel_Atl_Trei] ADD CONSTRAINT [Rel_Atl_Trei_fk1] FOREIGN KEY ([idAtleta]) REFERENCES [Atleta]([idAtleta]);

ALTER TABLE [Rel_Atl_Trei] ADD CONSTRAINT [Rel_Atl_Trei_fk2] FOREIGN KEY ([idTreinador]) REFERENCES [Treinador]([idTreinador]);