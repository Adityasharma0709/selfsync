<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8"%>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

// Get action
    String action = request.getParameter("action");

// ADD USER
    if ("add".equals(action)) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null && password != null && !username.trim().isEmpty()) {
            // check if username exists
            PreparedStatement check = con.prepareStatement("SELECT * FROM users WHERE username=?");
            check.setString(1, username);
            ResultSet cr = check.executeQuery();

            if (!cr.next()) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO users(username, password) VALUES (?,?)");
                ps.setString(1, username);
                ps.setString(2, password);
                ps.executeUpdate();
            }
        }
    }

// DELETE USER
    if ("delete".equals(action)) {
        String id = request.getParameter("id");
        if (id != null) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM users WHERE id=?");
            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();
        }
    }

// FETCH ALL USERS
    PreparedStatement ps = con.prepareStatement("SELECT * FROM users ORDER BY id ASC");
    ResultSet rs = ps.executeQuery();

    String json = "[";
    while (rs.next()) {
        json += "{ \"id\": " + rs.getInt("id")
                + ", \"username\": \"" + rs.getString("username") + "\" },";
    }
    if (json.endsWith(",")) {
        json = json.substring(0, json.length() - 1);
    }
    json += "]";

    out.print(json);
%>
