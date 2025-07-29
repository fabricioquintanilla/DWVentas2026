--Construir el DW Para analizar Venta de bicicletas
create database DWVentas20250407
go

use DWVentas20250407
go

--Se inicia creando las dimensiones
create table DimTiempo
(TiempoKey int primary key, --Llave surrogada
Fecha datetime not null,
Dia tinyint not null,
Mes tinyint not null,
Anio smallint not null)
go

create table DimProducto
(ProductoKey int primary key identity(1,1), --Llave surrogada
ProductID int not null, --Llave de negocio
Nombre varchar(50) not null,
NumeroProducto varchar(25) not null,
Color varchar(50) not null,
LineaProducto char(50) not null,
Clase char(50) not null,
Estilo char(50) not null,
PrecioLista float not null default(0),
Subcategoria varchar(50) not null,
Categoria varchar(50) not null,
Modelo varchar(50) not null,
Activo bit not null default 1,
FechaInicio datetime not null default getdate(),
FechaFin datetime null)
go

create table DimCliente
(ClienteKey int primary key identity(1,1), --Llave surrogada
ClienteID int not null, --Llave de negocio
PrimerNombre varchar(50) not null,
SegundoNombre varchar(50) not null,
Apellido varchar(50) not null,
TipoPersona varchar(50) not null,
Activo bit not null default 1,
FechaInicio datetime not null default getdate(),
FechaFin datetime null)
go

create table DimPromocion
(PromocionKey int primary key identity(1,1), --Llave surrogada
PromocionID int not null, --Llave de negocio
Descripcion varchar(255) not null,
Porcentaje float not null,
Tipo varchar(50) not null,
Categoria varchar(50) not null,
Activo bit not null default 1,
FechaInicio datetime not null default getdate(),
FechaFin datetime null)
go

create table DimVendedor
(VendedorKey int primary key identity(1,1), --Llave surrogada
VendedorID int not null, --Llave de negocio
PrimerNombre varchar(50) not null,
SegundoNombre varchar(50) not null,
Apellido varchar(50) not null,
TipoPersona varchar(50) not null,
Activo bit not null default 1,
FechaInicio datetime not null default getdate(),
FechaFin datetime null)
go

create table DimTerritorioVenta
(TerritorioVentaKey int primary key identity(1,1), --Llave surrogada
TerritorioID int not null, --Llave de negocio
Nombre varchar(50) not null,
Grupo varchar(50) not null,
Activo bit not null default 1,
FechaInicio datetime not null default getdate(),
FechaFin datetime null)
go

create table FactVentas
(TerritorioVentaKey int not null foreign key references 
DimTerritorioVenta(TerritorioVentaKey),
VendedorKey int not null foreign key references
DimVendedor(VendedorKey),
PromocionKey int not null foreign key references
DimPromocion(PromocionKey),
ClienteKey int not null foreign key references
DimCliente(ClienteKey),
ProductoKey int not null foreign key references
DimProducto(ProductoKey),
FechaOrdenKey int not null foreign key references
DimTiempo(TiempoKey),
FechaEntregaKey int not null foreign key references
DimTiempo(TiempoKey),
FechaEnvioKey int not null foreign key references
DimTiempo(TiempoKey),
Cantidad int not null, 
PrecioUnitario float not null, 
Descuento float not null, 
TotalLinea float not null,
NumeroOrden varchar(25) not null)
go


/*Procedimientos para Procesar datos*/

CREATE OR ALTER procedure [dbo].[ActualizarVendedor](@VendedorKey int, @PrimerNombre varchar(100),
@SegundoNombre varchar(100), @Apellido varchar(100), @TipoPersona varchar(100))
AS
begin

declare @PrimerNombreActual varchar(100),
		@SegundoNombreActual varchar(100),
		@ApellidoActual varchar(100),
		@TipoPersonaActual varchar(100),
		@IDVendedor int

select @PrimerNombreActual=PrimerNombre, @SegundoNombreActual=SegundoNombre,@ApellidoActual=
		Apellido, @TipoPersonaActual=TipoPersona, @IDVendedor=VendedorID
from DimVendedor where VendedorKey=@VendedorKey

/*
PrimerNombre, SegundoNombre y Apellido son SCD1

TipoPersona SCD2
*/

--SCD1
if (@PrimerNombreActual<>@PrimerNombre or @SegundoNombreActual<>@SegundoNombre
or @ApellidoActual<>@Apellido) 
	UPDATE DimVendedor set PrimerNombre=@PrimerNombre, SegundoNombre=@SegundoNombre,
	Apellido=@Apellido
	where VendedorKey=@VendedorKey

--SCD2
if (@TipoPersonaActual<>@TipoPersona)
begin
	update DimVendedor set Activo=0, fechafin=getdate() where VendedorKey=@VendedorKey

	insert into DimVendedor (VendedorID, PrimerNombre, SegundoNombre, Apellido, TipoPersona)
	values(@IDVendedor, @PrimerNombre, @SegundoNombre, @Apellido, @TipoPersona)
end
end