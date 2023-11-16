-- CREATE THE DATABASE

-- CREATE DATABASE [G9:15_Group1];
-- GO

--------------------- CREATE SCHEMAS -------------------------
DROP SCHEMA IF EXISTS DbSecurity; 
GO
CREATE SCHEMA DbSecurity
GO

DROP SCHEMA IF EXISTS [CH01-01-Dimension];
GO
CREATE SCHEMA [CH01-01-Dimension];
GO

DROP SCHEMA IF EXISTS [CH01-01-Fact];
GO
CREATE SCHEMA [CH01-01-Fact];
GO

DROP SCHEMA IF EXISTS [Project2]; 
GO
CREATE SCHEMA [Project2]
GO

DROP SCHEMA IF EXISTS [Utils]; 
GO
CREATE SCHEMA [Utils]
GO

DROP SCHEMA IF EXISTS [FileUpload]; 
GO
CREATE SCHEMA [FileUpload]
GO

/* Instructions for use of G9_1 Schema name:
Part of the design is to create either a view or Inline Table Value function for
the source input query to load the specific table using your group name as a
schema name */
DROP SCHEMA IF EXISTS [G9_1]; 
GO
CREATE SCHEMA [G9_1]
GO

DROP SCHEMA IF EXISTS [PkSequence]; 
GO
CREATE SCHEMA [PkSequence]
GO

DROP SCHEMA IF EXISTS [Process]; 
GO
CREATE SCHEMA [Process]
GO

------------------------- CREATE SEQUENCES ----------------------------

-- for replacing identity key in [CH01-01-Fact].[Data]
CREATE SEQUENCE PkSequence.[DataSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO

-- for replacing identity key in [CH01-01-Dimension].[DimCustomer]
CREATE SEQUENCE PkSequence.[DimCustomerSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO
-- for replacing identity key in [CH01-01-Dimension].[DimProductCategory]
CREATE SEQUENCE PkSequence.[DimProductCategorySequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647 
GO

-- for replacing identity key in [CH01-01-Dimension].[DimProduct]
CREATE SEQUENCE PkSequence.[DimProductSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647 
GO

CREATE SEQUENCE PkSequence.[DimProductSubCategorySequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO

-- for replacing identity key in [CH01-01-Dimension].[DimProductSubCategory]
CREATE SEQUENCE PkSequence.[DimTerritorySequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO

-- for replacing identity key in [CH01-01-Dimension].[DimOccupation]
CREATE SEQUENCE PkSequence.[OccupationSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO

-- for replacing identity key in [CH01-01-Dimension].[SalesManagers]
CREATE SEQUENCE PkSequence.[SalesManagersSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO

-- for automatically assigning keys in [DbSecurity].[UserAuthorization]
CREATE SEQUENCE PkSequence.[UserAuthorizationSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO

-- for replacing identity key in Process.[WorkflowSteps]
CREATE SEQUENCE PkSequence.[WorkFlowStepsSequenceObject] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
GO


------------------------ Utils functions using Script as Create ---------------------

/*
Function: [Utils].[CalculateDataTypeByteStorage]

Description:
This function calculates the storage size in bytes for a given SQL data type. 
It handles various data types, including varchar, char, int, money, and date. 
The storage size calculation is based on the data type and its specified length.

Parameters:
@DataType - A varchar(50) parameter representing the SQL data type whose storage 
size is to be calculated. The expected format is the data type followed by its 
length in parentheses (for example, 'varchar(50)').

Returns:
Int - The function returns an integer value representing the number of bytes required to store a value of the specified data type. For variable-length types like varchar, an additional 2 bytes are added to the specified length to account for storage overhead. For fixed-length types, it returns their standard storage size. If the data type is not recognized, it returns -999.

Usage:
This function is particularly useful for database sizing and planning. It can be used to estimate the storage requirements for tables based on their schema definitions.

Example:
SELECT [Utils].[CalculateDataTypeByteStorage] ('varchar(50)');
This example returns the storage size for a varchar data type with a length of 50 characters.

-- =============================================
-- Author:		Professor Heller
-- Create date: default
-- Description:	Code taken from the 'Script as Create' result of the scalar-Valued Function within the BIClass db
-- =============================================

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Utils].[CalculateDataTypeByteStorage] 
(
	-- Add the parameters for the function here
	@DataType varchar(50)
)
RETURNS int
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result int

    -- Return the result of the function
    RETURN  CASE
                          WHEN CHARINDEX('(', @DataType, 0) > 0
        AND SUBSTRING(@DataType, 1, 3) = 'var' THEN
                              CAST(SUBSTRING(
                                                @DataType
                                              , CHARINDEX('(', @DataType, 0) + 1
                                              , LEN(@DataType) - CHARINDEX('(', @DataType, 0) - 1
                                            ) AS INT) + 2
                          WHEN CHARINDEX('(', @DataType, 0) > 0
        AND SUBSTRING(@DataType, 1, 3) = 'cha' THEN
                              CAST(SUBSTRING(
                                                @DataType
                                              , CHARINDEX('(', @DataType, 0) + 1
                                              , LEN(@DataType) - CHARINDEX('(', @DataType, 0) - 1
                                            ) AS INT)
                          WHEN SUBSTRING(@DataType, 1, 3) = 'int' THEN
                              4
                          WHEN SUBSTRING(@DataType, 1, 3) = 'mon' THEN
                              4
                          WHEN SUBSTRING(@DataType, 1, 3) = 'dat' THEN
                              3
                          ELSE
                              -999
                      END

END
GO


-------------------------- recreating Util views using Script as Create ---------------------

/*
View: Utils.[ShowServerUserNameAndCurrentDatabase]

Description:
This view is designed to quickly provide essential information about the current SQL Server environment. It returns the name of the server on which SQL Server is running, the username of the current user as recognized by the system, and the name of the database currently in use.

Columns:
- ServerName: The name of the server where SQL Server is installed and running.
- YourUserName: The username of the current user as recognized by the system. This represents the user context in which the current SQL session is executing.
- CurrentDatabase: The name of the database that is currently in use by the session.

Usage:
This view can be particularly useful for users who connect to multiple databases on different servers, especially in environments with complex configurations or multiple instances of SQL Server. It helps quickly identify the current context, which can be crucial for database administrators, developers, and analysts working in multi-database environments.

Example:
SELECT * FROM Utils.[ShowServerUserNameAndCurrentDatabase];

This example retrieves the server name, the current user's username, and the name of the currently active database.

Note: The information returned by this view reflects the current session's context and may vary depending on the user's connection and selected database.

-- =============================================
-- Author:		Professor Heller
-- Create date: default
-- Description:	Code taken from the 'Script as Create' result of the views within the BIClass db
-- =============================================


*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view Utils.[ShowServerUserNameAndCurrentDatabase]
as
    select ServerName= @@SERVERNAME
       , YourUserName =  system_user
       , CurrentDatabase =  db_name();  
 
GO


/*
View: [Utils].[uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint]

Description:
This view provides comprehensive details about column definitions across various tables in the database. It concatenates information from different schema tables to give a detailed overview of each column, including its data type, nullability, default constraints, and check constraints if any. The view fetches data from INFORMATION_SCHEMA and sys schema to compile information about tables, columns, default constraints, and check constraints.

Columns:
- FullyQualifiedTableName: The schema and table name combined.
- SchemaName: The name of the schema to which the table belongs.
- TableName: The name of the table.
- ColumnName: The name of the column in the table.
- OrdinalPosition: The ordinal position of the column in the table.
- FullyQualifiedDomainName: The schema and domain name combined, if any.
- DomainName: The domain name of the column.
- DataType: The data type of the column, formatted with length, precision, and scale where applicable.
- IsNullable: Indicates if the column allows NULL values.
- DefaultName: The name of the default constraint applied to the column, if any.
- DefaultNameDefinition: The definition of the default constraint.
- CheckConstraintRuleName: The name of the check constraint applied to the column, if any.
- CheckConstraintRuleNameDefinition: The definition of the check constraint.

Usage:
This view is particularly useful for database administrators and developers who need to quickly retrieve detailed information about the database schema, especially when working with complex databases with many tables and columns. It can be used for schema analysis, documentation, or to aid in database migrations or upgrades.

Example:
SELECT * FROM [Utils].[uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint]
WHERE SchemaName = 'MySchema' AND TableName = 'MyTable';

This example retrieves detailed column information for all columns in the 'MyTable' table within the 'MySchema' schema.

-- =============================================
-- Author:		Professor Heller
-- Create date: default
-- Description:	Code taken from the 'Script as Create' result of the views within the BIClass db
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Utils].[uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint]
AS
    SELECT CONCAT(tbl.TABLE_SCHEMA, '.', tbl.TABLE_NAME) AS FullyQualifiedTableName ,
        tbl.TABLE_SCHEMA AS SchemaName ,
        tbl.TABLE_NAME AS TableName ,
        col.COLUMN_NAME AS ColumnName ,
        col.ORDINAL_POSITION AS OrdinalPosition,
        CONCAT(col.DOMAIN_SCHEMA, '.', col.DOMAIN_NAME) AS FullyQualifiedDomainName ,
        col.DOMAIN_NAME AS DomainName ,
        CASE
                      WHEN col.DATA_TYPE = 'char'
             THEN CONCAT('char(', CHARACTER_MAXIMUM_LENGTH, ')')
                     WHEN col.DATA_TYPE = 'nchar'
             THEN CONCAT('nchar(', CHARACTER_MAXIMUM_LENGTH, ')')
                     WHEN col.DATA_TYPE = 'Nvarchar'
             THEN CONCAT('nvarchar(', CHARACTER_MAXIMUM_LENGTH, ')')
                     WHEN col.DATA_TYPE = 'varchar'
             THEN CONCAT('varchar(', CHARACTER_MAXIMUM_LENGTH, ')')
             WHEN col.DATA_TYPE = 'numeric'
             THEN CONCAT('numeric(', NUMERIC_PRECISION, ', ',
                         NUMERIC_SCALE, ')')
             WHEN col.DATA_TYPE = 'decimal'
             THEN CONCAT('decimal(', NUMERIC_PRECISION, ', ',
                         NUMERIC_SCALE, ')')
             ELSE col.DATA_TYPE
        END AS DataType ,
        col.IS_NULLABLE AS IsNullable,
        dcn.DefaultName ,
        col.COLUMN_DEFAULT AS DefaultNameDefinition ,
        cc.CONSTRAINT_NAME AS CheckConstraintRuleName,
        cc.CHECK_CLAUSE  AS CheckConstraintRuleNameDefinition
    FROM ( SELECT TABLE_CATALOG ,
            TABLE_SCHEMA ,
            TABLE_NAME ,
            TABLE_TYPE
        FROM INFORMATION_SCHEMA.TABLES
        ) AS tbl
        INNER JOIN ( SELECT TABLE_CATALOG ,
            TABLE_SCHEMA ,
            TABLE_NAME ,
            COLUMN_NAME ,
            ORDINAL_POSITION ,
            COLUMN_DEFAULT ,
            IS_NULLABLE ,
            DATA_TYPE ,
            CHARACTER_MAXIMUM_LENGTH ,
            CHARACTER_OCTET_LENGTH ,
            NUMERIC_PRECISION ,
            NUMERIC_PRECISION_RADIX ,
            NUMERIC_SCALE ,
            DATETIME_PRECISION ,
            CHARACTER_SET_CATALOG ,
            CHARACTER_SET_SCHEMA ,
            CHARACTER_SET_NAME ,
            COLLATION_CATALOG ,
            COLLATION_SCHEMA ,
            COLLATION_NAME ,
            DOMAIN_CATALOG ,
            DOMAIN_SCHEMA ,
            DOMAIN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
                   ) AS col ON col.TABLE_CATALOG = tbl.TABLE_CATALOG
            AND col.TABLE_SCHEMA = tbl.TABLE_SCHEMA
            AND col.TABLE_NAME = tbl.TABLE_NAME
        LEFT OUTER JOIN ( SELECT t.name AS TableName ,
            SCHEMA_NAME(s.schema_id) AS SchemaName ,
            ac.name AS ColumnName ,
            d.name AS DefaultName
        FROM sys.all_columns AS ac
            INNER JOIN sys.tables AS t ON ac.object_id = t.object_id
            INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
            INNER JOIN sys.default_constraints AS d ON ac.default_object_id = d.object_id
                        ) AS dcn ON dcn.SchemaName = tbl.TABLE_SCHEMA
            AND dcn.TableName = tbl.TABLE_NAME
            AND dcn.ColumnName = col.COLUMN_NAME
        LEFT OUTER JOIN ( SELECT cu.TABLE_CATALOG ,
            cu.TABLE_SCHEMA ,
            cu.TABLE_NAME ,
            cu.COLUMN_NAME ,
            c.CONSTRAINT_CATALOG ,
            c.CONSTRAINT_SCHEMA ,
            c.CONSTRAINT_NAME ,
            c.CHECK_CLAUSE
        FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
                                    AS cu
            INNER JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS
                                    AS c ON c.CONSTRAINT_NAME = cu.CONSTRAINT_NAME
                        ) AS cc ON cc.TABLE_SCHEMA = tbl.TABLE_SCHEMA
            AND cc.TABLE_NAME = tbl.TABLE_NAME
            AND cc.COLUMN_NAME = col.COLUMN_NAME
 
 
GO


/*
View: [Utils].[uvw_FindTablesStorageBytes]

Description:
This view provides an estimate of the storage size in bytes for each column in tables within specified schemas (schemas starting with 'CH'). It utilizes the [Utils].[uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint] view to retrieve column details and then calculates the storage size based on the data type of each column. The view handles various data types, including varchar, char, int, money, and date, providing an estimate of the storage requirement for each column.

Columns:
- FullyQualifiedTableName: The combined schema and table name.
- ColumnName: The name of the column.
- DataType: The data type of the column.
- OrdinalPosition: The position of the column in the table.
- StorageBytes: An estimated storage size for the column in bytes. This estimate includes additional storage requirements for variable-length types.

Usage:
This view is useful for database sizing and capacity planning. It can be used to estimate the storage requirements for each column in the database's tables, which is particularly beneficial when working with large databases or planning for data growth.

Example:
SELECT * FROM [Utils].[uvw_FindTablesStorageBytes];

This example retrieves the estimated storage size for each column in tables belonging to schemas that start with 'CH'.

Note: The storage size calculations are estimates and may not reflect the exact storage requirements, especially for variable-length fields and fields with additional storage overhead.

-- =============================================
-- Author:		Professor Heller
-- Create date: default
-- Description:	Code taken from the 'Script as Create' result of the views within the BIClass db
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Utils].[uvw_FindTablesStorageBytes]
as
    select FullyQualifiedTableName
     , ColumnName
     , DataType
     , OrdinalPosition
     , StorageBytes = case
                          when charindex('(', DataType, 0) > 0
            and substring(DataType, 1, 3) = 'var' then
                              cast(substring(
                                                DataType
                                              , charindex('(', DataType, 0) + 1
                                              , len(DataType) - charindex('(', DataType, 0) - 1
                                            ) as int) + 2
                          when charindex('(', DataType, 0) > 0
            and substring(DataType, 1, 3) = 'cha' then
                              cast(substring(
                                                DataType
                                              , charindex('(', DataType, 0) + 1
                                              , len(DataType) - charindex('(', DataType, 0) - 1
                                            ) as int)
                          when substring(DataType, 1, 3) = 'int' then
                              4
                          when substring(DataType, 1, 3) = 'mon' then
                              4
                          when substring(DataType, 1, 3) = 'dat' then
                              3
                          else
                              -999
                      end
    from Utils.uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint
    where (SchemaName like 'CH%');
GO



------------------------- CREATE TABLES ---------------------------


-- UserAuthorization Table -- 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DbSecurity].[UserAuthorization]
(
    [UserAuthorizationKey] [int] NOT NULL,
    [ClassTime] [nchar](5) NOT NULL,
    [IndividualProject] [nvarchar](60) NULL,
    [GroupMemberLastName] [nvarchar](35) NOT NULL,
    [GroupMemberFirstName] [nvarchar](25) NOT NULL,
    [GroupName] [nvarchar](20) NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[UserAuthorizationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


-- OriginallyLoadedData Table -- 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FileUpload].[OriginallyLoadedData]
(
    [SalesKey] [int] NOT NULL,
    [ProductCategory] [varchar](20) NULL,
    [ProductSubcategory] [varchar](20) NULL,
    [SalesManager] [varchar](20) NULL,
    [ProductCode] [varchar](10) NULL,
    [ProductName] [varchar](40) NULL,
    [Color] [varchar](10) NULL,
    [ModelName] [varchar](30) NULL,
    [OrderQuantity] [int] NULL,
    [UnitPrice] [money] NULL,
    [ProductStandardCost] [money] NULL,
    [SalesAmount] [money] NULL,
    [OrderDate] [date] NULL,
    [MonthName] [varchar](10) NULL,
    [MonthNumber] [int] NULL,
    [Year] [int] NULL,
    [CustomerName] [varchar](30) NULL,
    [MaritalStatus] [char](1) NULL,
    [Gender] [char](1) NULL,
    [Education] [varchar](20) NULL,
    [Occupation] [varchar](20) NULL,
    [TerritoryRegion] [varchar](20) NULL,
    [TerritoryCountry] [varchar](20) NULL,
    [TerritoryGroup] [varchar](20) NULL
) ON [PRIMARY]
GO


-- Migrate the data from the BiClass DB to our group DB
INSERT INTO [G9:15_Group1].[FileUpload].[OriginallyLoadedData]
    ([SalesKey], [ProductCategory], [ProductSubcategory], [SalesManager], [ProductCode],
    [ProductName], [Color], [ModelName], [OrderQuantity], [UnitPrice],
    [ProductStandardCost], [SalesAmount], [OrderDate], [MonthName], [MonthNumber],
    [Year], [CustomerName], [MaritalStatus], [Gender], [Education],
    [Occupation], [TerritoryRegion], [TerritoryCountry], [TerritoryGroup])
SELECT
    [SalesKey], [ProductCategory], [ProductSubcategory], [SalesManager], [ProductCode],
    [ProductName], [Color], [ModelName], [OrderQuantity], [UnitPrice],
    [ProductStandardCost], [SalesAmount], [OrderDate], [MonthName], [MonthNumber],
    [Year], [CustomerName], [MaritalStatus], [Gender], [Education],
    [Occupation], [TerritoryRegion], [TerritoryCountry], [TerritoryGroup]
FROM [BIClass].[FileUpload].[OriginallyLoadedData];



/*
Table: [CH01-01-Fact].[Data]

Description:
This table serves as the central fact table for the sales data warehouse. It contains transactional 
data including sales details, product information, and customer information. The table is designed 
to integrate with various dimension tables in a star schema setup, allowing for complex analytical 
queries and reporting.

Columns:
[SalesKey] - The primary key for the table, uniquely identifying each sales transaction.
[SalesManagerKey] - Foreign key reference to the SalesManagers dimension table.
[OccupationKey] - Foreign key reference to the Occupation dimension table.
[TerritoryKey] - Foreign key reference to the Territory dimension table.
[ProductKey] - Foreign key reference to the Product dimension table.
[CustomerKey] - Foreign key reference to the Customer dimension table.
[ProductCategory], [SalesManager], [ProductSubcategory], ... - Descriptive attributes of the sale.
[UserAuthorizationKey] - Foreign key reference to the UserAuthorization table, used for tracking and auditing which users are responsible for the transaction records.
[DateAdded] - The date and time when the record was added to the table.
[DateOfLastUpdate] - The date and time when the record was last updated.

Foreign Key Relationships:
[FK_Data_DimCustomer] - Links to the Customer dimension.
[FK_Data_DimGender] - Links to the Gender dimension.
[FK_Data_DimMaritalStatus] - Links to the Marital Status dimension.
[FK_Data_DimOccupation] - Links to the Occupation dimension.
[FK_Data_DimOrderDate] - Links to the Order Date dimension.
[FK_Data_DimProduct] - Links to the Product dimension.
[FK_Data_DimTerritory] - Links to the Territory dimension.
[FK_Data_SalesManagers] - Links to the Sales Managers dimension.
[FK_Data_UserAuthorization] - Links to the User Authorization tracking table.

Usage:
This table is populated through ETL processes that extract sales data from operational systems. 
It is used for generating reports, performing sales trend analysis, and measuring performance 
indicators across different dimensions such as time, product, and sales territory.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Fact].[Data]
(
    [SalesKey] [int] NOT NULL,
    [SalesManagerKey] [int] NULL,
    [OccupationKey] [int] NULL,
    [TerritoryKey] [int] NULL,
    [ProductKey] [int] NULL,
    [CustomerKey] [int] NULL,
    [ProductCategory] [varchar](20) NULL,
    [SalesManager] [varchar](20) NULL,
    [ProductSubcategory] [varchar](20) NULL,
    [ProductCode] [varchar](10) NULL,
    [ProductName] [varchar](40) NULL,
    [Color] [varchar](10) NULL,
    [ModelName] [varchar](30) NULL,
    [OrderQuantity] [int] NULL,
    [UnitPrice] [money] NULL,
    [ProductStandardCost] [money] NULL,
    [SalesAmount] [money] NULL,
    [OrderDate] [date] NULL,
    [MonthName] [varchar](10) NULL,
    [MonthNumber] [int] NULL,
    [Year] [int] NULL,
    [CustomerName] [varchar](30) NULL,
    [MaritalStatus] [char](1) NULL,
    [Gender] [char](1) NULL,
    [Education] [varchar](20) NULL,
    [Occupation] [varchar](20) NULL,
    [TerritoryRegion] [varchar](20) NULL,
    [TerritoryCountry] [varchar](20) NULL,
    [TerritoryGroup] [varchar](20) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[SalesKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW G9_1.[uvw_FactData]
AS
    SELECT
        Saleskey,
        SalesManagerKey,
        OccupationKey,
        TerritoryKey,
        ProductKey,
        CustomerKey,
        ProductCategory,
        SalesManager,
        ProductSubcategory,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        OrderQuantity,
        UnitPrice,
        ProductStandardCost,
        SalesAmount,
        OrderDate,
        [MonthName],
        MonthNumber,
        [Year],
        CustomerName,
        MaritalStatus,
        Gender,
        Education,
        Occupation,
        TerritoryRegion,
        TerritoryCountry,
        TerritoryGroup,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
    FROM [CH01-01-Fact].[Data] 
GO

/*
Table: [CH01-01-Dimension].[DimCustomer]

Description:
This table serves as a dimension table in the data warehouse schema, primarily focusing on customer-related information. 
It stores key details about customers, along with auditing information about when each record was added and last updated. 
The table also integrates a link to user authorization through the UserAuthorizationKey.

Columns:
- CustomerKey: The primary key for the table, uniquely identifying each customer record.
- CustomerName: The name of the customer.
- UserAuthorizationKey: A foreign key that references the UserAuthorization table, indicating which user created or last 
updated the record. This is used for tracking and auditing purposes.
- DateAdded: The date and time when the record was added to the table.
- DateOfLastUpdate: The date and time when the record was last updated.

Primary Key:
- The primary key of the table is [CustomerKey], ensuring that each customer is uniquely identifiable.

Index and Statistics Options:
- PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS are set for optimal performance 
and concurrency control. OPTIMIZE_FOR_SEQUENTIAL_KEY is turned off.

Usage:
The DimCustomer table is used in conjunction with fact tables to provide a detailed and dimensional view of customer data. 
It's a key component in analyses, reports, and queries that require customer information.

Example:
SELECT * FROM [CH01-01-Dimension].[DimCustomer]
WHERE CustomerKey = 12345;

This example retrieves information for the customer with a CustomerKey of 12345.

Note: The table is part of a larger dimensional model and should be maintained with consideration to data integrity and 
consistency, particularly regarding the UserAuthorizationKey.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimCustomer]
(
    [CustomerKey] [int] NOT NULL,
    [CustomerName] [varchar](30) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW G9_1.[uvw_DimCustomer]
AS
    SELECT CustomerKey, CustomerName, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimCustomer] 
GO


/*
Table: [CH01-01-Dimension].[DimGender]

Description:
This table represents the gender dimension in the data warehouse schema. It categorizes and describes gender in a standardized format. The table includes a concise code for each gender category and a more descriptive label for each category. It also includes auditing fields for tracking the creation and modification of records.

Columns:
- Gender: A character field that serves as the primary key, representing a concise code for the gender (e.g., 'M' for male, 'F' for female).
- GenderDescription: A descriptive label for each gender category, such as 'Male', 'Female', etc.
- UserAuthorizationKey: A foreign key that references the UserAuthorization table, indicating which user created or last updated the record. This key is used for auditing purposes.
- DateAdded: The date and time when the record was initially added to the table.
- DateOfLastUpdate: The date and time when the record was last updated.

Primary Key:
- The primary key of the table is [Gender], ensuring a unique representation for each gender category.

Index and Statistics Options:
- PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS are configured for performance and concurrency optimization. OPTIMIZE_FOR_SEQUENTIAL_KEY is disabled.

Usage:
The DimGender table is typically used in conjunction with fact tables for gender-based analysis in reports, queries, and data mining operations. It is a key dimension in understanding and segmenting data by gender.

Example:
SELECT * FROM [CH01-01-Dimension].[DimGender]
WHERE Gender = 'M';

This example retrieves the record for the gender category represented by 'M'.

Note: Maintaining the integrity and consistency of data in this table is important, especially in terms of its relationship with the UserAuthorization table for auditing purposes.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimGender]
(
    [Gender] [char](1) NOT NULL,
    [GenderDescription] [varchar](6) NOT NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[Gender] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW G9_1.[uvw_DimGender]
AS
    SELECT Gender, GenderDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimGender] 
GO


/*
Table: [CH01-01-Dimension].[DimMaritalStatus]

Description:
The DimMaritalStatus table is part of the data warehouse dimensional model, specifically designed to represent various marital statuses. It provides a standardized way of categorizing individuals based on their marital status, using both a concise code and a more descriptive label. The table also incorporates fields for user authorization and timestamps to track when records are added or updated.

Columns:
- MaritalStatus: A character field that serves as the primary key. It represents a concise code for the marital status (e.g., 'S' for single, 'M' for married).
- MaritalStatusDescription: A descriptive label for each marital status category, such as 'Single', 'Married', etc.
- UserAuthorizationKey: A foreign key that links to the UserAuthorization table, denoting the user responsible for creating or updating the record. This field is essential for auditing and data governance.
- DateAdded: The date and time when the record was initially added to the table.
- DateOfLastUpdate: The date and time when the record was last updated.

Primary Key:
- The primary key of the table is [MaritalStatus], ensuring a unique and standardized representation for each marital status category.

Index and Statistics Options:
- Configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for optimal performance. OPTIMIZE_FOR_SEQUENTIAL_KEY is turned off.

Usage:
The DimMaritalStatus table is utilized in conjunction with fact tables to facilitate marital status-based analysis in reporting, querying, and data analysis operations. It is a key dimension in demographic and market segmentation analyses.

Example:
SELECT * FROM [CH01-01-Dimension].[DimMaritalStatus]
WHERE MaritalStatus = 'M';

This example retrieves information about the marital status represented by 'M'.

Note: Data integrity and consistency, especially in relation to the UserAuthorizationKey, are crucial for maintaining the reliability and auditability of this table.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimMaritalStatus]
(
    [MaritalStatus] [char](1) NOT NULL,
    [MaritalStatusDescription] [varchar](7) NOT NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[MaritalStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW G9_1.[uvw_DimMaritalStatus]
AS
    SELECT MaritalStatus, MaritalStatusDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimMaritalStatus] 
GO

/*
Table: [CH01-01-Dimension].[DimOccupation]

Description:
The DimOccupation table is a dimension table in the data warehouse schema that categorizes individuals based on their occupation. It contains a unique key for each occupation type and a descriptive label. Additionally, the table tracks the user who added or last updated each record, along with the dates of these actions, to aid in data governance and auditing.

Columns:
- OccupationKey: The primary key for the table, an integer uniquely identifying each occupation type.
- Occupation: A varchar(20) field providing a descriptive name or title for each occupation.
- UserAuthorizationKey: An integer foreign key linking to the UserAuthorization table. This key indicates which user is responsible for the creation or last update of the record and is vital for auditing.
- DateAdded: The datetime2(7) timestamp of when the record was added to the table.
- DateOfLastUpdate: The datetime2(7) timestamp of when the record was last updated.

Primary Key:
- The primary key is [OccupationKey], ensuring that each occupation type is uniquely identifiable.

Index and Statistics Options:
- The table is configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for optimal performance and concurrency management. OPTIMIZE_FOR_SEQUENTIAL_KEY is disabled.

Usage:
The DimOccupation table is used in conjunction with fact tables for analyses that require categorization or segmentation of data based on occupation. It is essential in workforce analysis, demographic studies, and market segmentation.

Example:
SELECT * FROM [CH01-01-Dimension].[DimOccupation]
WHERE OccupationKey = 101;

This example retrieves information about the occupation with an OccupationKey of 101.

Note: Maintaining the accuracy and consistency of the data in this table, especially the UserAuthorizationKey, is critical for ensuring the integrity and reliability of the data warehouse.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimOccupation]
(
    [OccupationKey] [int] NOT NULL,
    [Occupation] [varchar](20) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[OccupationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW G9_1.[uvw_DimOccupation]
AS
    SELECT OccupationKey, Occupation, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimOccupation] 
GO

/*
Table: [CH01-01-Dimension].[DimOrderDate]

Description:
The DimOrderDate table is a dimension table in the data warehouse schema focused on storing date-related information, particularly for orders. It breaks down each date into its constituent parts, such as month name, month number, and year, for more granular analysis. This table also includes fields for user authorization and timestamps to track when records are added or updated.

Columns:
- OrderDate: The primary key of the table, a date field uniquely identifying each day.
- MonthName: A varchar(10) field representing the name of the month for the given order date.
- MonthNumber: An integer representing the numeric month of the year for the given order date.
- Year: An integer representing the year for the given order date.
- UserAuthorizationKey: An integer foreign key linking to the UserAuthorization table, denoting the user responsible for creating or updating the record. This field is important for auditing and data governance.
- DateAdded: The datetime2(7) timestamp of when the record was initially added to the table.
- DateOfLastUpdate: The datetime2(7) timestamp of when the record was last updated.

Primary Key:
- The primary key of the table is [OrderDate], ensuring a unique representation for each date.

Index and Statistics Options:
- Configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for optimal performance. OPTIMIZE_FOR_SEQUENTIAL_KEY is turned off.

Usage:
The DimOrderDate table is typically used in conjunction with fact tables for date-based analysis in reports, queries, and data mining operations. It is a key dimension in time-based analyses, such as trend analysis and temporal comparisons.

Example:
SELECT * FROM [CH01-01-Dimension].[DimOrderDate]
WHERE OrderDate = '2023-01-01';

This example retrieves information for the order date of January 1, 2023.

Note: Data integrity and consistency, especially in relation to the UserAuthorizationKey, are crucial for maintaining the reliability and auditability of this table.

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimOrderDate]
(
    [OrderDate] [date] NOT NULL,
    [MonthName] [varchar](10) NULL,
    [MonthNumber] [int] NULL,
    [Year] [int] NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[OrderDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW G9_1.[uvw_DimOrderDate]
AS
    SELECT OrderDate, MonthName, MonthNumber, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimOrderDate] 
GO


/*
Table: [CH01-01-Dimension].[DimProduct]

Description:
This dimension table stores the master data related to products. It includes descriptive details of each product, 
such as category, subcategory, code, name, color, and model name. This table supports the star schema design by 
providing context to the sales transactions recorded in the fact table, allowing for more detailed analysis and 
reporting on product-related dimensions.

Columns:
[ProductKey] - The primary key for the table, uniquely identifying each product.
[ProductSubcategoryKey] - A foreign key that links to the product subcategory dimension table.
[ProductCategory] - A descriptive attribute specifying the category of the product.
[ProductSubcategory] - A descriptive attribute specifying the subcategory of the product.
[ProductCode] - A unique code assigned to the product.
[ProductName] - The name of the product.
[Color] - The color of the product.
[ModelName] - The model name of the product.
[UserAuthorizationKey] - A foreign key linking to the UserAuthorization table to track which user is responsible for the product record.
[DateAdded] - The date and time when the product record was added to the table.
[DateOfLastUpdate] - The date and time when the product record was last updated.

Foreign Key Relationships:
[FK_DimProduct_DimProductSubCategory] - Links to the Product Subcategory dimension to provide a hierarchical relationship within the product dimension.
[FK_DimProduct_UserAuthorization] - Links to the User Authorization table for tracking the user who has added or last updated the product record.

Usage:
The table is populated and updated through administrative processes where product information is managed. 
It is used in conjunction with the fact table to enable detailed product-level analysis and reporting in a business intelligence context.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimProduct]
(
    [ProductKey] [int] NOT NULL,
    [ProductSubcategoryKey] [int] NULL,
    [ProductCategory] [varchar](20) NULL,
    [ProductSubcategory] [varchar](20) NULL,
    [ProductCode] [varchar](10) NULL,
    [ProductName] [varchar](40) NULL,
    [Color] [varchar](10) NULL,
    [ModelName] [varchar](30) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[ProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW G9_1.[uvw_DimProduct]
AS
    SELECT
        ProductKey,
        ProductSubcategoryKey,
        ProductCategory,
        ProductSubcategory,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimProduct] 
GO

/*
Table: [CH01-01-Dimension].[DimTerritory]

Description:
The DimTerritory table is a dimension table in the data warehouse schema, designed to categorize geographical areas into territories for analysis. It includes information about various territorial levels, such as the group, country, and region. This table also incorporates user authorization tracking and timestamps for record creation and updates.

Columns:
- TerritoryKey: The primary key of the table, an integer that uniquely identifies each territory record.
- TerritoryGroup: A varchar(20) field representing the higher-level grouping of territories.
- TerritoryCountry: A varchar(20) field indicating the country associated with the territory.
- TerritoryRegion: A varchar(20) field specifying the region within the territory.
- UserAuthorizationKey: An integer foreign key linking to the UserAuthorization table, indicating which user is responsible for the record. This is important for auditing purposes.
- DateAdded: The datetime2(7) timestamp when the record was initially added to the table.
- DateOfLastUpdate: The datetime2(7) timestamp when the record was last updated.

Primary Key:
- The primary key is [TerritoryKey], ensuring unique identification of each territorial record.

Index and Statistics Options:
- Configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for optimized performance and concurrency. OPTIMIZE_FOR_SEQUENTIAL_KEY is disabled.

Usage:
The DimTerritory table is used in conjunction with fact tables to perform geographical or territorial analysis. It enables data segmentation and detailed examination based on geographic regions, which is crucial for regional sales analysis, market segmentation, and strategic planning.

Example:
SELECT * FROM [CH01-01-Dimension].[DimTerritory]
WHERE TerritoryKey = 100;

This example retrieves details about the territory with a TerritoryKey of 100.

Note: Data integrity and consistency, especially regarding the UserAuthorizationKey, are vital for maintaining the accuracy and auditability of this table.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimTerritory]
(
    [TerritoryKey] [int] NOT NULL,
    [TerritoryGroup] [varchar](20) NULL,
    [TerritoryCountry] [varchar](20) NULL,
    [TerritoryRegion] [varchar](20) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[TerritoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [G9_1].[uvw_DimTerritory]
AS
    SELECT TerritoryKey, TerritoryGroup, TerritoryCountry, TerritoryRegion, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimTerritory] 
GO

/*
Table: [CH01-01-Dimension].[SalesManagers]

Description:
The SalesManagers table is a dimension table within the data warehouse that provides detailed information about sales managers. It includes the manager's name, their office location, and the category they are associated with. The table also features fields for user authorization to track who added or updated the records and timestamps for these events.

Columns:
- SalesManagerKey: The primary key of the table, an integer uniquely identifying each sales manager.
- Category: A varchar(20) field indicating the category or segment the sales manager oversees.
- SalesManager: A varchar(50) field containing the name of the sales manager.
- Office: A varchar(50) field detailing the office location of the sales manager.
- UserAuthorizationKey: An integer foreign key that links to the UserAuthorization table, indicating the user responsible for creating or updating the record. This key is crucial for auditing and governance.
- DateAdded: The datetime2(7) timestamp when the record was added to the table.
- DateOfLastUpdate: The datetime2(7) timestamp when the record was last updated.

Primary Key:
- The primary key is [SalesManagerKey], ensuring each sales manager is uniquely identified.

Index and Statistics Options:
- The table is configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for performance optimization. OPTIMIZE_FOR_SEQUENTIAL_KEY is turned off.

Usage:
This table is utilized for analysis that involves sales performance, management efficiency, and regional sales strategies. It allows for a detailed breakdown of sales data by manager, office, and category.

Example:
SELECT * FROM [CH01-01-Dimension].[SalesManagers]
WHERE SalesManagerKey = 101;

This example retrieves information about the sales manager with a SalesManagerKey of 101.

Note: It's important to maintain the accuracy and consistency of the data in this table, particularly regarding the UserAuthorizationKey, to ensure data integrity and reliable auditing.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[SalesManagers]
(
    [SalesManagerKey] [int] NOT NULL,
    [Category] [varchar](20) NULL,
    [SalesManager] [varchar](50) NULL,
    [Office] [varchar](50) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[SalesManagerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [G9_1].[uvw_SalesManagers]
AS
    SELECT SalesManagerKey, SalesManager, Category, Office, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[SalesManagers] 
GO


/*
Table: [CH01-01-Dimension].[DimProductCategory]

Description:
The DimProductCategory table is a dimension table in the data warehouse, designed to categorize products into various categories. This table includes a unique key for each product category and a descriptive name for the category. It also contains fields for user authorization and timestamps to keep track of when each record was added or last updated, aiding in data governance and auditing.

Columns:
- ProductCategoryKey: The primary key of the table, an integer uniquely identifying each product category.
- ProductCategory: A varchar(20) field providing the name or description of the product category.
- UserAuthorizationKey: An integer foreign key that references the UserAuthorization table, indicating the user responsible for creating or updating the record. This is vital for auditing purposes.
- DateAdded: The datetime2(7) timestamp when the record was initially added to the table.
- DateOfLastUpdate: The datetime2(7) timestamp when the record was last updated.

Primary Key:
- The primary key is [ProductCategoryKey], ensuring each product category is uniquely identifiable.

Index and Statistics Options:
- Configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for optimal performance and data integrity. OPTIMIZE_FOR_SEQUENTIAL_KEY is turned off.

Usage:
The DimProductCategory table is used in conjunction with fact tables for product-based analysis. It enables businesses to segment and analyze data by product categories, which is crucial for market analysis, inventory management, and sales strategy.

Example:
SELECT * FROM [CH01-01-Dimension].[DimProductCategory]
WHERE ProductCategoryKey = 10;

This example retrieves information about the product category with a ProductCategoryKey of 10.

Note: Maintaining the accuracy and consistency of the data in this table, especially the UserAuthorizationKey, is crucial for ensuring the integrity and reliability of the data warehouse.

*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimProductCategory]
(
    [ProductCategoryKey] [int] NOT NULL,
    [ProductCategory] [varchar](20) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[ProductCategoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW G9_1.[uvw_DimProductCategory]
AS
    SELECT ProductCategoryKey, ProductCategory, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimProductCategory] 
GO

/*
Table: [CH01-01-Dimension].[DimProductSubCategory]

Description:
The DimProductSubCategory table is a dimension table within the data warehouse schema, designed to further categorize products into subcategories. This table links each subcategory to a broader product category, and it includes a unique identifier for each subcategory, along with a descriptive name. Additionally, the table tracks user authorization details and timestamps for the creation and update of records.

Columns:
- ProductSubcategoryKey: The primary key of the table, an integer uniquely identifying each product subcategory.
- ProductCategoryKey: An integer foreign key that references the ProductCategory dimension, linking the subcategory to its parent category.
- ProductSubcategory: A varchar(20) field providing the name or description of the product subcategory.
- UserAuthorizationKey: An integer foreign key linking to the UserAuthorization table, denoting the user responsible for creating or updating the record. This key is crucial for auditing and data governance.
- DateAdded: The datetime2(7) timestamp when the record was added to the table.
- DateOfLastUpdate: The datetime2(7) timestamp when the record was last updated.

Primary Key:
- The primary key is [ProductSubcategoryKey], ensuring unique identification of each product subcategory.

Index and Statistics Options:
- Configured with PAD_INDEX, STATISTICS_NORECOMPUTE, IGNORE_DUP_KEY, ALLOW_ROW_LOCKS, and ALLOW_PAGE_LOCKS for optimal performance. OPTIMIZE_FOR_SEQUENTIAL_KEY is disabled.

Usage:
The DimProductSubCategory table is used alongside fact tables for detailed product-based analysis, allowing for segmentation and analysis at a more granular subcategory level. This is essential for detailed market analysis, inventory management, and sales strategy formulation.

Example:
SELECT * FROM [CH01-01-Dimension].[DimProductSubCategory]
WHERE ProductSubcategoryKey = 200;

This example retrieves information about the product subcategory with a ProductSubcategoryKey of 200.

Note: It is important to maintain data integrity and consistency in this table, particularly concerning the UserAuthorizationKey, to ensure the reliability and auditability of the data.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CH01-01-Dimension].[DimProductSubCategory]
(
    [ProductSubcategoryKey] [int] NOT NULL,
    [ProductCategoryKey] [int] NOT NULL,
    [ProductSubcategory] [varchar](20) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    [DateAdded] [datetime2](7) NULL,
    [DateOfLastUpdate] [datetime2](7) NULL,
    PRIMARY KEY CLUSTERED 
(
	[ProductSubcategoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- accompanying view --

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [G9_1].[uvw_DimProductSubCategory]
AS
    SELECT ProductSubCategoryKey, ProductCategoryKey, ProductSubcategory, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimProductSubCategory] 
GO


/*

Table: Process.[WorkflowSteps]

Description:
This table is used for auditing and tracking the execution of various workflow steps within the system. 
It records key information about each workflow step, including a description, the number of rows affected, 
the start and end times of the step, and the user who executed the step.

Columns:
[WorkFlowStepKey] - The primary key for the table, uniquely identifying each workflow step.
[WorkFlowStepDescription] - A descriptive name or summary of the workflow step.
[WorkFlowStepTableRowCount] - The number of table rows that were affected or processed during the workflow step.
[StartingDateTime] - The date and time when the workflow step began.
[EndingDateTime] - The date and time when the workflow step ended.
[Class Time] - An optional field that could be used to record the time of a class or session during which the workflow step was executed.
[UserAuthorizationKey] - A foreign key linking to the UserAuthorization table to identify the user responsible for the workflow step.

Usage:
This table is populated by the 'usp_TrackWorkFlow' stored procedure, which is called at the beginning and end 
of each workflow step to log its execution. It can be used for monitoring system activity, analyzing the performance 
and duration of workflow steps, and ensuring that data processing is carried out by authorized users.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE Process.[WorkflowSteps]
(
    [WorkFlowStepKey] [int] NOT NULL,
    [WorkFlowStepDescription] [nvarchar](100) NOT NULL,
    [WorkFlowStepTableRowCount] [int] NULL,
    [StartingDateTime] [datetime2](7) NULL,
    [EndingDateTime] [datetime2](7) NULL,
    [Class Time] [char](5) NULL,
    [UserAuthorizationKey] [int] NOT NULL,
    PRIMARY KEY CLUSTERED 
(
	[WorkFlowStepKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

----- Misc product tables from BIClass----

-- ProductCategories Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FileUpload].[ProductCategories]
(
    [ProductCategory] [varchar](20) NOT NULL
) ON [PRIMARY]
GO

-- ProductSubcategories Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FileUpload].[ProductSubcategories]
(
    [ProductSubcategory] [varchar](20) NOT NULL
) ON [PRIMARY]
GO

----------------- Prepopulating the UserAuthorization Table with the Group Names -------------

INSERT INTO [DbSecurity].[UserAuthorization]
([GroupMemberLastName],[GroupMemberFirstName])
VALUES

        ('Georgievska','Aleksandra'),
        ('Yakubova','Sigalita'),
        ('Kong','Nicholas'),
        ('Wray','Edwin'),
        ('Ahmed','Ahnaf'),
        ('Richman','Aryeh');
GO

--------------------- Alter Tables To Update Defaults/Constraints -------------------

ALTER TABLE [CH01-01-Dimension].[DimCustomer] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[DimCustomerSequenceObject]) FOR [CustomerKey]
GO
ALTER TABLE [CH01-01-Dimension].[DimCustomer] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimCustomer] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimGender] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimGender] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimOccupation] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[OccupationSequenceObject]) FOR [OccupationKey]
GO
ALTER TABLE [CH01-01-Dimension].[DimOccupation] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimOccupation] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimOrderDate] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimOrderDate] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[DimProductSequenceObject]) FOR [ProductKey]
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductCategory] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[DimProductCategorySequenceObject]) FOR [ProductCategoryKey]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductCategory] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductCategory] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[DimProductSubCategorySequenceObject]) FOR [ProductSubcategoryKey]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[DimTerritory] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[DimTerritorySequenceObject]) FOR [TerritoryKey]
GO
ALTER TABLE [CH01-01-Dimension].[DimTerritory] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[DimTerritory] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Dimension].[SalesManagers] ADD  DEFAULT (NEXT VALUE FOR [PkSequence].[SalesManagersSequenceObject]) FOR [SalesManagerKey]
GO
ALTER TABLE [CH01-01-Dimension].[SalesManagers] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Dimension].[SalesManagers] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [CH01-01-Fact].[Data] ADD  DEFAULT (NEXT VALUE FOR PkSequence.[DataSequenceObject]) FOR [SalesKey]
GO
ALTER TABLE [CH01-01-Fact].[Data] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [CH01-01-Fact].[Data] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT (NEXT VALUE FOR PkSequence.[UserAuthorizationSequenceObject]) FOR [UserAuthorizationKey]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT ('9:15') FOR [ClassTime]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT ('PROJECT 2 RECREATE THE BICLASS DATABASE STAR SCHEMA') FOR [IndividualProject]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT ('GROUP 1') FOR [GroupName]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE Process.[WorkflowSteps] ADD  DEFAULT (NEXT VALUE FOR PkSequence.[WorkFlowStepsSequenceObject]) FOR [WorkFlowStepKey]
GO
ALTER TABLE Process.[WorkflowSteps] ADD  DEFAULT ((0)) FOR [WorkFlowStepTableRowCount]
GO
ALTER TABLE Process.[WorkflowSteps] ADD  DEFAULT (sysdatetime()) FOR [StartingDateTime]
GO
ALTER TABLE Process.[WorkflowSteps] ADD  DEFAULT (sysdatetime()) FOR [EndingDateTime]
GO
ALTER TABLE Process.[WorkflowSteps] ADD  DEFAULT ('9:15') FOR [Class Time]
GO
ALTER TABLE [CH01-01-Dimension].[DimCustomer]  WITH CHECK ADD  CONSTRAINT [FK_DimCustomer_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimCustomer] CHECK CONSTRAINT [FK_DimCustomer_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimGender]  WITH CHECK ADD  CONSTRAINT [FK_DimGender_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimGender] CHECK CONSTRAINT [FK_DimGender_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus]  WITH CHECK ADD  CONSTRAINT [FK_DimMaritalStatus_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] CHECK CONSTRAINT [FK_DimMaritalStatus_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimOccupation]  WITH CHECK ADD  CONSTRAINT [FK_DimOccupation_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimOccupation] CHECK CONSTRAINT [FK_DimOccupation_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimOrderDate]  WITH CHECK ADD  CONSTRAINT [FK_DimOrderDate_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimOrderDate] CHECK CONSTRAINT [FK_DimOrderDate_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct]  WITH CHECK ADD  CONSTRAINT [FK_DimProduct_DimProductSubCategory] FOREIGN KEY([ProductSubcategoryKey])
REFERENCES [CH01-01-Dimension].[DimProductSubCategory] ([ProductSubcategoryKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct] CHECK CONSTRAINT [FK_DimProduct_DimProductSubCategory]
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct]  WITH CHECK ADD  CONSTRAINT [FK_DimProduct_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimProduct] CHECK CONSTRAINT [FK_DimProduct_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductCategory]  WITH CHECK ADD  CONSTRAINT [FK_DimProductCategory_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimProductCategory] CHECK CONSTRAINT [FK_DimProductCategory_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory]  WITH CHECK ADD  CONSTRAINT [FK_DimProductSubCategory_DimProductCategory] FOREIGN KEY([ProductCategoryKey])
REFERENCES [CH01-01-Dimension].[DimProductCategory] ([ProductCategoryKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory] CHECK CONSTRAINT [FK_DimProductSubCategory_DimProductCategory]
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory]  WITH CHECK ADD  CONSTRAINT [FK_DimProductSubCategory_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory] CHECK CONSTRAINT [FK_DimProductSubCategory_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[DimTerritory]  WITH CHECK ADD  CONSTRAINT [FK_DimTerritory_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[DimTerritory] CHECK CONSTRAINT [FK_DimTerritory_UserAuthorization]
GO
ALTER TABLE [CH01-01-Dimension].[SalesManagers]  WITH CHECK ADD  CONSTRAINT [FK_SalesManagers_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Dimension].[SalesManagers] CHECK CONSTRAINT [FK_SalesManagers_UserAuthorization]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimCustomer] FOREIGN KEY([CustomerKey])
REFERENCES [CH01-01-Dimension].[DimCustomer] ([CustomerKey])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimCustomer]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimGender] FOREIGN KEY([Gender])
REFERENCES [CH01-01-Dimension].[DimGender] ([Gender])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimGender]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimMaritalStatus] FOREIGN KEY([MaritalStatus])
REFERENCES [CH01-01-Dimension].[DimMaritalStatus] ([MaritalStatus])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimMaritalStatus]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimOccupation] FOREIGN KEY([OccupationKey])
REFERENCES [CH01-01-Dimension].[DimOccupation] ([OccupationKey])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimOccupation]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimOrderDate] FOREIGN KEY([OrderDate])
REFERENCES [CH01-01-Dimension].[DimOrderDate] ([OrderDate])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimOrderDate]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimProduct] FOREIGN KEY([ProductKey])
REFERENCES [CH01-01-Dimension].[DimProduct] ([ProductKey])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimProduct]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_DimTerritory] FOREIGN KEY([TerritoryKey])
REFERENCES [CH01-01-Dimension].[DimTerritory] ([TerritoryKey])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_DimTerritory]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_SalesManagers] FOREIGN KEY([SalesManagerKey])
REFERENCES [CH01-01-Dimension].[SalesManagers] ([SalesManagerKey])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_SalesManagers]
GO
ALTER TABLE [CH01-01-Fact].[Data]  WITH CHECK ADD  CONSTRAINT [FK_Data_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [CH01-01-Fact].[Data] CHECK CONSTRAINT [FK_Data_UserAuthorization]
GO
ALTER TABLE Process.[WorkflowSteps]  WITH CHECK ADD  CONSTRAINT [FK_WorkFlowSteps_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE Process.[WorkflowSteps] CHECK CONSTRAINT [FK_WorkFlowSteps_UserAuthorization]
GO


-------------- Create Stored Procedures --------------

/*
Stored Procedure: Process.[usp_ShowWorkflowSteps]

Description:
This stored procedure is designed to retrieve and display all records from the Process.[WorkFlowSteps] table. It is intended to provide a comprehensive view of all workflow steps that have been logged in the system, offering insights into the various processes and their execution details.

Operations:
- The procedure sets NOCOUNT ON to prevent the return of the count of affected rows, thereby enhancing performance and reducing network traffic.
- A simple SELECT statement retrieves all records from the Process.[WorkFlowSteps] table, providing details such as the description of the workflow step, the start and end times, the number of rows affected, and the user authorization key associated with each step.

Usage:
This procedure is particularly useful for administrators and analysts who need to audit or review the history of workflow steps executed in the system. It allows for an easy overview of the entire workflow history, which can be crucial for process optimization, troubleshooting, and compliance purposes.

Example:
EXEC Process.[usp_ShowWorkflowSteps];

This example executes the stored procedure to retrieve and display all workflow steps from the Process.[WorkFlowSteps] table.

Note: The effectiveness of this procedure depends on the accurate and consistent logging of workflow steps in the Process.[WorkFlowSteps] table.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Show table of all workflow steps
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Process.[usp_ShowWorkflowSteps]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SELECT *
    FROM Process.[WorkFlowSteps];
END
GO

/*
Stored Procedure: Process.[usp_TrackWorkFlow]

Description:
This stored procedure is designed to track and log each step of various workflows within the system. It inserts records into the [WorkflowSteps] table, capturing key details about each workflow step, such as its description, the number of table rows affected, and the start and end times. This procedure is instrumental in maintaining an audit trail and enhancing transparency in automated processes.

Parameters:
- @WorkflowDescription: NVARCHAR(100) describing the workflow step.
- @WorkFlowStepTableRowCount: INT indicating the number of rows affected or processed during the workflow step.
- @StartingDateTime: DATETIME2 marking when the workflow step began.
- @EndingDateTime: DATETIME2 marking when the workflow step ended.
- @UserAuthorizationKey: INT identifying the user who initiated or is responsible for the workflow step, crucial for auditing purposes.

Usage:
This procedure should be invoked at the start and end of each significant workflow step within automated processes or ETL jobs. It ensures that all workflow activities are logged, which aids in monitoring, troubleshooting, and analyzing process efficiency and user activity.

Example:
EXEC Process.[usp_TrackWorkFlow]
    @WorkflowDescription = 'Data Load Step 1',
    @WorkFlowStepTableRowCount = 100,
    @StartingDateTime = '2023-11-13T08:00:00',
    @EndingDateTime = '2023-11-13T08:30:00',
    @UserAuthorizationKey = 5;

This example logs a workflow step described as 'Data Load Step 1', indicating that 100 rows were affected, starting at 8:00 AM and ending at 8:30 AM on November 13, 2023, performed by the user with authorization key 5.

Note: Proper usage of this stored procedure is essential for accurate and reliable workflow tracking. It should be consistently implemented across all relevant workflows for effective auditability and process analysis.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Keep track of all workflow steps
-- =============================================
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Process.[usp_TrackWorkFlow]
    -- Add the parameters for the stored procedure here
    @WorkflowDescription NVARCHAR(100),
    @WorkFlowStepTableRowCount INT,
    @StartingDateTime DATETIME2,
    @EndingDateTime DATETIME2,
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    INSERT INTO Process.[WorkflowSteps]
        (
        WorkFlowStepDescription,
        WorkFlowStepTableRowCount,
        StartingDateTime,
        EndingDateTime,
        [Class Time],
        UserAuthorizationKey
        )
    VALUES
        (@WorkflowDescription, @WorkFlowStepTableRowCount, @StartingDateTime, @EndingDateTime, '9:15',
            @UserAuthorizationKey);

END;
GO

/*
Stored Procedure: Project2.[AddForeignKeysToStarSchemaData]

Description:
This procedure is responsible for establishing foreign key relationships across various tables in the star schema database. It adds constraints to link fact and dimension tables to ensure referential integrity. The procedure also associates dimension tables with the UserAuthorization table, thereby establishing a traceable link between data records and the users responsible for their creation or updates.

Parameters:
- @UserAuthorizationKey: INT representing the user authorizing this operation, used for auditing purposes.

Operations:
1. Adds foreign key constraints to the [CH01-01-Fact].[Data] table, linking it to various dimension tables like DimCustomer, DimGender, DimMaritalStatus, etc.
2. Adds foreign key constraints to dimension tables, linking them to the [DbSecurity].[UserAuthorization] table.
3. Tracks the process using Process.[usp_TrackWorkFlow] to maintain an audit trail of the operation.

Usage:
This procedure should be executed when setting up the database schema or when modifications to the schema are required. It ensures data integrity across the star schema by enforcing appropriate foreign key relationships.

Example:
EXEC Project2.[AddForeignKeysToStarSchemaData] @UserAuthorizationKey = 5;

This example runs the procedure to add foreign keys across tables, authorized by the user with key 5.

Note: Proper execution of this procedure is critical to maintain data integrity and referential relationships in the star schema database. It should be executed with caution, ensuring that no data inconsistencies exist that could be affected by the new constraints.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Add the foreign keys to the start Schema database
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project2].[AddForeignKeysToStarSchemaData]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimCustomer
        FOREIGN KEY (CustomerKey)
        REFERENCES [CH01-01-Dimension].DimCustomer (CustomerKey);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimGender
        FOREIGN KEY (Gender)
        REFERENCES [CH01-01-Dimension].DimGender (Gender);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimMaritalStatus
        FOREIGN KEY (MaritalStatus)
        REFERENCES [CH01-01-Dimension].DimMaritalStatus (MaritalStatus);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimOccupation
        FOREIGN KEY (OccupationKey)
        REFERENCES [CH01-01-Dimension].DimOccupation (OccupationKey);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimOrderDate
        FOREIGN KEY (OrderDate)
        REFERENCES [CH01-01-Dimension].DimOrderDate (OrderDate);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimProduct
        FOREIGN KEY (ProductKey)
        REFERENCES [CH01-01-Dimension].DimProduct (ProductKey);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimTerritory
        FOREIGN KEY (TerritoryKey)
        REFERENCES [CH01-01-Dimension].DimTerritory (TerritoryKey);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_SalesManagers
        FOREIGN KEY (SalesManagerKey)
        REFERENCES [CH01-01-Dimension].SalesManagers (SalesManagerKey);
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
    ADD CONSTRAINT FK_DimProduct_DimProductSubCategory
        FOREIGN KEY (ProductSubcategoryKey)
        REFERENCES [CH01-01-Dimension].DimProductSubCategory (ProductSubCategoryKey);
    ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory]
    ADD CONSTRAINT FK_DimProductSubCategory_DimProductCategory
        FOREIGN KEY (ProductCategoryKey)
        REFERENCES [CH01-01-Dimension].DimProductCategory (ProductCategoryKey);
    ALTER TABLE [CH01-01-Dimension].DimCustomer
    ADD CONSTRAINT FK_DimCustomer_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimGender
    ADD CONSTRAINT FK_DimGender_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimMaritalStatus
    ADD CONSTRAINT FK_DimMaritalStatus_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimOccupation
    ADD CONSTRAINT FK_DimOccupation_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimOrderDate
    ADD CONSTRAINT FK_DimOrderDate_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimProduct
    ADD CONSTRAINT FK_DimProduct_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimProductCategory
    ADD CONSTRAINT FK_DimProductCategory_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimProductSubCategory
    ADD CONSTRAINT FK_DimProductSubCategory_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].DimTerritory
    ADD CONSTRAINT FK_DimTerritory_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Dimension].SalesManagers
    ADD CONSTRAINT FK_SalesManagers_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE Process.[WorkflowSteps]
    ADD CONSTRAINT FK_WorkFlowSteps_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    EXEC Process.[usp_TrackWorkFlow] 'Add Foreign Keys',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
GO

/*
Stored Procedure: Project2.[DropForeignKeysFromStarSchemaData]

Description:
This procedure is designed to remove foreign key constraints from various tables in the star schema database. It primarily focuses on dropping constraints that link fact and dimension tables as well as the constraints linking dimension tables to the UserAuthorization table. This is typically performed in preparation for data loading operations that require constraint-free bulk data manipulations.

Parameters:
- @UserAuthorizationKey: INT indicating the user authorizing the operation, used for auditing.

Operations:
1. Drops foreign key constraints from the [CH01-01-Fact].[Data] table and various dimension tables, ensuring the removal of referential integrity constraints.
2. Logs the procedure execution using Process.[usp_TrackWorkFlow] for audit trails, tracking the start and end times, and user responsibility.

Usage:
Execute this procedure before performing bulk data load operations or schema alterations that might be hindered by existing foreign key constraints. It ensures that data modifications can be performed without constraint violations.

Example:
EXEC Project2.[DropForeignKeysFromStarSchemaData] @UserAuthorizationKey = 5;

This example runs the procedure to drop foreign keys across the star schema tables, authorized by the user with key 5.

Note: Care should be taken when executing this procedure as dropping foreign keys can temporarily weaken data integrity. Ensure to re-establish the foreign keys after the required operations are completed.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Drop the foreign keys from the start Schema database
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project2].[DropForeignKeysFromStarSchemaData]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimCustomer;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimGender;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimMaritalStatus;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimOccupation;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimOrderDate;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimProduct;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimTerritory;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_SalesManagers;
    ALTER TABLE [CH01-01-Dimension].[DimProduct] DROP CONSTRAINT FK_DimProduct_DimProductSubCategory;
    ALTER TABLE [CH01-01-Dimension].[DimProductSubCategory] DROP CONSTRAINT FK_DimProductSubCategory_DimProductCategory;
    ALTER TABLE [CH01-01-Dimension].DimCustomer DROP CONSTRAINT FK_DimCustomer_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimGender DROP CONSTRAINT FK_DimGender_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimMaritalStatus DROP CONSTRAINT FK_DimMaritalStatus_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimOccupation DROP CONSTRAINT FK_DimOccupation_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimOrderDate DROP CONSTRAINT FK_DimOrderDate_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimProduct DROP CONSTRAINT FK_DimProduct_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimProductCategory DROP CONSTRAINT FK_DimProductCategory_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimProductSubCategory DROP CONSTRAINT FK_DimProductSubCategory_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].DimTerritory DROP CONSTRAINT FK_DimTerritory_UserAuthorization;
    ALTER TABLE [CH01-01-Dimension].SalesManagers DROP CONSTRAINT FK_SalesManagers_UserAuthorization;
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_UserAuthorization;
    ALTER TABLE Process.[WorkflowSteps] DROP CONSTRAINT FK_WorkFlowSteps_UserAuthorization;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    EXEC Process.[usp_TrackWorkFlow] 'Drop Foreign Keys',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
GO


/*
Stored Procedure: Project2.[Load_Data]

Description:
This procedure is responsible for loading data from the staging table [FileUpload].[OriginallyLoadedData]
into the fact table [CH01-01-Fact].[Data]. It matches staging data with existing dimensions and populates the
fact table with transactional and dimensional data. It also maintains metadata about the data load,
such as the responsible user and the timing of data load operations.

Parameters:
@UserAuthorizationKey - An integer key that identifies the user authorizing the data load operation.

Operations:
1. Inserts unique records into the fact table using data from the staging table.
2. Links each record to a user authorization record using the UserAuthorizationKey.
3. Dynamically creates a view to facilitate easy access and querying of the loaded data.
4. Logs the data load operation in the Process.[WorkflowSteps] table using the Process.[usp_TrackWorkFlow] stored procedure.
5. Returns the loaded data for review.

Usage:
The procedure should be executed when there is a need to refresh the data in the fact table as part
of regular ETL operations. It ensures that all data handling is audited and associated with a specific user.

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 11/13/23
-- Description:	Fill in the data table
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_Data]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Fact].[Data]
        (
        SalesKey,
        SalesManagerKey,
        OccupationKey,
        TerritoryKey,
        ProductKey,
        CustomerKey,
        ProductCategory,
        SalesManager,
        ProductSubcategory,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        OrderQuantity,
        UnitPrice,
        ProductStandardCost,
        SalesAmount,
        OrderDate,
        [MonthName],
        MonthNumber,
        [Year],
        CustomerName,
        MaritalStatus,
        Gender,
        Education,
        Occupation,
        TerritoryRegion,
        TerritoryCountry,
        TerritoryGroup,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
        )
    SELECT DISTINCT
        OLD.Saleskey,
        sm.SalesManagerKey,
        do.OccupationKey,
        dt.TerritoryKey,
        dp.ProductKey,
        dc.CustomerKey,
        OLD.ProductCategory,
        OLD.SalesManager,
        OLD.ProductSubcategory,
        OLD.ProductCode,
        OLD.ProductName,
        OLD.Color,
        OLD.ModelName,
        OLD.OrderQuantity,
        OLD.UnitPrice,
        OLD.ProductStandardCost,
        OLD.SalesAmount,
        OLD.OrderDate,
        OLD.[MonthName],
        OLD.MonthNumber,
        OLD.[Year],
        OLD.CustomerName,
        OLD.MaritalStatus,
        OLD.Gender,
        OLD.Education,
        OLD.Occupation,
        OLD.TerritoryRegion,
        OLD.TerritoryCountry,
        OLD.TerritoryGroup,
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM
        [FileUpload].[OriginallyLoadedData] AS OLD LEFT JOIN
        [CH01-01-Dimension].DimProduct AS dp
        on  dp.ProductName = OLD.ProductName AND
            dp.ProductCode = OLD.ProductCode LEFT JOIN
        [CH01-01-Dimension].DimTerritory AS dt
        on  dt.TerritoryCountry = OLD.TerritoryCountry AND
            dt.TerritoryGroup = OLD.TerritoryGroup AND
            dt.TerritoryRegion = OLD.TerritoryRegion INNER JOIN
        [CH01-01-Dimension].DimCustomer AS dc
        on  dc.CustomerName = OLD.CustomerName LEFT JOIN
        [CH01-01-Dimension].SalesManagers AS sm
        on  sm.SalesManager = OLD.SalesManager and
            sm.Category = OLD.ProductSubcategory LEFT JOIN
        [CH01-01-Dimension].DimOccupation AS do
        on do.Occupation = OLD.Occupation

    --- accompanying view ---
    EXEC ('DROP VIEW IF EXISTS G9_1.uvw_FactData');
    EXEC ('CREATE VIEW G9_1.uvw_FactData AS
    SELECT 
		Saleskey,
		SalesManagerKey,
		OccupationKey,
		TerritoryKey,
		ProductKey,
		CustomerKey,
		ProductCategory,
		SalesManager,
		ProductSubcategory,
		ProductCode,
		ProductName,
		Color,
		ModelName,
		OrderQuantity,
		UnitPrice,
		ProductStandardCost,
		SalesAmount,
		OrderDate,
		[MonthName],
		MonthNumber,
		[Year],
		CustomerName,
		MaritalStatus,
		Gender,
		Education,
		Occupation,
		TerritoryRegion,
		TerritoryCountry,
		TerritoryGroup,
		UserAuthorizationKey,
		DateAdded,
		DateOfLastUpdate
    FROM [CH01-01-Fact].[Data]');


    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Fact].[Data]);

    EXEC Process.[usp_TrackWorkFlow] 'Procedure: Project2.[Load_Data] loads data into [CH01-01-Fact].[Data]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;


    SELECT *
    FROM G9_1.uvw_FactData;

END;
GO

/*
Stored Procedure: Project2.[Load_DimProductCategory]

Description:
This procedure is designed for loading data into the [CH01-01-Dimension].[DimProductCategory] dimension table. It inserts data from the FileUpload.OriginallyLoadedData source, focusing on the ProductCategory column. The procedure also handles the tracking of data load operations with timestamps and user authorization keys.

Parameters:
- @UserAuthorizationKey: INT representing the user performing the data loading operation, used for auditing purposes.

Operations:
1. Inserts distinct ProductCategory values from FileUpload.OriginallyLoadedData into DimProductCategory.
2. Sets UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Creates or updates a view named G9_1.uvw_DimProductCategory to reflect the updated state of the DimProductCategory table.
4. Logs the procedure execution using Process.[usp_TrackWorkFlow], capturing details such as the number of rows affected and the start and end times of the operation.

Usage:
Execute this procedure to refresh or populate the DimProductCategory table with new data. It is particularly useful during ETL processes or when updating the dimension table with new category information.

Example:
EXEC Project2.[Load_DimProductCategory] @UserAuthorizationKey = 10;

This example populates the DimProductCategory table with data, authorized by the user with key 10.

Note: This procedure should be used with caution to ensure that the data integrity of the dimension table is maintained. Proper authorization and validation of the input data are essential to prevent data quality issues.

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 11/13/23
-- Description:	Fills in the product category table
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimProductCategory]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProductCategory]
        (
        ProductCategory,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
        )
    SELECT DISTINCT
        FileUpload.OriginallyLoadedData.[ProductCategory],
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData;

    --- accompanying view ---
    EXEC ('DROP VIEW IF EXISTS G9_1.uvw_DimProductCategory');
    EXEC ('CREATE VIEW G9_1.uvw_DimProductCategory AS
	SELECT ProductCategoryKey, ProductCategory, UserAuthorizationKey, DateAdded, DateOfLastUpdate
	FROM [CH01-01-Dimension].[DimProductCategory] ');

    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount =
    (
        SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimProductCategory
    );

    EXEC Process.[usp_TrackWorkFlow] 'Procedure: Project2.[Load_DimProductCategory] loads data into [CH01-01-Dimension].[DimProductCategory]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

    SELECT *
    FROM G9_1.uvw_DimProductCategory;
END;
GO

/*
Stored Procedure: Project2.[Load_DimProductSubcategory]

Description:
This procedure is designed for loading data into the [CH01-01-Dimension].[DimProductSubCategory] dimension table. It inserts data from the FileUpload.OriginallyLoadedData source, focusing on the ProductSubcategory column and linking it to the appropriate ProductCategoryKey. The procedure also manages tracking data load operations with timestamps and user authorization keys.

Parameters:
- @UserAuthorizationKey: INT indicating the user responsible for the data loading operation, used for auditing purposes.

Operations:
1. Inserts distinct ProductSubcategory values from FileUpload.OriginallyLoadedData into DimProductSubCategory, along with the corresponding ProductCategoryKey.
2. Sets UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Creates or updates a view named G9_1.uvw_DimProductSubCategory to reflect the updated state of the DimProductSubCategory table.
4. Logs the procedure execution using Process.[usp_TrackWorkFlow], capturing details like the number of rows affected, start and end times of the operation.

Usage:
Execute this procedure to refresh or populate the DimProductSubCategory table with new data. It is particularly useful during ETL processes or when updating the dimension table with new subcategory information.

Example:
EXEC Project2.[Load_DimProductSubcategory] @UserAuthorizationKey = 15;

This example populates the DimProductSubCategory table with data, authorized by the user with key 15.

Note: Care should be exercised when using this procedure to ensure the integrity of the dimension table. Proper authorization and validation of the input data are crucial to avoid data quality issues.

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 11/13/23
-- Description:	Fill in the product SUBcategory table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimProductSubcategory]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProductSubCategory]
        (
        ProductCategoryKey,
        ProductSubcategory,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
        )
    SELECT DISTINCT
        DPC.ProductCategoryKey,
        OLD.ProductSubcategory,
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData AS OLD
        FULL JOIN [CH01-01-Dimension].[DimProductCategory] AS DPC
        ON OLD.[ProductCategory] = DPC.[ProductCategory];

    --- accompanying view ---
    EXEC ('DROP VIEW IF EXISTS G9_1.uvw_DimProductSubCategory');
    EXEC ('CREATE VIEW G9_1.uvw_DimProductSubCategory AS
    SELECT ProductSubCategoryKey, ProductCategoryKey, ProductSubcategory, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimProductSubCategory] ');

    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount =
    (
        SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimProductSubCategory
    );

    EXEC Process.[usp_TrackWorkFlow] 'Procedure: Project2.[Load_DimProductSubCategory] loads data into [CH01-01-Dimension].[DimProductSubCategory]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

    SELECT *
    FROM G9_1.uvw_DimProductSubCategory;

END;
GO

/*
Stored Procedure: Project2.[Load_DimCustomer]

Description:
This procedure is tasked with loading data into the [CH01-01-Dimension].[DimCustomer] dimension table. It primarily focuses on inserting customer-related data from the FileUpload.OriginallyLoadedData source. Along with the customer names, the procedure also manages auditing fields such as the UserAuthorizationKey and timestamps for when records are added or updated.

Parameters:
- @UserAuthorizationKey: INT representing the user performing the data loading operation, used for auditing purposes.

Operations:
1. Inserts CustomerName from the FileUpload.OriginallyLoadedData into the DimCustomer table.
2. Sets the UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each record.
3. Manages an accompanying view (G9_1.uvw_DimCustomer) to reflect the current state of the DimCustomer table.
4. Uses Process.[usp_TrackWorkFlow] to log the procedure execution, including details on the number of rows affected and the operation's start and end times.

Usage:
Run this procedure to populate or update the DimCustomer table with new customer data. It is essential for ETL processes and updating the dimension table with fresh data.

Example:
EXEC Project2.[Load_DimCustomer] @UserAuthorizationKey = 20;

This command executes the procedure, loading customer data into the DimCustomer table, with the operation being authorized by the user with key 20.

Note: It is important to use this procedure carefully to maintain the integrity of the dimension table. Proper authorization and validation of input data are crucial to avoid compromising data quality.

-- =============================================
-- Author:		Nicholas Kong
-- Create date: 11/13/2023
-- Description:	Populate the customer table
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimCustomer]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimCustomer]
        (
        CustomerName, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT DISTINCT CustomerName, @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData


    --- accompanying view ---
    EXEC('DROP VIEW IF EXISTS G9_1.uvw_DimCustomer')
    EXEC('CREATE VIEW G9_1.uvw_DimCustomer AS
    SELECT CustomerKey, CustomerName, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimCustomer]')

    DECLARE @EndingDateTime DATETIME2;
    set @EndingDateTime = SYSDATETIME()

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimCustomer);

    EXEC Process.[usp_TrackWorkFlow]
        'Procedure: Project2.[Load_DimCustomer] loads data into [CH01-01-Dimension].[DimCustomer]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey

    EXEC('SELECT * FROM G9_1.uvw_DimCustomer')
END
GO

/*
Stored Procedure: Project2.[Load_DimGender]

Description:
This procedure is responsible for loading gender data into the [CH01-01-Dimension].[DimGender] table. It sources the data from FileUpload.OriginallyLoadedData, focusing on distinct gender values and providing a descriptive label for each. The procedure also handles the tracking of data load operations, including user authorization keys and timestamps for record creation and updates.

Parameters:
- @UserAuthorizationKey: INT indicating the user responsible for the data loading operation, used for auditing purposes.

Operations:
1. Inserts Gender and GenderDescription into the DimGender table.
2. Assigns UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each record.
3. Manages an accompanying view (G9_1.uvw_DimGender) to reflect the current state of the DimGender table.
4. Utilizes Process.[usp_TrackWorkFlow] to log the execution of the procedure, capturing details such as the number of rows affected and the operation's start and end times.

Usage:
Execute this procedure to populate or update the DimGender table with gender data. It is crucial during ETL processes or when the dimension table needs to be refreshed with new or updated gender information.

Example:
EXEC Project2.[Load_DimGender] @UserAuthorizationKey = 25;

This example populates the DimGender table with data, authorized by the user with key 25.

Note: It is important to use this procedure with care to ensure the integrity of the dimension table. Proper authorization and validation of the input data are essential to prevent data quality issues.

-- =============================================
-- Author:		Nicholas Kong
-- Create date: 11/13/2023
-- Description:	Populate the gender table
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimGender]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimGender]
        (Gender, GenderDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT DISTINCT Gender, CASE Gender WHEN 'M' THEN 'Male' ELSE 'Female' END AS GenderDescription, @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData


    --- accompanying view ---
    EXEC('DROP VIEW IF EXISTS G9_1.uvw_DimGender')
    EXEC('CREATE VIEW G9_1.uvw_DimGender AS
    SELECT Gender, GenderDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimGender]')

    DECLARE @EndingDateTime DATETIME2;
    set @EndingDateTime = SYSDATETIME()

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimGender);

    EXEC Process.[usp_TrackWorkFlow]
        'Procedure: Project2.[Load_DimGender]loads data into [CH01-01-Dimension].[DimGender]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey

    EXEC('SELECT * FROM G9_1.uvw_DimGender')
END;
GO


/*
Stored Procedure: Project2.[TruncateStarSchemaData]

Description:
This procedure is designed to truncate tables in the star schema of the data warehouse. It removes all records from specified dimension and fact tables and restarts the associated sequences. This action is essential for data refresh scenarios where existing data needs to be cleared before loading new data.

Parameters:
- @UserAuthorizationKey: INT representing the user authorizing the truncation operation, used for auditing purposes.

Operations:
1. Truncates each specified dimension and fact table within the [CH01-01-Dimension] and [CH01-01-Fact] schemas.
2. Resets the sequences associated with these tables to their initial values.
3. Logs the execution of the truncation process using Process.[usp_TrackWorkFlow], capturing details like the operation's start and end times, and user responsibility.

Usage:
Execute this procedure before performing bulk data load operations or when resetting the data warehouse for a fresh data import. It is particularly useful for maintaining a clean state in development or test environments or when reinitializing the data warehouse.

Example:
EXEC Project2.[TruncateStarSchemaData] @UserAuthorizationKey = 30;

This example executes the procedure to truncate the star schema tables, authorized by the user with key 30.

Note: This procedure should be used with extreme caution as it will irreversibly remove all data from the specified tables. Ensure that backups are taken or data is otherwise preserved if needed before executing this procedure.

-- =============================================
-- Author:		Nicholas Kong
-- Create date: 11/13/2023
-- Description:	Truncate the star schema 
-- =============================================
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[TruncateStarSchemaData]
    @UserAuthorizationKey int

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    TRUNCATE TABLE [CH01-01-Dimension].DimCustomer;
    ALTER SEQUENCE PkSequence.DimCustomerSequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Dimension].DimGender;
    TRUNCATE TABLE [CH01-01-Dimension].DimMaritalStatus;
    TRUNCATE TABLE [CH01-01-Dimension].DimOccupation;
    ALTER SEQUENCE PkSequence.OccupationSequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Dimension].DimOrderDate;
    TRUNCATE TABLE [CH01-01-Dimension].DimProduct;
    ALTER SEQUENCE PkSequence.DimProductSequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Dimension].DimProductCategory;
    ALTER SEQUENCE PkSequence.DimProductCategorySequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Dimension].DimProductSubCategory;
    ALTER SEQUENCE PkSequence.DimProductSubCategorySequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Dimension].DimTerritory;
    ALTER SEQUENCE PkSequence.DimTerritorySequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Dimension].SalesManagers;
    ALTER SEQUENCE PkSequence.SalesManagersSequenceObject RESTART WITH 1;
    TRUNCATE TABLE [CH01-01-Fact].[Data];
    ALTER SEQUENCE PkSequence.DataSequenceObject RESTART WITH 1;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    EXEC Process.[usp_TrackWorkFlow] 'Truncate Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END
GO


/*
Stored Procedure: Project2.[Load_DimMaritalStatus]

Description:
This procedure is designed for loading marital status data into the [CH01-01-Dimension].[DimMaritalStatus] dimension table. It pulls distinct marital status values from the FileUpload.OriginallyLoadedData source, providing a descriptive label for each status. The procedure also manages auditing fields, such as the UserAuthorizationKey, and timestamps for when records are added or updated.

Parameters:
- @UserAuthorizationKey: INT indicating the user responsible for the data loading operation, used for auditing purposes.

Operations:
1. Inserts MaritalStatus and MaritalStatusDescription into the DimMaritalStatus table.
2. Assigns UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each record.
3. Manages an accompanying view (G9_1.uvw_DimMaritalStatus) to reflect the current state of the DimMaritalStatus table.
4. Utilizes Process.[usp_TrackWorkFlow] to log the execution of the procedure, capturing details such as the number of rows affected, start and end times of the operation.

Usage:
Execute this procedure to populate or update the DimMaritalStatus table with marital status data. It is crucial during ETL processes or when the dimension table needs a refresh with new or updated marital status information.

Example:
EXEC Project2.[Load_DimMaritalStatus] @UserAuthorizationKey = 20;

This command populates the DimMaritalStatus table with data, authorized by the user with key 20.

Note: Care should be exercised when using this procedure to ensure the integrity of the dimension table. Proper authorization and validation of the input data are essential to prevent data quality issues.

-- =============================================
-- Author:		Edwin Wray
-- Create date: 11/13/2023
-- Description:	Populate the marital status table 
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimMaritalStatus]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimMaritalStatus]
        (
        MaritalStatus,
        MaritalStatusDescription,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
        )
    SELECT DISTINCT
        MaritalStatus,
        CASE
               WHEN OLD.MaritalStatus = 'M' THEN
                   'Married'
               ELSE
                   'Single'
           END AS MaritalStatusDescription,
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData AS OLD;


    EXEC ('DROP VIEW IF EXISTS G9_1.uvw_DimMaritalStatus');
    EXEC ('CREATE VIEW G9_1.uvw_DimMaritalStatus AS
    SELECT MaritalStatus, MaritalStatusDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimMaritalStatus]');

    --- accompanying view ---
    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimMaritalStatus);

    EXEC Process.[usp_TrackWorkFlow] 'Procedure: Project2.[Load_MaritalStatus] loads data into [CH01-01-Dimension].[DimMaritalStatus]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
    SELECT *
    FROM G9_1.uvw_DimMaritalStatus;
END;
GO
/*
Stored Procedure: Project2.[Load_DimOccupation]

Description:
This procedure is responsible for loading occupation data into the [CH01-01-Dimension].[DimOccupation] table. It takes distinct occupation data from the FileUpload.OriginallyLoadedData source, ensuring each record is unique. The procedure also manages the audit trail by including user authorization keys and timestamps for the addition and last update of each record.

Parameters:
- @UserAuthorizationKey: INT specifying the user performing the data loading operation, crucial for audit purposes.

Operations:
1. Inserts unique Occupation values into the DimOccupation table.
2. Sets UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Manages an accompanying view (G9_1.uvw_DimOccupation) to reflect the updated state of the DimOccupation table.
4. Logs the procedure execution using Process.[usp_TrackWorkFlow], capturing details such as the number of rows affected, the start and end times of the operation.

Usage:
Run this procedure to populate or refresh the DimOccupation table with new occupation data. Essential for ETL processes or when updating the dimension table with new occupation information.

Example:
EXEC Project2.[Load_DimOccupation] @UserAuthorizationKey = 35;

This example executes the procedure to load data into the DimOccupation table, authorized by the user with key 35.

Note: Care must be taken to ensure the integrity of the dimension table. Proper authorization and validation of input data are vital to maintain data quality.

-- =============================================
-- Author:		Edwin Wray
-- Create date: 11/13/2023
-- Description:	Populate the occupation table 
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimOccupation]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimOccupation]
        (Occupation,UserAuthorizationKey,DateAdded,DateOfLastUpdate)
    SELECT DISTINCT FileUpload.OriginallyLoadedData.[Occupation], @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData


    --- accompanying view ---
    EXEC('DROP VIEW IF EXISTS G9_1.uvw_DimOccupation')
    EXEC('CREATE VIEW G9_1.uvw_DimOccupation AS
	SELECT OccupationKey,Occupation,UserAuthorizationKey,DateAdded,DateOfLastUpdate
	FROM [CH01-01-Dimension].[DimOccupation]')


    DECLARE @EndingDateTime DATETIME2;
    set @EndingDateTime = SYSDATETIME()

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimOccupation);

    EXEC Process.[usp_TrackWorkFlow]
        'Procedure: Project2.[Load_DimOccupation] loads data into [CH01-01-Dimension].[DimOccupation]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey

    SELECT *
    FROM G9_1.uvw_DimOccupation
END
GO

/*
Stored Procedure: Project2.[Load_DimTerritory]

Description:
This procedure is designed to load territorial data into the [CH01-01-Dimension].[DimTerritory] table. It extracts distinct territorial information from the FileUpload.OriginallyLoadedData source and inserts it into the table. The procedure is also responsible for managing the audit trail, including user authorization keys and timestamps for each record's creation and last update.

Parameters:
- @UserAuthorizationKey: INT indicating the user responsible for the data loading operation, crucial for maintaining an audit trail.

Operations:
1. Inserts unique territorial data (TerritoryRegion, TerritoryCountry, TerritoryGroup) into the DimTerritory table.
2. Assigns the UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Manages a corresponding view (G9_1.uvw_DimTerritory) to provide a current representation of the DimTerritory table.
4. Logs the execution of the procedure using Process.[usp_TrackWorkFlow], capturing details such as the number of rows affected, start and end times of the operation.

Usage:
Execute this procedure to populate or update the DimTerritory table with territorial data. It is vital for ETL processes or when updating the dimension table with fresh territorial information.

Example:
EXEC Project2.[Load_DimTerritory] @UserAuthorizationKey = 40;

This example populates the DimTerritory table with data, authorized by the user with key 40.

Note: It is important to use this procedure carefully to ensure the integrity of the dimension table. Proper authorization and validation of input data are essential to prevent data quality issues.

-- =============================================
-- Author:		Edwin Wray
-- Create date: 11/13/2023
-- Description:	Populate the Territory table 
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimTerritory]
    @UserAuthorizationKey int

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].DimTerritory
        ([TerritoryRegion],
        [TerritoryCountry],
        [TerritoryGroup],
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate)

    SELECT DISTINCT OLD.[TerritoryRegion],
        OLD.[TerritoryCountry],
        OLD.[TerritoryGroup],
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData AS OLD

    DECLARE @EndingDateTime DATETIME2;
    set @EndingDateTime = SYSDATETIME()

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimTerritory);

    EXEC('DROP VIEW IF EXISTS G9_1.uvw_DimTerritory')
    EXEC('CREATE VIEW G9_1.uvw_DimTerritory AS
    SELECT TerritoryKey, TerritoryGroup, TerritoryCountry, TerritoryRegion, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimTerritory] ')

    EXEC Process.[usp_TrackWorkFlow]
        'Procedure: Project2.[Load_DimTerritory] loads data into [CH01-01-Dimension].[DimTerritory]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey

    SELECT *
    FROM G9_1.uvw_DimTerritory
END
GO

/*
Stored Procedure: Project2.[Load_DimOrderDate]

Description:
This procedure is tasked with loading order date data into the [CH01-01-Dimension].[DimOrderDate] table. It focuses on inserting distinct order date details, including the date, month name, month number, and year, from the FileUpload.OriginallyLoadedData source. The procedure also manages the audit trail by incorporating user authorization keys and timestamps for the addition and last update of each record.

Parameters:
- @UserAuthorizationKey: INT specifying the user responsible for the data loading operation, crucial for maintaining an audit trail.

Operations:
1. Inserts unique order date details into the DimOrderDate table.
2. Sets UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Manages an accompanying view (G9_1.uvw_DimOrderDate) to represent the current state of the DimOrderDate table.
4. Utilizes Process.[usp_TrackWorkFlow] to log the procedure's execution, capturing details such as the number of rows affected, start and end times of the operation.

Usage:
Run this procedure to populate or update the DimOrderDate table with order date data. Essential for ETL processes or when updating the dimension table with new date information.

Example:
EXEC Project2.[Load_DimOrderDate] @UserAuthorizationKey = 45;

This command executes the procedure to load data into the DimOrderDate table, authorized by the user with key 45.

Note: Care should be taken to ensure the integrity of the dimension table. Proper authorization and validation of input data are vital to avoid compromising data quality.

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 11/13/2023
-- Description:	Load the order date information into the table 
-- =============================================
*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimOrderDate]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimOrderDate]
        ([OrderDate],
        [MonthName],
        MonthNumber,
        [Year],
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate)

    SELECT DISTINCT A.[OrderDate],
        A.[MonthName],
        A.MonthNumber,
        A.[Year],
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData as A

    --- accompanying view ---
    EXEC('DROP VIEW IF EXISTS G9_1.uvw_DimOrderDate')
    EXEC('CREATE VIEW G9_1.uvw_DimOrderDate AS
	SELECT OrderDate, MonthName, MonthNumber, UserAuthorizationKey, DateAdded, DateOfLastUpdate
	FROM [CH01-01-Dimension].[DimOrderDate]')

    DECLARE @EndingDateTime DATETIME2;
    set @EndingDateTime = SYSDATETIME()

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].DimOrderDate);

    EXEC Process.[usp_TrackWorkFlow]
        'Procedure: Project2.[Load_DimOrderDate] loads data into [CH01-01-Dimension].[DimOrderDate]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey

    SELECT *
    FROM G9_1.uvw_DimOrderDate
END
GO

/*
Stored Procedure: Project2.[Load_SalesManagers]

Description:
The Project2.[Load_SalesManagers] procedure is designed to load sales manager data into the [CH01-01-Dimension].[SalesManagers] table. It extracts data from the FileUpload.OriginallyLoadedData source, focusing on unique SalesManager names and their associated categories. The procedure also handles the auditing aspect by including user authorization keys and timestamps for each record's creation and last update.

Parameters:
- @UserAuthorizationKey: INT specifying the user responsible for the data loading operation, crucial for maintaining an audit trail.

Operations:
1. Inserts distinct SalesManager and Category data into the SalesManagers table.
2. Assigns the UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Manages an accompanying view (G9_1.uvw_SalesManagers) to represent the updated state of the SalesManagers table.
4. Utilizes Process.[usp_TrackWorkFlow] to log the execution of the procedure, capturing details such as the number of rows affected, start and end times of the operation.

Usage:
Run this procedure to populate or update the SalesManagers table with new sales manager data. It is vital during ETL processes or when refreshing the dimension table with updated sales manager information.

Example:
EXEC Project2.[Load_SalesManagers] @UserAuthorizationKey = 50;

This command executes the procedure to load sales manager data into the SalesManagers table, authorized by the user with key 50.

Note: It is important to use this procedure carefully to ensure the integrity of the dimension table. Proper authorization and validation of input data are essential to avoid data quality issues.

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 11/13/2023
-- Description:	Load the Sales Manager information into the table 
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_SalesManagers]
    @UserAuthorizationKey int

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[SalesManagers]
        (SalesManager,
        Category,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate)

    SELECT DISTINCT OLD.[SalesManager],
        OLD.[ProductSubcategory],
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData AS OLD

    --- accompanying view ---
    EXEC('DROP VIEW IF EXISTS G9_1.uvw_SalesManagers')
    EXEC('CREATE VIEW G9_1.uvw_SalesManagers AS
    SELECT SalesManagerKey, SalesManager, Category, Office, UserAuthorizationKey, DateAdded, DateOfLastUpdate
    FROM [CH01-01-Dimension].[SalesManagers] ')

    DECLARE @EndingDateTime DATETIME2;
    set @EndingDateTime = SYSDATETIME()

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].SalesManagers);

    EXEC Process.[usp_TrackWorkFlow]
        'Procedure: Project2.[Load_SalesManagers] loads data into [CH01-01-Dimension].[SalesManagers]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey

    SELECT *
    FROM G9_1.uvw_SalesManagers
END;
GO

/*
Stored Procedure: Utils.[DropProcsInCSCI331FinalProject]

Description:
This procedure is specifically designed to drop a series of stored procedures associated with the CSCI331 Final Project. It ensures the removal of specific procedures from the database, typically as part of a cleanup, restructuring, or decommissioning process. The procedure also handles the tracking of this operation by including a user authorization key and timestamps.

Parameters:
- @UserAuthorizationKey: INT indicating the user authorizing this operation, used for audit purposes.

Operations:
1. Drops a predefined list of stored procedures related to the Project2 and Process schemas.
2. Utilizes Process.[usp_TrackWorkFlow] to log the execution of the procedure, including details like the operation's start and end times and the user's authorization key.

Usage:
Execute this procedure to remove specific stored procedures from the database as part of maintenance or when restructuring the database setup. It's particularly useful for ensuring a clean and controlled environment, either for development or post-project cleanup.

Example:
EXEC Utils.[DropProcsInCSCI331FinalProject] @UserAuthorizationKey = 55;

This command executes the procedure to drop the specified stored procedures, authorized by the user with key 55.

Note: Care must be taken when executing this procedure as it will irreversibly remove the specified stored procedures from the database. Ensure that this operation is part of a planned maintenance or cleanup process and that all necessary backups or documentation are in place.

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 11/13/2023
-- Description: Run the DropProcsInCSCI331FinalProject procedure
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Utils.[DropProcsInCSCI331FinalProject]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    DROP PROC IF EXISTS Project2.Load_SalesManagers;
    DROP PROC IF EXISTS Project2.Load_DimProductSubcategory;
    DROP PROC IF EXISTS Project2.Load_DimProductCategory;
    DROP PROC IF EXISTS Project2.Load_DimGender;
    DROP PROC IF EXISTS Project2.Load_DimMaritalStatus;
    DROP PROC IF EXISTS Project2.Load_DimOccupation;
    DROP PROC IF EXISTS Project2.Load_DimOrderDate;
    DROP PROC IF EXISTS Project2.Load_DimTerritory;
    DROP PROC IF EXISTS Project2.Load_DimProduct;
    DROP PROC IF EXISTS Project2.Load_DimCustomer;
    DROP PROC IF EXISTS Project2.Load_Data;
    DROP PROC IF EXISTS Project2.TruncateStarSchemaData;
    DROP PROC IF EXISTS Project2.LoadStarSchemaData;
    DROP PROC IF EXISTS Project2.AddForeignKeysToStarSchemaData;
    DROP PROC IF EXISTS Project2.DropForeignKeysFromStarSchemaData;
    DROP PROC IF EXISTS Project2.ShowTableStatusRowCount;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    EXEC Process.[usp_TrackWorkFlow] 'Drop Procedures',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

    DROP PROC IF EXISTS Process.usp_TrackWorkFlow;
END;
GO

/*
Stored Procedure: Project2.[Load_DimProduct]

Description:
This procedure is designed to load product data into the [CH01-01-Dimension].[DimProduct] table. It extracts and inserts distinct product information from the FileUpload.OriginallyLoadedData source, including product categories, subcategories, codes, names, colors, and model names. Additionally, the procedure manages the audit trail by incorporating user authorization keys and timestamps for each record's creation and last update.

Parameters:
- @UserAuthorizationKey: INT specifying the user responsible for the data loading operation, crucial for maintaining an audit trail.

Operations:
1. Inserts unique product data into the DimProduct table.
2. Sets UserAuthorizationKey, DateAdded, and DateOfLastUpdate for each new record.
3. Manages an accompanying view (G9_1.uvw_DimProduct) to represent the updated state of the DimProduct table.
4. Utilizes Process.[usp_TrackWorkFlow] to log the execution of the procedure, capturing details such as the number of rows affected, start and end times of the operation.

Usage:
Execute this procedure to populate or update the DimProduct table with new product data. It is essential for ETL processes or when updating the dimension table with new product information.

Example:
EXEC Project2.[Load_DimProduct] @UserAuthorizationKey = 60;

This command executes the procedure to load data into the DimProduct table, authorized by the user with key 60.

Note: Care should be taken to ensure the integrity of the dimension table. Proper authorization and validation of input data are vital to avoid data quality issues.

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 11/13/23
-- Description:	Populate the product table
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[Load_DimProduct]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProduct]
        (
        ProductSubcategoryKey,
        ProductCategory,
        ProductSubcategory,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
        )
    SELECT DISTINCT
        DPSC.ProductSubcategoryKey,
        OLD.ProductCategory,
        DPSC.ProductSubcategory,
        OLD.ProductCode,
        OLD.ProductName,
        OLD.Color,
        OLD.ModelName,
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM FileUpload.OriginallyLoadedData AS OLD
        FULL JOIN [CH01-01-Dimension].[DimProductSubCategory] AS DPSC
        ON OLD.[ProductSubcategory] = DPSC.[ProductSubcategory];

    --- accompanying view ---
    EXEC ('DROP VIEW IF EXISTS G9_1.uvw_DimProduct');
    EXEC ('CREATE VIEW G9_1.uvw_DimProduct AS
    SELECT 
		ProductKey,
		ProductSubcategoryKey,
		ProductCategory,
		ProductSubcategory,
		ProductCode,
		ProductName,
		Color,
		ModelName,
		UserAuthorizationKey,
		DateAdded,
		DateOfLastUpdate
    FROM [CH01-01-Dimension].[DimProduct]');

    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*)
    FROM [CH01-01-Dimension].[DimProduct]);

    EXEC Process.[usp_TrackWorkFlow] 'Procedure: Project2.[Load_DimProduct] loads data into [CH01-01-Dimension].[DimProduct]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

    SELECT *
    FROM G9_1.uvw_DimProduct;

END;
GO

/*
Stored Procedure: Project2.[ShowTableStatusRowCount]

Description:
This procedure is designed to report the row count of various tables in the database, providing a snapshot of the current data volume across different tables. It includes tables from the [CH01-01-Dimension], [CH01-01-Fact], [DbSecurity], and [Process] schemas. The procedure also logs this operation, including user authorization keys and timestamps, to maintain an audit trail.

Parameters:
- @TableStatus: VARCHAR(64) representing the label or status description for the row count report.
- @UserAuthorizationKey: INT indicating the user responsible for the operation, used for auditing purposes.

Operations:
1. Queries each specified table to calculate its row count.
2. Outputs the table name and its corresponding row count, along with the provided @TableStatus label.
3. Logs the execution using Process.[usp_TrackWorkFlow], capturing details such as the operation's start and end times and the user's authorization key.

Usage:
Run this procedure to obtain a row count report of various tables, which can be useful for data auditing, capacity planning, or simply understanding the current data volume in different parts of the database.

Example:
EXEC Project2.[ShowTableStatusRowCount] @TableStatus = 'Post-Load Analysis', @UserAuthorizationKey = 65;

This example retrieves the row counts for various tables under the label 'Post-Load Analysis', authorized by the user with key 65.

Note: This procedure is a utility tool for data monitoring and should be used accordingly. Ensure the correct interpretation of the row count data, especially in the context of data load operations or data audits.

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 11/13/23
-- Description:	Populate a table to show the status of the row counts
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE Project2.[ShowTableStatusRowCount]
    @TableStatus VARCHAR(64),
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();

    DECLARE @EndingDateTime DATETIME2;


    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;

            SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimCustomer',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimCustomer]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimGender',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimGender]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimMaritalStatus',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimMaritalStatus]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimOccupation',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimOccupation]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimOrderDate',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimOrderDate]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimProduct',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimProduct]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimProductCategory',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimProductCategory]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimProductSubcategory',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimProductSubcategory]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].DimTerritory',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[DimTerritory]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Dimension].SalesManagers',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Dimension].[SalesManagers]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[CH01-01-Fact].[Data]',
            [Row Count] = COUNT(*)
        FROM [CH01-01-Fact].[Data]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[DbSecurity].[UserAuthorization]',
            [Row Count] = COUNT(*)
        FROM [DbSecurity].[UserAuthorization]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = 'Process.WorkflowSteps',
            [Row Count] = COUNT(*)
        FROM Process.[WorkflowSteps];

    SET @EndingDateTime = SYSDATETIME();

    EXEC Process.[usp_TrackWorkFlow] 'Procedure: Project2.[ShowStatusRowCount] loads data into ShowTableStatusRowCount',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
GO



-- LoadStarSchemaData Procedure 

/*
ABOUT THIS PROCEDURE BY CHATGPT

This T-SQL script is for creating a stored procedure named LoadStarSchemaData within a SQL Server database, likely for the 
purpose of managing and updating a star schema data warehouse structure. Here's a breakdown of what this script does:

 1. Setting Options:
    
    * SET ANSI_NULLS ON: Ensures that the session treats NULL values according to the ANSI SQL standard.
    * SET QUOTED_IDENTIFIER ON: Allows the use of double quotes to delimit identifiers.

 2. Creating the Stored Procedure:
    
    * CREATE PROCEDURE [Project2].[LoadStarSchemaData]: This line starts the creation of a stored procedure named LoadStarSchemaData 
    under the schema Project2. It takes an @UserAuthorizationKey as an integer parameter.

 3. Procedure Body:
    
    * SET NOCOUNT ON;: This line stops the message that shows the number of rows affected by a T-SQL statement from being returned.
    * DECLARE @StartingDateTime DATETIME2: Declares a variable to store the starting time of the procedure execution.
    * Dropping Foreign Keys: The procedure calls [Project2].[DropForeignKeysFromStarSchemaData] to drop foreign keys before truncating tables. 
    This is necessary because you cannot truncate a table that has foreign keys referencing it.
    * Checking Table Status: Executes [Project2].[ShowTableStatusRowCount] to report the row count of tables before truncation.
    * Truncating Data: Executes [Project2].[TruncateStarSchemaData] to truncate the data in the star schema.
    * Loading Data: The procedure then loads data into various dimension tables (like product categories, subcategories, product, etc.) 
    and fact tables using multiple EXEC statements. Each EXEC statement calls a specific procedure to load data into a particular table.
    * Recreating Foreign Keys: After loading the data, it recreates the foreign keys using [Project2].[AddForeignKeysToStarSchemaData].
    * Final Steps: It checks the row count again after loading the data, sets an @EndingDateTime variable, and then calls [Process].[usp_TrackWorkFlow] 
    to track the workflow, passing in various parameters including the start and end times.

 4. End of Procedure: The script ends with END; to signify the end of the stored procedure and GO to signal the end of a batch of 
 Transact-SQL statements to the SQL Server.

In summary, this stored procedure is designed to manage the updating of a star schema database by first dropping foreign keys, 
truncating existing data, loading new data into the dimensional and fact tables, recreating the foreign keys, and logging the 
workflow process. The use of @UserAuthorizationKey in various places suggests that the procedure includes some form of authorization 
or tracking mechanism based on the user executing the procedure.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/14/23
-- Description:	Procedure runs other stored procedures to populate the data
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project2].[LoadStarSchemaData]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    --	Drop All of the foreign keys prior to truncating tables in the star schema
    EXEC  [Project2].[DropForeignKeysFromStarSchemaData] @UserAuthorizationKey = 1;
    --
    --	Check row count before truncation
    EXEC [Project2].[ShowTableStatusRowCount] @UserAuthorizationKey = 6,  -- Change -1 to the appropriate UserAuthorizationKey
		@TableStatus = N'''Pre-truncate of tables'''
    
    --	Always truncate the Star Schema Data
    EXEC  [Project2].[TruncateStarSchemaData] @UserAuthorizationKey = 3;

    --	Load the star schema
    /*
                                            Note: User Authorization keys are hardcoded, each representing a different group user 
                                                Aleksandra Georgievska → User Key 1
                                                Sigalita Yakubova → User Key 2
                                                Nicholas Kong → User Key 3
                                                Edwin Wray → User Key 4
                                                Ahnaf Ahmed → User Key 5
                                                Aryeh Richman → User Key 6
                                            */
    EXEC  [Project2].[Load_DimProductCategory] @UserAuthorizationKey = 2;       -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimProductSubcategory] @UserAuthorizationKey = 2;    -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimProduct] @UserAuthorizationKey = 6;               -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_SalesManagers] @UserAuthorizationKey = 5;            -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimGender] @UserAuthorizationKey = 3;                -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimMaritalStatus] @UserAuthorizationKey = 4;         -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimOccupation] @UserAuthorizationKey = 4;            -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimOrderDate] @UserAuthorizationKey = 5;             -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimTerritory] @UserAuthorizationKey = 4;             -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_DimCustomer] @UserAuthorizationKey = 3;              -- Change -1 to the appropriate UserAuthorizationKey
    EXEC  [Project2].[Load_Data] @UserAuthorizationKey = 2;                     -- Change -1 to the appropriate UserAuthorizationKey
    
    --	Recreate all of the foreign keys prior after loading the star schema
    --	Check row count before truncation
    EXEC	[Project2].[ShowTableStatusRowCount] @UserAuthorizationKey = 6,  -- Change -1 to the appropriate UserAuthorizationKey
		@TableStatus = N'''Row Count after loading the star schema'''
    --
    EXEC [Project2].[AddForeignKeysToStarSchemaData] @UserAuthorizationKey = 1; -- Change -1 to the appropriate UserAuthorizationKey
--
END;
GO