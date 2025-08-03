<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
    String fid = (String) session.getAttribute("faculty_id"); // ✅ Correct key
    if (fid == null) {
        response.sendRedirect("facultyLogin.jsp");
        return;
    }
%>

<html>
<head><title>Select Subject</title></head>
<body>
    <h2>Welcome Faculty ID: <%= fid %></h2>
    <form method="post" action="EnterMarksServlet">
        Select Subject:
        <select name="subject_id">
            <%
                try {
                    Connection con = DBConnection.getConnection();
                    PreparedStatement ps = con.prepareStatement("SELECT * FROM subjects WHERE fid = ?");
                    ps.setString(1, fid);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
            %>
                        <option value="<%= rs.getString("subject_id") %>">
                            <%= rs.getString("subject_name") %>
                        </option>
            <%
                    }
                    rs.close();
                    ps.close();
                    con.close();
                } catch (Exception e) {
                    out.println("Error loading subjects: " + e.getMessage());
                }
            %>
        </select>
        <input type="submit" value="Select">
    </form>
</body>
</html>
