<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8"%>
<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/shelfsync?useSSL=false&allowPublicKeyRetrieval=true",
    "root",
    "root"
);

String action = request.getParameter("action");

if ("update".equals(action)) {
    String productIdStr = request.getParameter("productId");
    String qtyStr = request.getParameter("qty");
    // Respond with a JSON object { message: "...", newQuantity: <int> }
    try {
        int productId = Integer.parseInt(productIdStr);
        int delta = Integer.parseInt(qtyStr);

        // 1) read current quantity
        PreparedStatement sel = con.prepareStatement("SELECT quantity FROM products WHERE id = ?");
        sel.setInt(1, productId);
        ResultSet rs = sel.executeQuery();

        int current = 0;
        if (rs.next()) {
            current = rs.getInt("quantity");
        } else {
            // product not found
            out.print("{\"message\":\"product_not_found\",\"newQuantity\":0}");
            return;
        }

        int newQty = current + delta;
        if (newQty < 0) newQty = 0; // enforce non-negative

        // 2) update to newQty (absolute set)
        PreparedStatement upd = con.prepareStatement("UPDATE products SET quantity = ? WHERE id = ?");
        upd.setInt(1, newQty);
        upd.setInt(2, productId);
        upd.executeUpdate();

        out.print("{\"message\":\"updated\",\"newQuantity\":" + newQty + "}");
        return;
    } catch (NumberFormatException nfe) {
        out.print("{\"message\":\"invalid_input\",\"newQuantity\":0}");
        return;
    } catch (Exception e) {
        out.print("{\"message\":\"error\",\"detail\":\"" + e.getMessage().replace("\"","'") + "\"}");
        return;
    }
}

if ("delete".equals(action)) {
    String id = request.getParameter("id");
    try {
        int pid = Integer.parseInt(id);
        PreparedStatement ps = con.prepareStatement("UPDATE products SET quantity = 0 WHERE id = ?");
        ps.setInt(1, pid);
        ps.executeUpdate();
        out.print("{\"message\":\"cleared\"}");
        return;
    } catch (Exception e) {
        out.print("{\"message\":\"error\",\"detail\":\"" + e.getMessage().replace("\"","'") + "\"}");
        return;
    }
}

/* FETCH CATEGORIES */
PreparedStatement catPS = con.prepareStatement("SELECT name FROM categories ORDER BY name ASC");
ResultSet rsCat = catPS.executeQuery();
StringBuilder categoriesJson = new StringBuilder("[");
while (rsCat.next()) {
    categoriesJson.append("\"").append(rsCat.getString("name")).append("\",");
}
if (categoriesJson.length() > 1 && categoriesJson.charAt(categoriesJson.length()-1)==',') {
    categoriesJson.setLength(categoriesJson.length()-1);
}
categoriesJson.append("]");

/* FETCH PRODUCTS AS INVENTORY */
PreparedStatement invPS = con.prepareStatement("SELECT id, name, category, IFNULL(quantity,0) AS quantity, unit FROM products ORDER BY id ASC");
ResultSet rsInv = invPS.executeQuery();
StringBuilder inventoryJson = new StringBuilder("[");
while (rsInv.next()) {
    inventoryJson.append("{")
        .append("\"id\":").append(rsInv.getInt("id")).append(",")
        .append("\"name\":\"").append(rsInv.getString("name").replace("\"","'")).append("\",")
        .append("\"category\":\"").append(rsInv.getString("category").replace("\"","'")).append("\",")
        .append("\"quantity\":").append(rsInv.getInt("quantity")).append(",")
        .append("\"unit\":\"").append(rsInv.getString("unit")).append("\"")
        .append("},");
}
if (inventoryJson.length() > 1 && inventoryJson.charAt(inventoryJson.length()-1)==',') {
    inventoryJson.setLength(inventoryJson.length()-1);
}
inventoryJson.append("]");

/* FINAL JSON */
String json = "{"
        + "\"categories\":" + categoriesJson.toString() + ","
        + "\"inventory\":" + inventoryJson.toString()
        + "}";
out.print(json);
%>
