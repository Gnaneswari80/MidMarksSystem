<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ page session="true" %>
<%
    if (session == null || session.getAttribute("hod_id") == null) {
        response.sendRedirect("hodLogin.jsp");
        return;
    }

    String hodId = (String) session.getAttribute("hod_id");
    String hodName = (String) session.getAttribute("hod_name"); // make sure this is set during login
    String hodDept = (String) session.getAttribute("hod_department");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HOD Home Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            text-align: center;
        }

        h2 {
            color: #2c3e50;
        }

        .button-group {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-top: 30px;
        }

        .button-group form {
            margin: 0;
        }

        .button-group input[type="submit"] {
            padding: 15px;
            font-size: 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s;
            color: white;
        }

        /* Colors for specific categories */
        .faculty-btn {
            background-color: #28a745;
        }

        .faculty-btn:hover {
            background-color: #218838;
        }

        .subject-btn {
            background-color: #17a2b8;
        }

        .subject-btn:hover {
            background-color: #117a8b;
        }

        .batch-btn {
            background-color: #ffc107;
            color: black;
        }

        .batch-btn:hover {
            background-color: #e0a800;
        }

        .other-btn {
            background-color: #6f42c1;
        }

        .other-btn:hover {
            background-color: #5936a3;
        }

        .logout {
            margin-top: 30px;
        }

        .logout a {
            text-decoration: none;
            color: red;
            font-weight: bold;
        }

    </style>
</head>
<body>

<div class="container">
    <h2>Welcome, <%= (hodName != null ? hodName : "HOD") %> (Department: <%= hodDept %>)</h2>

    <div class="button-group">
        <form action="addFaculty.jsp" method="get">
            <input type="submit" class="faculty-btn" value="Add Faculty">
        </form>

        <form action="removeFaculty.jsp" method="get">
            <input type="submit" class="faculty-btn" value="Remove Faculty">
        </form>

        <form action="addNewSubject.jsp" method="get">
            <input type="submit" class="subject-btn" value="Add New Subject">
        </form>

        <form action="removeSubject.jsp" method="get">
            <input type="submit" class="subject-btn" value="Remove Subject">
        </form>

        <form action="addNewBatch.jsp" method="get">
            <input type="submit" class="batch-btn" value="Add New Batch">
        </form>

        <form action="promoteBatch.jsp" method="get">
            <input type="submit" class="batch-btn" value="Promote a Batch">
        </form>

        <form action="hodDashboard.jsp" method="get">
            <input type="submit" class="other-btn" value="Internal Marks Generation">
        </form>

        <form action="updateFaculty.jsp" method="get">
            <input type="submit" class="faculty-btn" value="View /Update Faculty">
        </form>

        <form action="updateStudents.jsp" method="get">
            <input type="submit" class="other-btn" value="Update Students">
        </form>

        <form action="updateSubjects.jsp" method="get">
            <input type="submit" class="subject-btn" value="View / Update Subjects">
        </form>
    </div>

    <div class="logout">
        <a href="index.jsp">← Logout</a>
    </div>
</div>

</body>
</html>
