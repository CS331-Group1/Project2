import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class SimpleSwingApp {
	
	 // Create a database dropdown menu
    String[] databaseOption = {"","BIClass"};
    JComboBox<String> databaseDropdown = new JComboBox<>(databaseOption);
    
    String[] dataRetrievalBIClass = {"Create a Table called [CH01-01-Dimension].[DimProductCategory] (Step 1)",
    		"Create a Table called [CH01-01-Dimension].[DimProductSubcategory] (Step 2)",
    		"Insert Values to  [CH01-01-Dimension].[DimProductCategory] (Step 3)"};
    JComboBox<String> retrievalDropDownBIClass  = new JComboBox<>(dataRetrievalBIClass);
    
    //String[] dataRetrievalTSQLV4 = {"Create a Table (Step 1)","Insert data into table (Step 2)"};
    //JComboBox<String> retrievalDropDownTSQLV4  = new JComboBox<>(dataRetrievalTSQLV4);
    
    // for containing the drop downs and the run query button
    JPanel panel = new JPanel();
    
    JPanel panel2 = new JPanel();
    
    // for displaying query solution
    //JTextPane textPane = new JTextPane();

    public SimpleSwingApp()
    {
    	
        // Create a new window 
        JFrame frame = new JFrame("9:15_JDBC_Group 1");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(1200, 900); // Set the JFrame size

        // Create a button to update the text
        JButton runQueryButton = new JButton("Run Query");
        // Create an ActionListener and implement the actionPerformed method
    
        panel.add(runQueryButton);

        // Add an action listener to the JButton
    
        panel.add(databaseDropdown);
        panel.add(retrievalDropDownBIClass);
        //panel.add(retrievalDropDownTSQLV4);
        
        // Run Query code logic
        ActionListener buttonActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // Define the action to be performed when the button is clicked
            	
            	// when a user selects the database "TSQLV4" 
//            	if(databaseDropdown.getSelectedItem().equals("TSQLV4"))
//            	{
//            		String connectionUrl =
//            	    			"jdbc:sqlserver://localhost:13001;databaseName=TSQLV4;"
//            	    			+ "user=sa;password=PH@123456789;encrypt=true;"
//            	    			+ "trustServerCertificate=true";
//
//            	    	QueryStorage queryStorage = new QueryStorage(connectionUrl);
//            	    	
//            	    // I kept this in so you can learn from it .
//            	    // this is example of how the selections from the TSQLV4 database dropdown
//            	    	
//            		if(retrievalDropDownTSQLV4.getSelectedItem().equals("Create a Table (Step 1)"))
//            		{
//            			queryStorage.processQuery(queryStorage.getFirstQuery(), frame);
//            		}
//            		else if(retrievalDropDownTSQLV4.getSelectedItem().equals("Insert data into table (Step 2)"))
//            		{
//            			queryStorage.processQuery(queryStorage.getSecondQuery(), frame);
//            		}
//            	}
            	// Project uses the BIClass database drop down menu.
            	// where you will implement the logic for that.
            	
            	if(databaseDropdown.getSelectedItem().equals("BIClass"))
            	{
            		String connectionUrl =
        	    			"jdbc:sqlserver://localhost:13001;databaseName=BIClass;"
        	    			+ "user=sa;password=PH@123456789;encrypt=true;"
        	    			+ "trustServerCertificate=true";

        	    	QueryStorage queryStorage = new QueryStorage(connectionUrl);
        	    	
        	    	 // where you will implementing the logic for each selection of the BIClass dropdown 	
        	    	if(retrievalDropDownBIClass.getSelectedItem().equals("Create a Table called [CH01-01-Dimension].[DimProductCategory] (Step 1)"))
        	    	{
        	    		queryStorage.processQuery(queryStorage.getThirdQuery(), frame);
        	    	}
        	    	else if(retrievalDropDownBIClass.getSelectedItem().equals("Create a Table called [CH01-01-Dimension].[DimProductSubcategory] (Step 2)"))
        	    	{
        	    		queryStorage.processQuery(queryStorage.getFourthQuery(), frame);

        	    	}
        	    	else if(retrievalDropDownBIClass.getSelectedItem().equals("Insert Values to  [CH01-01-Dimension].[DimProductCategory] (Step 3)"))
        	    	{
        	    		queryStorage.processQuery(queryStorage.getFifthQuery(), frame);

        	    	}
            	}
            	else if(databaseDropdown.getSelectedItem().equals(""))
            	{
                    JOptionPane.showMessageDialog(null, "You must select a database.", "Message Dialog", JOptionPane.INFORMATION_MESSAGE);
            	}
                
            	panel.revalidate();

                JOptionPane.showMessageDialog(null, "Execution time of query is " + QueryProcessor.getExecutionTime() + " milliseconds.", "Message Dialog", JOptionPane.INFORMATION_MESSAGE);
           }
        };
        
        // Add the ActionListener to the JButton
        runQueryButton.addActionListener(buttonActionListener);
       
        // Add the panel with the button and dropdown menu to the "NORTH" position
        frame.add(panel, BorderLayout.NORTH);
        
        // Center the frame on the screen
        frame.setLocationRelativeTo(null);
        
        // Make the frame visible
        frame.setVisible(true);
    }
    
 
    public void update()
    {
    	System.out.println("\n");
    	
    	if(databaseDropdown.getSelectedItem().equals(""))
    	{
    		retrievalDropDownBIClass.setVisible(false);
    		//retrievalDropDownTSQLV4.setVisible(false);
    	}
    	else if(databaseDropdown.getSelectedItem().equals("TSQLV4"))
    	{
        	//retrievalDropDownTSQLV4.setVisible(true);
        	retrievalDropDownBIClass.setVisible(false);
    	}
    	else if(databaseDropdown.getSelectedItem().equals("BIClass"))
    	{
    		retrievalDropDownBIClass.setVisible(true);
        	//retrievalDropDownTSQLV4.setVisible(false);
    	}
    	
    }

    
   
}
