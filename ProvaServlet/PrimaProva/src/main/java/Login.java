import java.sql.*;
import java.util.Arrays;
public class Login {
public static boolean isUserValid(String name, String pass) {
boolean status = false;
try {
// initialize the driver to communicate with the database
System.out.println("\n\n\n\n"+name+"\n\n\n"+pass+"\n\n\n\n");
Class.forName("oracle.jdbc.driver.OracleDriver");
// connection string: address - port - db name
String url = "jdbc:oracle:thin:@localhost:1521/XEPDB1";
// database connection object by providing credentials: connection string - username - password
Connection con = DriverManager.getConnection (url, "system", "password123");
// prepared statement object that allows executing a query on the db...
PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
// ...using the username and...
ps.setString(1, name);
// ...password provided by the user to the JSP, passed from JSP to servlet, and from servlet to the db
ps.setString(2, pass); // ... oir setBlob()
// actually executes the query and obtains a ResultSet object containing the db response
ResultSet rs = ps.executeQuery();
// the next() method retrieves the first row of the query result
// returns true if there is at least one row, otherwise false
status = rs.next();
System.out.println("STATUS"+status+"\n\n\n\n");
} catch (Exception e) {
e.printStackTrace(); }
return status;
}


public static boolean registerUser(String name, String pass) {
    boolean status = false;
    try {
        // Initialize the database driver
        Class.forName("oracle.jdbc.driver.OracleDriver");

        // Connection string: address - port - db name
        String url = "jdbc:oracle:thin:@localhost:1521/XEPDB1";

        // Database connection object using credentials
        Connection con = DriverManager.getConnection(url, "system", "password123");

        // Check if the username already exists
        PreparedStatement checkUser = con.prepareStatement("SELECT username FROM users WHERE username=?");
        checkUser.setString(1, name);
        ResultSet rs = checkUser.executeQuery();

        if (rs.next()) {
            // User already exists
            System.out.println("User already exists. Please choose a different username.");
        } else {
            // Insert the new user into the database
            PreparedStatement insertUser = con.prepareStatement("INSERT INTO users (username, password) VALUES (?, ?)");
            insertUser.setString(1, name);
            insertUser.setString(2, pass);

            // Execute the insert query
            int rowsInserted = insertUser.executeUpdate();
            if (rowsInserted > 0) {
                status = true; // Registration successful
                System.out.println("User registered successfully!");
            }
        }


    } catch (Exception e) {
        e.printStackTrace();
    }
    return status;
}



}