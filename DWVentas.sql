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
go
--Actualizar Territorio de Ventas
CREATE OR ALTER   procedure [dbo].[ActualizarTerritorioVentas](@TerritorioVentaKey int, 
@Nombre varchar(50), @Grupo varchar(50))
AS
begin

declare @NombreActual varchar(50),
		@GrupoActual varchar(50),
		@TerritorioID int

select @NombreActual=Nombre, @GrupoActual=Grupo, @TerritorioID=TerritorioID
from DimTerritorioVenta where TerritorioVentaKey=@TerritorioVentaKey

/*
Nombre SCD2
*/

--SCD1
if (@GrupoActual<>@Grupo) 
	UPDATE DimTerritorioVenta set Grupo=@Grupo
	where TerritorioVentaKey=@TerritorioVentaKey

--SCD2
if (@NombreActual<>@Nombre)
begin
	update DimTerritorioVenta set Activo=0, fechafin=getdate() 
	where TerritorioVentaKey=@TerritorioVentaKey

	insert into DimTerritorioVenta(TerritorioID, Nombre, Grupo)
	values(@TerritorioID, @Nombre, @Grupo)
end
end

go

--Actualizar Promociones
CREATE OR ALTER   procedure [dbo].[ActualizarPromociones](@PromocionKey int, 
@Descripcion varchar(255), @Porcentaje float, @Tipo varchar(50), @Categoria varchar(50))
AS
begin

declare @DescripcionActual varchar(255),
		@PorcentajeActual float,
		@PromocionID int,
		@TipoActual varchar(50), 
		@CategoriaActual varchar(50)

select @DescripcionActual=Descripcion, @PorcentajeActual=Porcentaje, @PromocionID=PromocionID,
@TipoActual=Tipo, @CategoriaActual=Categoria
from DimPromocion where PromocionKey=@PromocionKey

/*
Todos los campos son considerados SCD2 (Caso excepcional)
*/

--SCD2
if (@DescripcionActual<>@Descripcion or @PorcentajeActual<>@Porcentaje or @TipoActual<>@Tipo
or @CategoriaActual<>@Categoria)
begin
	update DimPromocion set Activo=0, fechafin=getdate() 
	where PromocionKey=@PromocionKey

	insert into DimPromocion(PromocionID, Descripcion, Porcentaje, Tipo, Categoria)
	values(@PromocionID, @Descripcion, @Porcentaje, @Tipo, @Categoria)
end
end
go

--Actualizar Producto
CREATE OR ALTER   procedure [dbo].[ActualizarProductos](@ProductoKey int, 
@Nombre varchar(50), @NumeroProducto varchar(25), @Color varchar(50), @LineaProducto char(50),
@Clase char(50), @Estilo char(50), @PrecioLista float, @Subcategoria varchar(50), 
@Categoria varchar(50), @Modelo varchar(50))
AS
begin

declare @NombreActual varchar(50), 
		@NumeroProductoActual varchar(25), 
		@ColorActual varchar(50), 
		@LineaProductoActual char(50),
		@ClaseActual char(50), 
		@EstiloActual char(50), 
		@PrecioListaActual float, 
		@SubcategoriaActual varchar(50), 
		@CategoriaActual varchar(50), 
		@ModeloActual varchar(50),
		@ProductoID int

select @NombreActual = Nombre, 
		@NumeroProductoActual =NumeroProducto , 
		@ColorActual =Color, 
		@LineaProductoActual =LineaProducto ,
		@ClaseActual =Clase, 
		@EstiloActual =Estilo, 
		@PrecioListaActual =PrecioLista, 
		@SubcategoriaActual =Subcategoria, 
		@CategoriaActual =Categoria, 
		@ModeloActual =Modelo,
		@ProductoID=ProductID
from DimProducto where ProductoKey=@ProductoKey

/*
Todos los campos se consideraran SCD1
*/

--SCD1
if (@NombreActual<>@Nombre or @NumeroProductoActual<>@NumeroProducto or @ColorActual=@Color
or @LineaProductoActual<>@LineaProducto or @ClaseActual<>@Clase or @EstiloActual<>@Estilo
or @PrecioListaActual<>@PrecioLista or @SubcategoriaActual<>@Subcategoria or
@CategoriaActual<>@Categoria or @ModeloActual<>@Modelo) 

	UPDATE DimProducto set Nombre=@Nombre, NumeroProducto=@NumeroProducto, Color=@Color,
		LineaProducto=@LineaProducto, Clase=@Clase, Estilo=@Estilo,
		PrecioLista=@PrecioLista, Subcategoria=@Subcategoria, Categoria=@Categoria,
		Modelo=@Modelo
	where ProductoKey=@ProductoKey

end
go

--Actualizar Cliente
CREATE OR ALTER   procedure [dbo].[ActualizarClientes](@ClienteKey int, 
@PrimerNombre varchar(50), @SegundoNombre varchar(50), @Apellido varchar(50), 
@TipoPersona varchar(50))
AS
begin

declare @PrimerNombreActual varchar(50), 
		@SegundoNombreActual varchar(50), 
		@ApellidoActual varchar(50), 
		@TipoPersonaActual varchar(50),
		@ClienteID int

select @PrimerNombreActual = PrimerNombre, 
		@SegundoNombreActual =SegundoNombre, 
		@ApellidoActual = Apellido, 
		@TipoPersonaActual =TipoPersona,
		@ClienteID=ClienteID
from DimCliente where ClienteKey=@ClienteKey

/*
Todos los campos se consideraran SCD1
*/

--SCD1
if (@PrimerNombreActual<>@PrimerNombre or @SegundoNombreActual<>@SegundoNombre 
or @ApellidoActual=@Apellido or @TipoPersonaActual<>@TipoPersona) 

	UPDATE DimCliente set PrimerNombre=@PrimerNombre, SegundoNombre=@SegundoNombre, 
		Apellido=@Apellido, TipoPersona=@TipoPersona
	where ClienteKey=@ClienteKey

end


/*Crear tabla de parametros*/

create table Parametros(
ID int not null primary key identity(1,1),
Nombre varchar(100) not null,
Valor varchar(100) not null)
go

create or alter function LeerParametros(@Nombre varchar(100))
returns varchar
as
begin
	declare @valor varchar(100)=''

	select @valor=valor from parametros where nombre=@Nombre
	return @valor
end
go

create or alter procedure ActualizarParametro(@Nombre varchar(100), @valor varchar(100))
as
begin
	update parametros set valor=@valor where nombre=@nombre
end

insert into parametros(nombre,valor) values('FechaUltimaEjecucion',DATEADD(day,-2,GETDATE()))


select * from parametros

create table FactVentasSnapshot
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
NumeroOrden varchar(25) not null,
FechaCarga datetime not null default getdate())
go

select * from factventasSnapshot

update factventasSnapshot set fechacarga=convert(datetime,'03/09/2025',103)

if exists (select 1 from FactVentasSnapshot where cast(FechaCarga as date)=cast(getdate() as date))
begin
	delete factventasSnapshot
end

select cast(FechaCarga as date), cast(getdate() as date) from FactVentasSnapshot