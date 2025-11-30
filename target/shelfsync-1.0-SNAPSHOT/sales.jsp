<%@ page import="java.sql.*" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true",
    "root",
    "root"
);

String action = request.getParameter("action");

// Fetch all orders as JSON
PreparedStatement ps = con.prepareStatement("SELECT * FROM sales ORDER BY id DESC");
ResultSet rs = ps.executeQuery();

out.print("[");
boolean first = true;
while (rs.next()) {
    if (!first) out.print(",");
    first = false;

    out.print("{");
    out.print("\"id\":" + rs.getInt("id") + ",");
    out.print("\"product\":\"" + rs.getString("product") + "\",");
    out.print("\"category\":\"" + rs.getString("category") + "\",");
    out.print("\"qty\":" + rs.getInt("qty") + ",");
    out.print("\"price\":" + rs.getDouble("price") + ",");
    out.print("\"total_sale\":" + rs.getDouble("total_sale") + ",");   // ✅ ADDED
    out.print("\"date\":\"" + rs.getString("date") + "\"");
    out.print("}");
}
out.print("]");

rs.close();
ps.close();
con.close();
%>
