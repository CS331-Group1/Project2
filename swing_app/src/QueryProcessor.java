import java.awt.BorderLayout;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

public class QueryProcessor {
	
	
	private static long executionTime;
	
	// DPC stands for Dim Product Category - the name of the SQL table #1 
	
	private static DefaultTableModel DPCmodel = new DefaultTableModel();
	private static JPanel DPCjPanel = new JPanel();
	private static JTable DPCjtable = new JTable(DPCmodel);
	private static JScrollPane DPCscrollPane = new JScrollPane(DPCjtable);

	// DPS stands for Dim Product SubCategory - the name of the SQL table #2
	 
	private static DefaultTableModel DPSmodel = new DefaultTableModel();
	private static JPanel DPSjPanel = new JPanel();
	private static JTable DPSjtable = new JTable(DPSmodel);
	private static JScrollPane DPSscrollPane = new JScrollPane(DPSjtable);
	
	public QueryProcessor(QueryStorage queryStorage, String selectSql, JFrame frame)
	{
		
		/*
		 * Run the SQL Query 
		 */
		try (Connection connection = DriverManager.getConnection(queryStorage.getConnection());

				Statement statement = connection.createStatement();) 
				{
			
				ResultSet resultSet = statement.executeQuery(selectSql);
				// Start measuring time of execution here
                long startTime = System.currentTimeMillis();
				
					// adding columns for first query
//                	if(selectSql.equals(queryStorage.getFirstQuery()))
//					{
//					    Object[] columns = {"custid", "empid", "orderid"};
//					    
//					    for(int i = 0; i < columns.length;i++)
//					    {
//					    	DPCmodel.addColumn(columns[i]);
//					    	
//					    }
//					    
//					   
//						DPCjPanel.add(DPCscrollPane);
//						frame.add(DPCjPanel, BorderLayout.WEST);
//					}
                	// adding rows for the second query
//					if(selectSql.equals(queryStorage.getSecondQuery()))
//					{
//					
//						String custid = "";
//						int empid = 0;
//						int orderid = 0;
//						
//						while(resultSet.next())
//						{
//							custid = resultSet.getString("custid");
//							empid = resultSet.getInt("empid");
//							orderid = resultSet.getInt("orderid");
//							
//							
//							Object[] rowData = {custid, empid, orderid};
//							DPCmodel.addRow(rowData);
//						}
//						
//					}
					if(selectSql.equals(queryStorage.getThirdQuery()))
					{
					    String[] columns = {"ProductCategoryId", "ProductCategoryName"};
					    
					    for(int i = 0; i < columns.length;i++)
					    {
					    	DPCmodel.addColumn(columns[i]);
					    	
					    }
					    
					    // how to add the table #1 to the left
					    DPCjPanel.add(DPCscrollPane);
						frame.add(DPCjPanel, BorderLayout.WEST);
					    
					}
					else if(selectSql.equals(queryStorage.getFourthQuery()))
					{
					    String[] columns = {"ProductSubcategoryId", "ProductSubcategoryName"};
					    
					    for(int i = 0; i < columns.length;i++)
					    {
					    	DPSmodel.addColumn(columns[i]);
					    	
					    }
					    
					    // how to add the table #2 to the right

					    DPSjPanel.add(DPSscrollPane);
						frame.add(DPSjPanel, BorderLayout.EAST);
					    
					}
					else if(selectSql.equals(queryStorage.getFifthQuery()))
					{
						int productCategoryId = 0;
						String productCategoryName = "";
						
						
						while(resultSet.next())
						{
							productCategoryId = resultSet.getInt("ProductCategoryId");
							productCategoryName = resultSet.getString("ProductCategoryName");
							
							// DPCmodel is the table on the left of the Swing app
							// every iteration of the while loop, we are adding a new data per row to the table
							
							Object[] rowData = {productCategoryId, productCategoryName};
							DPCmodel.addRow(rowData);
						}
					}
						
                	 // End measuring time of execution here
	                 long endTime = System.currentTimeMillis();
	                 
	                 //Calculate execution time which is from when the query started and ended.
	                 executionTime = endTime - startTime;
	                 
		}
		catch (SQLException e)
		{
					e.printStackTrace();
		}
		
		
		
	}
	
	public static long getExecutionTime()
	{
		return executionTime;
	}
	
	

}
