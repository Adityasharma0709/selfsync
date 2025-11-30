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

if ("add".equals(action)) {
    String product = request.getParameter("product");
    String category = request.getParameter("category");
    String qty = request.getParameter("qty");
    String price = request.getParameter("total");
    String date = request.getParameter("date");

    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO orders(product, category, qty, price, date) VALUES (?, ?, ?, ?, ?)"
    );
    ps.setString(1, product);
    ps.setString(2, category);
    ps.setInt(3, Integer.parseInt(qty));
    ps.setDouble(4, Double.parseDouble(price));
    ps.setString(5, date);
    ps.executeUpdate();
    ps.close();

    out.print("{\"status\":\"success\"}");
    con.close();
    return;
}

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
    out.print("\"date\":\"" + rs.getString("date") + "\"");
    out.print("}");
}
out.print("]");

rs.close();
ps.close();
con.close();
%>
