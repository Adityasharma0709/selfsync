
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Register User</title>
</head>
<body>


<%
try {

    String username = request.getParameter("username");
    String password = request.getParameter("password");

Class.forName("com.mysql.cj.jdbc.Driver");

    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true",
        "root",
        "root"
    );

    // Check if username already exists
    PreparedStatement check = con.prepareStatement(
        "SELECT * FROM users WHERE username=?"
    );
    check.setString(1, username);
    ResultSet rs = check.executeQuery();

    if(rs.next()) {
        out.println("<h3>Username already exists! Try another.</h3>");
    } else {

        // INSERT without ID
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO users(username, password) VALUES(?, ?)"
        );

        ps.setString(1, username);
        ps.setString(2, password);

        ps.executeUpdate();

        out.println("<h3>Registration Successful!</h3>");

        // Redirect back to login
        
    }

    con.close();

} catch(Exception e) {
    out.println("Error: " + e);
}
%>

</body>
</html>