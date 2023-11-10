public class Group_1_Project_2_Main {

	
	public static void main(String[] args) {
		
	

	// Register the driver
	try {
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	} catch (ClassNotFoundException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
	
	
	
	
	// Launches the window
	 SimpleSwingApp app = new SimpleSwingApp();
	
		while(true)
		{
			// detect which drop down option depending on database selection
			app.update();
		}
	}
}