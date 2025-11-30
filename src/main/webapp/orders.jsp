<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8"%>
<%@page pageEncoding="UTF-8"%>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true",
            "root",
            "root"
        );

        // Fetch all orders
        PreparedStatement ps = con.prepareStatement(
            "SELECT id, product, category, qty, price, date, delivered FROM orders ORDER BY date DESC"
        );
        ResultSet rs = ps.executeQuery();

        String ordersJson = "[";
        while (rs.next()) {
            int id = rs.getInt("id");
            String product = rs.getString("product");
            String category = rs.getString("category");
            int qty = rs.getInt("qty");
            double price = rs.getDouble("price");
            double totalSale = qty * price;
            Date date = rs.getDate("date");
            String delivered = rs.getString("delivered");

            ordersJson += "{"
                    + "\"id\":" + id + ","
                    + "\"product\":\"" + product + "\","
                    + "\"category\":\"" + category + "\","
                    + "\"qty\":" + qty + ","
                    + "\"price\":" + price + ","
                    + "\"total_sale\":" + totalSale + ","
                    + "\"date\":\"" + date + "\","
                    + "\"delivered\":\"" + (delivered != null ? delivered : "") + "\""
                    + "},";
        }

        if (ordersJson.endsWith(",")) {
            ordersJson = ordersJson.substring(0, ordersJson.length() - 1);
        }
        ordersJson += "]";

        out.print(ordersJson);

        rs.close();
        ps.close();
        con.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
