<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page session="true" %>
<%
    if (session == null || session.getAttribute("hod_id") == null) {
        response.sendRedirect("hodLogin.jsp");
        return;
    }

    String dept = (String) session.getAttribute("hod_department");
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String batchYear = request.getParameter("batch_year");
        int sem = Integer.parseInt(request.getParameter("sem"));
        int year = Integer.parseInt(request.getParameter("year"));

        try {
            Connection conn = DBConnection.getConnection();

            // Select matching students from studentdetails
            String selectQuery = "SELECT student_id, stu_sem, stu_year FROM studentdetails " +
                                 "WHERE student_department = ? AND stu_batchyear = ? AND stu_sem = ? AND stu_year = ?";

            PreparedStatement selectStmt = conn.prepareStatement(selectQuery);
            selectStmt.setString(1, dept);
            selectStmt.setString(2, batchYear);
            selectStmt.setInt(3, sem);
            selectStmt.setInt(4, year);

            ResultSet rs = selectStmt.executeQuery();

            int updateCount = 0;
            while (rs.next()) {
                String sid = rs.getString("student_id");
                int currentSem = rs.getInt("stu_sem");
                int currentYear = rs.getInt("stu_year");

                boolean isFinalSem = false;

                // Check if the student is in final semester for the department
                if (dept.equalsIgnoreCase("mca") || dept.equalsIgnoreCase("mba") || dept.equalsIgnoreCase("mtech")) {
                    if (currentYear == 2 && currentSem == 2) {
                        isFinalSem = true;
                    }
                } else {
                    if (currentYear == 4 && currentSem == 2) {
                        isFinalSem = true;
                    }
                }

                if (!isFinalSem) {
                    // Promote: sem 1 → 2, else → sem 1 & year++
                    if (currentSem == 1) {
                        currentSem = 2;
                    } else {
                        currentSem = 1;
                        currentYear++;
                    }

                    // Update studentdetails table
                    String updateQuery = "UPDATE studentdetails SET stu_sem = ?, stu_year = ? WHERE student_id = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
                    updateStmt.setInt(1, currentSem);
                    updateStmt.setInt(2, currentYear);
                    updateStmt.setString(3, sid);

                    updateCount += updateStmt.executeUpdate();
                    updateStmt.close();
                }
            }

            rs.close();
            selectStmt.close();
            conn.close();

            message = updateCount + " student(s) promoted successfully.";

        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Promote Batch</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f7f7f7;
        }

        .container {
            width: 450px;
            margin: 80px auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            color: #333;
        }

        form {
            margin-top: 20px;
            display: flex;
            flex-direction: column;
        }

        select, input[type="text"], input[type="submit"] {
            padding: 10px;
            margin: 10px 0;
            font-size: 15px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        input[type="submit"] {
            background-color: #007BFF;
            color: white;
            cursor: pointer;
        }

        .message {
            text-align: center;
            color: green;
            margin-top: 15px;
        }

        .back {
            text-align: center;
            margin-top: 15px;
        }

        .back a {
            color: #007BFF;
            text-decoration: none;
        }

        .back a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Promote Batch</h2>
    <form method="post" action="promoteBatch.jsp">
        <label>Current Semester:</label>
        <select name="sem" required>
            <option value="1">1</option>
            <option value="2">2</option>
        </select>

        <label>Current Year:</label>
        <select name="year" required>
            <option value="1">1st Year</option>
            <option value="2">2nd Year</option>
            <option value="3">3rd Year</option>
            <option value="4">4th Year</option>
        </select>

        <label>Batch Year:</label>
        <input type="text" name="batch_year" placeholder="e.g. 2023" required />

        <input type="submit" value="Promote Students" />
    </form>

    <div class="message"><%= message %></div>

    <div class="back">
        <a href="hodHomePage.jsp">Back to HOD Home</a>
    </div>
</div>

</body>
</html>
