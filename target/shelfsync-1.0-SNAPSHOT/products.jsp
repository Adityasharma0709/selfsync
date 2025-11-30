<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8"%>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

// Handle action from HTML fetch()
    String action = request.getParameter("action");

// ADD PRODUCT
    if ("add".equals(action)) {
        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String price = request.getParameter("price");
        String unit = request.getParameter("unit");

        if (name != null && !name.trim().isEmpty()) {
            PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO products(name, category, price, unit) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, name);
            ps.setString(2, category);
            ps.setDouble(3, Double.parseDouble(price));
            ps.setString(4, unit);
            ps.executeUpdate();
        }
    }

// DELETE PRODUCT
    if ("delete".equals(action)) {
        String id = request.getParameter("id");
        if (id != null) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM products WHERE id=?");
            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();
        }
    }

// Fetch Categories
    PreparedStatement catPS = con.prepareStatement("SELECT name FROM categories ORDER BY name ASC");
    ResultSet rsCat = catPS.executeQuery();

    String categoriesJson = "[";
    while (rsCat.next()) {
        categoriesJson += "\"" + rsCat.getString("name") + "\",";
    }
    if (categoriesJson.endsWith(",")) {
        categoriesJson = categoriesJson.substring(0, categoriesJson.length() - 1);
    }
    categoriesJson += "]";

// Fetch Products
    PreparedStatement prodPS = con.prepareStatement("SELECT * FROM products ORDER BY id ASC");
    ResultSet rsProd = prodPS.executeQuery();

    String productsJson = "[";
    while (rsProd.next()) {
        productsJson += "{"
                + "\"id\": " + rsProd.getInt("id") + ","
                + "\"name\": \"" + rsProd.getString("name") + "\","
                + "\"category\": \"" + rsProd.getString("category") + "\","
                + "\"price\": " + rsProd.getDouble("price") + ","
                + "\"unit\": \"" + rsProd.getString("unit") + "\""
                + "},";
    }
    if (productsJson.endsWith(",")) {
        productsJson = productsJson.substring(0, productsJson.length() - 1);
    }
    productsJson += "]";

// Final JSON response
    String responseJson = "{ \"categories\": " + categoriesJson + ", \"products\": " + productsJson + " }";

    out.print(responseJson);
%>
