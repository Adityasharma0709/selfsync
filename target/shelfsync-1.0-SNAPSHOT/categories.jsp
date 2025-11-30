<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8"%>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true","root","root");

// ADD
String action = request.getParameter("action");
if ("add".equals(action)) {
    String name = request.getParameter("name");
    if (name != null && !name.trim().isEmpty()) {
        PreparedStatement ps = con.prepareStatement("INSERT INTO categories(name) VALUES(?)");
        ps.setString(1, name);
        ps.executeUpdate();
    }
}

// DELETE
if ("delete".equals(action)) {
    String id = request.getParameter("id");
    if (id != null) {
        PreparedStatement ps = con.prepareStatement("DELETE FROM categories WHERE id=?");
        ps.setInt(1, Integer.parseInt(id));
        ps.executeUpdate();
    }
}

// FETCH LIST
PreparedStatement ps = con.prepareStatement("SELECT * FROM categories ORDER BY id ASC");
ResultSet rs = ps.executeQuery();

String json = "[";
while (rs.next()) {
    json += "{ \"id\": " + rs.getInt("id") + ", \"name\": \"" + rs.getString("name") + "\" },";
}
if (json.endsWith(",")) json = json.substring(0, json.length() - 1);
json += "]";

out.print(json);
%>
