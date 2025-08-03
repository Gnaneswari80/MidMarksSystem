<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fid = request.getParameter("faculty_id");
        String pass = request.getParameter("faculty_password");
        String dept = request.getParameter("faculty_department");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");
            PreparedStatement ps = con.prepareStatement("SELECT * FROM faculty WHERE faculty_id = ? AND faculty_password = ? AND faculty_department = ?");
            ps.setString(1, fid);
            ps.setString(2, pass);
            ps.setString(3, dept);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("faculty_id", fid);
                session.setAttribute("faculty_department", dept);
                response.sendRedirect("facultyDashboard.jsp");
                return;
            } else {
                message = "Invalid Faculty ID or Password.";
            }

            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Faculty Login - Mid Marks System</title>
    <style>
        body {
            background-color: #f5f7fa;
            font-family: Arial, sans-serif;
        }
        .login-container {
            width: 400px;
            background: white;
            margin: 100px auto;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
        }
        .login-container h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #333;
        }
        input[type="text"], input[type="password"], select {
            width: 100%;
            padding: 10px;
            margin: 10px 0 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        input[type="submit"] {
            width: 100%;
            background: #0066cc;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }
        .error-message {
            color: red;
            text-align: center;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
<div class="login-container">
    <h2>Faculty Login</h2>

    <% if (!message.isEmpty()) { %>
        <div class="error-message"><%= message %></div>
    <% } %>

    <form method="post" action="">
        <label for="faculty_id">Faculty ID:</label>
        <input type="text" name="faculty_id" required />

        <label for="faculty_password">Password:</label>
        <input type="password" name="faculty_password" required />

        <label for="faculty_department">Department:</label>
        <select name="faculty_department" required>
            <option value="">--Select Department--</option>
            <option value="mca">MCA</option>
            <option value="mba">MBA</option>
            <option value="mtech">MTech</option>
            <option value="cse">CSE</option>
            <option value="ece">ECE</option>
            <option value="eee">EEE</option>
        </select>

        <input type="submit" value="Login" />
    </form>
    <a href="logout.jsp" style="float: right; padding: 10px; color: red; text-decoration: none; border-radius: 5px;">MOVE TO HOME</a>
    
</div>
</body>
</html>

