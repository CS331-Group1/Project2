
import javax.swing.JFrame;

public class QueryStorage{

	private String connectionURL;
	
	
	/*
	 * Here are all the TSQLV 4 code
	 */
//	private String selectSql1 = "DROP TABLE IF EXISTS dbo.Orders\r\n"
//			+ "\r\n"
//			+ "CREATE TABLE dbo.Orders\r\n"
//			+ "(\r\n"
//			+ "orderid INT NOT NULL\r\n"
//			+ "CONSTRAINT PK_Orders PRIMARY KEY,\r\n"
//			+ "orderdate DATE NOT NULL\r\n"
//			+ "CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),\r\n"
//			+ "empid INT NOT NULL,\r\n"
//			+ "custid VARCHAR(10) NOT NULL\r\n"
//			+ "\r\n"
//			+ ");\r\n"
//			+ "\r\n"
//			+ "Select O.orderid, O.empid, O.custid\r\n"
//			+ "From dbo.Orders as O;";
//
//	private String selectSql2 = "Insert INTO dbo.Orders(orderid, empid, custid)\r\n"
//			+ "VALUES (10003, 3, 'A'),\r\n"
//			+ "(1004,4,'C'),\r\n"
//			+ "(1005,5,'D'),\r\n"
//			+ "(1006,6,'E')\r\n"
//			+ "\r\n"
//			+ "\r\n"
//			+ "Select O.orderid, O.empid, O.custid\r\n"
//			+ "From dbo.Orders as O;\r\n"
//			+ "";
	
	/*
	 * BIClass database
	 */
	
	// creates table called [CH01-01-Dimension].[DimProductCategory]
	private String selectSql3 = "DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductCategory] \r\n"
			+ "\r\n"
			+ "CREATE TABLE [CH01-01-Dimension].[DimProductCategory] (\r\n"
			+ "    ProductCategoryId INT PRIMARY KEY,\r\n"
			+ "    ProductCategoryName NVARCHAR(255) NOT NULL\r\n"
			+ ");\r\n"
			+ "\r\n"
			+ "SELECT DPC.ProductCategoryId, DPC.ProductCategoryName\r\n"
			+ "FROM [CH01-01-Dimension].[DimProductCategory] as DPC";
	
	// creates table called [CH01-01-Dimension].[DimProductSubcategory]
	private String selectSql4 = "DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductSubcategory] \r\n"
			+ "\r\n"
			+ "CREATE TABLE [CH01-01-Dimension].[DimProductSubcategory] (\r\n"
			+ "    ProductSubcategoryId INT PRIMARY KEY,\r\n"
			+ "    ProductSubcategoryName NVARCHAR(255) NOT NULL,\r\n"
			+ ");\r\n"
			+ "\r\n"
			+ "\r\n"
			+ "Select DPS.ProductSubcategoryId, DPS.ProductSubcategoryName\r\n"
			+ "From [CH01-01-Dimension].[DimProductSubcategory] as DPS";
	
	// insert rows to the table called [CH01-01-Dimension].[DimProductCategory]
	private String selectSql5 = "INSERT INTO [CH01-01-Dimension].[DimProductCategory] (ProductCategoryId, ProductCategoryName)\r\n"
			+ "VALUES\r\n"
			+ "    (1, 'Electronics'),\r\n"
			+ "    (2, 'Clothing'),\r\n"
			+ "    (3, 'Home and Garden')\r\n"
			+ "    \r\n"
			+ "SELECT DPC.ProductCategoryId, DPC.ProductCategoryName\r\n"
			+ "From  [CH01-01-Dimension].[DimProductCategory] as DPC";
	
	
	
	public QueryStorage(String connectionURL)
	{
		this.connectionURL = connectionURL;
	}
	
	public void processQuery(String selectSql, JFrame frame)
	{
		QueryProcessor test = new QueryProcessor(this, selectSql, frame);
		
	}
	
	
	public String getFourthQuery() {
		// TODO Auto-generated method stub
		return selectSql4;
	}
	
	public String getThirdQuery() {
		// TODO Auto-generated method stub
		return selectSql3;
	}
	
	
//	public String getFirstQuery()
//	{
//		return selectSql1;
//	}
//
//	public String getSecondQuery() {
//		// TODO Auto-generated method stub
//		return selectSql2;
//	}
	
	public String getConnection()
	{
		return connectionURL;
	}

	public String getFifthQuery() {
		// TODO Auto-generated method stub
		return selectSql5;
	}

	

}
