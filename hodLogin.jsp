<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page session="true" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HOD Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #eef2f3;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-container {
            background: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.2);
            width: 400px;
        }
        h2 {
            text-align: center;
            color: #2c3e50;
        }
        input[type="text"], input[type="password"], select {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
        input[type="submit"] {
            background-color: #007bff;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            width: 100%;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #0056b3;
        }
        .error {
            color: red;
            text-align: center;
            margin-top: 10px;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2>HOD Login</h2>
    <form method="post" action="hodLogin.jsp">
        <label for="hod_id">HOD ID:</label>
        <input type="text" name="hod_id" id="hod_id" required>

        <label for="hod_password">Password:</label>
        <input type="password" name="hod_password" id="hod_password" required>

        <label for="hod_department">Department:</label>
        <select name="hod_department" id="hod_department" required>
            <option value="">Select Department</option>
            <option value="mca">MCA</option>
            <option value="mba">MBA</option>
            <option value="mtech">MTech</option>
            <option value="cse">CSE</option>
            <option value="ece">ECE</option>
            <option value="eee">EEE</option>
        </select>

        <input type="submit" value="Login">
    </form>
    

    <%
        String hod_id = request.getParameter("hod_id");
        String hod_password = request.getParameter("hod_password");
        String hod_department = request.getParameter("hod_department");

        if (hod_id != null && hod_password != null && hod_department != null) {
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM hod_table WHERE hod_id = ? AND hod_password = ? AND hod_department = ?");
                ps.setString(1, hod_id);
                ps.setString(2, hod_password);
                ps.setString(3, hod_department);

                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    session.setAttribute("hod_id", hod_id);
                    session.setAttribute("hod_department", hod_department);
                    session.setAttribute("hod_name", rs.getString("hod_name"));  // ✅ Set hod_name in session
                    response.sendRedirect("hodHomePage.jsp");
                } else {
    %>
                    <div class="error">Invalid credentials. Please try again.</div>
    <%
                }
            } catch (Exception e) {
    %>
                <div class="error">Error: <%= e.getMessage() %></div>
    <%
            }
        }
    %>
</div>

</body>
</html>
