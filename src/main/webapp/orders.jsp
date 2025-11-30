<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8"%>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true",
            "root", "root"
        );

        String action = request.getParameter("action");

        // MARK AS DELIVERED
        if ("deliver".equals(action)) {
            String id = request.getParameter("id");
            if (id != null) {
                // Fetch order details
                PreparedStatement psSelect = con.prepareStatement(
                    "SELECT product, category, qty, price, date FROM orders WHERE id=?"
                );
                psSelect.setInt(1, Integer.parseInt(id));
                ResultSet rs = psSelect.executeQuery();

                if (rs.next()) {
                    String product = rs.getString("product");
                    String category = rs.getString("category");
                    int qty = rs.getInt("qty");
                    double price = rs.getDouble("price");
                    double totalSale = qty * price;
                    Date date = rs.getDate("date");

                    // Insert into sales table
                    PreparedStatement psInsert = con.prepareStatement(
                        "INSERT INTO sales(product, category, qty, price, total_sale, date) VALUES (?, ?, ?, ?, ?, ?)"
                    );
                    psInsert.setString(1, product);
                    psInsert.setString(2, category);
                    psInsert.setInt(3, qty);
                    psInsert.setDouble(4, price);
                    psInsert.setDouble(5, totalSale);
                    psInsert.setDate(6, date);
                    psInsert.executeUpdate();
                    psInsert.close();

                    // Update orders table as delivered
                    PreparedStatement psUpdate = con.prepareStatement(
                        "UPDATE orders SET delivered='Yes' WHERE id=?"
                    );
                    psUpdate.setInt(1, Integer.parseInt(id));
                    psUpdate.executeUpdate();
                    psUpdate.close();
                }

                rs.close();
                psSelect.close();
            }
        }

        // FETCH ORDERS
        PreparedStatement psOrders = con.prepareStatement(
            "SELECT id, product, category, qty, price, date, delivered FROM orders ORDER BY date DESC"
        );
        ResultSet rsOrders = psOrders.executeQuery();

        String ordersJson = "[";
        while (rsOrders.next()) {
            int id = rsOrders.getInt("id");
            String product = rsOrders.getString("product");
            String category = rsOrders.getString("category");
            int qty = rsOrders.getInt("qty");
            double price = rsOrders.getDouble("price");
            double totalSale = qty * price;
            Date date = rsOrders.getDate("date");
            String delivered = rsOrders.getString("delivered");

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

        rsOrders.close();
        psOrders.close();
        con.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
