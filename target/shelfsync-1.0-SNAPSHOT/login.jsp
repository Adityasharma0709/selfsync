<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>User Login</title>
</head>
<body>

<%
String message = "";

if(request.getParameter("username") != null && request.getParameter("password") != null) {

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true",
            "root",
            "root"
        );

        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM users WHERE username=? AND password=?"
        );

        ps.setString(1, username);
        ps.setString(2, password);

        ResultSet rs = ps.executeQuery();

        if(rs.next()) {
            // Successful login → redirect to dashboard
            response.sendRedirect("dashboard.html");
        } else {
            message = "Invalid username or password!";
        }

        con.close();

    } catch(Exception e) {
        message = "Error: " + e;
    }
}
%>

<h2>Login</h2>

<form method="post">
    Username: <input type="text" name="username" required><br><br>
    Password: <input type="password" name="password" required><br><br>

    <button type="submit">Login</button>
</form>

<p style="color:red;"><%= message %></p>

</body>
</html>
