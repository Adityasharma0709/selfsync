<%@ page import="java.sql.*" %>
<%
String name = request.getParameter("name");
String category = request.getParameter("category");
String price = request.getParameter("price");
String unit = request.getParameter("unit");

response.setContentType("text/plain");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true", "root", "root"
    );

    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO products (name, category, price, unit) VALUES (?, ?, ?, ?)"
    );
    ps.setString(1, name);
    ps.setString(2, category);
    ps.setDouble(3, Double.parseDouble(price));
    ps.setString(4, unit);

    int rows = ps.executeUpdate();
    con.close();

    if (rows > 0) out.print("success");
    else out.print("failed");

} catch (Exception e) {
    out.print("error");
}
%>
